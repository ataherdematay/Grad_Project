# Flutter Yeniden Başlangıç Notları

**Karar (5 Kasım 2026):** eski `mobile/` klasörü silindi. Mobil uygulama Flutter ile sıfırdan yazılıyor.

**Plan onayı (9 Kasım 2026):** yeni uygulama `feature/flutter-app` dalında yazılıyor. Akışların kaynağı artık `docs/spec/` altındaki şartname; HTML prototip (`preview/`) görsel referans olarak kalıyor.

## Verilen kararlar

| Konu | Karar |
|---|---|
| Ödeme | Craftgate sandbox, gerçek 3-D Secure; güvence havuzu backend defterinde |
| Giriş | E-posta veya telefon + şifre; şifre sıfırlama e-posta koduyla |
| Admin paneli | Flutter Web, aynı depoda (`apps/admin`) |
| Platform | Önce iOS (Claude iOS Simulator); Android sonra |
| Backend | `backend/` genişletiliyor: Spring Boot 4.1, Java 21, PostgreSQL 16, Flyway |
| Otomatik aktarım | Usta işi bitirdikten 48 saat sonra, şikayet yoksa |
| Hedef | Önce RAD tarihleri (çekirdek 4 Aralık, test 25 Aralık, son kod 2 Ocak), sonra mağaza |

## Depo yapısı

```
backend/                  Spring Boot API
apps/mobile/              Flutter iOS/Android
apps/admin/               Flutter Web admin
packages/bitadilat_api/   Saf Dart: modeller, API istemcisi
packages/bitadilat_ui/    Tema, token'lar, ortak bileşenler
pubspec.yaml              Dart pub workspace kökü
```

**Flutter paketleri:** Riverpod 3, go_router, dio, freezed ve json_serializable, flutter_secure_storage, webview_flutter (3DS), image_picker, intl ve gen-l10n.

## Eski koda erişim

Son hali `69607a0` commit'inde duruyor:

```bash
git restore --source=69607a0 -- mobile
```

Yeniden kullanılabilecek tek parça tema token'larıdır: `git show 69607a0:mobile/lib/core/theme/app_colors.dart`.

## Silinen sürüm neydi?

- Flutter ve Dart 3, `go_router`, `flutter_bloc`; 33 ekran, `/step/N` rotaları.
- Yalnızca sabit veri vardı: ekranlar bloc veya repository kullanmıyordu, ağ çağrısı yoktu.
- Ödeme adımı yoktu. Testi tek bir smoke test idi.

## Yeni sürümde tekrarlanmaması gerekenler

| Eski sorun | Yeni sürümde | Şartname |
|---|---|---|
| Veri ekranlar arasında taşınmıyordu | Tek iş modeli, kimlikli rotalar (`/jobs/:id`) | `STATE_MACHINES.md`, `ROLE_SCREEN_MAP.md` |
| Müşteri ve usta birbirini etkilemiyordu | Durum backend'de, iki taraf aynı kaydı görür | `STATE_MACHINES.md` |
| Her teklif aynı detayı açıyordu | Detay ekranları kimlikle veri yükler | `API_V1.md` |
| Oturum ve rota koruması yoktu | Oturum, role göre yönlendirme | `NAVIGATION_RULES.md` §3 |
| Rol sızıntısı | Rol başına sekme yapısı, ortak ekran rolü değiştirmez | `NAVIGATION_RULES.md` §2 |
| Geri tuşu gönderilmiş forma dönüyordu | Kayıttan sonra yığın değişir | `NAVIGATION_RULES.md` §1 |
| Boş düğmeler, doğrulamasız formlar | Çalışmayan öğe yayınlanmaz; form doğrulaması zorunlu | `NAVIGATION_RULES.md` §5-6 |
| Dil seçimi işlevsizdi | Baştan gen-l10n, TR ve EN | `GLOSSARY.md` |
| 390 px sınırı, taşmalar | Duyarlı yerleşim, 320 px ve 2x yazı testi | — |
| `INTERNET` izni, ad ve imza eksikti | Bundle id `com.bitadilat.app`, ad "BiTadilat", iOS 16+ | — |

Silinen sürümün test kanıtları ve kabul kriterleri: `docs/MOBILE_APP_AUDIT.md`, Bölüm 6.

## Test ortamı

- iOS Simulator için tam Xcode gerekir. 9 Kasım'da bu bilgisayarda yalnızca Command Line Tools vardı; kurulum adımları plan dosyasında.
- Simulator Mac'in ağını kullanır, bu yüzden backend `http://localhost:8090` adresinden erişilebilir. Gerçek cihazda 3DS dönüşü için tünel (`cloudflared`) gerekir.
- Android emülatörü sonraki aşamada kurulacak.
