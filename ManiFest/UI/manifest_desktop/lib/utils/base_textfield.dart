import 'package:flutter/material.dart';

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

    // Default border
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),

    // Enabled border
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),

    // Focused border
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 152, 3, 186), // purple
        width: 2.0,
      ),
    ),

    // Error border
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: Color(0xFFE53E3E), // Red
        width: 1.5,
      ),
    ),

    // Focused error border
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: Color(0xFFE53E3E), // Red
        width: 2.0,
      ),
    ),

    // Icons styling
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

    // Label styling
    labelStyle: TextStyle(
      color: isError ? const Color(0xFFE53E3E) : Colors.grey[700],
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    // Hint text styling
    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
  );
}

// Alternative flat design variant
InputDecoration flatTextFieldDecoration(
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
    fillColor: const Color(0xFFF8F9FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

    // Flat border design
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide.none,
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(
        color: Color(0xFF6366F1), // Indigo
        width: 2.0,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444), // Red
        width: 1.5,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444), // Red
        width: 2.0,
      ),
    ),

    prefixIcon: prefixIcon != null
        ? Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              prefixIcon,
              color: isError
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF6B7280),
              size: 20,
            ),
          )
        : null,
    suffixIcon: suffixIcon != null
        ? Container(
            margin: const EdgeInsets.only(right: 12),
            child: Icon(suffixIcon, color: const Color(0xFF6B7280), size: 20),
          )
        : null,

    labelStyle: TextStyle(
      color: isError ? const Color(0xFFEF4444) : const Color(0xFF374151),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),

    hintStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
  );
}

// Minimal design variant
InputDecoration minimalTextFieldDecoration(
  String label, {
  IconData? prefixIcon,
  String? hintText,
  bool isError = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),

    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
    ),

    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
    ),

    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF3B82F6), // Blue
        width: 2.0,
      ),
    ),

    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFFDC2626), // Red
        width: 1.5,
      ),
    ),

    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFFDC2626), // Red
        width: 2.0,
      ),
    ),

    prefixIcon: prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              prefixIcon,
              color: isError
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF6B7280),
              size: 20,
            ),
          )
        : null,

    labelStyle: TextStyle(
      color: isError ? const Color(0xFFDC2626) : const Color(0xFF374151),
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),

    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
  );
}
