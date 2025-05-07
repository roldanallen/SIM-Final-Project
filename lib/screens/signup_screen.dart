import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'package:software_development/widgets/reusable_widget.dart';
import 'package:software_development/services/firestore_service.dart';
import 'package:software_development/services/user_model.dart';
import 'package:software_development/widgets/error_handler.dart';

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

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _usernameError;
  String? _genericError;

  bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{7,}$');
    return passwordRegExp.hasMatch(password);
  }

  bool isValidUsername(String username) {
    final usernameRegExp = RegExp(r'^[A-Za-z]{3,}\d+$');
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
            Colors.pink,
            Colors.purple,
            Colors.blue
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
                      _usernameError = ErrorHandler.handleFieldError(
                        value: _userNameTextController.text,
                        fieldType: 'username',
                        regExp: RegExp(r'^[A-Za-z]{3,}\d+$'),
                        emptyError: 'This field is required.',
                        invalidError: 'Username should have at least 3 letters and be followed by a number.',
                      );
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
                        color: _usernameError != null ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ErrorHandler.displayError(_usernameError),

                const SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailTextController,
                  onChanged: (_) {
                    setState(() {
                      _emailError = ErrorHandler.handleFieldError(
                        value: _emailTextController.text,
                        fieldType: 'email',
                        regExp: RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$'),
                        emptyError: 'This field is required.',
                        invalidError: 'Invalid email format.',
                      );
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
                        color: _emailError != null ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ErrorHandler.displayError(_emailError),

                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordTextController,
                  obscureText: true,
                  onChanged: (_) {
                    setState(() {
                      _passwordError = ErrorHandler.handleFieldError(
                        value: _passwordTextController.text,
                        fieldType: 'password',
                        regExp: RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{7,}$'),
                        emptyError: 'This field is required.',
                        invalidError: 'Password must contain at least 1 symbol, 1 capital letter, 1 number, and at least 8 characters.',
                      );
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
                        color: _passwordError != null ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ErrorHandler.displayError(_passwordError),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordTextController,
                  obscureText: true,
                  onChanged: (_) {
                    setState(() {
                      if (_confirmPasswordTextController.text != _passwordTextController.text) {
                        _confirmPasswordError = 'Password did not match.';
                      } else {
                        _confirmPasswordError = null;
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
                        color: _confirmPasswordError != null ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ErrorHandler.displayError(_confirmPasswordError),

                const SizedBox(height: 20),

                // Sign Up Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () async {
                    setState(() {
                      _genericError = '';
                    });

                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailTextController.text.trim(),
                        password: _passwordTextController.text,
                      );

                      User? firebaseUser = userCredential.user;
                      if (firebaseUser != null) {
                        // Add user to Firestore
                      }

                      _showSnackbar('Successfully created an account');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                  },
                  child: const Text("Sign Up", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                if (_genericError != null && _genericError!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_genericError!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}