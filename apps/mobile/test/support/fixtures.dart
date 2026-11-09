import 'dart:async';
import 'dart:typed_data';

import 'package:bitadilat_mobile/core/photos.dart';
import 'package:dio/dio.dart';

import 'harness.dart';

/// `GET /requests` gibi anahtarlarla (yöntem + `/api/v1` sonrası yol) sahte
/// sunucu kurar. Eşleşmeyen istek 404 `NOT_FOUND` döner.
Handler routes(
  Map<String, FutureOr<ResponseBody> Function(RequestOptions o)> m,
) {
  return (o) {
    final path = o.path.replaceFirst('/api/v1', '');
    final h = m['${o.method} $path'];
    return h == null ? apiError(404, 'NOT_FOUND') : h(o);
  };
}

Map<String, dynamic> mediaJson([String id = 'm1']) => {
  'id': id,
  'url': 'http://localhost:8090/api/v1/media/$id/content?exp=1&sig=2',
  'expiresAt': '2099-11-10T10:00:00Z',
};

List<Map<String, dynamic>> categoriesJson() => [
  {
    'id': 'plumbing',
    'nameTr': 'Tesisat',
    'nameEn': 'Plumbing',
    'icon': 'plumbing',
    'colorHex': '#0F4C5C',
    'sortOrder': 1,
  },
  {
    'id': 'electrical',
    'nameTr': 'Elektrik',
    'nameEn': 'Electrical',
    'icon': 'electrical',
    'colorHex': '#E87525',
    'sortOrder': 2,
  },
];

List<Map<String, dynamic>> districtsJson() => [
  {'id': '1', 'name': 'Kadıköy', 'side': 'ANADOLU'},
  {'id': '2', 'name': 'Beşiktaş', 'side': 'AVRUPA'},
];

List<Map<String, dynamic>> questionsJson() => [
  {
    'key': 'since',
    'labelTr': 'Sorun ne zamandır var?',
    'labelEn': 'Since when?',
    'options': [
      {'value': 'today', 'labelTr': 'Bugün', 'labelEn': 'Today'},
      {'value': 'days', 'labelTr': 'Birkaç gün', 'labelEn': 'A few days'},
    ],
  },
];

Map<String, dynamic> addressJson([String id = '7', bool isDefault = true]) => {
  'id': id,
  'label': 'Ev',
  'districtId': '1',
  'districtName': 'Kadıköy',
  'neighborhood': 'Moda',
  'lineFull': 'Moda Cd. 1',
  'doorNote': null,
  'isDefault': isDefault,
};

Map<String, dynamic> requestSummaryJson({
  String id = 'r1',
  String status = 'OPEN',
  int offerCount = 2,
}) => {
  'id': id,
  'publicCode': 'BD-00001',
  'title': 'Mutfak musluğu damlıyor',
  'categoryId': 'plumbing',
  'urgency': 'URGENT',
  'status': status,
  'districtName': 'Kadıköy',
  'neighborhood': 'Moda',
  'createdAt': '2026-11-10T08:00:00Z',
  'expiresAt': '2026-11-17T08:00:00Z',
  'offerCount': offerCount,
  'minOfferTotal': offerCount > 0 ? 2000.0 : null,
  'maxOfferTotal': offerCount > 0 ? 2450.0 : null,
};

Map<String, dynamic> requestDetailJson({
  String id = 'r1',
  String status = 'OPEN',
  int offerCount = 2,
  int matched = 3,
}) => {
  ...requestSummaryJson(id: id, status: status, offerCount: offerCount),
  'description': 'Mutfak musluğu sürekli damlatıyor, acil bakılmalı.',
  'preferredFrom': null,
  'preferredTo': null,
  'photos': [mediaJson()],
  'answers': [
    {'questionKey': 'since', 'answer': 'today'},
  ],
  'matchedProCount': matched,
  'matchFactors': matched > 0
      ? ['CATEGORY', 'DISTRICT', 'AVAILABILITY']
      : <String>[],
  'address': {
    'districtName': 'Kadıköy',
    'neighborhood': 'Moda',
    'lineFull': 'Moda Cd. 1',
    'doorNote': null,
  },
};

Map<String, dynamic> proCardJson({
  String id = 'p1',
  String name = 'Mavi Hat',
}) => {
  'id': id,
  'businessName': name,
  'fullName': 'Ali Usta',
  'ratingAvg': 4.6,
  'ratingCount': 12,
  'completedJobs': 30,
  'verified': true,
};

Map<String, dynamic> offerSummaryJson({
  String id = 'o1',
  String status = 'PENDING',
  int total = 2450,
  String pro = 'Mavi Hat',
}) => {
  'id': id,
  'publicCode': 'TK-0000$id',
  'requestId': 'r1',
  'status': status,
  'pro': proCardJson(id: 'p$id', name: pro),
  'laborAmount': total - 650,
  'materialsAmount': 650.0,
  'totalAmount': total.toDouble(),
  'arrivalFrom': '2026-11-11T10:00:00Z',
  'arrivalTo': '2026-11-11T12:00:00Z',
  'warrantyMonths': 6,
  'note': 'Malzeme dahil.',
  'validUntil': '2026-11-11T12:00:00Z',
  'createdAt': '2026-11-10T08:00:00Z',
};

