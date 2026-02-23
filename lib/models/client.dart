import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
abstract class Client with _$Client {
  const factory Client({
    required final String id,
    required final String name,
    @Default('default') final String profileId,
    @Default('') final String gstin,
    @Default('') final String address,
    @Default('') final String email,
    @Default('') final String phone,
    @Default('') final String primaryContact,
    @Default('') final String notes,
    @Default('') final String state,
    @Default('') final String pan,
    @Default('') final String stateCode,
  }) = _Client;

  factory Client.fromJson(final Map<String, dynamic> json) => _$ClientFromJson(json);
}
