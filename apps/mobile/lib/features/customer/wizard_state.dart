import 'dart:convert';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/draft_photos.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../auth/session.dart';

/// Eski, kullanıcıdan bağımsız taslak anahtarı. Artık okunmaz; açılışta silinir
/// (başka bir hesabın taslağı olabilir).
const String kDraftKey = 'request_draft_v1';

/// Taslak her kullanıcı için ayrı saklanır: aynı cihazda oturum açan başka
/// biri önceki kullanıcının adres ve açıklamasını görmez.
String draftKeyFor(String userId) => '$kDraftKey:$userId';
const int kTitleMin = 5;
const int kTitleMax = 150;
const int kDescMin = 20;
const int kDescMax = 2000;

/// Sihirbazın tek taslak durumu. Fotoğraflar `PhotoSet`te tutulur.
class RequestDraft {
  const RequestDraft({
    this.categoryId,
    this.urgency = RequestUrgency.urgent,
    this.preferredFrom,
    this.preferredTo,
    this.addressId,
    this.answers = const {},
    this.title = '',
    this.description = '',
  });

  final String? categoryId;
  final RequestUrgency urgency;
  final DateTime? preferredFrom;
  final DateTime? preferredTo;
  final String? addressId;
  final Map<String, String> answers;
  final String title;
  final String description;

  RequestDraft copyWith({
    String? categoryId,
    RequestUrgency? urgency,
    DateTime? preferredFrom,
    DateTime? preferredTo,
    bool clearDates = false,
    String? addressId,
    bool clearAddress = false,
    Map<String, String>? answers,
    String? title,
    String? description,
  }) => RequestDraft(
    categoryId: categoryId ?? this.categoryId,
    urgency: urgency ?? this.urgency,
    preferredFrom: clearDates ? null : (preferredFrom ?? this.preferredFrom),
    preferredTo: clearDates ? null : (preferredTo ?? this.preferredTo),
    addressId: clearAddress ? null : (addressId ?? this.addressId),
    answers: answers ?? this.answers,
    title: title ?? this.title,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'urgency': urgency.name,
    'preferredFrom': preferredFrom?.toUtc().toIso8601String(),
    'preferredTo': preferredTo?.toUtc().toIso8601String(),
    'addressId': addressId,
    'answers': answers,
    'title': title,
    'description': description,
  };

  factory RequestDraft.fromJson(Map<String, dynamic> j) => RequestDraft(
    categoryId: j['categoryId'] as String?,
    urgency: j['urgency'] == 'planned'
        ? RequestUrgency.planned
        : RequestUrgency.urgent,
    preferredFrom: j['preferredFrom'] == null
        ? null
        : DateTime.parse(j['preferredFrom'] as String),
    preferredTo: j['preferredTo'] == null
        ? null
        : DateTime.parse(j['preferredTo'] as String),
    addressId: j['addressId'] as String?,
    answers: {
      for (final e in ((j['answers'] as Map?) ?? const {}).entries)
        e.key.toString(): e.value.toString(),
    },
    title: (j['title'] as String?) ?? '',
    description: (j['description'] as String?) ?? '',
  );

  bool get isEmpty =>
      categoryId == null &&
      addressId == null &&
      title.isEmpty &&
      description.isEmpty &&
      answers.isEmpty;
}

enum WizardIssue {
  category,
  dateFrom,
  dateTo,
  dateOrder,
  datePast,
  dateRange,
  address,
  answers,
  title,
  description,
  photosBusy,
  photosFailed,
}

/// Adım doğrulaması (saf işlev). Sorunsuzsa liste boştur.
List<WizardIssue> validateStep(
  RequestDraft d,
  int step, {
  required DateTime now,
  List<String> requiredQuestionKeys = const [],
  bool photosBusy = false,
  bool photosFailed = false,
}) {
  final issues = <WizardIssue>[];
  switch (step) {
    case 1:
      if (d.categoryId == null) issues.add(WizardIssue.category);
      if (d.urgency == RequestUrgency.planned) {
        final f = d.preferredFrom;
        final t = d.preferredTo;
        if (f == null) issues.add(WizardIssue.dateFrom);
        if (t == null) issues.add(WizardIssue.dateTo);
        if (f != null && t != null) {
          if (!f.isBefore(t)) {
            issues.add(WizardIssue.dateOrder);
          } else if (!f.isAfter(now)) {
            issues.add(WizardIssue.datePast);
          } else if (t.isAfter(now.add(const Duration(days: 30)))) {
            issues.add(WizardIssue.dateRange);
          }
        }
      }
    case 2:
      if (d.addressId == null) issues.add(WizardIssue.address);
      if (requiredQuestionKeys.any((k) => (d.answers[k] ?? '').isEmpty)) {
        issues.add(WizardIssue.answers);
      }
    case 3:
      final t = d.title.trim().length;
      if (t < kTitleMin || t > kTitleMax) issues.add(WizardIssue.title);
      final c = d.description.trim().length;
      if (c < kDescMin || c > kDescMax) issues.add(WizardIssue.description);
      if (photosBusy) issues.add(WizardIssue.photosBusy);
      if (photosFailed) issues.add(WizardIssue.photosFailed);
  }
  return issues;
}

