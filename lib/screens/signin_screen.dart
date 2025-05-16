import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:software_development/screens/home/start_page_UI.dart';
import 'signup_screen.dart';
import 'package:software_development/widgets/reusable_widget.dart';
import 'package:software_development/screens/main_navigation.dart';
import 'package:software_development/screens/forgot_password_1.dart';
import 'package:software_development/screens/home/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? authError;

  bool isSubmitting = false;

  void signInUser() async {
    setState(() {
      emailError = _emailTextController.text.isEmpty ? 'Please enter email' : null;
      passwordError = _passwordTextController.text.isEmpty ? 'Please enter password' : null;
      authError = null;
    });

    if (emailError != null || passwordError != null) return;

    try {
      setState(() => isSubmitting = true);

      await _auth.signInWithEmailAndPassword(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully signed in."),
          backgroundColor: Colors.green,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid;
      final hasSeenWelcome = userId != null ? prefs.getBool('hasSeenWelcome_$userId') ?? false : false;

      if (hasSeenWelcome) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isSubmitting = false;
        print('FirebaseAuthException: ${e.code}');

        if (e.code == 'user-not-found') {
          emailError = 'No account found with this email';
        } else if (e.code == 'wrong-password') {
          passwordError = 'Invalid email or password';
        } else if (e.code == 'invalid-credential') {
          passwordError = 'Invalid email or password';
        } else if (e.code == 'user-disabled') {
          emailError = 'This account has been disabled';
        } else if (e.code == 'too-many-requests') {
          authError = 'Too many attempts. Try again later.';
        } else {
          authError = 'Unable to login: ${e.code}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const StartPage()),
                    );
                  },
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                Text(
                  "Bracelyte Sign In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You’re just one step away from greatness. Welcome back!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                reusableTextField(
                  "Enter email account",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                  errorText: emailError,
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                  errorText: passwordError,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (authError != null) ...[
                  SizedBox(height: 10),
                  Text(authError!, style: TextStyle(color: Colors.redAccent)),
                ],
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
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
                SizedBox(height: 20),
                signInSignUpButton(context, true, signInUser),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Register",
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
    );
  }
}