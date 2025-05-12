import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:software_development/screens/profile/edit_profile.dart';
import 'package:software_development/screens/profile/change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadCachedUserData();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null && mounted) {
      setState(() => _profileImage = File(path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? '';
      _lastName = prefs.getString('lastName') ?? '';
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('userData').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _username = data['username'] ?? '';
        });
        await prefs.setString('firstName', _firstName);
        await prefs.setString('lastName', _lastName);
        await prefs.setString('username', _username);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _initConnectivity() async {
    // Initial connectivity check
    final connectivityResults = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = connectivityResults.any((result) =>
        result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);
      });
    }

    // Fetch data if online
    if (_isOnline) {
      await _fetchUserData();
    }

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _isOnline = results.any((result) =>
          result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                        color: Colors.grey.shade400,
                        image: _profileImage != null
                            ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isOnline
                            ? _pickImage
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("There's no internet connection")),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit, size: 24, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Full Name
              Center(
                child: Text(
                  '$_firstName $_lastName',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Username
              Center(
                child: Text(
                  '@$_username',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              // Account Settings Section
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildButton(
                title: 'Edit Profile',
                description: 'Update your personal information',
                icon: Icons.edit,
                isEnabled: _isOnline,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                },
              ),
              _buildButton(
                title: 'Change Password',
                description: 'Secure your account with a new password',
                icon: Icons.lock,
                isEnabled: _isOnline,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                },
              ),
              // Notifications Section
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildButton(
                title: 'Allow Notifications',
                description: 'Receive alerts for updates and messages',
                icon: Icons.notifications,
                isEnabled: true,
                onTap: () {},
              ),
              _buildButton(
                title: 'Notification Preferences',
                description: 'Customize your notification settings',
                icon: Icons.tune,
                isEnabled: true,
                onTap: () {},
              ),
              // Preferences Section
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildButton(
                title: 'Dark Mode',
                description: 'Switch to a darker theme for better viewing',
                icon: Icons.dark_mode,
                isEnabled: true,
                onTap: () {},
              ),
              _buildButton(
                title: 'Language',
                description: 'Choose your preferred app language',
                icon: Icons.language,
                isEnabled: true,
                onTap: () {},
              ),
              _buildButton(
                title: 'Accessibility',
                description: 'Adjust app settings for better usability',
                icon: Icons.accessibility,
                isEnabled: true,
                onTap: () {},
              ),
              // Premium
              _buildButton(
                title: 'Premium',
                description: 'Unlock exclusive features with a subscription',
                icon: Icons.star,
                isEnabled: true,
                onTap: () {},
              ),
              // Account Deletion
              _buildButton(
                title: 'Delete Account',
                description: 'Permanently remove your account (username confirmation required)',
                icon: Icons.delete,
                textColor: Colors.red,
                iconColor: Colors.red,
                isEnabled: true,
                onTap: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    Color textColor = Colors.black,
    Color iconColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xF0F6F9FF),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: 0,
        ),
        onPressed: isEnabled
            ? onTap
            : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("There's no internet connection")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: isEnabled ? iconColor : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            color: isEnabled ? textColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? Colors.grey : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}