import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _retypePwdController = TextEditingController();

  bool _isCurrentPwdVisible = false;
  bool _isNewPwdVisible = false;

  String _currentPwdError = '';
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
        _currentPwdController.text.isNotEmpty &&
        _newPwdController.text.isNotEmpty &&
        _retypePwdController.text.isNotEmpty &&
        _currentPwdError.isEmpty &&
        _newPwdError.isEmpty &&
        _retypePwdError.isEmpty;
  }

  void _validateCurrent(String _) {
    setState(() {
      _currentPwdError = _currentPwdController.text.isEmpty
          ? 'This field is required.'
          : '';
    });
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
    _validateCurrent('');
    _validateNew('');
    _validateRetype('');
    setState(() {
      _firebaseError = '';
    });

    if (_currentPwdError.isEmpty &&
        _newPwdError.isEmpty &&
        _retypePwdError.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPwdController.text,
          );

          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(_newPwdController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully.')),
          );

          setState(() {
            _isFormChanged = false;
          });

          _currentPwdController.clear();
          _newPwdController.clear();
          _retypePwdController.clear();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'wrong-password') {
            _currentPwdError = 'Incorrect current password.';
          } else {
            _firebaseError = 'Error: ${e.message ?? "An error occurred."}';
          }
        });
      } catch (e) {
        setState(() {
          _firebaseError = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isFormChanged) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Do you want to exit without saving?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        ),
      ) ??
          false;
    }
    return true;
  }

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _retypePwdController.dispose();
    super.dispose();
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
    String? hintText,  // Add hintText here
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
              hintText: hintText, // Add hintText here
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text('Change Password'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPasswordField(
                        label: 'Current Password',
                        controller: _currentPwdController,
                        onChanged: _validateCurrent,
                        errorText: _currentPwdError,
                        isObscured: true,
                        isVisible: _isCurrentPwdVisible,
                        icon: Icons.lock,
                        toggleVisibility: () {
                          setState(() {
                            _isCurrentPwdVisible = !_isCurrentPwdVisible;
                          });
                        },
                        hintText: 'Enter Password',  // Add this line
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
                        hintText: 'Enter New Password',  // Add this line
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
                        hintText: 'Re-type New Password',  // Add this line
                      ),

                      if (_firebaseError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, left: 4.0),
                          child: Text(_firebaseError,
                              style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: SizedBox(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
