import 'package:indian_formatters/indian_formatters.dart';

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
    final error = IndianValidators.validateMobile(value);
    if (error != null) {
      return ValidationResult.invalid(error);
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
    final error = IndianValidators.validateGST(value.trim().toUpperCase());
    if (error != null) {
      return ValidationResult.invalid(error);
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
    final error = IndianValidators.validatePAN(value.trim().toUpperCase());
    if (error != null) {
      return ValidationResult.invalid(error);
    }
    return const ValidationResult.valid();
  }

  static String? pan(final String? value) {
    final result = validatePan(value);
    return result.errorMessage;
  }
  
  static String? ifsc(final String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return IndianValidators.validateIFSC(value.trim().toUpperCase());
  }

  static String? aadhaar(final String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return IndianValidators.validateAadhaar(value.trim());
  }
}
