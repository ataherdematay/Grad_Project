# BiTadilat Backend API Sözleşmesi & Veritabanı Mimarisi (v1.0.0)

> **Rol:** Senior Product Manager & Mobile Software Architect  
> **Hedef Kitle:** Backend & Veritabanı Geliştirme Ekibi, Mobil İstemci Geliştiricileri  
> **Durum:** Onaylandı & Kararlı (Production-Ready Spec)  
> **Protokol:** HTTPS REST API + WebSocket (Canlı Konum & Sohbet)  
> **Temel Veri Formatı:** JSON (`application/json; charset=utf-8`)

---

## 1. Mimari Prensipler ve Güvenlik (Core Principles)

1. **Çift Rol Ayrımı (Role-Based Access Control):**
   - Sistemde kullanıcılar `CUSTOMER` (Müşteri) veya `PRO` (Usta / Esnaf) rolüne sahiptir.
   - Tüm uç noktalar token içerisindeki `role` talebini (claim) zorunlu olarak denetler. Müşteri uç noktalarına usta, usta uç noktalarına müşteri erişemez.
2. **Güvenli Havuz (Escrow Protection) Modeli:**
   - Müşteri usta teklifini kabul ettiğinde tutar doğrudan ustaya **aktarılmaz**; platformun BDDK/TCMB lisanslı sanal POS havuz hesabında (Escrow) bloke edilir (`LOCKED`).
   - İş bitiminde müşteri onay kodu (PIN) veya dijital tamamlama onayı verdiğinde bakiye platform hizmet komisyonu (%10) kesilerek ustaya serbest bırakılır (`RELEASED`).
3. **Gizlilik ve Doğrudan İletişim Yasağı:**
   - İki taraf arasında teklif kabul edilip havuz ödemesi kilitlenmeden telefon numarası veya tam sokak/bina adresi kesinlikle paylaşılmaz. İletişim BiTadilat Maskeli Mesajlaşma üzerinden yürütülür.
4. **Zaman Dilimi ve Para Birimi:**
   - Tüm tarihler **ISO 8601** formatında UTC (`YYYY-MM-DDTHH:mm:ssZ`) saklanır.
   - Para birimi **TRY (₺)** cinsindendir ve kuruş hassasiyeti için tamsayı (integer / `kurus`) veya `NUMERIC(10, 2)` olarak modellenir.

---

## 2. İlişkisel Veritabanı Şeması (PostgreSQL Schema)

