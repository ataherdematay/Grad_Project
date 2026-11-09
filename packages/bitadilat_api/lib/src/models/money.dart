import 'package:freezed_annotation/freezed_annotation.dart';

/// Para tutarı, kuruş (`int`) olarak tutulur; `double` ile toplama yapılmaz.
/// Sözleşmede tutarlar iki ondalıklı JSON sayısıdır (TRY).
@immutable
class Money implements Comparable<Money> {
  const Money.cents(this.cents);

  static const Money zero = Money.cents(0);

  /// Lira cinsinden tam sayı (örn. 2450).
  const Money.lira(int lira) : cents = lira * 100;

  final int cents;

  /// JSON sayısı ya da `"2450.50"` metni. Kuruşa yuvarlanır.
  factory Money.fromJson(Object? value) {
    if (value is num) return Money.cents((value * 100).round());
    if (value is String) return Money.cents((num.parse(value) * 100).round());
    throw FormatException('Tutar çözülemedi: $value');
  }

  /// İki ondalıklı JSON sayısı.
  num toJson() => cents / 100;

  Money operator +(Money other) => Money.cents(cents + other.cents);
  Money operator -(Money other) => Money.cents(cents - other.cents);

  /// Adet ile çarpım (kuruşa yuvarlanır).
  Money times(num quantity) => Money.cents((cents * quantity).round());

  /// Yüzde (örn. `%10`), yarım kuruş yukarı yuvarlanır.
  Money percent(int pct) => Money.cents((cents * pct + 50) ~/ 100);

  bool get isZero => cents == 0;
  bool get isPositive => cents > 0;

  /// Kuruş kısmı yoksa `true` (biçimleyici `₺2.450` gösterir).
  bool get isWhole => cents % 100 == 0;

  /// Lira kısmı (kuruş atılır).
  int get lira => cents ~/ 100;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  bool operator <(Money other) => cents < other.cents;
  bool operator >(Money other) => cents > other.cents;

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'Money($cents)';
}

class MoneyConverter implements JsonConverter<Money, Object?> {
  const MoneyConverter();

  @override
  Money fromJson(Object? json) => Money.fromJson(json);

  @override
  Object? toJson(Money object) => object.toJson();
}

class NullableMoneyConverter implements JsonConverter<Money?, Object?> {
  const NullableMoneyConverter();

  @override
  Money? fromJson(Object? json) => json == null ? null : Money.fromJson(json);

  @override
  Object? toJson(Money? object) => object?.toJson();
}
