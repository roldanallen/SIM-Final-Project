import 'package:flutter/material.dart';

class ErrorHandler {
  // This function handles general error validation for the fields
  static String? handleFieldError({
    required String value,
    required String fieldType,
    required RegExp regExp,
    required String emptyError,
    required String invalidError,
  }) {
    if (value.isEmpty) {
      return emptyError;
    } else if (!regExp.hasMatch(value)) {
      return invalidError;
    }
    return null;
  }

  // This function handles the form field error display
  static Widget displayError(String? error) {
    if (error != null && error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