```sql
-- 1. KULLANICILAR VE YETKİLENDİRME
CREATE TYPE user_role AS ENUM ('CUSTOMER', 'PRO', 'ADMIN');
CREATE TYPE verification_status AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(15) UNIQUE NOT NULL, -- Format: +905XXXXXXXXX
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role user_role NOT NULL DEFAULT 'CUSTOMER',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. USTA PROFİLİ VE DOĞRULAMA (SADECE 'PRO' İÇİN)
CREATE TABLE pro_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(120), -- Örn: Mavi Hat Su Tesisatı
    primary_category_id VARCHAR(50) NOT NULL,
    experience_years INT DEFAULT 1,
    identity_verified BOOLEAN DEFAULT FALSE,
    tax_verified BOOLEAN DEFAULT FALSE,
    criminal_record_verified BOOLEAN DEFAULT FALSE,
    rating_avg NUMERIC(3, 2) DEFAULT 5.00,
    total_reviews_count INT DEFAULT 0,
    completed_jobs_count INT DEFAULT 0,
    available_status BOOLEAN DEFAULT TRUE,
    current_lat NUMERIC(10, 7),
    current_lng NUMERIC(10, 7),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. HİZMET KATEGORİLERİ
CREATE TABLE service_categories (
    id VARCHAR(50) PRIMARY KEY, -- 'plumbing', 'electrical', 'paint', 'cleaning', 'carpentry', 'ac_service'
    name_tr VARCHAR(100) NOT NULL,
    icon_name VARCHAR(50) NOT NULL,
    color_hex VARCHAR(10) NOT NULL,
    base_inspection_fee NUMERIC(10, 2) DEFAULT 250.00,
    is_active BOOLEAN DEFAULT TRUE
);

-- 4. TALEP / İŞ İLANLARI (JOB REQUESTS)
CREATE TYPE job_status AS ENUM (
    'DRAFT',            -- Taslak form
    'PENDING_OFFERS',   -- Teklif toplanıyor (Ustalara açık)
    'ESCROW_PENDING',   -- Teklif seçildi, ödeme bekleniyor
    'SCHEDULED',        -- Ödeme havuzda kilitlendi, randevu tarihi bekleniyor
    'PRO_EN_ROUTE',     -- Usta yola çıktı
    'IN_PROGRESS',      -- Usta adreste, çalışma başladı
    'COMPLETED',        -- İş bitti, müşteri onayı bekleniyor
    'RELEASED',         -- Escrow ustaya aktarıldı, puanlama yapıldı
    'DISPUTED',         -- İhtilaf / İade talebi
    'CANCELLED'         -- İptal edildi
);

CREATE TYPE urgency_level AS ENUM ('EMERGENCY_TODAY', 'THIS_WEEK', 'FLEXIBLE');

CREATE TABLE job_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES users(id) ON DELETE RESTRICT,
    category_id VARCHAR(50) REFERENCES service_categories(id),
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    urgency urgency_level NOT NULL DEFAULT 'THIS_WEEK',
    preferred_date DATE NOT NULL,
    preferred_time_slot VARCHAR(50) NOT NULL, -- Örn: '14:00 - 17:00'
    city VARCHAR(50) NOT NULL DEFAULT 'İstanbul',
    district VARCHAR(50) NOT NULL, -- Örn: 'Kadıköy'
    neighborhood VARCHAR(100) NOT NULL, -- Örn: 'Moda'
    address_line_masked TEXT, -- Mahalle ve cadde
    address_full_encrypted TEXT, -- Sadece teklif onaylanıp havuz açılınca ustaya görünür
    geo_lat NUMERIC(10, 7),
    geo_lng NUMERIC(10, 7),
    photo_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    status job_status NOT NULL DEFAULT 'PENDING_OFFERS',
    selected_offer_id UUID,
    completion_pin VARCHAR(6), -- Müşterinin ustaya vereceği 6 haneli doğrulama PIN'i
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. USTA TEKLİFLERİ (OFFERS)
CREATE TYPE offer_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED');

CREATE TABLE offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES job_requests(id) ON DELETE CASCADE,
    pro_id UUID REFERENCES pro_profiles(id) ON DELETE CASCADE,
    labor_amount NUMERIC(10, 2) NOT NULL,
    materials_amount NUMERIC(10, 2) DEFAULT 0.00,
    total_amount NUMERIC(10, 2) NOT NULL,
    warranty_months INT DEFAULT 12,
    estimated_arrival_minutes INT DEFAULT 45,
    note TEXT,
    status offer_status NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. GÜVENLİ HAVUZ / ÖDEME İŞLEMLERİ (ESCROW TRANSACTIONS)
CREATE TYPE escrow_status AS ENUM ('INITIALIZED', 'LOCKED', 'RELEASED_TO_PRO', 'REFUNDED_TO_CUSTOMER', 'DISPUTED');

CREATE TABLE escrow_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID UNIQUE REFERENCES job_requests(id),
    customer_id UUID REFERENCES users(id),
    pro_id UUID REFERENCES pro_profiles(id),
    total_amount NUMERIC(10, 2) NOT NULL,
    platform_commission NUMERIC(10, 2) NOT NULL, -- %10
    pro_payout_amount NUMERIC(10, 2) NOT NULL,   -- %90
    status escrow_status NOT NULL DEFAULT 'INITIALIZED',
    payment_provider_ref VARCHAR(100), -- Sanal POS Referansı (Iyzico / Stripe)
    locked_at TIMESTAMP WITH TIME ZONE,
    released_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE
);

-- 7. MESAJLAŞMA (IN-APP CHAT)
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES job_requests(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id),
    message_text TEXT NOT NULL,
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. DEĞERLENDİRME VE PUANLAMA (REVIEWS)
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID UNIQUE REFERENCES job_requests(id),
    customer_id UUID REFERENCES users(id),
    pro_id UUID REFERENCES pro_profiles(id),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 3. RESTful API Uç Noktaları (Endpoints Specification)

### 3.1. Yetkilendirme (Auth Module)

#### `POST /api/v1/auth/send-otp`
Kullanıcı cep telefonuna SMS ile tek kullanımlık 6 haneli kod gönderir.
- **Request Body:**
```json
{
  "phoneNumber": "+905321234567"
}
```
- **Response 200 OK:**
```json
{
  "success": true,
  "message": "Doğrulama kodu SMS ile gönderildi.",
  "countdownSeconds": 60,
  "maskedPhone": "+90 532 *** ** 67"
}
```

#### `POST /api/v1/auth/verify-otp`
SMS kodunu doğrular, JWT Access/Refresh token çifti döner. Kullanıcı ilk kez geliyorsa `isNewUser: true` döner.
- **Request Body:**
```json
{
  "phoneNumber": "+905321234567",
  "code": "481920",
  "selectedRole": "CUSTOMER" // veya "PRO"
}
```
- **Response 200 OK:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "d8e3b1c2-9a8f-4b0e-9231-...",
  "isNewUser": false,
  "user": {
    "id": "u-101",
    "phoneNumber": "+905321234567",
    "firstName": "Ata",
    "lastName": "Atay",
    "role": "CUSTOMER",
    "avatarUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150"
  }
}
```

