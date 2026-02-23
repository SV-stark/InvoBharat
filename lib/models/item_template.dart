import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_template.freezed.dart';
part 'item_template.g.dart';

@freezed
abstract class ItemTemplate with _$ItemTemplate {
  const factory ItemTemplate({
    required final String id,
    required final String description,
    required final String unit,
    @Default(0.0) final double amount,
    @Default(18.0) final double gstRate,
    @Default('SAC') final String codeType,
    @Default('') final String sacCode,
    @Default(1.0) final double quantity,
  }) = _ItemTemplate;

  factory ItemTemplate.fromJson(final Map<String, dynamic> json) =>
      _$ItemTemplateFromJson(json);
}