Map<String, dynamic> offerDetailJson({
  String id = 'o1',
  String status = 'PENDING',
  bool forPro = false,
}) => {
  ...offerSummaryJson(id: id, status: status),
  'items': [
    {
      'kind': 'LABOR',
      'description': 'İşçilik',
      'quantity': 1,
      'unitPrice': 1800.0,
      'lineTotal': 1800.0,
    },
    {
      'kind': 'MATERIAL',
      'description': 'Küresel vana',
      'quantity': 2,
      'unitPrice': 325.0,
      'lineTotal': 650.0,
    },
  ],
  'serviceFee': forPro ? 245.0 : null,
  'netEarning': forPro ? 2205.0 : null,
  'declineReason': null,
};

Map<String, dynamic> feedItemJson({String? myOfferId}) => {
  'id': 'r1',
  'publicCode': 'BD-00001',
  'title': 'Mutfak musluğu damlıyor',
  'categoryId': 'plumbing',
  'urgency': 'URGENT',
  'districtName': 'Kadıköy',
  'neighborhood': 'Moda',
  'createdAt': '2026-11-10T08:00:00Z',
  'preferredFrom': null,
  'preferredTo': null,
  'photoCount': 2,
  'offerCount': 1,
  'myOfferId': myOfferId,
};

Map<String, dynamic> proRequestJson({Map<String, dynamic>? myOffer}) => {
  ...feedItemJson(myOfferId: myOffer == null ? null : 'o1'),
  'description': 'Mutfak musluğu sürekli damlatıyor, acil bakılmalı.',
  'photos': [mediaJson()],
  'answers': [
    {'questionKey': 'since', 'answer': 'today'},
  ],
  'myOffer': myOffer,
};

Map<String, dynamic> proProfileJson({String availability = 'ACTIVE'}) => {
  'businessName': 'Usta Tesisat',
  'bio': 'Yirmi yıllık tecrübe.',
  'experienceYears': 20,
  'categoryIds': ['plumbing'],
  'districtIds': ['1'],
  'workingHours': [
    {'weekday': 1, 'start': '09:00', 'end': '18:00', 'acceptsUrgent': true},
  ],
  'reviewStatus': 'APPROVED',
  'availability': availability,
  'ratingAvg': 4.8,
  'ratingCount': 5,
  'completedJobs': 9,
};

Map<String, dynamic> proPublicJson() => {
  'id': 'p1',
  'businessName': 'Mavi Hat',
  'fullName': 'Ali Usta',
  'bio': 'Yirmi yıllık tecrübe.',
  'experienceYears': 20,
  'ratingAvg': 4.6,
  'ratingCount': 12,
  'completedJobs': 30,
  'memberSince': '2026-01-10T00:00:00Z',
  'categoryIds': ['plumbing'],
  'districts': [
    {'id': '1', 'name': 'Kadıköy'},
  ],
  'verifiedDocuments': ['IDENTITY', 'TRADE_CERT'],
};

Map<String, dynamic> applicationJson({
  String status = 'PENDING_REVIEW',
  String? note,
}) => {
  'reviewStatus': status,
  'reviewNote': note,
  'businessName': 'Usta Tesisat',
  'bio': '',
  'experienceYears': 5,
  'categoryIds': ['plumbing'],
  'districtIds': ['1'],
  'documents': [
    {
      'id': 'd1',
      'type': 'IDENTITY',
      'status': status == 'NEEDS_DOCUMENTS' ? 'REJECTED' : 'PENDING',
      'media': mediaJson('d1'),
    },
  ],
  'submittedAt': '2026-11-10T08:00:00Z',
};

/// Sahte fotoğraf seçici: sırayla verilen boyutlarda, her seferinde farklı
/// içerikli dosya döner.
class FakePicker implements PhotoPicker {
  FakePicker(this.sizes);

  final List<int> sizes;
  int calls = 0;

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    final size = sizes[calls < sizes.length ? calls : sizes.length - 1];
    calls++;
    // Her seçim farklı bir fotoğraf (aynı baytlar yinelenen sayılır).
    final bytes = Uint8List(size);
    if (size > 0) bytes[0] = calls & 0xff;
    return PickedPhoto(bytes: bytes, name: 'p$calls.jpg');
  }
}

ResponseBody uploadOk(RequestOptions o, [String id = 'up1']) => json(201, {
  'id': id,
  'contentType': 'image/jpeg',
  'sizeBytes': 10,
  'width': 10,
  'height': 10,
});

/// Her ekranın ortak katalog + adres uç noktaları.
Map<String, FutureOr<ResponseBody> Function(RequestOptions)> baseRoutes() => {
  'GET /categories': (_) => json(200, categoriesJson()),
  'GET /districts': (_) => json(200, districtsJson()),
  'GET /categories/plumbing/questions': (_) => json(200, questionsJson()),
  'GET /categories/electrical/questions': (_) => json(200, questionsJson()),
  'GET /me/addresses': (_) => json(200, [addressJson()]),
};
