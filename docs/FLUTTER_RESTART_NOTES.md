# Flutter Yeniden Başlangıç Notları

**Karar (5 Kasım 2026):** eski `mobile/` klasörü silindi. Mobil uygulama ileride Flutter ile sıfırdan yazılacak. Şimdilik akışların referansı HTML prototiptir (`preview/`).

## Eski koda erişim

Son hali `69607a0` commit'inde duruyor. Silme commit'lendikten sonra bile geri alınabilir:

```bash
git restore --source=69607a0 -- mobile
```

## Silinen sürüm neydi?

- Flutter ve Dart 3, `go_router`, `flutter_bloc`; 33 ekran, `/step/N` rotaları.
- Yalnızca sabit veri vardı: ekranlar bloc veya repository kullanmıyordu, ağ çağrısı yoktu.
- Ödeme adımı yoktu. Testi tek bir smoke test idi.

## Yeni sürümde tekrarlanmaması gerekenler

| Eski sorun | Yeni sürümde |
|---|---|
| Veri ekranlar arasında taşınmıyordu | Tek iş modeli ve durum makinesi, kimlikli rotalar (`/jobs/:id`), numaralı `/step/N` yok |
| Müşteri ve usta birbirini etkilemiyordu | Durum backend'de tutulur, iki taraf aynı kaydı görür |
| Her teklif aynı detayı açıyordu | Detay ekranları kimlikle veri yükler |
| Oturum ve rota koruması yoktu | Gerçek OTP, oturum, role göre yönlendirme |
| Rol sızıntısı (usta müşteri ekranına düşüyordu) | Rol başına ayrı sekme yapısı (`ShellRoute`), role özel sohbet ve şikayet |
| Geri tuşu gönderilmiş forma dönüyordu | Kayıttan sonra yığın değiştirilir; sekme köklerinde geri oku olmaz |
| Boş düğmeler, doğrulamasız formlar | Çalışmayan öğe yayınlanmaz; form doğrulaması zorunlu |
| Dil seçimi işlevsizdi | Baştan Flutter yerelleştirmesi, sabit metin yok |
| 390 px sınırı, klavye ve taşma sorunları | Duyarlı yerleşim, küçük ekran ve büyük yazı testi |
| Yayın derlemesinde `INTERNET` izni ve imza eksikti | Baştan doğru uygulama adı, izinler ve imza |

Silinen sürümün test kanıtları ve kabul kriterleri: `docs/MOBILE_APP_AUDIT.md`, Bölüm 6.

## Başlamadan önce gereken kararlar

Gerçek ürün kapsamı, emanet modeli, iptal ve komisyon kuralları, admin paneli yeri, backend kapsamı ve takvim.

## İlk teslimat için asgari kapsam

1. Akış şartnamesi: iş durum makinesi, rol-ekran haritası, terim sözlüğü, geri kuralları.
2. Backend: iş, teklif, randevu ve mesaj API'leri, oturum, PostgreSQL.
3. Flutter temeli: tema, yönlendirme, oturum, API katmanı, yolculuk testleri.
4. Müşteri ve usta yolculuğu uçtan uca; ödeme için 3-D Secure WebView.

Tasarım dili için `BiTadilatDESIGN.md` ve prototip ekranları kullanılabilir. Backend ödeme servisi (`backend/`) korunur.

## Test ortamı notu

Bu bilgisayarda Xcode ve Android emülatörü yoktu. Yeni sürüm gerçek cihazda veya emülatörde de test edilmeli.
