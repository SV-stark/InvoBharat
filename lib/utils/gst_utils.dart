import 'package:indian_formatters/indian_formatters.dart';

class GstUtils {
  /// Validates GSTIN format
  /// Returns true if GSTIN is valid, false otherwise
  static bool isValidGstin(final String gstin) {
    if (gstin.isEmpty) return true; // Empty is allowed (optional field)
    return IndianValidators.isGST(gstin.toUpperCase());
  }

  /// Extracts state name from GSTIN
  static String? getStateName(final String gstin) {
    if (gstin.length < 2) return null;
    return IndianValidators.getGSTState(gstin.toUpperCase());
  }

  /// Extracts state code from GSTIN
  static String? getStateCode(final String gstin) {
    if (gstin.length < 2) return null;
    final code = IndianValidators.getGSTStateCode(gstin.toUpperCase());
    return code?.toString().padLeft(2, '0');
  }

  /// Extracts PAN from GSTIN
  static String? getPan(final String gstin) {
    if (gstin.length < 12) return null;
    // GSTIN has PAN from index 2 to 12
    return gstin.substring(2, 12).toUpperCase();
  }

  /// Validates GSTIN and returns detailed validation result
  static GstinValidationResult validate(final String gstin) {
    if (gstin.isEmpty) {
      return GstinValidationResult.valid();
    }

    final error = IndianValidators.validateGST(gstin.toUpperCase());
    if (error != null) {
      return GstinValidationResult.invalid(error);
    }

    final stateName = getStateName(gstin);
    final stateCode = getStateCode(gstin);

    return GstinValidationResult.valid(
      stateCode: stateCode,
      stateName: stateName,
      pan: getPan(gstin),
    );
  }
}

class GstinValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? stateCode;
  final String? stateName;
  final String? pan;

  GstinValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.stateCode,
    this.stateName,
    this.pan,
  });

  factory GstinValidationResult.valid({
    final String? stateCode,
    final String? stateName,
    final String? pan,
  }) {
    return GstinValidationResult._(
      isValid: true,
      stateCode: stateCode,
      stateName: stateName,
      pan: pan,
    );
  }

  factory GstinValidationResult.invalid(final String errorMessage) {
    return GstinValidationResult._(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}
