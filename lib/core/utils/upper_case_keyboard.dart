import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Convert to uppercase
    final uppercaseText = newValue.text.toUpperCase();

    // Only allow alphanumeric characters
    final filteredText = uppercaseText.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}