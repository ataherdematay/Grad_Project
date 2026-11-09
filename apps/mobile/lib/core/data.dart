import 'dart:math';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Ödemeler sonraki dalgada gelecek. `false` iken "Teklifi kabul et" hiç
/// görünmez.
const bool kPaymentsEnabled = false;

/// Listeler sayfalama yerine tek istekte en çok bu kadar kayıt ister
/// (sunucu varsayılanı 20, üst sınırı 50).
const int kListLimit = 50;

/// Hata ekranında "Tekrar dene" olduğundan otomatik yeniden deneme yok.
Duration? noRetry(int retryCount, Object error) => null;

ApiClient _api(Ref ref) => ref.watch(apiClientProvider);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => _api(ref).catalog.categories(),
  retry: noRetry,
);

final districtsProvider = FutureProvider<List<District>>(
  (ref) => _api(ref).catalog.districts(),
  retry: noRetry,
);

final questionsProvider = FutureProvider.autoDispose
    .family<List<Question>, String>(
      (ref, categoryId) => _api(ref).catalog.questions(categoryId),
      retry: noRetry,
    );

final addressesProvider = FutureProvider.autoDispose<List<Address>>(
  (ref) => _api(ref).me.addresses(),
  retry: noRetry,
);

/// `scope`: `active` ya da `past`.
final requestsProvider = FutureProvider.autoDispose
    .family<Paged<RequestSummary>, String>(
      (ref, scope) => _api(ref).requests.list(scope: scope, limit: kListLimit),
      retry: noRetry,
    );

final requestProvider = FutureProvider.autoDispose
    .family<RequestDetail, String>(
      (ref, id) => _api(ref).requests.get(id),
      retry: noRetry,
    );

/// Teklif listesi sorgusu: seçimler sunucuya gider.
class OffersQuery {
  const OffersQuery({
    required this.requestId,
    this.sort = OfferSort.recommended,
    this.maxPrice,
    this.minRating,
  });

  final String requestId;
  final OfferSort sort;
  final Money? maxPrice;
  final double? minRating;

  OffersQuery copyWith({
    OfferSort? sort,
    Money? maxPrice,
    double? minRating,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
  }) => OffersQuery(
    requestId: requestId,
    sort: sort ?? this.sort,
    maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    minRating: clearMinRating ? null : (minRating ?? this.minRating),
  );

  bool get hasFilter => maxPrice != null || minRating != null;

  @override
  bool operator ==(Object other) =>
      other is OffersQuery &&
      other.requestId == requestId &&
      other.sort == sort &&
      other.maxPrice == maxPrice &&
      other.minRating == minRating;

  @override
  int get hashCode => Object.hash(requestId, sort, maxPrice, minRating);
}

final requestOffersProvider = FutureProvider.autoDispose
    .family<OfferList, OffersQuery>(
      (ref, q) => _api(ref).requests.offers(
        q.requestId,
        sort: q.sort,
        maxPrice: q.maxPrice,
        minRating: q.minRating,
      ),
      retry: noRetry,
    );

final offerProvider = FutureProvider.autoDispose.family<OfferDetail, String>(
  (ref, id) => _api(ref).offers.get(id),
  retry: noRetry,
);

final proPublicProvider = FutureProvider.autoDispose
    .family<ProPublicProfile, String>(
      (ref, id) => _api(ref).pros.get(id),
      retry: noRetry,
    );

final proReviewsProvider = FutureProvider.autoDispose
    .family<Paged<ReviewItem>, String>(
      (ref, id) => _api(ref).pros.reviews(id, limit: kListLimit),
      retry: noRetry,
    );

/// Başvuru yoksa `null` (404).
final proApplicationProvider = FutureProvider.autoDispose<ProApplication?>((
  ref,
) async {
  try {
    return await _api(ref).pro.application();
  } on ApiException catch (e) {
    if (e.code == ApiErrorCode.notFound) return null;
    rethrow;
  }
}, retry: noRetry);

final proProfileProvider = FutureProvider.autoDispose<ProProfile>(
  (ref) => _api(ref).pro.profile(),
  retry: noRetry,
);

final feedProvider = FutureProvider.autoDispose
    .family<FeedPage, RequestUrgency?>(
      (ref, urgency) => _api(ref).pro.feed(urgency: urgency, limit: kListLimit),
      retry: noRetry,
    );

final proRequestProvider = FutureProvider.autoDispose
    .family<ProRequestDetail, String>(
      (ref, id) => _api(ref).pro.request(id),
      retry: noRetry,
    );

final proOffersProvider = FutureProvider.autoDispose
    .family<Paged<ProOfferItem>, OfferStatus?>(
      (ref, status) => _api(ref).pro.offers(status: status, limit: kListLimit),
      retry: noRetry,
    );

/// Durum değiştiren işlemden sonra talep ve teklif sağlayıcılarını geçersiz
/// kılar (NAVIGATION_RULES §4).
void invalidateRequestData(WidgetRef ref) {
  ref
    ..invalidate(requestsProvider)
    ..invalidate(requestProvider)
    ..invalidate(requestOffersProvider)
    ..invalidate(offerProvider)
    ..invalidate(feedProvider)
    ..invalidate(proRequestProvider)
    ..invalidate(proOffersProvider);
}

void invalidateProData(WidgetRef ref) {
  invalidateRequestData(ref);
  ref
    ..invalidate(proApplicationProvider)
    ..invalidate(proProfileProvider);
}

/// `Idempotency-Key` için rastgele UUID v4.
String newIdempotencyKey() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int from, int to) =>
      [for (var i = from; i < to; i++) b[i].toRadixString(16).padLeft(2, '0')]
          .join();
  return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
}
