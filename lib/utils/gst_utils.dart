class GstUtils {
  /// Validates GSTIN format
  /// Returns true if GSTIN is valid, false otherwise
  static bool isValidGstin(String gstin) {
    if (gstin.isEmpty) return true; // Empty is allowed (optional field)
    
    // GSTIN should be 15 characters
    if (gstin.length != 15) return false;
    
    // GSTIN format: 2 digits (state code) + 10 alphanumeric (PAN) + 1 digit (entity number) + 1 alphabet (Z by default) + 1 alphanumeric (check digit)
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    
    return gstinRegex.hasMatch(gstin.toUpperCase());
  }
  
  /// Extracts state code from GSTIN
  static String? getStateCode(String gstin) {
    if (!isValidGstin(gstin) || gstin.length < 2) return null;
    return gstin.substring(0, 2);
  }
  
  /// Extracts PAN from GSTIN
  static String? getPan(String gstin) {
    if (!isValidGstin(gstin) || gstin.length < 12) return null;
    return gstin.substring(2, 12);
  }
  
  /// Gets state name from state code
  static String getStateName(String stateCode) {
    final states = {
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
      '25': 'Daman and Diu',
      '26': 'Dadra and Nagar Haveli',
      '27': 'Maharashtra',
      '28': 'Andhra Pradesh',
      '29': 'Karnataka',
      '30': 'Goa',
      '31': 'Lakshadweep',
      '32': 'Kerala',
      '33': 'Tamil Nadu',
      '34': 'Puducherry',
      '35': 'Andaman and Nicobar Islands',
      '36': 'Telangana',
      '37': 'Andhra Pradesh',
    };
    
    return states[stateCode] ?? 'Unknown State';
  }
  
  /// Validates GSTIN and returns detailed validation result
  static GstinValidationResult validate(String gstin) {
    if (gstin.isEmpty) {
      return GstinValidationResult.valid(); // Empty is considered valid
    }
    
    if (gstin.length != 15) {
      return GstinValidationResult.invalid('GSTIN must be 15 characters');
    }
    
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    
    if (!gstinRegex.hasMatch(gstin.toUpperCase())) {
      return GstinValidationResult.invalid('Invalid GSTIN format');
    }
    
    final stateCode = gstin.substring(0, 2);
    final stateName = getStateName(stateCode);
    
    return GstinValidationResult.valid(
      stateCode: stateCode,
      stateName: stateName,
      pan: gstin.substring(2, 12),
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
  
  factory GstinValidationResult.valid({String? stateCode, String? stateName, String? pan}) {
    return GstinValidationResult._(
      isValid: true,
      stateCode: stateCode,
      stateName: stateName,
      pan: pan,
    );
  }
  
  factory GstinValidationResult.invalid(String errorMessage) {
    return GstinValidationResult._(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}
