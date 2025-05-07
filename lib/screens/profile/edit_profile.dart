import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _usernameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _dobController       = TextEditingController();
  final TextEditingController _phoneController     = TextEditingController();
  final TextEditingController _bioController       = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;

  bool _isUsernameValid = true;
  bool _isChanged = false;

  void _onFieldChanged(String value, {String? field}) {
    setState(() {
      _isChanged = true;
      if (field == 'username') {
        _isUsernameValid = isValidUsername(value); // You can keep your validation function here
      }
      // Add similar checks for first name and last name if necessary
    });
  }

  bool isRequiredField(String label) {
    return label == 'First Name' ||
        label == 'Last Name' ||
        label == 'Username'; // Email is read-only and phone/bio are excluded
  }

  bool _areRequiredFieldsFilled() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty;
  }
  bool isValidUsername(String username) {
    final hasThreeLetters = RegExp(r'[a-zA-Z]').allMatches(username).length >= 3;
    final hasNumber = RegExp(r'\d').hasMatch(username);
    final noSymbols = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
    return hasThreeLetters && hasNumber && noSymbols;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _isChanged = true;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime initialDate = _dobController.text.isEmpty
        ? DateTime.now() // Default to current date if no date is selected
        : DateTime.parse(_dobController.text.split('-').reversed.join('-')); // Parse existing date

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        _isChanged = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_isChanged) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Do you really want to leave?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Leave')),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // <- Fetch from Firebase
  }

  void fetchUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('userData')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _dobController.text = data['birthdate'] ?? '';
        _selectedCountry = data['country'] ?? '';
        _selectedGender = data['gender'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _bioController.text = data['bio'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile picture
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: _buildShadowField(_firstNameController, 'First Name', hintText: "Enter Name")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildShadowField(_lastNameController, 'Last Name', hintText: "Enter Name")),
                ],
              ),
              const SizedBox(height: 20),
              _buildShadowField(_usernameController, "Username", isUsername: true, hintText: "Enter username"),
              const SizedBox(height: 20),
              _buildShadowField(_emailController, 'Email Address', readOnly: true),
              const SizedBox(height: 20),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildCountryPicker(),
              const SizedBox(height: 20),
              _buildGenderPicker(),
              const SizedBox(height: 20),
// Skip validation for phone and bio
              _buildShadowField(_phoneController, 'Phone Number'),
              const SizedBox(height: 20),
              _buildShadowField(_bioController, 'Bio'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isChanged && _isUsernameValid) ? Colors.green : Colors.grey, // Ensure button is only enabled if username is valid
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (_isChanged && _isUsernameValid && _areRequiredFieldsFilled()) ? () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) return;

                    // Prepare data to update
                    final updatedData = {
                      'firstName': _firstNameController.text.trim(),
                      'lastName': _lastNameController.text.trim(),
                      'username': _usernameController.text.trim(),
                      'birthdate': _dobController.text.trim(),
                      'country': _selectedCountry,
                      'gender': _selectedGender,
                      'phoneNumber': _phoneController.text.trim(),
                      'bio': _bioController.text.trim(),
                    };

                    try {
                      await FirebaseFirestore.instance.collection('userData').doc(userId).update(updatedData);
                      // You can show a success message or navigate back after updating.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
                      Navigator.pop(context); // Go back after saving
                    } catch (e) {
                      // Handle errors if any
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile')));
                    }
                  } : null,
                  child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShadowField(
      TextEditingController controller,
      String label, {
        bool readOnly = false,
        bool isUsername = false,
        String? hintText,
        IconData? icon,
      }) {
    final isEmailField = readOnly;
    final isRequired = isRequiredField(label);
    final isUsernameField = isUsername;

    final trimmedText = controller.text.trim();
    final bool isEmpty = trimmedText.isEmpty;

    // Error logic
    final bool showRequiredError = isRequired && isEmpty;
    final bool showUsernameFormatError = isUsernameField && !isEmpty && !_isUsernameValid;
    final bool hasError = showRequiredError || showUsernameFormatError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEmailField ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                _isChanged = true;
                if (isUsernameField) {
                  _isUsernameValid = isValidUsername(value);
                }
              });
            },
          ),
        ),
        if (showRequiredError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "This field is required",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        else if (showUsernameFormatError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Must contain at least three (3) letters and one (1) number",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }


  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of Birth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity, // Use double.infinity to make the container stretch
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _dobController.text.isEmpty ? 'Select Date' : _dobController.text,
              style: TextStyle(
                fontSize: 16,
                color: _dobController.text.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Country', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              onSelect: (country) {
                setState(() {
                  _selectedCountry = country.name;
                  _isChanged = true;
                });
              },
            );
          },
          child: Container(
            width: double.infinity, // Use double.infinity to make the container stretch
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _selectedCountry ?? 'Select Country',
              style: TextStyle(
                fontSize: 16,
                color: _selectedCountry == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Others', child: Text('Others')),
              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
                _isChanged = true;
              });
            },
          ),
        ),
      ],
    );
  }
}
