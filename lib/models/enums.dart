enum InvoiceStyle {
  modern,
  professional,
  minimal;

  String get name => toString().split('.').last;
}

enum GstRate {
  exempt(0.0),
  low(5.0),
  reduced(12.0),
  standard(18.0),
  luxury(28.0);

  final double value;
  const GstRate(this.value);
}
