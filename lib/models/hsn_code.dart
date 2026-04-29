class HsnCode {
  final String code;
  final String description;
  final double rate; // Typical rate, can function as a default (18%)

  const HsnCode({
    required this.code,
    required this.description,
    this.rate = 18.0,
  });

  factory HsnCode.fromJson(final Map<String, dynamic> json) {
    return HsnCode(
      code: json['code'] as String,
      description: json['description'] as String,
    );
  }
}
