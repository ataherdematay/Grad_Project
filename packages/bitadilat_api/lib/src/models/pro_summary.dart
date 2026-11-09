import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'pro_summary.freezed.dart';
part 'pro_summary.g.dart';

@freezed
abstract class ProSummary with _$ProSummary {
  const factory ProSummary({
    required ReviewStatus reviewStatus,
    required ProAvailability availability,
    String? businessName,
  }) = _ProSummary;

  factory ProSummary.fromJson(Map<String, dynamic> json) =>
      _$ProSummaryFromJson(json);
}
