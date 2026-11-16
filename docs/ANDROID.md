# BiTadilat Android

Uygulama `apps/mobile` altindaki Flutter projesidir; Android kismi `apps/mobile/android` icindedir.

- applicationId / namespace: `com.bitadilat.app`, etiket: `BiTadilat`
- minSdk 24, targetSdk Flutter'in guncel hedefi (`flutter.targetSdkVersion`, su an 36)
- Simge: adaptive icon (gradient arka plan + ev/onay isareti), Android 13 tematik (monochrome) katman, API 24-25 icin eski PNG mipmap'ler. Kaynak iOS uygulama simgesidir.
- Acilis ekrani: iOS LaunchScreen ile ayni (`#F7F8F6` zemin + yuvarlatilmis logo). Android 12+ SplashScreen API'si (`values-v31`), eski surumlerde `launch_background`. Sonra `NormalTheme` ayni zemini kullandigi icin beyaz parlama olmaz.

## Calistirma (emulator)

Emulatorde bilgisayardaki backend `http://10.0.2.2:8090` adresindedir:

```sh
cd apps/mobile
flutter run -d <emulator-id> --dart-define=API_BASE_URL=http://10.0.2.2:8090
# yalnizca derleme
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8090
```

Fiziksel cihazda bilgisayarin LAN adresini kullanin ya da `adb reverse tcp:8090 tcp:8090` ile `http://localhost:8090` verin.

## Ag kurali (iOS ATS ile ayni mantik)

- Release: yalnizca HTTPS (`src/main/res/xml/network_security_config.xml`, cleartext kapali).
- Debug: `src/debug/res/xml/network_security_config.xml` ayni dosyayi gecersiz kilar ve duz HTTP'yi yalnizca `10.0.2.2`, `localhost`, `127.0.0.1` icin acar.
- Release icin `--dart-define=API_BASE_URL=https://...` verilmelidir. Network security config yalnizca platform agini (3-D Secure WebView, sistem tarayicisi) denetler; dio'nun kullandigi dart:io soketleri bu kurala tabi degildir. Bu yuzden `main()` release derlemesinde `https` olmayan bir `API_BASE_URL` ile acilmaz (`ensureSecureApiBaseUrl`, iOS icin de gecerli).
- `profile` derlemesi release kuralini (yalnizca HTTPS) kullanir.

## Izinler

Yalnizca `INTERNET`. Kamera ve galeri `image_picker` ile sistem kamera uygulamasi ve Android Photo Picker uzerinden acildigi icin `CAMERA`, `READ_MEDIA_IMAGES` veya `READ_EXTERNAL_STORAGE` bildirilmez (Android 13+ dahil). `CAMERA` bildirilirse calisma zamani izni de gerekir; gerek yok. Kamera donanimi `required="false"` olarak isaretlidir. Uygulama ileride dogrudan medya okumaya gecerse `READ_MEDIA_IMAGES` eklenmelidir.

## Release imzalama

Keystore repoda tutulmaz ve burada olusturulmaz. Kendi makinenizde bir kez uretin:

```sh
keytool -genkeypair -v -keystore ~/bitadilat-upload.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Ardindan `apps/mobile/android/key.properties` dosyasini olusturun (`.gitignore` ile dislanmistir, commit etmeyin):

```properties
storeFile=/Users/<siz>/bitadilat-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

`storeFile` mutlak ya da `android/` klasorune gore goreli olabilir. CI'da dosya yerine ortam degiskenleri kullanilir: `BITADILAT_KEYSTORE_FILE`, `BITADILAT_STORE_PASSWORD`, `BITADILAT_KEY_ALIAS`, `BITADILAT_KEY_PASSWORD`.

```sh
cd apps/mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.example.com   # Play Store
```

Imza bilgisi yoksa release derlemesi bilerek hata verir (debug anahtariyla imzali release uretilmez). Debug derlemesi imza ayari istemez.
