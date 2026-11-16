# BiTadilat — Yazılım Tasarım Belgesi (SDD)

| | |
|---|---|
| Proje | BiTadilat (COMP/SOFT4902 Bitirme Projesi, Güz 2026) |
| Belge | Yazılım Tasarım Belgesi (System Design Document) |
| Durum | Taslak. Kod `feature/flutter-app` dalındaki 565bfb4 işlemine göre yazıldı |
| Kaynaklar | `BiTadilat_Requirements_Analysis_Document.md` (RAD v1.1), `docs/spec/*`, `backend/`, `apps/*`, `packages/*` |
| Dil | Türkçe. Kod, tablo ve alan adları İngilizce kalır |

Bu belge **gerçekleştirilmiş sistemi** anlatır. RAD'daki bir şey yapılmadıysa "gerçekleştirilmedi" yazılıdır. RAD'dan bilinçli ayrılmalar 11. bölümde toplanmıştır.

---

## 1. Amaç ve kapsam

BiTadilat, İstanbul'da ev tadilat ve onarım işi isteyen müşterileri uygun ustalarla buluşturan bir pazaryeridir. Müşteri talep açar, kurallara göre eşleşen ustalar yapılandırılmış teklif verir, müşteri bir teklifi kabul edip parayı kartla yatırır. Para, iş onaylanana kadar bir emanet (güvence) defterinde tutulur. Anlaşmazlıkta yönetici karar verir.

**Kapsamdaki parçalar**

| Parça | Teknoloji | Konum |
|---|---|---|
| Mobil uygulama (müşteri ve usta, tek hesap iki mod) | Flutter, iOS öncelikli | `apps/mobile` |
| Yönetim paneli | Flutter Web | `apps/admin` |
| Ortak API istemcisi ve modeller | Dart paketi | `packages/bitadilat_api` |
| Ortak tasarım bileşenleri | Dart paketi | `packages/bitadilat_ui` |
| Sunucu | Spring Boot 4.1.2, Java 21, Spring Security (JWT), Flyway | `backend` |
| Veritabanı | PostgreSQL 16 | `backend/src/main/resources/db/migration` |
| Ödeme sağlayıcısı | Craftgate **sandbox** (3D Secure) | dış hizmet |

**Kapsam dışı / gerçekleştirilmedi**

- Tanıtım web sitesi (RAD UC14): yapılmadı.
- Push bildirimi (FCM/APNs): yapılmadı. `device_tokens` tablosu ve `PUT /api/v1/devices` var, gönderen servis yok. Uygulama içi bildirim merkezi var.
- Gerçek e-posta/SMS: şifre sıfırlama kodu `LoggingEmailSender` ile yalnızca log'a yazılır.
- Docker ile paketleme: repoda Dockerfile yok.
- Android: proje iskeleti var, derlenip sınanmadı.
- Gerçek para: Craftgate yalnızca sandbox. Usta ödemesi (payout) bankaya gönderilmez, `payout_ledger` ve `escrow_payment` satırlarında **kaydedilir**.

---

## 2. Mimari

### 2.1 Bileşen diyagramı

```mermaid
flowchart LR
    subgraph Istemciler["İstemciler (Flutter)"]
        MOB["Mobil uygulama<br/>apps/mobile (iOS öncelikli)<br/>müşteri modu + usta modu"]
        ADM["Yönetim paneli<br/>apps/admin (Flutter Web)"]
        APIPKG["bitadilat_api<br/>dio istemcisi, modeller,<br/>refresh interceptor"]
        UIPKG["bitadilat_ui<br/>tema, bileşenler, tokenlar"]
        MOB --> APIPKG
        ADM --> APIPKG
        MOB --> UIPKG
        ADM --> UIPKG
    end

    subgraph Sunucu["Spring Boot API (backend, port 8090)"]
        SEC["Güvenlik: JWT HS256,<br/>RBAC, CORS"]
        AUTH["auth + user<br/>kayıt, giriş, refresh,<br/>şifre sıfırlama, adres"]
        REQ["request + catalog<br/>talep, eşleştirme"]
        PRO["pro<br/>başvuru, akış, kazanç"]
        OFR["offer<br/>teklif"]
        PAY["payment<br/>3DS başlatma, callback,<br/>emanet defteri, süpürücü"]
        JOB["job<br/>iş durum makinesi,<br/>randevu, şikayet, puan"]
        CHT["chat<br/>mesajlar (yoklama)"]
        MED["media<br/>yükleme, imzalı URL"]
        NTF["notification<br/>uygulama içi merkez"]
        ADMS["admin<br/>başvuru, şikayet,<br/>hesap, ödeme listesi"]
        SCH["Zamanlayıcılar (5 dk):<br/>ExpiryJob, JobScheduler,<br/>PaymentSweeper"]
    end

    DB[("PostgreSQL 16<br/>Flyway V1..V6")]
    DISK[("Yerel disk<br/>medya dosyaları")]
    CG["Craftgate sandbox<br/>3D Secure, iade"]
    MAIL["EmailSender<br/>(yalnızca log)"]

    APIPKG -- "HTTPS/JSON, Bearer JWT" --> SEC
    SEC --> AUTH
    SEC --> REQ
    SEC --> PRO
    SEC --> OFR
    SEC --> PAY
    SEC --> JOB
    SEC --> CHT
    SEC --> MED
    SEC --> NTF
    SEC --> ADMS
    AUTH --> DB
    REQ --> DB
    PRO --> DB
    OFR --> DB
    PAY --> DB
    JOB --> DB
    CHT --> DB
    NTF --> DB
    ADMS --> DB
    MED --> DISK
    MED --> DB
    PAY -- "REST (SDK)" --> CG
    CG -- "3DS callback (form POST)" --> PAY
    AUTH --> MAIL
    SCH --> JOB
    SCH --> PAY
    SCH --> REQ
```

Katmanlama kuralları (kodda uygulanan):

- İstemci sunucuyla yalnızca REST/JSON ile konuşur (RAD: ayrık mimari). Sözleşme `docs/spec/API_V1.md`. Hata gövdesi `{ "error": { "code", "message", ... } }` biçimindedir.
- İş kuralları sunucudadır. İstemci "hangi düğme görünür" bilgisini sunucunun döndüğü `actions` listesinden alır (`JobStateMachine.allowedActions`). Kural ve ekran ayrışamaz.
- `PaymentGateway` arayüzü Craftgate SDK'yı arkasına saklar. Servis katmanı SDK tiplerini görmez; testler sahte ağ geçidiyle çalışır.
- Şema Flyway ile yönetilir, `ddl-auto=validate`. Testler her bağlamda şemayı baştan kurar.

### 2.2 Dağıtım diyagramı

Gerçekleştirilen dağıtım **geliştirme ve sandbox** düzenidir. Üretim ortamı ve Docker yoktur.

```mermaid
flowchart TB
    subgraph DevMac["Geliştirme makinesi (macOS)"]
        SIM["iOS Simulator<br/>BiTadilat.app (Flutter)"]
        BROWSER["Tarayıcı<br/>Flutter Web yönetim paneli"]
        subgraph JVM["JVM (Java 21)"]
            APP["bitadilat-api.jar<br/>Spring Boot, :8090<br/>profil: dev"]
        end
        PG[("PostgreSQL 16<br/>:5432, veritabanı bitadilat")]
        FS[("./data/media<br/>MEDIA_DIR")]
        SIM -- "HTTP localhost:8090" --> APP
        BROWSER -- "HTTP localhost:8090" --> APP
        APP -- "JDBC" --> PG
        APP -- "dosya G/Ç" --> FS
    end
    CGS["Craftgate sandbox<br/>sandbox-api.craftgate.io"]
    APP -- "HTTPS, API anahtarı (env)" --> CGS
    SIM -. "WebView: banka 3DS sayfası" .-> CGS
    CGS -. "callback: POST /api/payments/3ds/callback" .-> APP
```

Çalışma ortamı notları:

- `dev` profili yalnızca loopback adresine bağlanır (`BITADILAT_BIND`, varsayılan 127.0.0.1) ve tohum veri ile `POST /api/v1/dev/reset` uç noktasını açar. `prod` profilinde bu bean'ler yoktur, OpenAPI/Swagger kapalıdır, gizli anahtarlar için varsayılan değer yoktur (`ProdProfileConfigTest`).
- Gerekli ortam değişkenleri: `DB_URL`, `DB_USER`, `DB_PASSWORD`, `JWT_SECRET` (en az 32 bayt), `ADDRESS_KEY` (base64, 32 bayt), `MEDIA_SIGNING_KEY` (en az 32 bayt), `MEDIA_DIR`, `CRAFTGATE_*` anahtarları, `APP_PUBLIC_BASE_URL` (3DS callback adresi için), `CORS_ALLOWED_ORIGINS`.
- 3DS callback adresi bankanın tarayıcısından erişilebilir olmalıdır (`APP_PUBLIC_BASE_URL`). Yerelde bu, Simulator için `localhost` ile çalışır; gerçek cihaz için dışarıdan erişilebilir bir adres gerekir (gerçekleştirilmedi).
- Yönetim paneli statik Flutter Web çıktısıdır (`apps/admin/web`). Ayrı bir barındırma yapılandırması yoktur; geliştirmede `flutter run -d chrome`.

