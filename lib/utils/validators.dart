class ValidationResult {
  final bool isValid;
  final bool isEmpty;
  final String? errorMessage;

  const ValidationResult.valid()
    : isValid = true,
      isEmpty = false,
      errorMessage = null;

  const ValidationResult.empty()
    : isValid = true,
      isEmpty = true,
      errorMessage = null;

  const ValidationResult.invalid(final String message)
    : isValid = false,
      isEmpty = false,
      errorMessage = message;
}

class Validators {
  static String? required(
    final String? value, {
    final String message = 'Required',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static ValidationResult validateEmail(final String? value) {
    if (value == null || value.isEmpty) return const ValidationResult.empty();
    final emailRegex = RegExp(r'^[\w-\.\+]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return const ValidationResult.invalid('Invalid email address');
    }
    return const ValidationResult.valid();
  }

  static String? email(final String? value) {
    final result = validateEmail(value);
    return result.errorMessage;
  }

  static ValidationResult validatePhone(final String? value) {
    if (value == null || value.isEmpty) return const ValidationResult.empty();
    if (value.length < 10) {
      return const ValidationResult.invalid(
        'Phone number too short (min 10 digits)',
      );
    }
    return const ValidationResult.valid();
  }

  static String? phone(final String? value) {
    final result = validatePhone(value);
    return result.errorMessage;
  }

  static ValidationResult validateGstin(final String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.empty();
    }
    final trimmed = value.trim().toUpperCase();
    final gstinRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!gstinRegex.hasMatch(trimmed)) {
      return const ValidationResult.invalid(
        'Invalid GSTIN format (15 characters: 2 digits + 5 letters + 4 digits + 1 letter + 1 alphanumeric + Z + 1 alphanumeric)',
      );
    }
    return const ValidationResult.valid();
  }

  static String? gstin(final String? value) {
    final result = validateGstin(value);
    return result.errorMessage;
  }

  static String? doubleValue(final String? value) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Must be positive';
    return null;
  }

  static ValidationResult validatePan(final String? value) {
    if (value == null || value.trim().isEmpty) {
      return const ValidationResult.empty();
    }
    final trimmed = value.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(trimmed)) {
      return const ValidationResult.invalid(
        'Invalid PAN format (5 letters + 4 digits + 1 letter)',
      );
    }
    return const ValidationResult.valid();
  }

  static String? pan(final String? value) {
    final result = validatePan(value);
    return result.errorMessage;
  }
}
