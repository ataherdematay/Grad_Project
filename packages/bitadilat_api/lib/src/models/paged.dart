import 'package:freezed_annotation/freezed_annotation.dart';

/// Sayfalı liste: `{items, nextCursor}`; `nextCursor` bittiğinde `null`.
@immutable
class Paged<T> {
  const Paged({required this.items, this.nextCursor});

  factory Paged.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) => Paged(
    items: [
      for (final e in (json['items'] as List<dynamic>? ?? const <dynamic>[]))
        itemFromJson(e as Map<String, dynamic>),
    ],
    nextCursor: json['nextCursor']?.toString(),
  );

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) => {
    'items': [for (final e in items) itemToJson(e)],
    'nextCursor': nextCursor,
  };

  @override
  bool operator ==(Object other) =>
      other is Paged<T> &&
      other.nextCursor == nextCursor &&
      _listEq(other.items, items);

  @override
  int get hashCode => Object.hash(nextCursor, Object.hashAll(items));

  static bool _listEq(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
