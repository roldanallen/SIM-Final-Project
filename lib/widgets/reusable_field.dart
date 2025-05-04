import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isPasswordField;
  final bool isConfirmPasswordField;
  final TextEditingController? confirmPasswordController;
  final VoidCallback? onTap;
  final List<String>? dropdownOptions;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.controller,
    required this.validator,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPasswordField = false,
    this.isConfirmPasswordField = false,
    this.confirmPasswordController,
    this.onTap,
    this.dropdownOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMismatch = isConfirmPasswordField &&
        confirmPasswordController != null &&
        controller.text != confirmPasswordController!.text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: dropdownOptions == null
                ? TextFormField(
              controller: controller,
              obscureText: isPasswordField || isConfirmPasswordField ? true : obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: hintText ?? '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              validator: validator,
              onTap: onTap,
            )
                : DropdownButtonFormField<String>(
              value: controller.text.isNotEmpty ? controller.text : null,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: hintText ?? '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              items: dropdownOptions!
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: (value) {
                controller.text = value ?? '';
              },
              validator: validator,
            ),
          ),
          if (isMismatch)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 4),
              child: Text(
                'Passwords do not match',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
