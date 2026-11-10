import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'pro_summary.dart';

part 'me.freezed.dart';
part 'me.g.dart';

@freezed
abstract class Me with _$Me {
  const factory Me({
    @JsonKey(fromJson: idFromJson) required String id,
    required String fullName,
    required String email,
    String? phone,
    required String locale,
    required UserMode lastMode,
    required bool isAdmin,
    required String status,
    ProSummary? pro,
  }) = _Me;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
}
