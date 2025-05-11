import 'package:flutter/material.dart';
import 'package:software_development/screens/forgot_password_2.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _emailValid = false;
  bool _emailTouched = false;
  bool _codeSent = false;
  bool _codeValid = false;
  bool _codeTouched = false;

  final String _verificationCode = 'yQkm0o4';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _isEmailFormatValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _validateInputs() {
    setState(() {
      _emailValid = _isEmailFormatValid(_emailController.text.trim());
      _codeValid = _codeController.text.trim() == _verificationCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 'Next' button is enabled only if both email and code are valid
    final isNextEnabled = _emailValid && _codeValid;
    final isSendCodeEnabled = _emailValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Forgot Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                'To reset your password, enter your registered email below. '
                    'We’ll send you a verification code to confirm your identity.',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 30),

              // Email input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: (!_emailValid && _emailTouched)
                        ? Colors.red
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _emailTouched = true;
                            _emailValid = _isEmailFormatValid(value.trim());
                          });
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: isSendCodeEnabled
                          ? () {
                        setState(() {
                          _codeSent = true;
                        });
                      }
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: isSendCodeEnabled ? Colors.blue : Colors.grey,
                      ),
                      child: const Text('Send Code'),
                    ),
                  ],
                ),
              ),

              if (!_emailValid && _emailTouched)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Please enter a valid email address',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              if (_codeSent)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Code sent to your email.',
                    style: TextStyle(color: Colors.green),
                  ),
                ),

              const SizedBox(height: 20),

              // Code input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: (!_codeValid && _codeTouched)
                        ? Colors.red
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter code',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.verified_user_outlined, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _codeTouched = true;
                      _codeValid = value.trim() == _verificationCode;
                    });
                  },
                ),
              ),

              if (!_codeValid && _codeTouched)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Invalid code. Please try again.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const Spacer(),

              ElevatedButton(
                onPressed: isNextEnabled
                    ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPassword2Screen(),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNextEnabled ? Colors.green : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
