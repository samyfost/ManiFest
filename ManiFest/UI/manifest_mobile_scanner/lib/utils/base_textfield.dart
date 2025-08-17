import 'package:flutter/material.dart';

InputDecoration customTextFieldDecoration(
  String labelText, {
  IconData? prefixIcon,
  String? hintText,
  IconData? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: const Color(0xFF6B7280))
        : null,
    suffixIcon: suffixIcon != null
        ? Icon(suffixIcon, color: const Color(0xFF6B7280))
        : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade500, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
  );
}

// ---------------------------
// Custom Text Field Helper
// ---------------------------
Widget customTextField({
  required String label,
  required TextEditingController controller,
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
  double? width, // optional fixed width
  VoidCallback? onSubmitted, // Handle Enter key press
  bool enabled = true,
  bool obscureText = false,
  TextInputType? keyboardType,
  int? maxLines,
  int? maxLength,
}) {
  Widget textField = TextField(
    controller: controller,
    decoration: customTextFieldDecoration(
      label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
    ),
    onSubmitted: (_) {
      if (onSubmitted != null) {
        onSubmitted();
      }
    },
    enabled: enabled,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
  );

  // Force width if provided, even inside Expanded/Flexible
  if (width != null) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: textField),
    );
  }

  return textField;
}

// ---------------------------
// Custom Dropdown Helper
// ---------------------------
Widget customDropdownField<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  IconData? prefixIcon,
  String? hintText,
  bool isError = false,
  double? width,
}) {
  Widget dropdown = DropdownButtonFormField<T>(
    decoration: customTextFieldDecoration(
      label,
      prefixIcon: prefixIcon,
      hintText: hintText,
    ),
    value: value,
    items: items,
    onChanged: onChanged,
  );

  if (width != null) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: width, child: dropdown),
    );
  }

  return dropdown;
}
