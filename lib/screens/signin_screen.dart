import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:software_development/screens/home/home_screen.dart';
import 'signup_screen.dart';
import 'package:software_development/widgets/reusable_widget.dart';
import 'package:software_development/screens/main_navigation.dart';

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
      authError = null; // Clear previous auth error
    });

    if (emailError != null || passwordError != null) return;

    try {
      setState(() => isSubmitting = true);

      await _auth.signInWithEmailAndPassword(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );

      // Successful login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully signed in."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
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
    final inputDecorationSpacing = SizedBox(height: 20);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Column(
            children: [
              logoWidget("assets/images/background01.png"),
              SizedBox(height: 30),
              reusableTextField(
                "Enter Email",
                Icons.email_outlined,
                false,
                _emailTextController,
                errorText: emailError,
              ),
              inputDecorationSpacing,
              reusableTextField(
                "Enter Password",
                Icons.lock_outline,
                true,
                _passwordTextController,
                errorText: passwordError,
              ),
              if (authError != null) ...[
                SizedBox(height: 10),
                Text(authError!, style: TextStyle(color: Colors.redAccent)),
              ],
              inputDecorationSpacing,
              signInSignUpButton(context, true, signInUser),
              signUpOption()
            ],
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
