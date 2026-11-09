# BiTadilat Akış Şartnamesi

Flutter uygulaması, admin paneli ve backend bu belgelere göre yazılır. Bir davranış belgede yoksa önce buraya eklenir, sonra koda geçer.

| Belge | İçerik |
|---|---|
| [STATE_MACHINES.md](STATE_MACHINES.md) | Hesap, usta, talep, teklif, iş, şikayet ve emanet durumları; iptal, randevu, 48 saat ve puan kuralları |
| [ROLE_SCREEN_MAP.md](ROLE_SCREEN_MAP.md) | Her ekranın rotası, erişimi, prototip karşılığı ve veri erişim kuralları |
| [NAVIGATION_RULES.md](NAVIGATION_RULES.md) | Geri tuşu, rol sınırı, rota korumaları, onay diyalogları |
| [GLOSSARY.md](GLOSSARY.md) | Terimler, kategoriler, durum etiketleri, yazım kuralları |
| [DATA_MODEL.md](DATA_MODEL.md) | PostgreSQL tabloları ve kısıtlar |
| [API_V1.md](API_V1.md) | Uç nokta taslağı ve hata kodları |
| [SEED_DATA.md](SEED_DATA.md) | Tek demo veri seti |

**Kaynaklar:** RAD (`BiTadilat_Requirements_Analysis_Document.md`), tasarım (`BiTadilatDESIGN.md`, `BI_TADILAT_AI_HANDOFF.md`), denetim (`docs/MOBILE_APP_AUDIT.md`), prototip (`preview/`, `screens_map.json`).

**RAD'dan ayrılan noktalar** (`docs/PAYMENT_RAD_CHANGE_NOTE.md` içinde gerekçesiyle): online ödeme ve güvence havuzu kapsamda, durum adları birleştirildi, kayıt ve şifre sıfırlama eklendi.

**Bu belgeler varsayılan kuralları içerir.** Takım veya danışman farklı karar verirse önce burası güncellenir.
