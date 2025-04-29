import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPwdController = TextEditingController();
  final _newPwdController     = TextEditingController();
  final _retypePwdController  = TextEditingController();

  bool _isCurrentPwdVisible = false;
  bool _isNewPwdVisible = false;

  String _currentPwdError = '';
  String _newPwdError     = '';
  String _retypePwdError  = '';

  bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{7,}$');
    return passwordRegExp.hasMatch(password);
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

  void _handleSave() {
    // ensure final validation
    _validateCurrent('');
    _validateNew('');
    _validateRetype('');
    if (_currentPwdError.isEmpty &&
        _newPwdError.isEmpty &&
        _retypePwdError.isEmpty) {
      // TODO: implement change-password logic
    }
  }

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _retypePwdController.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required void Function(String) onChanged,
    required String errorText,
    required bool isObscured,
    bool isVisible = false,
    required IconData icon,
    VoidCallback? toggleVisibility, // make nullable
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
              controller: controller,
              obscureText: isObscured && !isVisible,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: Icon(icon),
                suffixIcon: toggleVisibility != null
                    ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility,
                )
                    : null,
              ),
            ),
          ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(errorText, style: const TextStyle(color: Colors.red)),
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
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current Password
                    _buildPasswordField(
                      controller: _currentPwdController,
                      hint: 'Current Password',
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
                    ),
                    const SizedBox(height: 20),

                    // New Password
                    _buildPasswordField(
                      controller: _newPwdController,
                      hint: 'New Password',
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
                    ),
                    const SizedBox(height: 20),

                    // Re-type New Password (no reveal for this one)
                    _buildPasswordField(
                      controller: _retypePwdController,
                      hint: 'Re-type New Password',
                      onChanged: _validateRetype,
                      errorText: _retypePwdError,
                      isObscured: true,
                      isVisible: false,
                      icon: Icons.lock,
                      toggleVisibility: null, // don't show eye icon
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Save button at bottom
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleSave,
                    child:
                    const Text('Save', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