class WizardState {
  const WizardState({
    required this.draft,
    this.step = 1,
    this.fromReview = false,
    this.editingId,
    this.editOfferCount = 0,
    this.attempted = false,
    this.submitting = false,
  });

  final RequestDraft draft;
  final int step;

  /// "Gözden geçir"den "Düzenle" ile gelindi: adım sonunda tekrar 4'e dönülür.
  final bool fromReview;
  final String? editingId;

  /// Düzenlenen talepteki bekleyen teklif sayısı. Kaydetmek bunları
  /// geçersiz kılar (STATE_MACHINES §2); kullanıcıya önce sorulur.
  final int editOfferCount;

  /// Kullanıcı "Devam"a bastı; hatalar görünür.
  final bool attempted;
  final bool submitting;

  bool get isEditing => editingId != null;

  WizardState copyWith({
    RequestDraft? draft,
    int? step,
    bool? fromReview,
    String? editingId,
    bool clearEditing = false,
    bool? attempted,
    bool? submitting,
  }) => WizardState(
    draft: draft ?? this.draft,
    step: step ?? this.step,
    fromReview: fromReview ?? this.fromReview,
    editingId: clearEditing ? null : (editingId ?? this.editingId),
    editOfferCount: editOfferCount,
    attempted: attempted ?? this.attempted,
    submitting: submitting ?? this.submitting,
  );
}

class WizardController extends Notifier<WizardState> {
  late PhotoSet photos;
  String _idemKey = newIdempotencyKey();
  String? _userId;

  /// Taslağın diskte tuttuğu fotoğraf dosyaları.
  Set<String> _paths = {};
  final Set<int> _writing = {};

  /// `true` iken fotoğraf değişimleri taslağa yazılmaz ve dosyalar silinmez
  /// (düzenleme moduna geçiş gibi toplu işlemler).
  bool _quiet = false;

