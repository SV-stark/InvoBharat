class Validators {
  static String? required(final String? value, {final String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(final String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? phone(final String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 10) {
      return 'Phone number too short';
    }
    return null;
  }

  static String? gstin(final String? value) {
    if (value == null || value.isEmpty) return null;
    // Basic GSTIN regex: 2 digits, 5 chars, 4 digits, 1 char, 1 char, Z, 1 char
    final gstinRegex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstinRegex.hasMatch(value)) {
      return 'Invalid GSTIN format';
    }
    return null;
  }

  static String? doubleValue(final String? value) {
    if (value == null || value.isEmpty) return null; // Allow empty (optional)
    final num = double.tryParse(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Must be positive';
    return null;
  }

  static String? pan(final String? value) {
    if (value == null || value.isEmpty) return null;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value)) {
      return 'Invalid PAN format';
    }
    return null;
  }
}
