import 'package:flutter/material.dart';

// ---------------------------
// Input Decoration Helper
// ---------------------------
InputDecoration customTextFieldDecoration(
  String label, {
  IconData? prefixIcon,
  IconData? suffixIcon,
  String? hintText,
  bool isError = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 152, 3, 186),
        width: 2.0,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2.0),
    ),
    prefixIcon: prefixIcon != null
        ? Icon(
            prefixIcon,
            color: isError ? const Color(0xFFE53E3E) : Colors.grey[600],
            size: 20,
          )
        : null,
    suffixIcon: suffixIcon != null
        ? Icon(suffixIcon, color: Colors.grey[600], size: 20)
        : null,
    labelStyle: TextStyle(
      color: isError ? const Color(0xFFE53E3E) : Colors.grey[700],
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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
      isError: isError,
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
      isError: isError,
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
