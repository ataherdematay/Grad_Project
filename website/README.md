# BiTadilat tanıtım sitesi / promo website

Tek sayfalık, derleme gerektirmeyen statik site (HTML + CSS + küçük bir JS). Varsayılan dil Türkçe, EN düğmesiyle İngilizce. Üçüncü taraf izleme veya CDN yok.

## Yerelde önizleme

```sh
cd website
python3 -m http.server 8000
# http://localhost:8000
```

## İçerik

- `index.html`, `style.css`, `site.js`: sayfa, tema (açık/koyu, sistem ayarına göre), dil değiştirme (tercih `localStorage`'da; `?lang=en` ile de açılır).
- `legal/*.html`: yasal metin taslakları (TR + EN, sayfa içinde dil düğmesi). Aynı metinlerin Markdown halleri `docs/legal/*.tr.md` ve `*.en.md` içindedir; iki kopya birlikte güncellenmelidir. Tüm metinler TASLAKTIR ve yayından önce hukukçu incelemesi gerekir; `[KÖŞELİ]` alanlar şirket bilgisi bekliyor.
- `assets/`: Manrope değişken fontu (`OFL.txt` lisansıyla birlikte, `packages/bitadilat_ui/fonts` kaynağından), uygulama ikonu (`apps/mobile/ios/Runner/Assets.xcassets`), iki örnek veri ekran görüntüsü (iOS simülatörü, demo veri).
- Renkler `packages/bitadilat_ui/lib/src/tokens.dart` değerleriyle aynıdır.

## Yayın öncesi yapılacaklar

- App Store rozeti yer tutucudur; gerçek bağlantı yok. Mağaza yayınlanınca bağlantı ve resmi rozet eklenecek.
- Şirket ünvanı, adres, MERSİS ve e-posta alanları doldurulacak (`index.html` altbilgisi ve `legal/`).
- Yasal metinler hukukçuya gönderilecek, "TASLAK" şeritleri ancak o zaman kaldırılacak.
