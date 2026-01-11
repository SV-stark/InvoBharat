import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_template.freezed.dart';
part 'item_template.g.dart';

@freezed
abstract class ItemTemplate with _$ItemTemplate {
  const factory ItemTemplate({
    required String id,
    required String description,
    required String unit,
    @Default(0.0) double amount,
    @Default(18.0) double gstRate,
    @Default('SAC') String codeType,
    @Default('') String sacCode,
  }) = _ItemTemplate;

  factory ItemTemplate.fromJson(Map<String, dynamic> json) =>
      _$ItemTemplateFromJson(json);
}