### 2.3 Paket yapısı

```
backend/src/main/java/com/bitadilat/
  auth/  user/  catalog/  request/  pro/  offer/  job/  chat/  media/
  notification/  admin/  payment/{controller,service,domain,gateway,dto,config}
  common/{security,...}  dev/
apps/mobile/lib/{app,core,l10n,features/{auth,customer,pro,jobs,chat,payment,notifications,settings,shell,common}}
apps/admin/lib/{app,core,l10n,features/{auth,dashboard,applications,complaints,accounts,payments,shell,common}}
packages/bitadilat_api/lib/src/{api,core,models,...}      (freezed + json_serializable)
packages/bitadilat_ui/lib/src/{theme,tokens,typography,app_button,...}
```

İstemci durum yönetimi: Riverpod. Yönlendirme: go_router (rota korumaları `router_guards_test.dart` ile sınanır). Yerelleştirme: `gen-l10n` ARB dosyaları (TR/EN, canlı geçiş).

---

## 3. Kullanım durumu diyagramı

RAD'daki UC01–UC14, gerçekleştirilen duruma göre güncellendi. `EK` ile başlayanlar RAD'da olmayıp sonradan eklenenlerdir.

```mermaid
flowchart LR
    MUS(["Müşteri"])
    USTA(["Usta"])
    ADMIN(["Yönetici"])
    SIS(["Sistem / zamanlayıcı"])
    CG(["Craftgate sandbox"])

    subgraph BiTadilat["BiTadilat sistemi"]
        UC01(["UC01 Kayıt, giriş,<br/>şifre sıfırlama, hesap silme"])
        UC02(["UC02 Talep oluştur"])
        UC03(["UC03 Kural tabanlı eşleştirme"])
        UC04(["UC04 Yapılandırılmış teklif ver"])
        UC05(["UC05 Teklifleri karşılaştır,<br/>kabul et ve öde (3DS)"])
        UC06(["UC06 Randevu"])
        UC07(["UC07 Uygulama içi mesaj"])
        UC08(["UC08 İş ilerlemesi"])
        UC09(["UC09 Tamamlamayı onayla<br/>(48 saat otomatik)"])
        UC10(["UC10 Değerlendir"])
        UC11(["UC11 Talep / iş iptali"])
        UC12(["UC12 Usta başvurusunu doğrula"])
        UC13(["UC13 Şikayeti karara bağla"])
        UC14(["UC14 Tanıtım sitesi<br/>GERÇEKLEŞTİRİLMEDİ"])
        EK1(["EK1 Şikayet aç"])
        EK2(["EK2 Bildirim merkezi"])
        EK3(["EK3 Usta başvurusu gönder"])
        EK4(["EK4 Hesap askıya al / aç"])
        EK5(["EK5 Ödeme listesi"])
        EK6(["EK6 Kazançlar"])
    end

    MUS --- UC01
    MUS --- UC02
    MUS --- UC05
    MUS --- UC06
    MUS --- UC07
    MUS --- UC09
    MUS --- UC10
    MUS --- UC11
    MUS --- EK1
    MUS --- EK2
    USTA --- UC01
    USTA --- EK3
    USTA --- UC04
    USTA --- UC06
    USTA --- UC07
    USTA --- UC08
    USTA --- UC11
    USTA --- EK2
    USTA --- EK6
    ADMIN --- UC12
    ADMIN --- UC13
    ADMIN --- EK4
    ADMIN --- EK5
    SIS --- UC03
    SIS --- UC09
    CG --- UC05
    UC02 -. "include" .-> UC03
    UC05 -. "include" .-> CG
    EK1 -. "extend" .-> UC13
    UC13 -. "include" .-> CG
```

