# Gezinme ve Geri Kuralları

Denetimde bulunan geri hatalarını (P9, P13, P14 ve Bölüm 6) önlemek için. Her ekran bu kurallara göre test edilir.

## 1. Yığın kuralları

1. **Sekme kökü:** alt sekmelerin ilk ekranında geri oku yoktur. iOS kaydırma hareketi ve Android geri tuşu uygulamayı kapatmaz; Android'de önce Ana sayfa sekmesine döner.
2. **Kayıttan sonra yığın değişir:** bir form sunucuya kaydedildiğinde formu yığından çıkar (`go`, `push` değil). Geri tuşu gönderilmiş forma hiçbir zaman dönmez.

   | Kayıt | Sonrası açılan | Geri gidince |
   |---|---|---|
   | Talep yayınlandı | `/c/requests/:id/published` | `/c/requests` |
   | Ödeme başarılı | `/c/jobs/:id/appointment` | `/c/jobs/:id` |
   | Randevu talebi gönderildi | `/c/jobs/:id` | `/c/requests` |
   | Teklif gönderildi | `/p/offers/:id/sent` | `/p/feed` |
   | Teslim onayı | `/c/jobs/:id/review` | `/c/jobs/:id` |
   | Puan yayınlandı | `/c/jobs/:id` | `/c/requests` |
   | Şikayet oluşturuldu | `/c/complaints/:id` | `/c/jobs/:id` |
   | İş iptal edildi | `/c/requests` veya `/p/jobs/:id/cancelled` | Sekme kökü |
   | Usta "işi bitirdim" | `/p/jobs/:id/finished` | `/p/jobs` |
   | Başvuru gönderildi | `/p/application` | Profil |

3. **Bitmiş işe geri yok:** ödenmiş teklif, yayınlanmış talep, verilmiş puan gibi tamamlanmış adımlar yığında kalmaz.
4. **Detay ekranı derin bağlantıyla açıldıysa** (bildirim, link) geri oku ilgili sekme köküne gider; boş yığında `pop` yapılmaz.
5. **Modal ve alt sayfalar** (filtre, reddetme gerekçesi, onay diyaloğu) kapatıldığında altındaki ekran değişmeden kalır; seçimler korunur.

## 2. Rol sınırı

- Ortak ekranlar (sohbet, bildirimler, ayarlar) rolü **değiştirmez**. Sohbetten geri dönüş, sohbete gelinen ekrandır; usta modundaysa usta ekranı.
- Mod değişimi yalnızca Profil'deki düğmeyle olur ve yığını sıfırlar.
- Usta modundayken `/c/...` rotası açılmaya çalışılırsa usta moduna ait eşdeğer ekrana, yoksa sekme köküne yönlendirilir (tersi de aynı).

## 3. Rota korumaları (`go_router` `redirect`)

Sırayla değerlendirilir:

1. Oturum yok ve rota `G` değil → `/welcome?next=<rota>`. Girişten sonra `next` açılır (yalnızca izinli iç rota).
2. Oturum var ve rota `G` → modun ana sekmesi.
3. Rota usta modu istiyor, profil `PENDING_REVIEW` / `NEEDS_DOCUMENTS` / `REJECTED` → `/p/application`.
4. Rota usta modu istiyor, usta profili yok → `/p/apply`.
5. Kayıt yetkisi sunucudan `403` / `404` dönerse → "Bu içeriğe erişemezsin" ekranı, sekme köküne dön düğmesi.
6. Hesap `SUSPENDED` (sunucu `401 ACCOUNT_SUSPENDED`) → oturum kapanır, açıklamalı giriş ekranı.

## 4. Veri tazeliği

- Ekran odaklanınca (geri dönüş dahil) veri yeniden çekilir; eski veri yüklenirken gösterilir, üstte ince ilerleme çubuğu olur.
- Durum değiştiren eylemden sonra ilgili tüm sağlayıcılar geçersiz kılınır (ör. teklif kabulü: teklif, talep, talep listesi, işler).
- Sunucu `409 ILLEGAL_STATE` dönerse kullanıcıya "Bu işlem artık yapılamıyor, ekran güncellendi" denir ve ekran yenilenir.

## 5. Onay diyalogları (RAD:169)

Zorunlu: teklif kabulü, iş veya talep iptali, teslim onayı, teklifi geri çekme, şikayet gönderme, hesap silme, çıkış. Diyalog sonucu ve geri alınamazlık açıkça yazar ("Bu işlem geri alınamaz. ₺2.450 kartına iade edilir.").

## 6. Bekleme ve hata durumları

- Her liste için boş durum metni ve bir sonraki adım düğmesi vardır.
- Ağ hatasında ekran içinde "Tekrar dene"; form verisi kaybolmaz.
- Gönder düğmeleri istek sürerken kilitlenir; çift dokunma iki kayıt üretmez (sunucu tarafında da idempotent anahtar).
