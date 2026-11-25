import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data.dart' show noRetry;
import 'providers.dart';

/// `GET /jobs/{id}/payment/timeline` (müşteri ve usta).
final paymentTimelineProvider = FutureProvider.autoDispose
    .family<PaymentTimeline, String>(
      (ref, jobId) => ref.watch(apiClientProvider).paymentDemo.timeline(jobId),
      retry: noRetry,
    );

/// `GET /jobs/{id}/payment/receipt` (yalnız müşteri).
final paymentReceiptProvider = FutureProvider.autoDispose
    .family<PaymentReceipt, String>(
      (ref, jobId) => ref.watch(apiClientProvider).paymentDemo.receipt(jobId),
      retry: noRetry,
    );

/// Sayfa başına kayıt (sunucu varsayılanı 20).
const int kPaymentsPageSize = 20;

/// Ödeme geçmişi: biriken sayfalar, sonraki sayfa imleci ve "daha fazla"
/// durumu. İlk sayfa hatası [AsyncValue] hatası olur; sonraki sayfa hatası
/// listeyi korur, [moreError] ile bildirilir.
@immutable
class PaymentHistoryState {
  const PaymentHistoryState({
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  final List<PaymentHistoryItem> items;
  final String? nextCursor;
  final bool loadingMore;
  final ApiException? moreError;

  bool get hasMore => nextCursor != null;

  PaymentHistoryState copyWith({
    List<PaymentHistoryItem>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
    ApiException? moreError,
    bool clearMoreError = false,
  }) => PaymentHistoryState(
    items: items ?? this.items,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    loadingMore: loadingMore ?? this.loadingMore,
    moreError: clearMoreError ? null : (moreError ?? this.moreError),
  );
}

class PaymentHistoryController extends AsyncNotifier<PaymentHistoryState> {
  @override
  Future<PaymentHistoryState> build() async {
    final page = await ref
        .watch(apiClientProvider)
        .paymentDemo
        .myPayments(limit: kPaymentsPageSize);
    return PaymentHistoryState(items: page.items, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final s = state.value;
    if (s == null || !s.hasMore || s.loadingMore) return;
    state = AsyncData(s.copyWith(loadingMore: true, clearMoreError: true));
    try {
      final page = await ref
          .read(apiClientProvider)
          .paymentDemo
          .myPayments(cursor: s.nextCursor, limit: kPaymentsPageSize);
      state = AsyncData(
        PaymentHistoryState(
          items: [...s.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } on ApiException catch (e) {
      state = AsyncData(s.copyWith(loadingMore: false, moreError: e));
    }
  }
}

final paymentHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      PaymentHistoryController,
      PaymentHistoryState
    >(PaymentHistoryController.new, retry: noRetry);
