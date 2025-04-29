import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'package:software_development/widgets/reusable_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _usernameError = '';
  String _genericError = '';

  bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{7,}$');
    return passwordRegExp.hasMatch(password);
  }

  bool isValidUsername(String username) {
    final usernameRegExp = RegExp(r'^[A-Za-z]{3,}\d+$'); // Username starts with 3 letters followed by a number
    return usernameRegExp.hasMatch(username);
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),

                // Username Field
                TextField(
                  controller: _userNameTextController,
                  onChanged: (_) {
                    setState(() {
                      if (_userNameTextController.text.isEmpty) {
                        _usernameError = 'This field is required.';
                      } else if (!isValidUsername(_userNameTextController.text)) {
                        _usernameError = 'Username should have at least 3 letters and be followed by a number.';
                      } else {
                        _usernameError = '';
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter username",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: _usernameError.isNotEmpty ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_usernameError.isNotEmpty)
                  Text(_usernameError, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailTextController,
                  onChanged: (_) {
                    setState(() {
                      if (_emailTextController.text.isEmpty) {
                        _emailError = 'This field is required.';
                      } else if (!isValidEmail(_emailTextController.text)) {
                        _emailError = 'Invalid email format.';
                      } else {
                        _emailError = '';
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter email",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: _emailError.isNotEmpty ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_emailError.isNotEmpty)
                  Text(_emailError, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordTextController,
                  obscureText: true,
                  onChanged: (_) {
                    setState(() {
                      if (_passwordTextController.text.isEmpty) {
                        _passwordError = 'This field is required.';
                      } else if (!isValidPassword(_passwordTextController.text)) {
                        _passwordError = 'Password must contain at least 1 symbol, 1 capital letter, 1 number, and at least 8 characters.';
                      } else {
                        _passwordError = '';
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter password",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: _passwordError.isNotEmpty ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_passwordError.isNotEmpty)
                  Text(_passwordError, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordTextController,
                  obscureText: true,
                  onChanged: (_) {
                    setState(() {
                      if (_confirmPasswordTextController.text.isEmpty) {
                        _confirmPasswordError = 'This field is required.';
                      } else if (_confirmPasswordTextController.text != _passwordTextController.text) {
                        _confirmPasswordError = 'Password did not match.';
                      } else {
                        _confirmPasswordError = '';
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Confirm password",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: _confirmPasswordError.isNotEmpty ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_confirmPasswordError.isNotEmpty)
                  Text(_confirmPasswordError, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 20),

                // Sign Up Button
                signInSignUpButton(context, false, () async {
                  setState(() {
                    _emailError = '';
                    _usernameError = '';
                    _passwordError = '';
                    _confirmPasswordError = '';
                    _genericError = '';
                  });

                  bool hasError = false;

                  // Validate Username
                  if (_userNameTextController.text.isEmpty) {
                    _usernameError = 'This field is required.';
                    hasError = true;
                  } else if (!isValidUsername(_userNameTextController.text)) {
                    _usernameError = 'Username should have at least 3 letters and be followed by a number.';
                    hasError = true;
                  }

                  // Validate Email
                  if (_emailTextController.text.isEmpty) {
                    _emailError = 'This field is required.';
                    hasError = true;
                  } else if (!isValidEmail(_emailTextController.text)) {
                    _emailError = 'Invalid email format.';
                    hasError = true;
                  }

                  // Validate Password
                  if (_passwordTextController.text.isEmpty) {
                    _passwordError = 'This field is required.';
                    hasError = true;
                  } else if (!isValidPassword(_passwordTextController.text)) {
                    _passwordError = 'Password must contain at least 1 symbol, 1 capital letter, 1 number, and be 7+ characters.';
                    hasError = true;
                  }

                  // Validate Confirm Password
                  if (_confirmPasswordTextController.text.isEmpty) {
                    _confirmPasswordError = 'This field is required.';
                    hasError = true;
                  } else if (_confirmPasswordTextController.text != _passwordTextController.text) {
                    _confirmPasswordError = 'Passwords do not match.';
                    hasError = true;
                  }

                  if (hasError) {
                    setState(() {}); // Refresh the UI with errors
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text,
                    );
                    _showSnackbar('Successfully created an account');

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'email-already-in-use') {
                      setState(() {
                        _emailError = 'This email address is already in use.';
                      });
                    } else {
                      setState(() {
                        _genericError = 'Error: ${e.message}';
                      });
                    }
                  }
                }),

                if (_genericError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_genericError, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
