import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Hata ekranında "Tekrar dene" olduğundan otomatik yeniden deneme yok.
Duration? noRetry(int retryCount, Object error) => null;

AdminApi _admin(Ref ref) => ref.watch(apiClientProvider).admin;

final statsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => _admin(ref).stats(),
  retry: noRetry,
);

/// Başvurularda kategori adları için.
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(apiClientProvider).catalog.categories(),
  retry: noRetry,
);

@immutable
class ApplicationsQuery {
  const ApplicationsQuery({
    this.status = ReviewStatus.pendingReview,
    this.q = '',
  });

  final ReviewStatus status;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is ApplicationsQuery && other.status == status && other.q == q;

  @override
  int get hashCode => Object.hash(status, q);
}

final applicationsProvider = FutureProvider.autoDispose
    .family<List<AdminApplicationSummary>, ApplicationsQuery>(
      (ref, query) =>
          _admin(ref).applications(status: query.status, q: query.q),
      retry: noRetry,
    );

final applicationProvider = FutureProvider.autoDispose
    .family<AdminApplicationDetail, String>(
      (ref, id) => _admin(ref).application(id),
      retry: noRetry,
    );

/// `null`: sunucu varsayılanı (açık ve incelemede).
final complaintsProvider = FutureProvider.autoDispose
    .family<List<AdminComplaintItem>, ComplaintStatus?>(
      (ref, status) => _admin(ref).complaints(status: status),
      retry: noRetry,
    );

final complaintProvider = FutureProvider.autoDispose
    .family<AdminComplaintDetail, String>(
      (ref, id) => _admin(ref).complaint(id),
      retry: noRetry,
    );

@immutable
class UsersQuery {
  const UsersQuery({this.q = '', this.role, this.status, this.districtId});

  final String q;
  final AccountRole? role;
  final AccountStatus? status;

  /// İlçe süzgeci: o ilçede adresi olan veya o ilçeye hizmet veren hesaplar.
  final String? districtId;

  UsersQuery copyWith({
    String? q,
    AccountRole? Function()? role,
    AccountStatus? Function()? status,
    String? Function()? districtId,
  }) => UsersQuery(
    q: q ?? this.q,
    role: role == null ? this.role : role(),
    status: status == null ? this.status : status(),
    districtId: districtId == null ? this.districtId : districtId(),
  );

  @override
  bool operator ==(Object other) =>
      other is UsersQuery &&
      other.q == q &&
      other.role == role &&
      other.status == status &&
      other.districtId == districtId;

  @override
  int get hashCode => Object.hash(q, role, status, districtId);
}

/// İstanbul ilçeleri (hesap süzgeci).
final districtsProvider = FutureProvider.autoDispose<List<District>>(
  (ref) => ref.watch(apiClientProvider).catalog.districts(),
  retry: noRetry,
);

/// İncelemedeki ödemeler (`GET /admin/payments/review`).
final paymentReviewsProvider =
    FutureProvider.autoDispose<List<AdminPaymentReviewItem>>(
      (ref) => _admin(ref).paymentReviews(),
      retry: noRetry,
    );

final usersProvider = FutureProvider.autoDispose
    .family<List<AdminUser>, UsersQuery>(
      (ref, query) => _admin(ref).users(
        q: query.q,
        role: query.role,
        status: query.status,
        districtId: query.districtId,
      ),
      retry: noRetry,
    );

/// `null`: tüm durumlar.
final paymentsProvider = FutureProvider.autoDispose
    .family<AdminPayments, String?>(
      (ref, status) => _admin(ref).payments(status: status),
      retry: noRetry,
    );
