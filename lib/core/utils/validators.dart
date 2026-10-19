/// Input validation helpers for forms and data entry.
abstract class Validators {
  static String? requiredField(
    String? value, [
    String message = 'This field is required',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? bdPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    // Standard Bangladesh numbers: 013, 014, 015, 016, 017, 018, 019
    final bdRegex = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
    if (!bdRegex.hasMatch(clean)) {
      return 'Enter a valid 11-digit Bangladeshi mobile number';
    }
    return null;
  }

  static String? otp(String? value, [int length = 4]) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the verification code';
    }
    if (value.trim().length != length ||
        !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Enter a valid $length-digit numeric code';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Amount']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }
}
