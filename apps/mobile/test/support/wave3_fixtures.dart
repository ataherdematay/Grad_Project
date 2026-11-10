import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

/// Testlerde sabit "şimdi" (yerel saat).
final DateTime kNow = DateTime(2026, 11, 10, 9);

SessionState customerSession() => SessionState.signedIn(testMe());

SessionState proSession3() => SessionState.signedIn(
  testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
);

const tall = Size(390, 3200);

Finder btn(String label) => find.widgetWithText(AppButton, label);

String tr(String Function(AppLocalizations) f) =>
    f(lookupAppLocalizations(const Locale('tr')));

String en(String Function(AppLocalizations) f) =>
    f(lookupAppLocalizations(const Locale('en')));

String utc(DateTime local) => local.toUtc().toIso8601String();

/// Teklifteki varış aralığı: yarın 10:00-12:00 (yerel).
DateTime get offerFrom => DateTime(2026, 11, 11, 10);
DateTime get offerTo => DateTime(2026, 11, 11, 12);

Map<String, dynamic> acceptedOfferJson({bool forPro = false}) => {
  ...offerDetailJson(id: 'o1', status: 'ACCEPTED', forPro: forPro),
  'laborAmount': 900.0,
  'materialsAmount': 300.0,
  'totalAmount': 1200.0,
  'arrivalFrom': utc(offerFrom),
  'arrivalTo': utc(offerTo),
  'validUntil': '2026-11-20T10:00:00Z',
  'serviceFee': forPro ? 120.0 : null,
  'netEarning': forPro ? 1080.0 : null,
};

Map<String, dynamic> pendingOfferJson() => {
  ...acceptedOfferJson(),
  'status': 'PENDING',
  'validUntil': '2026-11-12T12:00:00Z',
};

Map<String, dynamic> eventJson(
  int id, {
  String type = 'STATUS_CHANGED',
  String? to,
  String? note,
  Map<String, dynamic>? photo,
  String actor = 'SYSTEM',
}) => {
  'id': id,
  'type': type,
  'fromStatus': null,
  'toStatus': to,
  'note': note,
  'photo': photo,
  'actorRole': actor,
  'createdAt': '2026-11-10T07:00:00Z',
};

Map<String, dynamic> jobDetailJson({
  String id = 'j1',
  String status = 'SCHEDULED',
  String role = 'CUSTOMER',
  List<String> actions = const ['CHAT', 'CANCEL'],
  Map<String, dynamic>? pendingProposal,
  List<Map<String, dynamic>>? timeline,
  String? autoCompleteAt,
  Map<String, dynamic>? complaint,
  Map<String, dynamic>? review,
  int unread = 0,
  String escrow = 'LOCKED',
}) {
  final pro = role == 'PRO';
  return {
    'id': id,
    'publicCode': 'BD-88409',
    'requestId': 'r1',
    'title': 'Mutfak musluğu damlıyor',
    'categoryId': 'plumbing',
    'status': status,
    'viewerRole': role,
    'counterpart': {
      'id': pro ? 'c1' : 'p1',
      'displayName': pro ? 'Ali Y.' : 'Mavi Hat',
    },
    'totalAmount': 1200.0,
    'scheduledFrom': utc(offerFrom),
    'scheduledTo': utc(offerTo),
    'updatedAt': '2026-11-10T08:00:00Z',
    'unreadMessages': unread,
    'offer': acceptedOfferJson(forPro: pro),
    'address': {
      'districtName': 'Kadıköy',
      'neighborhood': 'Moda',
      'lineFull': 'Moda Cd. 1/3',
      'doorNote': 'Zil bozuk',
    },
    'appointment': {
      'scheduledFrom': utc(offerFrom),
      'scheduledTo': utc(offerTo),
      'pendingProposal': pendingProposal,
    },
    'timeline':
        timeline ??
        [
          eventJson(1, to: 'AWAITING_APPOINTMENT'),
          eventJson(
            2,
            type: 'PHOTO',
            note: 'Arıza fotoğrafı',
            photo: mediaJson('ph1'),
            actor: 'PRO',
          ),
        ],
    'payment': {
      'ref': 'ESC-1',
      'status': escrow,
      'totalAmount': 1200.0,
      'refundedAmount': 0,
      'serviceFee': pro ? 120.0 : null,
      'netEarning': pro ? 1080.0 : null,
    },
    'autoCompleteAt': autoCompleteAt,
    'review': review,
    'complaint': complaint,
    'allowedActions': actions,
  };
}

Map<String, dynamic> jobSummaryJson({
  String id = 'j1',
  String status = 'SCHEDULED',
  String role = 'CUSTOMER',
  int unread = 0,
}) => {
  'id': id,
  'publicCode': 'BD-88409',
  'requestId': 'r1',
  'title': 'Mutfak musluğu damlıyor',
  'categoryId': 'plumbing',
  'status': status,
  'viewerRole': role,
  'counterpart': {
    'id': 'p1',
    'displayName': role == 'PRO' ? 'Ali Y.' : 'Mavi Hat',
  },
  'totalAmount': 1200.0,
  'scheduledFrom': utc(offerFrom),
  'scheduledTo': utc(offerTo),
  'updatedAt': '2026-11-10T08:00:00Z',
  'unreadMessages': unread,
};

Map<String, dynamic> paymentJson({
  String ref = 'ESC-1',
  String status = 'LOCKED',
  String? jobId = 'j1',
  String? errorCode,
  bool uncertain = false,
}) => {
  'ref': ref,
  'status': status,
  'offerId': 'o1',
  'requestId': 'r1',
  'jobId': jobId,
  'totalAmount': 1200.0,
  'cardLast4': '0001',
  'errorCode': errorCode,
  'errorMessage': errorCode == null ? null : 'Sunucu metni',
  'resultUncertain': uncertain,
};

Map<String, dynamic> messageJson(
  int id, {
  bool mine = false,
  String body = 'Merhaba',
  Map<String, dynamic>? photo,
}) => {
  'id': id,
  'senderRole': mine ? 'CUSTOMER' : 'PRO',
  'mine': mine,
  'body': body,
  'photo': photo,
  'createdAt': '2026-11-10T08:0$id:00Z',
};

Map<String, dynamic> complaintJson({String status = 'OPEN'}) => {
  'id': '5',
  'publicCode': 'SK-1001',
  'jobId': 'j1',
  'reason': 'EXTRA_CHARGE',
  'description': 'Anlaşılandan fazla ücret istendi, kabul etmedim.',
  'evidence': [mediaJson('ev1')],
  'status': status,
  'decision': null,
  'decisionNote': null,
  'createdAt': '2026-11-10T08:00:00Z',
  'decidedAt': null,
};

/// Verilen yol/yöntem anahtarlarıyla sahte sunucu; ortak katalog dahil.
Handler server3(
  Map<String, FutureOr<ResponseBody> Function(RequestOptions)> m,
) => routes({
  ...baseRoutes(),
  'GET /offers/o1': (_) => json(200, pendingOfferJson()),
  ...m,
});