---

### 3.2. Hizmet Talebi & Sihirbaz (Job Requests Module)

#### `GET /api/v1/categories`
Aktif tüm hizmet kategorilerini ve taban ücretlerini döner.
- **Response 200 OK:**
```json
[
  {
    "id": "plumbing",
    "name": "Su & Sıhhi Tesisat",
    "icon": "water_drop",
    "color": "#0F4C5C",
    "description": "Su kaçağı tespiti, musluk tamiri, boru yenileme"
  },
  {
    "id": "electrical",
    "name": "Elektrik Tesisatı",
    "icon": "bolt",
    "color": "#E87525",
    "description": "Priz montajı, sigorta arızası, aydınlatma montajı"
  },
  {
    "id": "paint",
    "name": "Boya & Badana",
    "icon": "format_paint",
    "color": "#107A5B",
    "description": "İç cephe boyası, duvar alçı tamiri, tavan boyama"
  }
]
```

#### `POST /api/v1/jobs`
Müşterinin yeni iş ilanı oluşturmasını sağlar (Wizard tamamlandığında çağrılır).
- **Headers:** `Authorization: Bearer <TOKEN>`
- **Request Body:**
```json
{
  "categoryId": "plumbing",
  "title": "Banyo Bataryası Değişimi ve Su Kaçağı Tamiri",
  "description": "Mutfak tezgahı altındaki su borusundan hafif sızıntı var ve banyo bataryası damlatıyor.",
  "urgency": "THIS_WEEK",
  "preferredDate": "2026-10-25",
  "preferredTimeSlot": "14:00 - 17:00",
  "city": "İstanbul",
  "district": "Kadıköy",
  "neighborhood": "Caferağa Mah.",
  "addressLine": "Moda Cad. No:42 Daire:5",
  "photoUrls": [
    "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400"
  ]
}
```
- **Response 201 Created:**
```json
{
  "id": "job-84920",
  "status": "PENDING_OFFERS",
  "createdAt": "2026-10-22T19:50:00Z",
  "matchingProsCount": 8,
  "estimatedFirstOfferMinutes": 15
}
```

#### `GET /api/v1/jobs/{jobId}`
Belirli bir talebin tüm detaylarını, tekliflerini ve aktif durumunu getirir.
- **Response 200 OK:**
```json
{
  "id": "job-84920",
  "title": "Banyo Bataryası Değişimi",
  "category": "plumbing",
  "status": "PENDING_OFFERS",
  "urgency": "THIS_WEEK",
  "preferredDate": "25 Ekim Cuma",
  "preferredTimeSlot": "14:00 - 17:00",
  "district": "Kadıköy, Moda",
  "offersCount": 3,
  "offers": [
    {
      "id": "off-01",
      "pro": {
        "id": "pro-201",
        "name": "Mavi Hat Su Tesisatı (Ahmet Usta)",
        "rating": 4.9,
        "completedJobs": 248,
        "badges": ["KİMLİK ONAYLI", "SABIKA KAYDI TEMİZ", "12 AY GARANTİ"],
        "avatarUrl": "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150"
      },
      "laborAmount": 1800.00,
      "materialsAmount": 650.00,
      "totalAmount": 2450.00,
      "warrantyMonths": 12,
      "arrivalEstimationMinutes": 45,
      "status": "PENDING"
    }
  ]
}
```

