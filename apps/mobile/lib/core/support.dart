import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Destek adresi yalnız `--dart-define=SUPPORT_EMAIL=...` ile verilir.
/// Tanımsızsa e-posta bağlantısı gösterilmez (uydurma adres yok).
const String kSupportEmail = String.fromEnvironment('SUPPORT_EMAIL');

/// Ekranlarda kullanılan destek adresi; boşsa genel destek metni gösterilir.
final supportEmailProvider = Provider<String>((_) => kSupportEmail.trim());
