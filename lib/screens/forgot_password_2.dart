import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword2Screen extends StatefulWidget {
  const ForgotPassword2Screen({Key? key}) : super(key: key);

  @override
  _ForgotPassword2ScreenState createState() => _ForgotPassword2ScreenState();
}

class _ForgotPassword2ScreenState extends State<ForgotPassword2Screen> {
  final _newPwdController = TextEditingController();
  final _retypePwdController = TextEditingController();

  bool _isNewPwdVisible = false;

  String _newPwdError = '';
  String _retypePwdError = '';
  String _firebaseError = '';

  bool _isFormChanged = false;

  bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{7,}$');
    return passwordRegExp.hasMatch(password);
  }

  bool _isSaveEnabled() {
    return _isFormChanged &&
        _newPwdController.text.isNotEmpty &&
        _retypePwdController.text.isNotEmpty &&
        _newPwdError.isEmpty &&
        _retypePwdError.isEmpty;
  }

  void _validateNew(String _) {
    final pwd = _newPwdController.text;
    setState(() {
      if (pwd.isEmpty) {
        _newPwdError = 'This field is required.';
      } else if (!isValidPassword(pwd)) {
        _newPwdError =
        'Password must contain 1 symbol, 1 capital letter, 1 number, and at least 8 characters.';
      } else {
        _newPwdError = '';
      }
    });
  }

  void _validateRetype(String _) {
    final confirm = _retypePwdController.text;
    setState(() {
      if (confirm.isEmpty) {
        _retypePwdError = 'This field is required.';
      } else if (confirm != _newPwdController.text) {
        _retypePwdError = 'Passwords do not match.';
      } else {
        _retypePwdError = '';
      }
    });
  }

  Future<void> _handleSave() async {
    _validateNew('');
    _validateRetype('');
    setState(() {
      _firebaseError = '';
    });

    if (_newPwdError.isEmpty && _retypePwdError.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(_newPwdController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully.')),
          );

          setState(() {
            _isFormChanged = false;
          });

          _newPwdController.clear();
          _retypePwdController.clear();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _firebaseError = 'Error: ${e.message ?? "An error occurred."}';
        });
      } catch (e) {
        setState(() {
          _firebaseError = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required void Function(String) onChanged,
    required String errorText,
    required bool isObscured,
    bool isVisible = false,
    required IconData icon,
    VoidCallback? toggleVisibility,
    String? hintText,
  }) {
    final hasError = errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: hasError ? Border.all(color: Colors.red, width: 1.2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured && !isVisible,
            onChanged: (text) {
              onChanged(text);
              setState(() {
                _isFormChanged = true;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.grey,
              ),
              suffixIcon: toggleVisibility != null
                  ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
              )
                  : null,
              hintText: hintText,
            ),
          ),
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        //title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                  "Choose a new password and confirm it below. "
                  "Your new password should be secure, with at least 8 characters, a symbol, and a number.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'New Password',
                controller: _newPwdController,
                onChanged: _validateNew,
                errorText: _newPwdError,
                isObscured: true,
                isVisible: _isNewPwdVisible,
                icon: Icons.lock,
                toggleVisibility: () {
                  setState(() {
                    _isNewPwdVisible = !_isNewPwdVisible;
                  });
                },
                hintText: 'Enter New Password',
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Re-type New Password',
                controller: _retypePwdController,
                onChanged: _validateRetype,
                errorText: _retypePwdError,
                isObscured: true,
                isVisible: false,
                icon: Icons.lock,
                toggleVisibility: null,
                hintText: 'Re-type New Password',
              ),
              if (_firebaseError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 4.0),
                  child: Text(
                    _firebaseError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaveEnabled() ? Colors.green : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaveEnabled() ? _handleSave : null,
                  child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
