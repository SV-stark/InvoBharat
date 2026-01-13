import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
class Client with _$Client {
  const factory Client({
    required String id,
    required String name,
    @Default('default') String profileId,
    @Default('') String gstin,
    @Default('') String address,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String primaryContact,
    @Default('') String notes,
    @Default('') String state,
    @Default('') String pan,
    @Default('') String stateCode,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
