import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_development/screens/signin_screen.dart'; // Import your SignIn screen here
import 'package:software_development/screens/main_navigation.dart';

class ProfileIconSettings extends StatefulWidget {
  final File? profileImage;
  final String userName;

  const ProfileIconSettings({
    super.key,
    required this.profileImage,
    required this.userName,
  });

  @override
  State<ProfileIconSettings> createState() => _ProfileIconSettingsState();
}

class _ProfileIconSettingsState extends State<ProfileIconSettings> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlay() {
    const bubbleWidth = 160.0;
    const bubbleRadius = 8.0;
    const arrowSize = Size(16, 8);
    const verticalSpacing = 8.0;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(), // Transparent barrier
            ),
          ),

          // The actual floating popup
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, verticalSpacing),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: bubbleWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(bubbleRadius),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _toggleOverlay();
                            MainNavigationScreen.goToProfileTab();
                          },
                          icon: const Icon(Icons.person, color: Colors.black87),
                          label: const Text('My Profile'),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        const Divider(height: 1),
                        TextButton.icon(
                          onPressed: () {
                            _toggleOverlay();
                            _showLogoutDialog();
                          },
                          icon: const Icon(Icons.logout, color: Colors.black87),
                          label: const Text('Log out'),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Log out the user using FirebaseAuth
              await FirebaseAuth.instance.signOut();

              // Redirect to SignIn screen
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: widget.profileImage != null
              ? FileImage(widget.profileImage!)
              : null,
          child: widget.profileImage == null
              ? const Icon(Icons.person, size: 28, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

