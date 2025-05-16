import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:software_development/screens/home/welcome_screen.dart';
import 'package:software_development/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedCountry;
  bool _isChanged = false;
  bool _hasTypedUsername = false;
  bool _hasTypedEmail = false;
  bool _hasTypedPassword = false;
  bool _hasTypedConfirmPassword = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _usernameError;
  String? _dobError;
  String? _countryError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void _onFieldChanged(String value, {String? field}) {
    setState(() {
      _isChanged = true;
      switch (field) {
        case 'username':
          _hasTypedUsername = value.trim().isNotEmpty;
          final isUsernameValid = isValidUsername(value.trim());
          _usernameError = _hasTypedUsername && !isUsernameValid
              ? 'Must contain at least three (3) letters and one (1) number'
              : null;
          break;
        case 'firstName':
          _firstNameError = value.trim().isEmpty ? _firstNameError : null;
          break;
        case 'lastName':
          _lastNameError = value.trim().isEmpty ? _lastNameError : null;
          break;
        case 'email':
          _hasTypedEmail = value.trim().isNotEmpty;
          _emailError = _hasTypedEmail && !isValidEmail(value.trim())
              ? 'Invalid email format'
              : null;
          break;
        case 'password':
          _hasTypedPassword = value.trim().isNotEmpty;
          _passwordError = _hasTypedPassword && !isValidPassword(value.trim())
              ? 'Must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, 1 special character'
              : null;
          _confirmPasswordError = _hasTypedConfirmPassword &&
              _confirmPasswordController.text.trim() != value.trim()
              ? 'Passwords do not match'
              : null;
          break;
        case 'confirmPassword':
          _hasTypedConfirmPassword = value.trim().isNotEmpty;
          _confirmPasswordError = _hasTypedConfirmPassword &&
              value.trim() != _passwordController.text.trim()
              ? 'Passwords do not match'
              : null;
          break;
      }
    });
  }

  bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    final hasThreeLetters = RegExp(r'[a-zA-Z]').allMatches(username).length >= 3;
    final hasNumber = RegExp(r'\d').hasMatch(username);
    final noSymbols = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
    return hasThreeLetters && hasNumber && noSymbols;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  bool _areStep1FieldsFilled() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().isNotEmpty &&
        isValidUsername(_usernameController.text.trim()) &&
        _dobController.text.isNotEmpty &&
        _selectedCountry != null;
  }

  bool _areStep2FieldsFilled() {
    final password = _passwordController.text.trim();
    return _emailController.text.trim().isNotEmpty &&
        isValidEmail(_emailController.text.trim()) &&
        password.isNotEmpty &&
        isValidPassword(password) &&
        _confirmPasswordController.text.trim() == password;
  }

  void _validateStep1() {
    setState(() {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final username = _usernameController.text.trim();

      _firstNameError = firstName.isEmpty ? 'This field is required' : null;
      _lastNameError = lastName.isEmpty ? 'This field is required' : null;
      _usernameError = username.isEmpty
          ? 'This field is required'
          : !isValidUsername(username)
          ? 'Must contain at least three (3) letters and one (1) number'
          : null;
      _dobError = _dobController.text.isEmpty ? 'This field is required' : null;
      _countryError = _selectedCountry == null ? 'This field is required' : null;
    });
  }

  void _validateStep2() {
    setState(() {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      _emailError = email.isEmpty
          ? 'This field is required'
          : !isValidEmail(email)
          ? 'Invalid email format'
          : null;
      _passwordError = password.isEmpty
          ? 'This field is required'
          : !isValidPassword(password)
          ? 'Must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, 1 special character'
          : null;
      _confirmPasswordError = confirmPassword.isEmpty
          ? 'This field is required'
          : confirmPassword != password
          ? 'Passwords do not match'
          : null;
    });
  }

  Future<void> _pickDate() async {
    DateTime initialDate = _dobController.text.isEmpty
        ? DateTime.now()
        : DateTime.parse(_dobController.text.split('-').reversed.join('-'));

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
        _dobError = null;
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        ),
      ) ??
          false;
    }
    return true;
  }

  void _nextPage() {
    _validateStep1();
    if (_areStep1FieldsFilled()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializeToolsCollection(String userId) async {
    final tools = ['todo', 'gym', 'waterreminder', 'workout', 'dietplan', 'customplan'];
    final batch = FirebaseFirestore.instance.batch();

    for (final tool in tools) {
      final toolRef = FirebaseFirestore.instance
          .collection('userData')
          .doc(userId)
          .collection('tools')
          .doc(tool);
      // Create a dummy document to initialize the collection
      batch.set(toolRef, {'initialized': true});
      // Create a dummy task to initialize the tasks subcollection
      final taskRef = toolRef.collection('tasks').doc('init');
      batch.set(taskRef, {'dummy': true});
      // Delete the dummy task immediately to leave the subcollection empty but existing
      batch.delete(taskRef);
    }

    await batch.commit();
  }

  void _signUp() async {
    _validateStep2();
    if (!_areStep2FieldsFilled()) return;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId != null) {
        final userData = {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'birthdate': _dobController.text.trim(),
          'country': _selectedCountry,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'bio': "",
          'gender': "Prefer not to say",
          'uid': userId, // Added uid as a field
        };

        await FirebaseFirestore.instance.collection('userData').doc(userId).set(userData);

        // Initialize the tools collection and its subcollections
        await _initializeToolsCollection(userId);

        // Sign the user in after account creation
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // Navigate to WelcomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create account';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered';
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
        setState(() {
          _passwordError = errorMessage;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  const Text(
                    'Bracelyte Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You’re one step away from managing your health and tasks. Let’s get started!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDatePicker(),
                              const SizedBox(height: 20),
                              _buildCountryPicker(),
                              const SizedBox(height: 20),
                              _buildShadowField(
                                _firstNameController,
                                'First Name',
                                hintText: 'Enter Name',
                                errorText: _firstNameError,
                                field: 'firstName',
                              ),
                              const SizedBox(height: 20),
                              _buildShadowField(
                                _lastNameController,
                                'Last Name',
                                hintText: 'Enter Name',
                                errorText: _lastNameError,
                                field: 'lastName',
                              ),
                              const SizedBox(height: 20),
                              _buildShadowField(
                                _usernameController,
                                'Username',
                                hintText: 'Enter username',
                                errorText: _usernameError,
                                field: 'username',
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShadowField(
                                _emailController,
                                'Email Address',
                                hintText: 'Enter email',
                                errorText: _emailError,
                                field: 'email',
                              ),
                              const SizedBox(height: 20),
                              _buildShadowField(
                                _passwordController,
                                'Password',
                                hintText: 'Enter password',
                                isPassword: true,
                                errorText: _passwordError,
                                field: 'password',
                              ),
                              const SizedBox(height: 20),
                              _buildShadowField(
                                _confirmPasswordController,
                                'Confirm Password',
                                hintText: 'Re-enter password',
                                isPassword: true,
                                errorText: _confirmPasswordError,
                                field: 'confirmPassword',
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/google.png', width: 40, height: 40),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Image.asset('assets/images/facebook.png', width: 40, height: 40),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          'or',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _currentPage == 0
                      ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _areStep1FieldsFilled() ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _previousPage,
                          child: const Text(
                            'Back',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _areStep2FieldsFilled() ? Colors.green : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _signUp,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShadowField(
      TextEditingController controller,
      String label, {
        bool isPassword = false,
        String? hintText,
        String? errorText,
        String? field,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
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
            border: errorText != null && errorText.isNotEmpty
                ? Border.all(color: Colors.red, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
            ),
            onChanged: (value) => _onFieldChanged(value, field: field),
          ),
        ),
        if (errorText != null && errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
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
            width: double.infinity,
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
              border: _dobError != null && _dobError!.isNotEmpty
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
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
        if (_dobError != null && _dobError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _dobError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
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
                  _countryError = null;
                });
              },
            );
          },
          child: Container(
            width: double.infinity,
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
              border: _countryError != null && _countryError!.isNotEmpty
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
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
        if (_countryError != null && _countryError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _countryError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}