| UC | Gerçekleşen davranış | Durum |
|---|---|---|
| UC01 | E-posta **veya** telefon + şifre, KVKK/koşul onayı, şifre sıfırlama (e-posta kodu), hesap silme (anonimleştirme), müşteri/usta mod geçişi | Yapıldı (RAD'dan değişti) |
| UC02 | 4 adımlı sihirbaz, en fazla 5 fotoğraf, ilçe, acil/planlı | Yapıldı |
| UC03 | Kategori + ilçe + müsaitlik + onay durumu; eşleşme nedenleri (`matchFactors`); sıfır eşleşmede talep yine yayımlanır | Yapıldı |
| UC04 | Emek + malzeme kalemleri, varış aralığı, garanti, not; `Idempotency-Key` | Yapıldı |
| UC05 | Karşılaştırma, kabul = kart ile 3DS ödeme; başarılı callback teklifi kabul eder, diğerlerini `SUPERSEDED` yapar, işi açar | Yapıldı (genişledi) |
| UC06 | Usta onaylar ya da yeni aralık önerir; karşı taraf kabul eder | Yapıldı (değişti) |
| UC07 | İş başına sohbet, fotoğraf, okundu bilgisi; **yoklama** (websocket yok); iş kapandıktan 30 gün sonra salt okunur | Yapıldı |
| UC08 | Adrese ulaştım, başladım, bitirdim, not/fotoğraf | Yapıldı (değişti) |
| UC09 | Müşteri onayı ya da 48 saat sonra otomatik; emanet ustaya serbest bırakılır | Yapıldı (genişledi) |
| UC10 | Yalnızca `COMPLETED` iş, bir kez, 1–5 yıldız | Yapıldı |
| UC11 | Yalnızca iş başlamadan (`AWAITING_APPOINTMENT`, `SCHEDULED`, `ARRIVED`), tam iade | Yapıldı (değişti) |
| UC12 | Başvuru onayla / reddet / belge iste | Yapıldı |
| UC13 | Tam iade, %50/%50, ustaya aktar; uyarı ve askıya alma | Yapıldı (genişledi) |
| UC14 | — | **Gerçekleştirilmedi** |

---

## 4. Alan modeli (sınıf diyagramı)

Ana varlıklar ve aralarındaki ilişkiler. Alan adları veritabanı sütunlarının camelCase karşılığıdır. Tam sütun listesi 5. bölümdeki ER diyagramlarındadır.

```mermaid
classDiagram
    direction LR
    class User {
        UUID id
        String fullName
        String email
        String phone
        String passwordHash
        UserStatus status
        UserMode lastMode
        boolean isAdmin
        Instant kvkkAcceptedAt
    }
    class Address {
        UUID id
        String label
        String neighborhood
        String lineFullEncrypted
        String doorNoteEncrypted
        boolean isDefault
    }
    class ProProfile {
        UUID userId
        String businessName
        ReviewStatus reviewStatus
        Availability availability
        BigDecimal ratingAvg
        int completedJobs
        int warningCount
    }
    class ProDocument {
        DocumentType type
        DocumentStatus status
    }
    class ServiceRequest {
        UUID id
        String publicCode
        Urgency urgency
        String title
        String description
        RequestStatus status
        int matchedProCount
        Instant expiresAt
    }
    class Offer {
        UUID id
        BigDecimal laborAmount
        BigDecimal materialsAmount
        BigDecimal totalAmount
        int warrantyMonths
        OfferStatus status
        Instant validUntil
    }
    class OfferItem {
        ItemKind kind
        String description
        BigDecimal quantity
        BigDecimal unitPrice
    }
    class Job {
        UUID id
        JobStatus status
        Instant scheduledFrom
        Instant scheduledTo
        Instant autoCompleteAt
    }
    class AppointmentProposal {
        ActorRole proposedBy
        Instant slotFrom
        Instant slotTo
        ProposalStatus status
    }
    class JobEvent {
        EventType type
        ActorRole actorRole
        String note
    }
    class Message {
        long id
        String body
    }
    class Review {
        int rating
        String comment
        boolean isAnonymous
    }
    class Complaint {
        String publicCode
        ComplaintReason reason
        ComplaintStatus status
        String decision
        boolean warnPro
        boolean suspendPro
    }
    class EscrowPayment {
        String ref
        BigDecimal totalAmount
        BigDecimal commission
        BigDecimal proPayout
        BigDecimal refundedAmount
        EscrowStatus status
        String cardLast4
        int refundAttempts
    }
    class PayoutLedgerEntry {
        BigDecimal amount
        String kind
    }
    class Media {
        UUID id
        MediaPurpose purpose
        String contentType
        long sizeBytes
    }
    class Notification {
        String type
        String titleKey
        Instant readAt
    }

    User "1" --> "0..*" Address : sahip
    User "1" --> "0..1" ProProfile : usta modu
    ProProfile "1" --> "0..*" ProDocument
    User "1" --> "0..*" ServiceRequest : müşteri
    ServiceRequest "1" --> "0..*" Offer
    ProProfile "1" --> "0..*" Offer : verir
    Offer "1" --> "1..*" OfferItem
    Offer "1" --> "0..1" Job : kabul edilince
    ServiceRequest "1" --> "0..1" Job : aktif iş
    Job "1" --> "0..*" AppointmentProposal
    Job "1" --> "0..*" JobEvent
    Job "1" --> "0..*" Message
    Job "1" --> "0..1" Review
    Job "1" --> "0..*" Complaint : aynı anda en çok 1 açık
    Job "1" --> "0..1" EscrowPayment : emanet
    EscrowPayment "1" --> "0..*" PayoutLedgerEntry
    User "1" --> "0..*" Notification
    User "1" --> "0..*" Media : yükler
```

Notlar:

- `EscrowPayment.offer_id` bir **yabancı anahtar değildir** (V1'den gelen düz `varchar`). `request_id`, `customer_id`, `pro_id`, `job_id` V5 ile yabancı anahtar oldu. `payout_ledger.payment_ref` de yabancı anahtar değildir.
- `job_events.type` değerleri: `STATUS_CHANGED`, `NOTE`, `PHOTO`, `APPOINTMENT_PROPOSED`, `APPOINTMENT_ACCEPTED`.
- Teklif tutarı kuralı veritabanında zorunludur: `total_amount = labor_amount + materials_amount`.

---

## 5. Veri tabanı (ER diyagramları)

Aşağıdaki diyagramlar **Flyway V1–V6 betiklerinin boş bir PostgreSQL veritabanına uygulanması** ve `information_schema` sorgulanması ile üretilmiştir (31 tablo). Anahtar işaretleri: `PK` birincil, `FK` yabancı, `UK` benzersiz sütun. Kısmi benzersiz indeksler ve CHECK kısıtları diyagramda görünmez, 5.6'da özetlenmiştir. Diyagramlar okunabilirlik için 5 gruba bölünmüştür; bazı tablolar (ör. `users`) birden fazla grupta tekrar eder.

### 5.1 Kimlik, adres, medya, yönetim

```mermaid
erDiagram
    users {
        uuid id PK
        varchar full_name
        varchar email
        varchar phone UK
        varchar password_hash
        varchar locale
        varchar status
        varchar last_mode
        boolean is_admin
        timestamptz kvkk_accepted_at
        timestamptz terms_accepted_at
        timestamptz deleted_at
        timestamptz created_at
        timestamptz updated_at
    }
    refresh_tokens {
        uuid id PK
        uuid user_id FK
        varchar token_hash UK
        uuid family_id
        timestamptz expires_at
        timestamptz revoked_at
        uuid replaced_by FK
        varchar user_agent
        timestamptz created_at
    }
    password_reset_codes {
        uuid id PK
        uuid user_id FK
        varchar code_hash
        timestamptz expires_at
        int attempts
        timestamptz used_at
        timestamptz created_at
    }
    login_attempts {
        uuid id PK
        varchar identifier_hash
        varchar ip
        boolean success
        timestamptz created_at
    }
    addresses {
        uuid id PK
        uuid user_id FK
        varchar label
        int district_id FK
        varchar neighborhood
        text line_full_encrypted
        text door_note_encrypted
        boolean is_default
        timestamptz created_at
        timestamptz updated_at
    }
    device_tokens {
        uuid id PK
        uuid user_id FK
        varchar platform
        varchar token UK
        timestamptz updated_at
    }
    admin_actions {
        uuid id PK
        uuid admin_id FK
        varchar action
        varchar target_type
        varchar target_id
        text note
        timestamptz created_at
    }
    districts {
        int id PK
        varchar name UK
        varchar city
        varchar side
        boolean is_active
    }
    media {
        uuid id PK
        uuid owner_id FK
        varchar purpose
        varchar storage_key UK
        varchar content_type
        bigint size_bytes
        int width
        int height
        varchar sha256
        timestamptz created_at
    }
    users ||--o{ refresh_tokens : "user_id"
    refresh_tokens ||--o{ refresh_tokens : "replaced_by"
    users ||--o{ password_reset_codes : "user_id"
    users ||--o{ addresses : "user_id"
    districts ||--o{ addresses : "district_id"
    users ||--o{ media : "owner_id"
    users ||--o{ device_tokens : "user_id"
    users ||--o{ admin_actions : "admin_id"
```

### 5.2 Usta profili

```mermaid
erDiagram
    users {
        uuid id PK
        varchar full_name
        varchar email
        varchar phone UK
        varchar password_hash
        varchar locale
        varchar status
        varchar last_mode
        boolean is_admin
        timestamptz kvkk_accepted_at
        timestamptz terms_accepted_at
        timestamptz deleted_at
        timestamptz created_at
        timestamptz updated_at
    }
    pro_profiles {
        uuid user_id PK,FK
        varchar business_name
        text bio
        int experience_years
        varchar review_status
        text review_note
        varchar availability
        numeric rating_avg
        int rating_count
        int completed_jobs
        int cancellation_count
        int warning_count
        timestamptz approved_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
    }
    pro_categories {
        uuid pro_id PK,FK
        varchar category_id PK,FK
    }
    pro_districts {
        uuid pro_id PK,FK
        int district_id PK,FK
    }
    pro_working_hours {
        uuid id PK
        uuid pro_id FK
        int weekday
        time start_time
        time end_time
        boolean accepts_urgent
    }
    pro_documents {
        uuid id PK
        uuid pro_id FK
        varchar type
        uuid media_id FK
        varchar status
        uuid reviewed_by FK
        timestamptz reviewed_at
        timestamptz created_at
    }
    categories {
        varchar id PK
        varchar name_tr
        varchar name_en
        varchar icon
        varchar color_hex
        int sort_order
        boolean is_active
    }
    districts {
        int id PK
        varchar name UK
        varchar city
        varchar side
        boolean is_active
    }
    media {
        uuid id PK
        uuid owner_id FK
        varchar purpose
        varchar storage_key UK
        varchar content_type
        bigint size_bytes
        int width
        int height
        varchar sha256
        timestamptz created_at
    }
    pro_profiles ||--o{ pro_districts : "pro_id"
    users ||--o{ media : "owner_id"
    districts ||--o{ pro_districts : "district_id"
    users ||--o{ pro_profiles : "user_id"
    pro_profiles ||--o{ pro_categories : "pro_id"
    categories ||--o{ pro_categories : "category_id"
    pro_profiles ||--o{ pro_working_hours : "pro_id"
    pro_profiles ||--o{ pro_documents : "pro_id"
    media ||--o{ pro_documents : "media_id"
    users ||--o{ pro_documents : "reviewed_by"
```


### 5.3 Talep ve teklif

```mermaid
erDiagram
    users {
        uuid id PK
        varchar full_name
        varchar email
        varchar phone UK
        varchar password_hash
        varchar locale
        varchar status
        varchar last_mode
        boolean is_admin
        timestamptz kvkk_accepted_at
        timestamptz terms_accepted_at
        timestamptz deleted_at
        timestamptz created_at
        timestamptz updated_at
    }
    categories {
        varchar id PK
        varchar name_tr
        varchar name_en
        varchar icon
        varchar color_hex
        int sort_order
        boolean is_active
    }
    districts {
        int id PK
        varchar name UK
        varchar city
        varchar side
        boolean is_active
    }
    addresses {
        uuid id PK
        uuid user_id FK
        varchar label
        int district_id FK
        varchar neighborhood
        text line_full_encrypted
        text door_note_encrypted
        boolean is_default
        timestamptz created_at
        timestamptz updated_at
    }
    media {
        uuid id PK
        uuid owner_id FK
        varchar purpose
        varchar storage_key UK
        varchar content_type
        bigint size_bytes
        int width
        int height
        varchar sha256
        timestamptz created_at
    }
    service_requests {
        uuid id PK
        varchar public_code UK
        uuid customer_id FK
        varchar category_id FK
        varchar urgency
        timestamptz preferred_from
        timestamptz preferred_to
        varchar title
        text description
        int district_id FK
        varchar neighborhood
        uuid address_id FK
        varchar status
        int matched_pro_count
        timestamptz expires_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar cancel_reason
        varchar cancel_note
    }
    request_photos {
        uuid request_id PK,FK
        uuid media_id PK,FK
        int sort_order UK
    }
    request_answers {
        uuid request_id PK,FK
        varchar question_key PK
        varchar answer
    }
    offers {
        uuid id PK
        varchar public_code UK
        uuid request_id FK
        uuid pro_id FK
        numeric labor_amount
        numeric materials_amount
        numeric total_amount
        timestamptz arrival_from
        timestamptz arrival_to
        int warranty_months
        varchar note
        varchar status
        timestamptz valid_until
        varchar decline_reason
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar decline_note
        varchar idempotency_key
    }
    offer_items {
        uuid id PK
        uuid offer_id FK
        varchar kind
        varchar description
        numeric quantity
        numeric unit_price
        int sort_order
    }
    pro_profiles {
        uuid user_id PK,FK
        varchar business_name
        text bio
        int experience_years
        varchar review_status
        text review_note
        varchar availability
        numeric rating_avg
        int rating_count
        int completed_jobs
        int cancellation_count
        int warning_count
        timestamptz approved_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
    }
    users ||--o{ addresses : "user_id"
    districts ||--o{ addresses : "district_id"
    users ||--o{ media : "owner_id"
    users ||--o{ pro_profiles : "user_id"
    users ||--o{ service_requests : "customer_id"
    categories ||--o{ service_requests : "category_id"
    districts ||--o{ service_requests : "district_id"
    addresses ||--o{ service_requests : "address_id"
    service_requests ||--o{ request_photos : "request_id"
    media ||--o{ request_photos : "media_id"
    service_requests ||--o{ request_answers : "request_id"
    service_requests ||--o{ offers : "request_id"
    pro_profiles ||--o{ offers : "pro_id"
    offers ||--o{ offer_items : "offer_id"
```

### 5.4 İş, randevu, sohbet, değerlendirme, şikayet

```mermaid
erDiagram
    jobs {
        uuid id PK
        uuid request_id FK
        uuid offer_id FK,UK
        uuid customer_id FK
        uuid pro_id FK
        varchar status
        varchar status_before_dispute
        timestamptz scheduled_from
        timestamptz scheduled_to
        timestamptz arrived_at
        timestamptz started_at
        timestamptz finished_at
        timestamptz completed_at
        timestamptz cancelled_at
        varchar cancelled_by
        varchar cancel_reason
        timestamptz auto_complete_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar cancel_note
        timestamptz auto_complete_reminded_at
    }
    appointment_proposals {
        uuid id PK
        uuid job_id FK
        varchar proposed_by
        timestamptz slot_from
        timestamptz slot_to
        varchar status
        timestamptz created_at
    }
    job_events {
        uuid id PK
        uuid job_id FK
        uuid actor_id FK
        varchar type
        varchar from_status
        varchar to_status
        varchar note
        uuid media_id FK
        timestamptz created_at
        varchar actor_role
        bigint seq
    }
    messages {
        bigint id PK
        uuid job_id FK
        uuid sender_id FK
        varchar body
        uuid media_id FK
        timestamptz created_at
    }
    message_reads {
        uuid job_id PK,FK
        uuid user_id PK,FK
        bigint last_read_id
    }
    reviews {
        uuid id PK
        uuid job_id FK,UK
        uuid customer_id FK
        uuid pro_id FK
        int rating
        text_array tags
        varchar comment
        boolean is_anonymous
        timestamptz created_at
    }
    complaints {
        uuid id PK
        varchar public_code UK
        uuid job_id FK
        uuid customer_id FK
        uuid pro_id FK
        varchar reason
        text description
        varchar status
        varchar decision
        text decision_note
        uuid decided_by FK
        timestamptz decided_at
        boolean warn_pro
        boolean suspend_pro
        timestamptz created_at
        timestamptz updated_at
    }
    complaint_evidence {
        uuid complaint_id PK,FK
        uuid media_id PK,FK
    }
    offers {
        uuid id PK
        varchar public_code UK
        uuid request_id FK
        uuid pro_id FK
        numeric labor_amount
        numeric materials_amount
        numeric total_amount
        timestamptz arrival_from
        timestamptz arrival_to
        int warranty_months
        varchar note
        varchar status
        timestamptz valid_until
        varchar decline_reason
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar decline_note
        varchar idempotency_key
    }
    service_requests {
        uuid id PK
        varchar public_code UK
        uuid customer_id FK
        varchar category_id FK
        varchar urgency
        timestamptz preferred_from
        timestamptz preferred_to
        varchar title
        text description
        int district_id FK
        varchar neighborhood
        uuid address_id FK
        varchar status
        int matched_pro_count
        timestamptz expires_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar cancel_reason
        varchar cancel_note
    }
    users {
        uuid id PK
        varchar full_name
        varchar email
        varchar phone UK
        varchar password_hash
        varchar locale
        varchar status
        varchar last_mode
        boolean is_admin
        timestamptz kvkk_accepted_at
        timestamptz terms_accepted_at
        timestamptz deleted_at
        timestamptz created_at
        timestamptz updated_at
    }
    pro_profiles {
        uuid user_id PK,FK
        varchar business_name
        text bio
        int experience_years
        varchar review_status
        text review_note
        varchar availability
        numeric rating_avg
        int rating_count
        int completed_jobs
        int cancellation_count
        int warning_count
        timestamptz approved_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
    }
    media {
        uuid id PK
        uuid owner_id FK
        varchar purpose
        varchar storage_key UK
        varchar content_type
        bigint size_bytes
        int width
        int height
        varchar sha256
        timestamptz created_at
    }
    users ||--o{ media : "owner_id"
    users ||--o{ pro_profiles : "user_id"
    users ||--o{ service_requests : "customer_id"
    service_requests ||--o{ offers : "request_id"
    pro_profiles ||--o{ offers : "pro_id"
    service_requests ||--o{ jobs : "request_id"
    offers ||--o{ jobs : "offer_id"
    users ||--o{ jobs : "customer_id"
    pro_profiles ||--o{ jobs : "pro_id"
    jobs ||--o{ appointment_proposals : "job_id"
    jobs ||--o{ job_events : "job_id"
    users ||--o{ job_events : "actor_id"
    media ||--o{ job_events : "media_id"
    jobs ||--o{ messages : "job_id"
    users ||--o{ messages : "sender_id"
    media ||--o{ messages : "media_id"
    jobs ||--o{ message_reads : "job_id"
    users ||--o{ message_reads : "user_id"
    jobs ||--o{ reviews : "job_id"
    users ||--o{ reviews : "customer_id"
    pro_profiles ||--o{ reviews : "pro_id"
    jobs ||--o{ complaints : "job_id"
    users ||--o{ complaints : "customer_id"
    pro_profiles ||--o{ complaints : "pro_id"
    users ||--o{ complaints : "decided_by"
    complaints ||--o{ complaint_evidence : "complaint_id"
    media ||--o{ complaint_evidence : "media_id"
```

### 5.5 Emanet, defter, bildirim

```mermaid
erDiagram
    escrow_payment {
        varchar ref PK
        varchar offer_id
        varchar job_ref
        varchar attempt_key UK
        varchar conversation_id UK
        bigint craftgate_payment_id UK
        numeric total_amount
        numeric commission
        numeric pro_payout
        numeric refunded_amount
        varchar status
        varchar card_last4
        varchar error_message
        boolean result_uncertain
        timestamptz created_at
        timestamptz locked_at
        timestamptz released_at
        timestamptz refunded_at
        bigint version
        uuid request_id FK
        uuid customer_id FK
        uuid pro_id FK
        uuid job_id FK
        varchar channel
        varchar provider
        varchar error_code
        int refund_attempts
        timestamptz last_refund_attempt_at
        timestamptz next_refund_attempt_at
    }
    payout_ledger {
        uuid id PK
        varchar payment_ref
        uuid pro_id FK
        numeric amount
        varchar kind
        timestamptz created_at
    }
    notifications {
        uuid id PK
        uuid user_id FK
        varchar type
        varchar title_key
        varchar body_key
        jsonb params
        varchar target_route
        timestamptz read_at
        timestamptz created_at
    }
    jobs {
        uuid id PK
        uuid request_id FK
        uuid offer_id FK,UK
        uuid customer_id FK
        uuid pro_id FK
        varchar status
        varchar status_before_dispute
        timestamptz scheduled_from
        timestamptz scheduled_to
        timestamptz arrived_at
        timestamptz started_at
        timestamptz finished_at
        timestamptz completed_at
        timestamptz cancelled_at
        varchar cancelled_by
        varchar cancel_reason
        timestamptz auto_complete_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar cancel_note
        timestamptz auto_complete_reminded_at
    }
    offers {
        uuid id PK
        varchar public_code UK
        uuid request_id FK
        uuid pro_id FK
        numeric labor_amount
        numeric materials_amount
        numeric total_amount
        timestamptz arrival_from
        timestamptz arrival_to
        int warranty_months
        varchar note
        varchar status
        timestamptz valid_until
        varchar decline_reason
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar decline_note
        varchar idempotency_key
    }
    service_requests {
        uuid id PK
        varchar public_code UK
        uuid customer_id FK
        varchar category_id FK
        varchar urgency
        timestamptz preferred_from
        timestamptz preferred_to
        varchar title
        text description
        int district_id FK
        varchar neighborhood
        uuid address_id FK
        varchar status
        int matched_pro_count
        timestamptz expires_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
        varchar cancel_reason
        varchar cancel_note
    }
    users {
        uuid id PK
        varchar full_name
        varchar email
        varchar phone UK
        varchar password_hash
        varchar locale
        varchar status
        varchar last_mode
        boolean is_admin
        timestamptz kvkk_accepted_at
        timestamptz terms_accepted_at
        timestamptz deleted_at
        timestamptz created_at
        timestamptz updated_at
    }
    pro_profiles {
        uuid user_id PK,FK
        varchar business_name
        text bio
        int experience_years
        varchar review_status
        text review_note
        varchar availability
        numeric rating_avg
        int rating_count
        int completed_jobs
        int cancellation_count
        int warning_count
        timestamptz approved_at
        timestamptz created_at
        timestamptz updated_at
        bigint version
    }
    users ||--o{ pro_profiles : "user_id"
    service_requests ||--o{ escrow_payment : "request_id"
    users ||--o{ service_requests : "customer_id"
    users ||--o{ escrow_payment : "customer_id"
    users ||--o{ escrow_payment : "pro_id"
    service_requests ||--o{ offers : "request_id"
    pro_profiles ||--o{ offers : "pro_id"
    service_requests ||--o{ jobs : "request_id"
    offers ||--o{ jobs : "offer_id"
    users ||--o{ jobs : "customer_id"
    pro_profiles ||--o{ jobs : "pro_id"
    jobs ||--o{ escrow_payment : "job_id"
    pro_profiles ||--o{ payout_ledger : "pro_id"
    users ||--o{ notifications : "user_id"
```

### 5.6 Kısmi benzersiz indeksler ve CHECK kısıtları (önemli olanlar)

Bu kurallar iş kuralını **veritabanı düzeyinde** de zorunlu kılar.

| Kural | Mekanizma |
|---|---|
| Bir usta aynı talebe tek `PENDING` teklif verir | `ux_offers_one_pending_per_pro (request_id, pro_id) WHERE status='PENDING'` |
| Aynı `Idempotency-Key` tek teklif üretir | `ux_offers_idempotency (pro_id, idempotency_key)` |
| Bir talepte tek aktif iş | `ux_jobs_one_active_per_request (request_id) WHERE status <> 'CANCELLED'` |
| Bir teklif en çok bir işe dönüşür | `jobs.offer_id UNIQUE` |
| Talep başına aynı anda tek `INITIALIZED` ödeme | `ux_escrow_one_initialized_per_request` |
| Bir işin tek emaneti | `ux_escrow_job (job_id) WHERE job_id IS NOT NULL` |
| Aynı ödeme denemesi iki kez başlamaz | `escrow_payment.attempt_key UNIQUE` |
| Bir işte en çok bir açık şikayet | `ux_complaints_one_open_per_job WHERE status IN ('OPEN','IN_REVIEW')` |
| Bir işte en çok bir bekleyen randevu önerisi | `ux_appointment_one_pending` |
| Bir iş için tek puan | `reviews.job_id UNIQUE` |
| Bir medya dosyası en çok bir kayda bağlanır | `ux_request_photos_media`, `ux_pro_documents_media`, `ux_job_events_media`, `ux_messages_media`, `ux_complaint_evidence_media` |
| Kullanıcı başına tek varsayılan adres | `ux_addresses_one_default` |
| E-posta büyük/küçük harf duyarsız benzersiz | `ux_users_email_lower (lower(email))` |
| Talep en çok 5 fotoğraf | `request_photos.sort_order BETWEEN 0 AND 4` |
| Fotoğraf ≤ 1,5 MB, belge ≤ 5 MB | `media.size_bytes` CHECK |
| Teklif tutarı = emek + malzeme, her ikisi pozitif | `offers` CHECK |
| Durum alanları geçerli değerlerle sınırlı | Tüm `status`, `kind`, `purpose` sütunlarında CHECK |

---

## 6. Dinamik modeller (sıra diyagramları)

### 6.1 Kayıt / giriş ve token yenileme

```mermaid
sequenceDiagram
    autonumber
    actor K as Kullanıcı
    participant APP as Mobil uygulama (bitadilat_api)
    participant API as Spring Boot (AuthService)
    participant DB as PostgreSQL

    K->>APP: Ad, e-posta, telefon, şifre, KVKK ve koşul onayı
    APP->>API: POST /api/v1/auth/register
    API->>API: Doğrula (şifre ≥ 8, harf ve rakam), telefonu E.164 yap
    API->>DB: users ekle (BCrypt hash, kvkk_accepted_at)
    API->>DB: refresh_tokens ekle (SHA-256 hash, yeni family_id)
    API-->>APP: 201 accessToken (JWT 15 dk), refreshToken (30 gün), me
    APP->>APP: Token'ları Keychain'e yaz (flutter_secure_storage)

    Note over K,DB: Giriş
    K->>APP: E-posta ya da telefon + şifre
    APP->>API: POST /api/v1/auth/login
    API->>DB: login_attempts: son 15 dk başarısız sayısı
    alt 5 veya daha fazla başarısız
        API-->>APP: 429 TOO_MANY_ATTEMPTS
    else yanlış şifre
        API->>DB: başarısız deneme kaydı
        API-->>APP: 401 BAD_CREDENTIALS (hesap var mı belli olmaz)
    else askıya alınmış hesap
        API-->>APP: 401 ACCOUNT_SUSPENDED
    else doğru
        API->>DB: sayaç temizle, yeni oturum ailesi
        API-->>APP: 200 accessToken, refreshToken, me
    end

    Note over K,DB: Token yenileme (access token süresi dolunca)
    APP->>API: GET /api/v1/... (Bearer eski token)
    API-->>APP: 401 TOKEN_EXPIRED
    APP->>API: POST /api/v1/auth/refresh (refreshToken)
    API->>DB: token_hash ile ara
    alt token iptal edilmiş (yeniden kullanım)
        API->>DB: tüm aileyi iptal et
        API-->>APP: 401 (yeniden giriş gerekir)
    else geçerli
        API->>DB: eski satırı iptal et (replaced_by), yeni satır ekle
        API-->>APP: 200 yeni accessToken + yeni refreshToken
        APP->>API: İlk isteği yeni token ile yinele
    end
```

### 6.2 Talep → teklif → 3DS ödeme → iş

```mermaid
sequenceDiagram
    autonumber
    actor M as Müşteri
    actor U as Usta
    participant APP as Mobil uygulama
    participant API as Spring Boot
    participant DB as PostgreSQL
    participant CG as Craftgate sandbox
    participant BANK as Banka 3DS sayfası (WebView)

    M->>APP: Talep sihirbazı (kategori, adres, açıklama, fotoğraf)
    APP->>API: POST /api/v1/requests
    API->>DB: service_requests (OPEN), eşleşen usta sayısı
    API-->>APP: 201 talep (matchedProCount)

    U->>APP: Akış
    APP->>API: GET /api/v1/pro/feed
    API-->>APP: Kategori + ilçe + müsaitlik eşleşen açık talepler (adres maskeli)
    U->>APP: Teklif formu (emek, malzeme, varış, garanti)
    APP->>API: POST /api/v1/pro/requests/{id}/offers (Idempotency-Key)
    API->>DB: offers PENDING, offer_items
    API->>DB: bildirim: müşteriye "teklif geldi"
    API-->>APP: 201 teklif

    M->>APP: Teklifleri karşılaştır, "Kabul et ve öde", kart bilgisi
    APP->>API: POST /api/v1/payments/3ds/init (offerId, attemptKey, kart)
    API->>API: Kart doğrula (Luhn, tarih). Tutarı sunucudaki tekliften al
    API->>DB: escrow_payment INITIALIZED (yalnız son 4 hane saklanır)
    API->>CG: init3ds (tutar, conversationId, callbackUrl)
    CG-->>API: paymentId, htmlContent
    API-->>APP: 200 ref, htmlContent
    APP->>BANK: WebView htmlContent yükle
    BANK->>CG: Müşteri 3DS doğrulamasını tamamlar
    CG->>API: POST /api/payments/3ds/callback (form)
    API->>API: İmza doğrula (callback anahtarı varsa)
    API->>DB: ödeme satırını kilitle (FOR UPDATE)
    API->>CG: complete3ds / retrieve (gerçek durumu Craftgate'ten oku)
    alt SUCCESS ve tutar eşleşir
        API->>DB: escrow LOCKED
        API->>DB: aynı işlemde teklif ACCEPTED, diğer teklifler SUPERSEDED, talep ASSIGNED, iş AWAITING_APPOINTMENT
        API->>DB: bildirimler (usta ve kaybeden ustalar)
    else talep bu arada başka ödemeyle atanmış
        API->>CG: tam iade
        API->>DB: escrow LOCKED sonra REFUNDED_TO_CUSTOMER (REQUEST_ALREADY_ASSIGNED)
    else banka reddi
        API->>DB: escrow FAILED, talep serbest
    end
    API-->>BANK: 302 /api/payments/3ds/done (sayfa veri göstermez)
    APP->>APP: Bitiş adresi yakalanır, WebView kapanır
    loop en çok 30 sn
        APP->>API: GET /api/v1/payments/{ref}
        API-->>APP: INITIALIZED veya LOCKED veya FAILED
    end
    APP-->>M: Sonuç ekranı, iş ekranına geçiş
```

Notlar: ödeme kaydı banka çağrısı sürerken işlemsiz kaydedilir; talepte ikinci `INITIALIZED` kayıt `409 PAYMENT_IN_PROGRESS` verir. Callback gelmezse `PaymentSweeper` 30 dakikadan eski kayıtları Craftgate'e sorarak kapatır (`PaymentSweeperTest`).

### 6.3 İş durum akışı ve 48 saat otomatik tamamlama

```mermaid
sequenceDiagram
    autonumber
    actor M as Müşteri
    actor U as Usta
    participant API as Spring Boot (JobController, JobStateMachine)
    participant DB as PostgreSQL
    participant SCH as JobScheduler (5 dk)
    participant ESC as EscrowService
    participant CG as Craftgate

    Note over M,U: İş AWAITING_APPOINTMENT ile açılır, emanet LOCKED
    M->>API: POST /jobs/{id}/appointment/proposals (aralık)
    U->>API: POST /jobs/{id}/appointment/proposals/{pid}/accept
    API->>DB: iş SCHEDULED, olay kaydı
    U->>API: POST /jobs/{id}/arrived
    API->>DB: iş ARRIVED
    U->>API: POST /jobs/{id}/start
    API->>DB: iş IN_PROGRESS
    U->>API: POST /jobs/{id}/finish
    API->>DB: iş WORK_FINISHED, auto_complete_at = şimdi + 48 saat
    API->>DB: bildirim: müşteriye "iş bitti, onayla"

    alt Müşteri onaylar
        M->>API: POST /jobs/{id}/confirm
        API->>DB: işi kilitle, geçişi doğrula (CONFIRM)
        API->>ESC: release(emanet)
        ESC->>DB: RELEASED_TO_PRO, payout_ledger PAYOUT + COMMISSION (%10)
        API->>DB: iş COMPLETED, usta completed_jobs + 1
        API->>DB: bildirim: ustaya "ödeme serbest"
    else Müşteri sessiz kalır
        SCH->>DB: 24. saatte hatırlatma (bir kez)
        SCH->>DB: auto_complete_at geçmiş, açık şikayet yok, WORK_FINISHED işleri seç (SKIP LOCKED)
        SCH->>API: aynı JobSettlement.complete (rol SYSTEM)
        API->>ESC: release(emanet)
        ESC->>DB: RELEASED_TO_PRO, defter
        API->>DB: iş COMPLETED
    else Müşteri şikayet açar
        M->>API: POST /jobs/{id}/complaint
        API->>DB: iş DISPUTED, emanet DISPUTED, şikayet OPEN
        Note over SCH: Zamanlayıcı DISPUTED işe dokunmaz
    end
    M->>API: POST /jobs/{id}/review (yalnız COMPLETED)
    API->>DB: reviews ekle, usta puan ortalaması güncelle
```

Not: otomatik tamamlama ve müşteri onayı aynı geçiştir (`Trigger.CONFIRM`) ve yarışırsa emanet iki kez serbest bırakılmaz (`confirmOrComplaintRacingTheSchedulerNeverReleasesTwice`). Bu iki yolda Craftgate'e danışılmaz; çünkü para zaten emanette tutulmuştur ve serbest bırakma yalnızca defter kaydıdır (usta ödemesi bankaya gönderilmez).

### 6.4 Şikayet → yönetici kararı

```mermaid
sequenceDiagram
    autonumber
    actor M as Müşteri
    actor A as Yönetici
    participant APP as Mobil / Admin Web
    participant API as Spring Boot (AdminComplaintService)
    participant DB as PostgreSQL
    participant ESC as EscrowService
    participant CG as Craftgate

    M->>APP: Şikayet formu (neden, açıklama ≥ 20 karakter, ≤ 5 fotoğraf)
    APP->>API: POST /api/v1/jobs/{id}/complaint
    API->>DB: complaints OPEN, iş DISPUTED, emanet DISPUTED (tek işlem)
    API->>DB: bildirim: ustaya ve yöneticilere

    A->>APP: Şikayet kuyruğu, ayrıntı (zaman çizelgesi, sohbet, ödeme, kanıt)
    APP->>API: GET /api/v1/admin/complaints/{id}
    A->>APP: "İncelemeye al"
    APP->>API: POST /api/v1/admin/complaints/{id}/review
    API->>DB: OPEN, IN_REVIEW, admin_actions kaydı

    A->>APP: Karar (gerekçe ≥ 10 karakter, isteğe bağlı uyarı ve askıya alma)
    APP->>API: POST /api/v1/admin/complaints/{id}/decision
    API->>DB: işi ve şikayeti kilitle, DISPUTED mi diye doğrula
    alt FULL_REFUND (tam iade)
        API->>DB: iş CANCELLED, talep CANCELLED
        API->>ESC: refundFully
        ESC->>CG: iade durumunu sor sonra kalan tutarı iade et
        ESC->>DB: REFUNDED_TO_CUSTOMER, defter REFUND, komisyon yok
    else SPLIT_50_50 (bölüşüm)
        API->>DB: iş RESOLVED
        API->>ESC: settleSplit
        ESC->>CG: yarı tutarı iade et (daha önce iade edilmişse tekrar gönderme)
        ESC->>DB: SPLIT_SETTLED, müşteriye yarı, ustaya yarı, komisyon yok
    else RELEASE_TO_PRO (ustaya aktar, şikayet reddedilir)
        API->>DB: iş COMPLETED, şikayet DISMISSED
        API->>ESC: releaseAfterDispute
        ESC->>DB: RELEASED_TO_PRO, %10 komisyon, iade yok
    end
    opt uyarı veya askıya alma seçili
        API->>DB: warning_count + 1 veya usta SUSPENDED, bekleyen teklifler WITHDRAWN
    end
    API->>DB: bildirim: iki tarafa gerçek tutarlarla
    alt Craftgate hatası
        CG-->>API: hata
        API-->>APP: 502 GATEWAY_ERROR, tüm işlem geri alınır
    else
        API-->>APP: 200
    end
```

Para hareketi işlemin **en sonunda** yapılır; ağ geçidi hatasında emanet, iş ve şikayet değişmez, karar yeniden denenebilir (`gatewayFailureReturns502AndChangesNothingThenRetrySucceeds`). Craftgate'te zaman aşımına uğramış ama gerçekleşmiş bir iade ikinci kez gönderilmez (STATE_MACHINES.md bölüm 5).

---

## 7. Durum makineleri

Kaynak: `docs/spec/STATE_MACHINES.md` ve kod (`JobStateMachine`, `EscrowPayment`, `*Status` enum'ları). Geçersiz geçiş `409 ILLEGAL_STATE` döner.

### 7.1 Hesap

```mermaid
stateDiagram-v2
    [*] --> ACTIVE : kayıt
    ACTIVE --> SUSPENDED : yönetici askıya alır
    SUSPENDED --> ACTIVE : yönetici açar
    ACTIVE --> DELETED : kullanıcı siler (açık iş veya kilitli emanet yoksa)
    DELETED --> [*]
```

### 7.2 Usta profili (`review_status`)

```mermaid
stateDiagram-v2
    [*] --> PENDING_REVIEW : başvuru
    PENDING_REVIEW --> APPROVED : yönetici onaylar
    PENDING_REVIEW --> NEEDS_DOCUMENTS : belge istenir
    PENDING_REVIEW --> REJECTED : reddedilir
    NEEDS_DOCUMENTS --> PENDING_REVIEW : yeniden gönderim
    REJECTED --> PENDING_REVIEW : yeniden başvuru
    APPROVED --> SUSPENDED : askı (yönetici veya şikayet kararı)
    SUSPENDED --> APPROVED : yönetici açar
```

`REJECTED → PENDING_REVIEW` geçişi `STATE_MACHINES.md` içinde yazılı değildir, ancak kod buna izin verir (`ProService.submit`: yalnızca `NEEDS_DOCUMENTS` ve `REJECTED` yeniden başvurabilir) ve `ProFlowTest` içinde sınanır. Spec'e eklenmesi gerekir.

### 7.3 Talep

```mermaid
stateDiagram-v2
    [*] --> OPEN : talep yayımlanır
    OPEN --> ASSIGNED : ödeme LOCKED, teklif kabul
    OPEN --> CANCELLED : müşteri iptal
    OPEN --> EXPIRED : 7 gün kabul yok
    ASSIGNED --> OPEN : usta işi iptal eder
    ASSIGNED --> CANCELLED : müşteri iptali veya tam iade kararı
```

### 7.4 Teklif

```mermaid
stateDiagram-v2
    [*] --> PENDING : usta teklif verir
    PENDING --> ACCEPTED : ödeme LOCKED
    PENDING --> SUPERSEDED : başka teklif kabul edildi
    PENDING --> DECLINED : müşteri reddetti
    PENDING --> WITHDRAWN : usta geri çekti veya askıya alındı
    PENDING --> EXPIRED : süre doldu, talep düzenlendi veya kapandı
    SUPERSEDED --> PENDING : usta işi iptal etti, süre geçmediyse
    ACCEPTED --> WITHDRAWN : usta işi başlamadan iptal etti
```

### 7.5 İş

```mermaid
stateDiagram-v2
    [*] --> AWAITING_APPOINTMENT : ödeme LOCKED
    AWAITING_APPOINTMENT --> SCHEDULED : randevu kabul
    AWAITING_APPOINTMENT --> CANCELLED : iptal
    SCHEDULED --> ARRIVED : usta adrese ulaştı
    SCHEDULED --> CANCELLED : iptal
    SCHEDULED --> DISPUTED : şikayet
    ARRIVED --> IN_PROGRESS : başladı
    ARRIVED --> CANCELLED : iptal
    ARRIVED --> DISPUTED : şikayet
    IN_PROGRESS --> WORK_FINISHED : bitirdi
    IN_PROGRESS --> DISPUTED : şikayet
    WORK_FINISHED --> COMPLETED : müşteri onayı veya 48 saat
    WORK_FINISHED --> DISPUTED : şikayet
    DISPUTED --> COMPLETED : ustaya aktar
    DISPUTED --> CANCELLED : tam iade
    DISPUTED --> RESOLVED : %50 / %50
    COMPLETED --> [*]
    CANCELLED --> [*]
    RESOLVED --> [*]
```

### 7.6 Şikayet

```mermaid
stateDiagram-v2
    [*] --> OPEN : müşteri açar
    OPEN --> IN_REVIEW : yönetici inceleme
    IN_REVIEW --> RESOLVED : tam iade veya %50/%50
    IN_REVIEW --> DISMISSED : ustaya aktar
    OPEN --> RESOLVED : doğrudan karar
    OPEN --> DISMISSED : doğrudan karar
```

Kodda `decide` hem `OPEN` hem `IN_REVIEW` durumundan karar kabul eder; `RELEASE_TO_PRO` kararı şikayeti `DISMISSED`, diğerleri `RESOLVED` yapar (`AdminComplaintService`).

### 7.7 Emanet (`escrow_payment.status`)

```mermaid
stateDiagram-v2
    [*] --> INITIALIZED : 3DS başlatıldı
    INITIALIZED --> LOCKED : banka onayı, doğrulanmış tutar
    INITIALIZED --> FAILED : red, 3DS terk, süpürücü
    LOCKED --> DISPUTED : şikayet
    LOCKED --> RELEASED_TO_PRO : onay veya 48 saat
    LOCKED --> REFUNDED_TO_CUSTOMER : iptal, yarış iadesi
    DISPUTED --> RELEASED_TO_PRO : ustaya aktar (%10 komisyon)
    DISPUTED --> REFUNDED_TO_CUSTOMER : tam iade
    DISPUTED --> SPLIT_SETTLED : %50 / %50
    RELEASED_TO_PRO --> [*]
    REFUNDED_TO_CUSTOMER --> [*]
    SPLIT_SETTLED --> [*]
    FAILED --> [*]
```

Randevu önerisi (`appointment_proposals.status`): `PENDING → ACCEPTED | SUPERSEDED | REJECTED`; bir işte tek `PENDING` olabilir.

---

## 8. Erişim ve yetki matrisi

| Kaynak / işlem | Anonim | Müşteri | Usta (onaylı) | Yönetici |
|---|---|---|---|---|
| Kayıt, giriş, şifre sıfırlama | Evet | — | — | — |
| Kategori ve ilçe listesi | Evet | Evet | Evet | Evet |
| Talep oluştur / düzenle / iptal | — | Yalnız kendi talebi | — | — |
| Talep ayrıntısı | — | Kendi talebi (tam adres) | Eşleşen talep, **adres maskeli** (ilçe ve mahalle) | — |
| Teklif ver / geri çek | — | — | Yalnız kendi teklifi | — |
| Teklifleri gör | — | Kendi talebine gelenler | Yalnız kendi teklifi (hizmet bedeli ve net kazanç yalnız ona görünür) | — |
| Ödeme başlat / sonuç | — | Yalnız kendi teklifi için | Atanmış usta sonucu görür | Görür |
| İş ayrıntısı, tam adres | — | Katılımcı müşteri | Katılımcı usta (kabul sonrası) | — |
| Sohbet | — | Yalnız o işin tarafları | Yalnız o işin tarafları | — |
| Puan ver | — | Yalnız `COMPLETED` işte, bir kez | — | — |
| Şikayet aç | — | Kendi işi | — | — |
| Usta başvurusu | — | Başvurabilir | Kendi başvurusu | Karar verir |
| Şikayet kararı, hesap askı, ödeme listesi | — | — | — | Evet (`ROLE_ADMIN`) |

Zorlama: `SecurityConfig` (`/api/v1/admin/**` için `hasRole("ADMIN")`, diğer `/api/v1/**` için kimlik), servis katmanında sahiplik denetimi (başkasının kaydı `404`). Testler: `AdminApplicationTest.everyAdminEndpointRejectsNonAdminsWith403AndAnonymousWith401`, `RequestFlowTest.otherUsersGet404ForRequestAndNeverSeeFullAddress`, `ChatTest.nonParticipantGets404EverywhereAndBodyIsValidated`, `ProFlowTest.proRequestDetailIsMaskedAndLimitedToMatchingPros`.

### Sınır koşulları (boundary conditions)

| Durum | Davranış |
|---|---|
| Sunucu ödeme sırasında kapanır | Kayıt `INITIALIZED` kalır; `PaymentSweeper` 30 dk sonra Craftgate'e sorup kapatır |
| Callback hiç gelmez (WebView kapandı) | Aynı süpürücü; müşteri `FAILED` sonrası yeniden dener |
| Aynı talebe iki müşteri ödemesi yarışır | Biri işi açar, diğeri otomatik iade edilir (`REQUEST_ALREADY_ASSIGNED`) |
| İade başarısız | Emanet `LOCKED` kalır, süpürücü artan aralıkla en çok 8 kez dener, sonra `REFUND_NEEDS_REVIEW` (elle inceleme) |
| Craftgate erişilemez | Başlatmada `502 GATEWAY_ERROR`; karar/iptalde işlem geri alınır |
| Aynı kullanıcı çok kez yanlış şifre girer | 15 dk içinde 5 başarısızdan sonra `429` |
| Eşzamanlı güncelleme | Sürüm sütunu (`version`) ile iyimser kilit; çakışma `409 ILLEGAL_STATE` |
| Yükleme kotası | 24 saatte 60 yükleme sonrası `429` |

---

## 9. Güvenlik tasarımı

**Kimlik doğrulama**

- Erişim token'ı: JWT, HS256, 15 dakika, issuer doğrulanır, sır en az 32 bayt (`JWT_SECRET`). `alg=none` ve başka sırla imzalı token reddedilir (`AuthHardeningTest`).
- Yenileme token'ı: opak rastgele değer, 30 gün. Veritabanında yalnızca SHA-256 özeti saklanır. **Döndürme (rotation):** her yenilemede eski satır iptal edilir, yenisi yazılır. **Yeniden kullanım tespiti:** iptal edilmiş token tekrar gelirse tüm aile (aynı oturum zinciri) iptal edilir. Aynı token ile eşzamanlı yenileme en çok bir oturum üretir (`parallelRefreshWithSameTokenYieldsAtMostOneSession`). Access token içindeki `family` claim'i, şifre değişince diğer oturumların kapanmasını sağlar.
- Şifre: BCrypt (Spring `BCryptPasswordEncoder`), en az 8 karakter, harf ve rakam, en çok 72 bayt.
- Kaba kuvvet koruması: hesap başına (e-posta ve telefon aynı sayaç) 15 dakikada 5 başarısız deneme. Hesap yoksa da sahte hash karşılaştırılır; yanıt hesap varlığını sızdırmaz. Şifre sıfırlama kodu: özet olarak saklanır, 15 dk geçerli, 5 yanlış denemede geçersiz, saatte en çok 5 kod.
- İstemci: mobilde token'lar iOS Keychain'de (`first_unlock_this_device`, iCloud eşitlemesi kapalı, `secure_token_store_test.dart`). Yönetim panelinde token yalnızca **bellekte** tutulur (`MemoryTokenStore`); sayfa yenilenince oturum biter.

**Yetkilendirme**

- Durumsuz (stateless) oturum, CSRF kapalı (çerez kullanılmaz), CORS yalnızca yapılandırılan kaynaklara. Banka callback yolları CORS dışıdır (üst düzey form POST).
- Rol: `users.is_admin` → `ROLE_ADMIN`. Müşteri ve usta ayrımı kaynak sahipliği ve `pro_profiles.review_status = APPROVED` ile sağlanır.
- Hata gövdeleri ayrıntı sızdırmaz (`server.error.include-message=never`, stack trace kapalı).

**Veri koruma**

- **Adres şifreleme:** `addresses.line_full_encrypted` ve `door_note_encrypted` AES-256-GCM ile şifrelenir. Çıktı `base64(iv[12] | şifreli metin | etiket[16])`; her şifrelemede rastgele IV, aynı metin farklı çıktı verir. **AAD** olarak kullanıcı kimliği bağlanır; başka satıra kopyalanan değer çözülmez. Anahtar `ADDRESS_KEY` ortam değişkenidir (veritabanında yok). Mahalle ve ilçe şifrelenmez (eşleştirme için gerekli). Tam adres yalnızca kabul sonrası, işin tarafları için döner. Testler: `AccountTest.addressIsEncryptedAtRestAndReadableThroughApi`, `sameTextEncryptsDifferentlyEachTime`, `CommonRulesTest.aesGcmRoundTripBindsToAad`.
- **İmzalı medya URL'leri:** medya içeriği `GET /api/v1/media/{id}/content?exp=...&sig=...` ile sunulur; imza `HMAC-SHA256(MEDIA_SIGNING_KEY, "id.exp")`, geçerlilik 10 dakika. İmza yalnızca erişim denetiminden geçen çağırana üretilir (`signaturesAreOnlyIssuedAfterAccessChecks`). Dosya türü uzantıya göre değil **sihirli baytlarla** doğrulanır (`typeIsCheckedByMagicBytesNotByNameOrPurpose`); PDF `attachment` olarak sunulur.
- **Kart verisi:** kart numarası ve CVC saklanmaz, loglanmaz, yanıtta dönmez; yalnızca son 4 hane kaydedilir (`cardDataIsNeverLoggedOrReturned`). `CardDetails.toString()` gizlidir. Ödeme tutarı her zaman sunucudaki tekliften alınır; istemcinin gönderdiği tutar yok sayılır. Callback sonucu istemci parametrelerine değil Craftgate sorgusuna göre karara bağlanır (`forgedSuccessIsDecidedByCraftgateNotByParams`). **Not:** callback imza doğrulaması yalnızca `craftgate.callback-key` doluysa yapılır; boşsa doğrulama atlanır ve güvenlik Craftgate sorgusuna dayanır.
- **Hesap silme:** kişisel veriler anonimleştirilir; finansal kayıtlar yasal süre boyunca kalır. Açık işi ya da kilitli emaneti olan hesap silinemez.
- **Denetim izi:** yönetici eylemleri `admin_actions` tablosuna yazılır.

**KVKK notları (6698)**

| Konu | Durum |
|---|---|
| Açık rıza ve aydınlatma | Kayıtta KVKK ve koşul onay kutusu zorunlu; `kvkk_accepted_at`, `terms_accepted_at` saklanır. Hukuki metinler yer tutucudur, hukuk incelemesi yapılmadı |
| Silme hakkı | Hesap silme (anonimleştirme) var |
| Veri minimizasyonu | Adres şifreli, usta telefon/e-posta herkese açık profilde yok, müşteri telefonu ustaya gösterilmez |
| Saklama süresi politikası | **Yok** (tanımlı değil) |
| Veri taşınabilirliği / dışa aktarım | **Yok** |
| Aktarım güvenliği | HTTPS dağıtımda gereklidir; yerel geliştirmede HTTP (yalnız Debug, ATS istisnası `platform_config_test.dart`) |
| Üçüncü taraf | Craftgate yalnızca ödeme için; kart verisi BiTadilat'ta tutulmaz |

---

## 10. Arayüz ve erişilebilirlik tasarımı

- Dokunma hedefi en az **48 dp** (`AppSizes.minTouch`, `components_test.dart`); metin kontrastı WCAG 2.1 AA (≥ 4.5:1, `contrast_test.dart`). Tasarım belgelerinde geçen "44 pt" eskidir.
- TR/EN canlı geçiş: `gen-l10n`; hem mobil hem admin. Tüm hata kodları için iki dilde mesaj vardır (`auth_screens_test.dart: her ApiErrorCode için TR ve EN mesaj var`).
- Geri döndürülemez eylemlerde onay: teklif kabulü (ayrı onay ekranı, ardından ödeme), iptal, tamamlama onayı, şikayet, hesap silme, yönetici kararı (onay diyaloğu).
- 320 px genişlik ve 2x yazı ölçeğinde taşma testleri bileşen ve ekran düzeyinde vardır.

---

## 11. RAD'dan sapmalar

Aşağıdaki değişiklikler proje sahibinin kararıdır. RAD metni **güncellenmemiştir**; `docs/PAYMENT_RAD_CHANGE_NOTE.md` ödeme değişikliği için ekip ve danışman onayını bekler.

| # | RAD'da | Yapılan | Gerekçe / kanıt |
|---|---|---|---|
| 1 | Ödeme kapsam dışı (RAD 1.2) | Craftgate **sandbox** 3DS ödeme + backend **emanet defteri**, %10 komisyon; usta ödemesi yalnızca kaydedilir | `PAYMENT_RAD_CHANGE_NOTE.md`; UC05, UC09, UC11, UC13 etkilenir |
| 2 | Telefon + SMS kodu ile giriş (SCR-01) | **E-posta veya telefon + şifre**; kayıtta KVKK onayı, e-posta kodu ile şifre sıfırlama, hesap silme, tek hesapta müşteri/usta modu | SMS sağlayıcısı yok; telefon yalnızca tanımlayıcı |
| 3 | Backend sorumlusu takım üyesi | Backend **Spring Boot 4.1 / Java 21 / PostgreSQL 16 / Flyway** olarak yazıldı | Takım dalındaki NestJS iskeleti kullanılmıyor |
| 4 | "Web tabanlı yönetim paneli", çatı belirtilmemiş | **Flutter Web** (`apps/admin`), aynı depoda, ortak paketlerle | Tek dil ve ortak API istemcisi |
| 5 | Android APK ve iOS | **iOS öncelikli**; Android sonraya bırakıldı (iskelet var, sınanmadı) | Simulator ile uçtan uca sınanıyor |
| 6 | Karşılıklı tamamlama onayı; iş durumları `AGREED`…`COMPLETED` | Müşteri onayı **veya 48 saat sonra otomatik aktarım**; durum kümeleri tekleştirildi (`AWAITING_APPOINTMENT`…`RESOLVED`) | `STATE_MACHINES.md` bölüm 7 eşleme tablosu |
| 7 | Randevu: karşılıklı kabul | Usta onaylar ya da yeni aralık önerir | `JobFlowTest.appointmentProposalAcceptanceRescheduleAndCounterProposal` |
| 8 | İlerleme: genel durum | Adrese ulaştım → başladım → bitirdim | `JobStateMachine` |
| 9 | İptal: genel | Yalnızca iş başlamadan; sonrası şikayet; şikayet açıkken iptal/iade kapalı | `cancelIsRefusedFromInProgressOnward` |
| 10 | Şikayet hakemliği: genel | Tam iade, %50/%50 (komisyonsuz), ustaya aktar (%10 komisyon); uyarı ve askıya alma | `AdminComplaintTest` |
| 11 | Push bildirim (FCM/APNs) | **Uygulama içi bildirim merkezi** (19 tür); push yok | Apple geliştirici hesabı ve Firebase gerekir |
| 12 | Sohbet | Yoklama (3 sn), websocket yok; iş kapandıktan 30 gün sonra salt okunur | `chat_wave3_test.dart` |
| 13 | Dokunma hedefi 48 dp | 48 dp korundu (tasarım belgeleri 44 pt diyor) | `tokens.dart` |
| 14 | Docker ile paketli backend | **Yok** | Açık iş |
| 15 | Tanıtım sitesi (UC14) | **Yok** | Açık karar |
| 16 | RAD ekranları | Eklenenler: kazançlar, tekliflerim, bildirim merkezi, kayıtlı adresler, ödeme sonucu | `docs/spec/ROLE_SCREEN_MAP.md` |

Prototipe özgü ifadeler ("komisyonsuz", "%100 Garantili", garanti süreleri) uygulama metinlerinden çıkarılmalıdır; bu belge onları gerçekleştirilmiş davranış olarak saymaz.

---

## 12. Açık noktalar

- Tanıtım sitesi, push bildirim, Docker, Android derlemesi, gerçek e-posta/SMS ve KVKK saklama/dışa aktarım politikası gerçekleştirilmedi (bkz. 1 ve 9).
- Kullanılabilirlik (%80, 5 kullanıcı), süre hedefleri (3 dk / 90 sn), erişilebilirlik süresi (%99,5) ve gecikme (500 ms) ölçülmedi. Plan: `USABILITY_STUDY.md`, `TEST_PLAN.md`.
- `REJECTED → PENDING_REVIEW` (yeniden başvuru) geçişi kodda var, `STATE_MACHINES.md`'de yok; spec güncellenmelidir (7.2).