  @override
  WizardState build() {
    // Kullanıcı değişince (çıkış, başka hesapla giriş) taslak ve fotoğraflar
    // sıfırlanır.
    _userId = ref.watch(sessionProvider.select((s) => s.me?.id));
    final set = PhotoSet(
      api: ref.read(apiClientProvider).media,
      picker: ref.read(photoPickerProvider),
      recompress: ref.read(recompressProvider),
    );
    set.addListener(_onPhotosChanged);
    ref.onDispose(() {
      set
        ..removeListener(_onPhotosChanged)
        ..dispose();
    });
    photos = set;
    _paths = {};
    _writing.clear();
    _idemKey = newIdempotencyKey();
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.containsKey(kDraftKey)) prefs.remove(kDraftKey);
    final loaded = _load();
    if (!loaded.isEditing) _restorePhotos(set);
    return loaded;
  }

  List<Map<String, dynamic>> _savedPhotos() {
    final id = _userId;
    if (id == null) return const [];
    final raw = ref.read(sharedPreferencesProvider).getString(draftKeyFor(id));
    if (raw == null) return const [];
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return [
        for (final e in (j['photos'] as List? ?? const []))
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Kayıtlı taslaktaki fotoğrafları yerel dosyadan geri getirir. Dosyası
  /// olmayan fotoğraf sessizce düşer.
  Future<void> _restorePhotos(PhotoSet set) async {
    final saved = _savedPhotos();
    if (saved.isEmpty) return;
    final store = ref.read(draftPhotoStoreProvider);
    final restored = <Map<String, dynamic>>[];
    for (final e in saved) {
      final path = e['path'] as String?;
      final mediaId = e['mediaId'] as String?;
      if (path == null || mediaId == null) continue;
      final bytes = await store.read(path);
      if (bytes == null) continue;
      if (!ref.mounted || !identical(photos, set)) return;
      if (state.isEditing) return;
      _quiet = true;
      set.addRestored(
        bytes: bytes,
        mediaId: mediaId,
        name: (e['name'] as String?) ?? 'photo.jpg',
        mime: (e['mime'] as String?) ?? 'image/jpeg',
        localPath: path,
      );
      _quiet = false;
      restored.add(e);
    }
    if (!ref.mounted) return;
    _paths = {for (final e in restored) e['path'] as String};
    // Düşen fotoğraflar kayıttan da çıkar.
    if (restored.length != saved.length) _persist();
  }

  /// Fotoğraf eklenince/silinince taslağı günceller; yeni yüklenen
  /// fotoğrafın yerel kopyasını yazar, silinenin dosyasını kaldırır.
  void _onPhotosChanged() {
    if (_quiet || state.isEditing) return;
    final id = _userId;
    if (id == null) return;
    final store = ref.read(draftPhotoStoreProvider);
    final current = <String>{};
    for (final item in photos.items) {
      final path = item.localPath;
      if (path != null) current.add(path);
      if (item.status == PhotoStatus.done &&
          item.remote == null &&
          item.bytes != null &&
          item.mediaId != null &&
          path == null &&
          _writing.add(item.localId)) {
        store.save(id, item.mediaId!, item.bytes!).then((p) {
          _writing.remove(item.localId);
          if (!ref.mounted) return;
          if (photos.items.contains(item)) {
            item.localPath = p;
            _paths.add(p);
            _persist();
          } else {
            store.delete(p);
          }
        });
      }
    }
    for (final gone in _paths.difference(current)) {
      store.delete(gone);
    }
    _paths = {..._paths.intersection(current)};
    _persist();
  }

  List<Map<String, dynamic>> _photoJson() => [
    for (final item in photos.items)
      if (item.status == PhotoStatus.done &&
          item.remote == null &&
          item.mediaId != null &&
          item.localPath != null)
        {
          'mediaId': item.mediaId,
          'path': item.localPath,
          'name': item.name,
          'mime': item.mime,
        },
  ];

  WizardState _load() {
    final id = _userId;
    if (id == null) return WizardState(draft: const RequestDraft());
    final raw = ref.read(sharedPreferencesProvider).getString(draftKeyFor(id));
    if (raw == null) return WizardState(draft: const RequestDraft());
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return WizardState(
        draft: RequestDraft.fromJson(j['draft'] as Map<String, dynamic>),
        step: ((j['step'] as int?) ?? 1).clamp(1, 3),
      );
    } catch (_) {
      return WizardState(draft: const RequestDraft());
    }
  }

  void _persist() {
    final id = _userId;
    if (state.isEditing || id == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = _photoJson();
    if (state.draft.isEmpty && saved.isEmpty) {
      prefs.remove(draftKeyFor(id));
    } else {
      prefs.setString(
        draftKeyFor(id),
        jsonEncode({
          'draft': state.draft.toJson(),
          'step': state.step,
          'photos': saved,
        }),
      );
    }
  }

  void update(RequestDraft Function(RequestDraft d) f) {
    state = state.copyWith(draft: f(state.draft));
    _idemKey = newIdempotencyKey();
    _persist();
  }

  /// Yeni talep için açılış: düzenleme kalıntısı varsa kayıtlı taslağa dön.
  void enterNew() {
    if (!state.isEditing) return;
    _quiet = true;
    photos.clear();
    _quiet = false;
    _paths = {};
    state = _load();
    _restorePhotos(photos);
  }

  /// Mevcut talebi doldurarak düzenleme modunu açar.
  void startEdit(RequestDetail d, List<Address> addresses) {
    if (state.editingId == d.id) return;
    String? addressId;
    final a = d.address;
    if (a != null && a.lineFull != null) {
      for (final x in addresses) {
        if (x.lineFull == a.lineFull && x.neighborhood == a.neighborhood) {
          addressId = x.id;
        }
      }
    }
    // Taslağın fotoğraf dosyaları düzenleme sırasında korunur.
    _quiet = true;
    photos.clear();
    photos.addRemote(d.photos);
    _quiet = false;
    state = WizardState(
      editingId: d.id,
      editOfferCount: d.offerCount,
      draft: RequestDraft(
        categoryId: d.categoryId,
        urgency: d.urgency,
        // Seçiciler ve doğrulama yerel saatle çalışır.
        preferredFrom: d.preferredFrom?.toLocal(),
        preferredTo: d.preferredTo?.toLocal(),
        addressId: addressId,
        answers: {for (final a in d.answers) a.questionKey: a.answer},
        title: d.title,
        description: d.description,
      ),
    );
  }

  void goTo(int step, {bool fromReview = false}) {
    state = state.copyWith(
      step: step,
      fromReview: fromReview,
      attempted: false,
    );
    _persist();
  }

  List<WizardIssue> issues(int step, DateTime now, List<String> requiredKeys) =>
      validateStep(
        state.draft,
        step,
        now: now,
        requiredQuestionKeys: requiredKeys,
        photosBusy: photos.isBusy,
        photosFailed: photos.hasFailed,
      );

  /// Yayından önce 1-3. adımlar yeniden doğrulanır: geri yüklenen taslakta
  /// tarih eskimiş ya da bir adım atlanmış olabilir. Sorunlu ilk adım açılır
  /// ve hatalar gösterilir; sorun yoksa `true`.
  bool validateAll(DateTime now, List<String> requiredKeys) {
    for (var step = 1; step <= 3; step++) {
      if (issues(step, now, requiredKeys).isNotEmpty) {
        state = state.copyWith(step: step, fromReview: true, attempted: true);
        _persist();
        return false;
      }
    }
    return true;
  }

  /// Sunucunun `field` hatasını sihirbaz adımına eşler; bilinmiyorsa `null`.
  static int? stepForField(String? field) => switch (field) {
    'categoryId' || 'urgency' || 'preferredFrom' || 'preferredTo' => 1,
    'addressId' || 'answers' => 2,
    'title' || 'description' || 'photoIds' => 3,
    _ => null,
  };

  /// Sunucu hatasındaki adımı inceleme dönüşüyle açar.
  void showServerFieldStep(int step) {
    state = state.copyWith(step: step, fromReview: true, attempted: true);
    _persist();
  }

  /// Doğrulama geçerse bir sonraki adıma (ya da inceleme adımına) geçer.
  bool next(DateTime now, List<String> requiredKeys) {
    final bad = issues(state.step, now, requiredKeys);
    if (bad.isNotEmpty) {
      state = state.copyWith(attempted: true);
      return false;
    }
    goTo(state.fromReview ? 4 : state.step + 1);
    return true;
  }

  /// Sihirbaz içi geri: `true` ise önceki adıma gidildi, `false` ise ekran
  /// kapanabilir.
  bool back() {
    if (state.step <= 1) return false;
    goTo(state.fromReview && state.step < 4 ? 4 : state.step - 1);
    return true;
  }

  RequestInput buildInput() {
    final d = state.draft;
    final planned = d.urgency == RequestUrgency.planned;
    return RequestInput(
      categoryId: d.categoryId!,
      urgency: d.urgency,
      preferredFrom: planned ? d.preferredFrom?.toUtc() : null,
      preferredTo: planned ? d.preferredTo?.toUtc() : null,
      title: d.title.trim(),
      description: d.description.trim(),
      addressId: d.addressId!,
      photoIds: photos.mediaIds,
      answers: [
        for (final e in d.answers.entries)
          RequestAnswer(questionKey: e.key, answer: e.value),
      ],
    );
  }

  /// Yayınlar ya da (düzenleme modunda) günceller. `ApiException` fırlatır;
  /// form verisi korunur.
  Future<RequestDetail> submit() async {
    if (state.submitting) throw StateError('submitting');
    state = state.copyWith(submitting: true);
    try {
      final api = ref.read(apiClientProvider).requests;
      final body = buildInput();
      final result = state.isEditing
          ? await api.update(state.editingId!, body)
          : await api.create(body, idempotencyKey: _idemKey);
      return result;
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  /// Yayın sonrası taslağı ve fotoğrafları siler.
  ///
  /// Düzenleme kaydedildiyse yeni talep taslağına dokunulmaz; kayıtlı taslak
  /// geri yüklenir (yoksa bir sonraki değişiklik onu silerdi).
  void finish() {
    final editing = state.isEditing;
    final id = _userId;
    if (id != null && !editing) {
      ref.read(sharedPreferencesProvider).remove(draftKeyFor(id));
    }
    _quiet = true;
    if (!editing) {
      // Yayınlanan talebin taslak fotoğrafları diskten silinir.
      final store = ref.read(draftPhotoStoreProvider);
      for (final p in _paths) {
        store.delete(p);
      }
      _paths = {};
    }
    photos.clear();
    _quiet = false;
    _idemKey = newIdempotencyKey();
    state = editing ? _load() : WizardState(draft: const RequestDraft());
    if (editing) _restorePhotos(photos);
  }
}

final wizardProvider = NotifierProvider<WizardController, WizardState>(
  WizardController.new,
);
