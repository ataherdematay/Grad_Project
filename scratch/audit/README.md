# Akış Testi Scriptleri

Prototip ve Flutter için tekrar çalıştırılabilir testler. Bulgular `docs/MOBILE_APP_AUDIT.md` içinde, ilk ölçümler `baseline/` klasöründe. Node 22+ ve Google Chrome gerekir; ek paket yok.

## Hazırlık

Prototip testleri için backend açık olmalı:

```bash
cd backend && ./mvnw spring-boot:run
```

**Flutter testleri yalnızca silinen sürümü (`69607a0`) kapsar:** `/step/N` rotalarına ve eski metinlere bağlıdır, yeni uygulamada yeniden yazılmalıdır. Eski sürümü tekrar ölçmek için:

```bash
git worktree add /tmp/bitadilat_old 69607a0
```

```bash
cd /tmp/bitadilat_old/mobile && flutter build web --pwa-strategy=none -o /tmp/bitadilat_web
```

```bash
python3 -m http.server 8092 --bind 127.0.0.1 --directory /tmp/bitadilat_web
```

## Çalıştırma

Tıklama testleri her ekrandaki her öğeye basar. Prototip testinde tüm yazma istekleri engellenir, bu yüzden Craftgate'te ödeme başlatılamaz.

```bash
node scratch/audit/crawl_prototype.mjs TR /tmp/prototype_TR.json
```

```bash
node scratch/audit/crawl_prototype.mjs EN /tmp/prototype_EN.json
```

```bash
node scratch/audit/crawl_flutter.mjs /tmp/flutter.json /tmp/flutter_shots
```

Müşteri ve usta yolculuğu, geri tuşlarıyla birlikte:

```bash
node scratch/audit/journey_flutter.mjs
```

Ekran görüntüleri ve taşma, dokunma alanı, kırık görsel ölçümü:

```bash
node scratch/audit/capture_prototype.mjs /tmp/prototype_shots
```

## Düzeltme sonrası karşılaştırma

```bash
node scratch/audit/compare.mjs scratch/audit/baseline/prototype_TR.json /tmp/prototype_TR.json
```

```bash
node scratch/audit/summarize.mjs /tmp/prototype_TR.json
```

## Sınırlar

- Tıklamalar programla yapılır, gerçek parmak hareketi değildir. Kapalı bir öğenin üstüne binen katmanları yakalamaz.
- "Görünür etkisiz" her zaman hata demek değildir: form alanı, seçim kutusu ve metin değiştirmeyen seçimler de bu gruba girer. Sonucu ekranla birlikte yorumlayın.
- Flutter'da her ekran doğrudan adresle açılır, yani geri yığını boştur. Yığına bağlı davranışlar için `journey_flutter.mjs` kullanılır.
- Flutter, Chrome'da test edilir. Gerçek cihaz klavyesi, geri hareketi, çentik ve izinler bu testlerin dışındadır.
