import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Talep taslağındaki fotoğrafların yerel kopyaları. Taslak uygulama
/// kapanıp açılınca fotoğrafları da geri getirsin diye yüklenen her
/// fotoğraf kullanıcıya özel bir klasöre yazılır.
abstract class DraftPhotoStore {
  /// Kopyayı yazar ve yolunu döndürür.
  Future<String> save(String userId, String mediaId, Uint8List bytes);

  /// Dosya yoksa ya da okunamıyorsa `null`.
  Future<Uint8List?> read(String path);

  Future<void> delete(String path);
}

class FileDraftPhotoStore implements DraftPhotoStore {
  FileDraftPhotoStore({this.baseDir});

  /// Testlerde geçici klasör verilir; yoksa uygulama destek klasörü.
  final Directory? baseDir;

  Future<Directory> _dir(String userId) async {
    final root = baseDir ?? await getApplicationSupportDirectory();
    final safe = userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final dir = Directory('${root.path}/draft_photos/$safe');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> save(String userId, String mediaId, Uint8List bytes) async {
    final dir = await _dir(userId);
    final safe = mediaId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File('${dir.path}/$safe.img');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<Uint8List?> read(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return null;
      return await f.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Silinemeyen dosya bir sonraki temizlikte kalır; kullanıcıya yansımaz.
    }
  }
}

final draftPhotoStoreProvider = Provider<DraftPhotoStore>(
  (ref) => FileDraftPhotoStore(),
);
