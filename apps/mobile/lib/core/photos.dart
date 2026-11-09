import 'dart:async';
import 'dart:isolate';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Sunucu sınırı: 1 572 864 bayt (1,5 MB).
const int kMaxPhotoBytes = 1572864;
const int kMaxRequestPhotos = 5;

enum PhotoSource { camera, gallery }

class PickedPhoto {
  const PickedPhoto({
    required this.bytes,
    required this.name,
    this.mime = 'image/jpeg',
  });

  final Uint8List bytes;
  final String name;
  final String mime;
}

/// Fotoğraf seçici; testlerde sahtesi verilir.
abstract class PhotoPicker {
  Future<PickedPhoto?> pick(PhotoSource source);
}

/// `image_picker`: en çok 2048 px genişlik, kalite 80.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 80,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final name = file.name.isEmpty ? 'photo.jpg' : file.name;
    final lower = name.toLowerCase();
    final mime = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.heic')
        ? 'image/heic'
        : 'image/jpeg';
    return PickedPhoto(bytes: bytes, name: name, mime: mime);
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);

/// Daha düşük kalite ve genişlikle yeniden sıkıştırır; olmazsa `null`.
typedef Recompress = Future<Uint8List?> Function(
  Uint8List bytes,
  int quality,
  int maxWidth,
);

Future<Uint8List?> defaultRecompress(
  Uint8List bytes,
  int quality,
  int maxWidth,
) => Isolate.run(() {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final resized = decoded.width > maxWidth
      ? img.copyResize(decoded, width: maxWidth)
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
});

final recompressProvider = Provider<Recompress>((ref) => defaultRecompress);

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
}

/// 1,5 MB'ı aşıyorsa kaliteyi düşürüp bir kez daha dener; yine aşıyorsa
/// [PhotoTooLargeException].
Future<PickedPhoto> preparePhoto(PickedPhoto p, Recompress recompress) async {
  if (p.bytes.length <= kMaxPhotoBytes) return p;
  final smaller = await recompress(p.bytes, 50, 1600);
  if (smaller == null || smaller.length > kMaxPhotoBytes) {
    throw const PhotoTooLargeException();
  }
  final base = p.name.contains('.')
      ? p.name.substring(0, p.name.lastIndexOf('.'))
      : p.name;
  return PickedPhoto(bytes: smaller, name: '$base.jpg', mime: 'image/jpeg');
}

enum PhotoStatus { uploading, done, failed }

/// `PhotoSet.add` sonucu.
enum PhotoAddResult { added, duplicate, skipped }

enum PhotoFailure { tooLarge, upload, pick }

class PhotoItem {
  PhotoItem({
    required this.localId,
    this.bytes,
    this.remote,
    this.name = 'photo.jpg',
    this.mime = 'image/jpeg',
    this.status = PhotoStatus.uploading,
    this.progress = 0,
    this.mediaId,
    this.failure,
    this.error,
  });

  final int localId;

  /// Yerel önizleme (yüklenen dosya).
  final Uint8List? bytes;

  /// Sunucudaki mevcut fotoğraf (talep düzenleme).
  final MediaRef? remote;
  final String name;
  final String mime;
  PhotoStatus status;
  double progress;
  String? mediaId;
  PhotoFailure? failure;
  ApiException? error;
}

/// Seçme, yükleme ilerlemesi ve tek tek kaldırma. En fazla [max] öğe.
class PhotoSet extends ChangeNotifier {
  PhotoSet({
    required this.api,
    required this.picker,
    required this.recompress,
    this.purpose = MediaPurpose.requestPhoto,
    this.max = kMaxRequestPhotos,
  });

  final MediaApi api;
  final PhotoPicker picker;
  final Recompress recompress;
  final MediaPurpose purpose;
  final int max;

  final List<PhotoItem> _items = [];
  int _seq = 0;
  bool _disposed = false;

  List<PhotoItem> get items => List.unmodifiable(_items);
  bool get isFull => _items.length >= max;
  bool get isBusy => _items.any((e) => e.status == PhotoStatus.uploading);
  bool get hasFailed => _items.any((e) => e.status == PhotoStatus.failed);

  /// Yüklenmiş (ya da zaten sunucuda olan) kimlikler.
  List<String> get mediaIds => [
    for (final e in _items)
      if (e.status == PhotoStatus.done && e.mediaId != null) e.mediaId!,
  ];

  void addRemote(Iterable<MediaRef> refs) {
    for (final r in refs) {
      if (_items.length >= max) break;
      _items.add(
        PhotoItem(
          localId: _seq++,
          remote: r,
          status: PhotoStatus.done,
          mediaId: r.id,
          progress: 1,
        ),
      );
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Seçici açılır, sonuç yüklenir. Sınır dolmuşsa hiçbir şey yapmaz.
  Future<PhotoAddResult> add(PhotoSource source) async {
    if (isFull) return PhotoAddResult.skipped;
    final PickedPhoto? picked;
    try {
      picked = await picker.pick(source);
    } catch (_) {
      return PhotoAddResult.skipped;
    }
    if (picked == null || isFull) return PhotoAddResult.skipped;
    // Aynı fotoğraf ikinci kez yüklenmez (talepte iki kopya görünürdü).
    final bytes = picked.bytes;
    if (_items.any((e) => _sameBytes(e.bytes, bytes))) {
      return PhotoAddResult.duplicate;
    }
    final item = PhotoItem(
      localId: _seq++,
      bytes: picked.bytes,
      name: picked.name,
      mime: picked.mime,
    );
    _items.add(item);
    _notify();
    await _upload(item, picked);
    return PhotoAddResult.added;
  }

  Future<void> _upload(PhotoItem item, PickedPhoto picked) async {
    item
      ..status = PhotoStatus.uploading
      ..failure = null
      ..error = null
      ..progress = 0;
    _notify();
    try {
      final ready = await preparePhoto(picked, recompress);
      final res = await api.upload(
        bytes: ready.bytes,
        filename: ready.name,
        purpose: purpose,
        contentType: ready.mime,
        onProgress: (sent, total) {
          if (total > 0) {
            item.progress = sent / total;
            _notify();
          }
        },
      );
      item
        ..mediaId = res.id
        ..status = PhotoStatus.done
        ..progress = 1;
    } on PhotoTooLargeException {
      item
        ..status = PhotoStatus.failed
        ..failure = PhotoFailure.tooLarge;
    } on ApiException catch (e) {
      item
        ..status = PhotoStatus.failed
        ..failure = PhotoFailure.upload
        ..error = e;
    } catch (_) {
      // Sıkıştırma ya da çözme hatası: öğe "yükleniyor"da takılı kalmaz,
      // sihirbaz ilerleyebilir (yeniden dene ya da kaldır).
      item
        ..status = PhotoStatus.failed
        ..failure = PhotoFailure.upload
        ..error = null;
    }
    _notify();
  }

  static bool _sameBytes(Uint8List? a, Uint8List b) {
    if (a == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> retry(PhotoItem item) async {
    final bytes = item.bytes;
    if (bytes == null) return;
    await _upload(
      item,
      PickedPhoto(bytes: bytes, name: item.name, mime: item.mime),
    );
  }

  void remove(PhotoItem item) {
    _items.remove(item);
    _notify();
  }

  void clear() {
    _items.clear();
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
