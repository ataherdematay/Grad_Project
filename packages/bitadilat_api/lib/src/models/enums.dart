import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserMode { customer, pro }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReviewStatus {
  pendingReview,
  needsDocuments,
  approved,
  rejected,
  suspended,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ProAvailability { active, onBreak }
