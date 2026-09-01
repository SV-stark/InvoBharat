import 'package:invobharat/utils/validators.dart';

class GstUtils {
  /// Validates GSTIN format
  /// Returns true if GSTIN is valid, false otherwise
  static bool isValidGstin(final String gstin) {
    final clean = gstin.trim();
    if (clean.isEmpty) return true; // Empty is allowed (optional field)
    return Validators.validateGstin(clean).isValid;
  }

  static const Map<String, String> stateCodeMap = {
    '01': 'Jammu and Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra and Nagar Haveli and Daman and Diu',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh (Old)',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman and Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
    '38': 'Ladakh',
    '97': 'Other Territory',
    '99': 'Centre Jurisdiction',
  };

  /// Resolves a standardized 2-digit GST state code from string (code, name, or combined)
  static String? getStateCodeFromInput(final String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final clean = input.trim();

    // Check if it's already a 2-digit code or starts with 2 digits like "07-Delhi"
    final digitMatch = RegExp(r'^(\d{2})').firstMatch(clean);
    if (digitMatch != null) {
      final code = digitMatch.group(1)!;
      if (stateCodeMap.containsKey(code)) return code;
    }

    // Match by state name (case-insensitive, ignore punctuation)
    final normalized = clean.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final entry in stateCodeMap.entries) {
      final entryNorm = entry.value.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      if (normalized == entryNorm ||
          normalized.contains(entryNorm) ||
          entryNorm.contains(normalized)) {
        return entry.key;
      }
    }

    return null;
  }

  /// Extracts state name from GSTIN or 2-digit state code
  static String? getStateName(final String gstin) {
    final clean = gstin.trim().toUpperCase();
    if (clean.length == 2 && stateCodeMap.containsKey(clean)) {
      return stateCodeMap[clean];
    }
    if (clean.length == 15 && isValidGstin(clean)) {
      final code = clean.substring(0, 2);
      return stateCodeMap[code];
    }
    return null;
  }

  /// Extracts state code from GSTIN or 2-digit state code
  static String? getStateCode(final String gstin) {
    final clean = gstin.trim().toUpperCase();
    if (clean.length == 2 && stateCodeMap.containsKey(clean)) {
      return clean;
    }
    if (clean.length == 15 && isValidGstin(clean)) {
      final code = clean.substring(0, 2);
      return stateCodeMap.containsKey(code) ? code : null;
    }
    return null;
  }

  /// Extracts PAN from GSTIN
  static String? getPan(final String gstin) {
    final clean = gstin.trim().toUpperCase();
    if (clean.length == 15 && isValidGstin(clean)) {
      return clean.substring(2, 12);
    }
    return null;
  }

  /// Validates GSTIN and returns detailed validation result
  static GstinValidationResult validate(final String gstin) {
    final clean = gstin.trim();
    if (clean.isEmpty) {
      return GstinValidationResult.valid();
    }

    final validation = Validators.validateGstin(clean);
    if (!validation.isValid) {
      return GstinValidationResult.invalid(
        validation.errorMessage ?? 'Invalid GST number',
      );
    }

    final stateName = getStateName(clean);
    final stateCode = getStateCode(clean);

    return GstinValidationResult.valid(
      stateCode: stateCode,
      stateName: stateName,
      pan: getPan(clean),
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
    return GstinValidationResult._(isValid: false, errorMessage: errorMessage);
  }
}
