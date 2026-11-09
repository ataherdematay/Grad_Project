/// Kimlikler sunucuda uuid ya da metin; sayı gelirse de metne çevrilir.
String idFromJson(Object? value) => value.toString();

/// Sunucu kimliği sayıysa sayı, değilse metin olarak gönderilir.
Object wireId(String id) => int.tryParse(id) ?? id;

/// Kimlik listesi: sayı ya da metin gelebilir; metne çevrilir.
List<String> idListFromJson(Object? value) => [
  for (final e in (value as List<dynamic>? ?? const <dynamic>[])) e.toString(),
];

/// Gövdeye yazarken sayısal kimlikler sayı olarak gider.
List<Object> idListToJson(List<String> ids) => [for (final i in ids) wireId(i)];

String? idFromJsonNullable(Object? value) => value?.toString();
