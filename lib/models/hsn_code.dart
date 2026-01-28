class HsnCode {
  final String code;
  final String description;
  final double rate; // Typical rate, can function as a default (18%)

  const HsnCode({
    required this.code,
    required this.description,
    this.rate = 18.0,
  });
}