---

### 3.3. Teklif Seçimi ve Escrow Ödemesi (Escrow & Payment Module)

#### `POST /api/v1/jobs/{jobId}/accept-offer`
Müşteri ustanın teklifini seçer ve ödeme adımını başlatır.
- **Request Body:**
```json
{
  "offerId": "off-01",
  "cardToken": "tok_visa_4242",
  "saveCard": false
}
```
- **Response 200 OK:**
```json
{
  "success": true,
  "jobStatus": "SCHEDULED",
  "escrowTransaction": {
    "id": "esc-901",
    "totalAmount": 2450.00,
    "status": "LOCKED",
    "guaranteeDays": 30,
    "lockedAt": "2026-10-22T19:55:00Z"
  },
  "completionPin": "849201"
}
```

#### `POST /api/v1/jobs/{jobId}/complete-work`
Müşteri işin bittiğini onaylar ve PIN'i teyit eder. Tutar ustaya aktarılır.
- **Request Body:**
```json
{
  "pin": "849201",
  "customerRating": 5,
  "customerReview": "Ahmet usta tam vaktinde geldi, temiz ve titiz çalıştı. Garanti belgesini de teslim etti."
}
```
- **Response 200 OK:**
```json
{
  "success": true,
  "jobStatus": "RELEASED",
  "escrowStatus": "RELEASED_TO_PRO",
  "payoutSummary": {
    "totalPaid": 2450.00,
    "proEarnings": 2205.00,
    "platformFee": 245.00
  }
}
```

---

### 3.4. Usta (Pro) Uç Noktaları

#### `GET /api/v1/pro/feed/jobs`
Ustanın konumuna (örn. Kadıköy, 10 km çap) ve uzmanlık kategorisine uygun yeni iş taleplerini listeler.
- **Headers:** `Authorization: Bearer <PRO_TOKEN>`
- **Response 200 OK:**
```json
[
  {
    "id": "job-84920",
    "title": "Banyo Bataryası Değişimi ve Su Kaçağı Tamiri",
    "district": "Kadıköy / Moda",
    "distanceKm": 1.4,
    "urgency": "THIS_WEEK",
    "estimatedBudgetRange": "₺1.800 - ₺2.500",
    "createdAt": "12 dk önce",
    "currentBidsCount": 2
  }
]
```

#### `POST /api/v1/pro/jobs/{jobId}/bid`
Usta açık ilana teklif verir.
- **Request Body:**
```json
{
  "laborAmount": 1800.00,
  "materialsAmount": 650.00,
  "warrantyMonths": 12,
  "estimatedArrivalMinutes": 45,
  "note": "Pirinç döküm batarya ve 1. sınıf fleksi hortum kullanılacaktır. 1 yıl sızdırmazlık garantili."
}
```
- **Response 201 Created:**
```json
{
  "offerId": "off-01",
  "status": "SUBMITTED",
  "jobStatus": "PENDING_OFFERS"
}
```

#### `GET /api/v1/pro/dashboard`
Ustanın aktif işlerini, aylık kazanç istatistiklerini ve beklemedeki havuz bakiyesini getirir.
- **Response 200 OK:**
```json
{
  "activeJob": {
    "jobId": "job-84920",
    "customerName": "Ata A.",
    "district": "Kadıköy, Moda",
    "amount": 2450.00,
    "status": "IN_PROGRESS"
  },
  "stats": {
    "thisMonthEarnings": 34850.00,
    "escrowLockedPending": 2450.00,
    "completedJobsThisMonth": 18,
    "ratingAvg": 4.9
  }
}
```

---

## 4. Hata Yönetimi Standardı (RFC 7807 Problem Details)

Tüm hata yanıtları standart HTTP durum kodları ve aşağıdaki JSON gövdesiyle döner:

```json
{
  "type": "https://bitadilat.com/errors/escrow-already-locked",
  "title": "Teklif Zaten Kabul Edildi",
  "status": 409,
  "detail": "Bu iş talebi için 'off-01' numaralı teklif zaten kabul edilmiş ve havuz ödemesi kilitlenmiştir.",
  "instance": "/api/v1/jobs/job-84920/accept-offer",
  "code": "ESCROW_ALREADY_LOCKED",
  "timestamp": "2026-10-22T19:50:00Z"
}
```
