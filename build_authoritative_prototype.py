import os, json, re

screens_dir = '/Users/ata/Documents/antigravity/BiTadilat/preview/screens'
preview_dir = '/Users/ata/Documents/antigravity/BiTadilat/preview'

# The authoritative 41-screen specification
screens_spec = [
    # -------------------------------------------------------------
    # FLOW 1: MÜŞTERİ GİRİŞ & ONBOARDING (Adım 01 - 03)
    # -------------------------------------------------------------
    {
        'id': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'step_num': 1,
        'title': 'Hoş Geldiniz & Rol Seçimi (SCR-01)',
        'flow': '1. Müşteri Giriş & Onboarding',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': None,
        'next_sid': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'role_pro': 'a512d0928f11b9cb02877746d580c548',
        'role_homeowner': 'fbbe0f405e1f4531a14dcdd6b1c5736a'
    },
    {
        'id': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'step_num': 2,
        'title': 'Telefon Doğrulama',
        'flow': '1. Müşteri Giriş & Onboarding',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': '42c148a1fb25400ca549481fa6abe01f'
    },
    {
        'id': '42c148a1fb25400ca549481fa6abe01f',
        'step_num': 3,
        'title': 'SMS Doğrulama Kodu',
        'flow': '1. Müşteri Giriş & Onboarding',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a'
    },

    # -------------------------------------------------------------
    # FLOW 2: MÜŞTERİ TALEP SİHİRBAZI (Adım 04 - 09)
    # -------------------------------------------------------------
    {
        'id': 'cc1f55661a1a4036a890b43d9f15596a',
        'step_num': 4,
        'title': 'Müşteri Ana Sayfası (SCR-03)',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': '44c003fee81d4a188f187608554efdd5',
        'tab_home': 'cc1f55661a1a4036a890b43d9f15596a',
        'tab_requests': '86fe79e681034183a8681bb0d2893e29',
        'tab_messages': 'c9aa92f5a4e04897952d05f30c2aef10',
        'tab_profile': '20de80b8dc984e86be873761409a2396'
    },
    {
        'id': '44c003fee81d4a188f187608554efdd5',
        'step_num': 5,
        'title': 'Talep Adım 1/4: Hizmet & Öncelik (SCR-02)',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'b3c3c2845017451fb1b85b89f04fd4b8'
    },
    {
        'id': 'b3c3c2845017451fb1b85b89f04fd4b8',
        'step_num': 6,
        'title': 'Talep Adım 2/4: Konum & İş Detayı',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '44c003fee81d4a188f187608554efdd5',
        'next_sid': '585d649f4ea046ffa70e4cb481ddd030'
    },
    {
        'id': '585d649f4ea046ffa70e4cb481ddd030',
        'step_num': 7,
        'title': 'Talep Adım 3/4: Fotoğraflar & Ek Bilgi',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'b3c3c2845017451fb1b85b89f04fd4b8',
        'next_sid': 'a0949c91cbe34557b16273c8e91d067a'
    },
    {
        'id': 'a0949c91cbe34557b16273c8e91d067a',
        'step_num': 8,
        'title': 'Talep Adım 4/4: Talebi Gözden Geçir',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '585d649f4ea046ffa70e4cb481ddd030',
        'next_sid': '94a730cef5374f2ab9632d9acf0d7e19',
        'edit_step1': '44c003fee81d4a188f187608554efdd5',
        'edit_step2': 'b3c3c2845017451fb1b85b89f04fd4b8',
        'edit_step3': '585d649f4ea046ffa70e4cb481ddd030'
    },
    {
        'id': '94a730cef5374f2ab9632d9acf0d7e19',
        'step_num': 9,
        'title': 'Talep Yayınlandı — Teklif Bekleniyor',
        'flow': '2. Müşteri Talep Sihirbazı',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': '86fe79e681034183a8681bb0d2893e29',
        'see_offers_sid': '994e3b4ffce942ce8778f7a6cfaa42c0'
    },

    # -------------------------------------------------------------
    # FLOW 3: TEKLİF KARŞILAŞTIRMA & RANDEVU (Adım 10 - 19)
    # -------------------------------------------------------------
    {
        'id': '86fe79e681034183a8681bb0d2893e29',
        'step_num': 10,
        'title': 'Müşteri Taleplerim Listesi (SCR-C-REQ)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'tab_home': 'cc1f55661a1a4036a890b43d9f15596a',
        'tab_requests': '86fe79e681034183a8681bb0d2893e29',
        'tab_messages': 'c9aa92f5a4e04897952d05f30c2aef10',
        'tab_profile': '20de80b8dc984e86be873761409a2396'
    },
    {
        'id': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'step_num': 11,
        'title': 'Gelen Teklifler Listesi (SCR-04)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '86fe79e681034183a8681bb0d2893e29',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'compare_sid': '1fc70722168942c4a1933cd9c641ad68'
    },
    {
        'id': 'ea7af2d7298b4b6cb24e4603935503f0',
        'step_num': 12,
        'title': 'Teklif Detayı & Kapsam',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'next_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'reject_sid': '45350ca7f3de4ee6bedcde20b5a1b385',
        'profile_sid': '98cd20d6ab4e4f8fbc29bc462ce55cca',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },
    {
        'id': '45350ca7f3de4ee6bedcde20b5a1b385',
        'step_num': 13,
        'title': 'Müşteri Teklif Reddetme & Geri Bildirim (SCR-C-OFFER-REJ)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'next_sid': '994e3b4ffce942ce8778f7a6cfaa42c0'
    },
    {
        'id': '1fc70722168942c4a1933cd9c641ad68',
        'step_num': 14,
        'title': 'Teklifleri Karşılaştır (Matris)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0'
    },
    {
        'id': '98cd20d6ab4e4f8fbc29bc462ce55cca',
        'step_num': 15,
        'title': 'Hizmet Profesyoneli Profili (SCR-05)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },
    {
        'id': '58f9993b5f444ff3a9f9361cb8d3b731',
        'step_num': 16,
        'title': 'Teklif Kabul Onayı (Güvence Havuzu)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'next_sid': '7c6ec3a02d3347a997a3fc5b1a2c91d0',
        'pay_error_sid': '1476367258dd4a7aa4b9cbda6b0091c0'
    },
    {
        'id': '1476367258dd4a7aa4b9cbda6b0091c0',
        'step_num': 17,
        'title': 'Güvence Havuzu Ödeme Hatası & 3D Secure (SCR-C-PAY-ERR)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'next_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'retry_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'offer_sid': 'ea7af2d7298b4b6cb24e4603935503f0'
    },
    {
        'id': '7c6ec3a02d3347a997a3fc5b1a2c91d0',
        'step_num': 18,
        'title': 'Randevu Zamanı Seç (SCR-06)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'next_sid': '3bd2afe80ced4d2498ec9f16c7099326'
    },
    {
        'id': '3bd2afe80ced4d2498ec9f16c7099326',
        'step_num': 19,
        'title': 'Randevu Talebi İletildi',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'f3e7de808fdb49c18e3c5d430cb72528'
    },

    # -------------------------------------------------------------
    # FLOW 4: AKTİF İŞ, MESAJLAŞMA & TESLİM (Adım 20 - 27)
    # -------------------------------------------------------------
    {
        'id': 'f3e7de808fdb49c18e3c5d430cb72528',
        'step_num': 20,
        'title': 'İş Alanı — Randevu Onaylandı',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'd485263b3ae244a9b35500665b5c759b',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10',
        'milestones_sid': 'b89d998c02d34e67b8e8f34334f87f02',
        'reschedule_sid': '6acc9307352f497ca6bd878d628c6a1a'
    },
    {
        'id': 'c9aa92f5a4e04897952d05f30c2aef10',
        'step_num': 21,
        'title': 'Usta ile Mesajlaşma (SCR-07)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'pro_back_sid': '8ba8c346d11c46f39163fd6ebf06dae1'
    },
    {
        'id': 'b89d998c02d34e67b8e8f34334f87f02',
        'step_num': 22,
        'title': 'İş Aşamaları ve İlerleme Takibi (SCR-08)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'd485263b3ae244a9b35500665b5c759b',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10',
        'dispute_sid': '488f3698f93c454099ca2382585aeb66'
    },
    {
        'id': '6acc9307352f497ca6bd878d628c6a1a',
        'step_num': 23,
        'title': 'Randevu İptal / Değişiklik Talebi (SCR-09)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'dbf40b28dba64bd1bedb40e075662c42',
        'keep_sid': 'f3e7de808fdb49c18e3c5d430cb72528'
    },
    {
        'id': 'd485263b3ae244a9b35500665b5c759b',
        'step_num': 24,
        'title': 'İş Tamamlama ve Teslim Onayı (SCR-10)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'db8a1b368a7749cbb5fd6cf497f34de6',
        'dispute_sid': '488f3698f93c454099ca2382585aeb66'
    },
    {
        'id': 'db8a1b368a7749cbb5fd6cf497f34de6',
        'step_num': 25,
        'title': 'Hizmet Değerlendirme ve Puanlama (SCR-11)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'd485263b3ae244a9b35500665b5c759b',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a'
    },
    {
        'id': '488f3698f93c454099ca2382585aeb66',
        'step_num': 26,
        'title': 'Şikayet ve Uyuşmazlık Bildirimi (SCR-12)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'd485263b3ae244a9b35500665b5c759b',
        'next_sid': '3bb4b954e5224b0097b2bee12be9bcbf'
    },
    {
        'id': '3bb4b954e5224b0097b2bee12be9bcbf',
        'step_num': 27,
        'title': 'Şikayet İletildi ve Durum Takibi (SCR-13)',
        'flow': '4. Aktif İş, Mesajlaşma & Teslim',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },

    # -------------------------------------------------------------
    # FLOW 5: MÜŞTERİ PROFİL & AYARLAR (Adım 28)
    # -------------------------------------------------------------
    {
        'id': '20de80b8dc984e86be873761409a2396',
        'step_num': 28,
        'title': 'Müşteri Profil & Ayarlar (SCR-C-PROF)',
        'flow': '5. Müşteri Profil & Ayarlar',
        'role': 'CUSTOMER',
        'device': 'MOBILE',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'tab_home': 'cc1f55661a1a4036a890b43d9f15596a',
        'tab_requests': '86fe79e681034183a8681bb0d2893e29',
        'tab_messages': 'c9aa92f5a4e04897952d05f30c2aef10',
        'tab_profile': '20de80b8dc984e86be873761409a2396',
        'switch_to_pro': 'a512d0928f11b9cb02877746d580c548',
        'logout_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf'
    },

    # -------------------------------------------------------------
    # FLOW 6: HİZMET PROFESYONELİ (USTA) AKIŞI (Adım 29 - 37)
    # -------------------------------------------------------------
    {
        'id': 'a512d0928f11b9cb02877746d580c548',
        'step_num': 29,
        'title': 'Usta Kayıt & Belge Yükleme (SCR-P-ONB)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': 'def294a930bf4bb78f7ba4f857611884'
    },
    {
        'id': 'def294a930bf4bb78f7ba4f857611884',
        'step_num': 30,
        'title': 'Usta Belge İncelemede Bekleme (SCR-P-PENDING)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': 'a512d0928f11b9cb02877746d580c548',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'switch_customer_sid': 'cc1f55661a1a4036a890b43d9f15596a'
    },
    {
        'id': '11b9cb02877746d580c5484512d0928f',
        'step_num': 31,
        'title': 'Usta Eşleşen Talepler Akışı (SCR-14)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': 'b9086f1030784def8eb267fd9110addd',
        'tab_requests': '11b9cb02877746d580c5484512d0928f',
        'tab_active_jobs': '8ba8c346d11c46f39163fd6ebf06dae1',
        'tab_messages': 'c9aa92f5a4e04897952d05f30c2aef10',
        'tab_availability': 'fc6f0f8e9b724365a5a0f124617dbe7a'
    },
    {
        'id': 'b9086f1030784def8eb267fd9110addd',
        'step_num': 32,
        'title': 'Usta Teklif Hazırlama (SCR-15)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '82f9d783b88b40ec8ca6260566c0f5cb'
    },
    {
        'id': '82f9d783b88b40ec8ca6260566c0f5cb',
        'step_num': 33,
        'title': 'Usta Teklif Gönderildi Onayı (SCR-16)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'tab_availability': 'fc6f0f8e9b724365a5a0f124617dbe7a'
    },
    {
        'id': 'fc6f0f8e9b724365a5a0f124617dbe7a',
        'step_num': 34,
        'title': 'Usta Profil & Müsaitlik Yönetimi (SCR-17)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'switch_to_customer': 'cc1f55661a1a4036a890b43d9f15596a',
        'logout_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf'
    },
    {
        'id': '8ba8c346d11c46f39163fd6ebf06dae1',
        'step_num': 35,
        'title': 'Usta İş Yürütme & Aşama Yönetimi (SCR-18)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': 'c6ebf06dae18ba8c346d11c46f39163f',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10',
        'cancel_sid': 'dbf40b28dba64bd1bedb40e075662c42'
    },
    {
        'id': 'dbf40b28dba64bd1bedb40e075662c42',
        'step_num': 36,
        'title': 'Usta Randevu İptali Bildirimi (SCR-P-CANCEL)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },
    {
        'id': 'c6ebf06dae18ba8c346d11c46f39163f',
        'step_num': 37,
        'title': 'Usta Teslim Bildirimi İletildi (SCR-P-DONE)',
        'flow': '6. Hizmet Profesyoneli (Usta)',
        'role': 'PRO',
        'device': 'MOBILE',
        'back_sid': '8ba8c346d11c46f39163fd6ebf06dae1',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'tab_availability': 'fc6f0f8e9b724365a5a0f124617dbe7a'
    },

    # -------------------------------------------------------------
    # FLOW 7: YÖNETİCİ WEB PORTALI & TANITIM SİTESİ (Adım 38 - 41)
    # -------------------------------------------------------------
    {
        'id': '612429fdea1b42a1bf9e628883f7e58f',
        'step_num': 38,
        'title': 'Yönetici Web: Belge İnceleme (SCR-19)',
        'flow': '7. Yönetici Portalı & Web',
        'role': 'ADMIN',
        'device': 'DESKTOP',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'disputes_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'accounts_sid': '5ce8968e2703443ca129c0e7c9e9d145'
    },
    {
        'id': 'cb00d67723e34ec990786a82d25c77ca',
        'step_num': 39,
        'title': 'Yönetici Web: Şikayet Merkezi (SCR-20)',
        'flow': '7. Yönetici Portalı & Web',
        'role': 'ADMIN',
        'device': 'DESKTOP',
        'back_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'next_sid': '5ce8968e2703443ca129c0e7c9e9d145',
        'documents_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'accounts_sid': '5ce8968e2703443ca129c0e7c9e9d145'
    },
    {
        'id': '5ce8968e2703443ca129c0e7c9e9d145',
        'step_num': 40,
        'title': 'Yönetici Web: Hesap Yönetimi (SCR-21)',
        'flow': '7. Yönetici Portalı & Web',
        'role': 'ADMIN',
        'device': 'DESKTOP',
        'back_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'next_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'documents_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'disputes_sid': 'cb00d67723e34ec990786a82d25c77ca'
    },
    {
        'id': '164cd33666284338b929a8325dc5ea20',
        'step_num': 41,
        'title': 'BiTadilat Tanıtım ve Karşılama Sitesi (SCR-22)',
        'flow': '7. Yönetici Portalı & Web',
        'role': 'WEB',
        'device': 'DESKTOP',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'start_customer': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'start_pro': 'a512d0928f11b9cb02877746d580c548'
    }
]

# 1. Update screens_map.json
screens_map_data = [
    {
        'id': s['id'],
        'title': s['title'],
        'device': s['device'],
        'role': s['role'],
        'step_num': s['step_num'],
        'flow': s['flow']
    }
    for s in screens_spec
]
with open('/Users/ata/Documents/antigravity/BiTadilat/screens_map.json', 'w', encoding='utf-8') as f:
    json.dump(screens_map_data, f, ensure_ascii=False, indent=2)
print(f'Updated screens_map.json with all {len(screens_map_data)} screens')

# 2. Inject clean, targeted navigation controller to each HTML screen
# I18N DICTIONARY FOR BILINGUAL SUPPORT (TR / EN)
I18N_DICT_DATA = {
  "Hoş Geldiniz": "Welcome",
  "Geri": "Back",
  "Devam Et": "Continue",
  "Sonraki": "Next",
  "Önceki": "Previous",
  "Sonraki Adım": "Next Step",
  "Önceki Adım": "Previous Step",
  "İptal": "Cancel",
  "İptal Et": "Cancel",
  "Vazgeç": "Cancel",
  "Kaydet": "Save",
  "Onayla": "Approve",
  "Gönder": "Submit",
  "Tamamla": "Complete",
  "Filtrele": "Filter",
  "Arama": "Search",
  "Detaylar": "Details",
  "Ayrıntılar": "Details",
  "Kapat": "Close",
  "Yardım": "Help",
  "Destek": "Support",
  "Çıkış Yap": "Log Out",
  "Oturumu Kapat": "Log Out",
  "Giriş yap": "Log in",
  "Giriş Yap": "Log in",
  "Kayıt Ol": "Sign Up",
  "Uygula": "Apply",
  "Düzenle": "Edit",
  "Yenile": "Refresh",
  "Tümü": "All",
  "Temizle": "Clear",
  "Seç": "Select",
  "Seçiniz": "Select",
  "Ana Sayfa": "Home",
  "Taleplerim": "My Requests",
  "Talepler": "Requests",
  "Mesajlar": "Messages",
  "Profil": "Profile",
  "İşlerim": "My Jobs",
  "Aktif İşler": "Active Jobs",
  "Müsaitlik": "Availability",
  "Takvim": "Calendar",
  "Ayarlar": "Settings",
  "Bildirimler": "Notifications",
  "Evin için doğru ustayı güvenle bul.": "Find the right tradesperson for your home with confidence.",
  "İhtiyacını anlat, doğrulanmış ustalardan şeffaf ve garantili teklifler al.": "Describe your need, get transparent and guaranteed offers from verified pros.",
  "Onaylı Ustalar": "Verified Pros",
  "Sabit Fiyat": "Fixed Price",
  "İş Garantisi": "Work Guarantee",
  "Nasıl başlamak istersin?": "How would you like to start?",
  "Ev sahibi / Müşteri": "Homeowner / Customer",
  "Onarım veya yenileme ihtiyacım var.": "I need repair or renovation.",
  "Hizmet profesyoneli": "Service Professional",
  "Yeni iş fırsatları arıyorum.": "I am looking for new job opportunities.",
  "Telefon numarasıyla devam et": "Continue with phone number",
  "Zaten bir hesabın var mı?": "Already have an account?",
  "Ev & Usta Ağı": "Home & Pro Network",
  "Devam ederek Kullanım Koşulları ve Gizlilik Politikası'nı kabul etmiş olursun.": "By continuing, you agree to our Terms of Use and Privacy Policy.",
  "Kullanım Koşulları": "Terms of Use",
  "Gizlilik Politikası": "Privacy Policy",
  "Telefon Numaranı Gir": "Enter Your Phone Number",
  "Telefon Numarası": "Phone Number",
  "Giriş yapmak ve randevularını yönetmek için 10 haneli cep telefonu numaranı yaz.": "Enter your 10-digit mobile phone number to log in and manage your appointments.",
  "Kodu Gönder": "Send Code",
  "SMS ile tek kullanımlık şifre gönderilecektir.": "A one-time verification code will be sent via SMS.",
  "SMS Doğrulama": "SMS Verification",
  "SMS Doğrulama Kodu": "SMS Verification Code",
  "Doğrula ve Devam Et": "Verify & Continue",
  "numarasına gönderdiğimiz 6 haneli doğrulama kodunu girin.": "Enter the 6-digit verification code sent to your number.",
  "Kodu tekrar gönder": "Resend code",
  "Kalan süre:": "Time remaining:",
  "Kalan süre": "Time remaining",
  "Doğrulama Kodu": "Verification Code",
  "Hangi konuda yardıma ihtiyacın var?": "What do you need help with?",
  "Hızlı Talep Oluştur": "Create Quick Request",
  "Acil Usta Çağır": "Emergency Call",
  "Tesisat": "Plumbing",
  "Elektrik": "Electrical",
  "Boya & Badana": "Painting",
  "Tadilat & Dekorasyon": "Renovation",
  "Klima & Havalandırma": "HVAC & AC",
  "Mobilya Montaj": "Furniture Assembly",
  "Temizlik": "Cleaning",
  "Popüler Hizmetler": "Popular Services",
  "Aktif Taleplerin": "Your Active Requests",
  "Teklif Bekleniyor": "Awaiting Offers",
  "İnceleniyor": "Under Review",
  "Öne Çıkan Ustalar": "Featured Pros",
  "Gelen Teklifler": "Received Offers",
  "Kategoriler": "Categories",
  "Tümünü Gör": "View All",
  "Talep Oluştur": "Create Request",
  "Talep Adım 1/4: Hizmet & Öncelik": "Step 1/4: Service & Priority",
  "Talep Adım 2/4: Konum & İş Detayı": "Step 2/4: Location & Job Details",
  "Talep Adım 3/4: Fotoğraflar & Ek Bilgi": "Step 3/4: Photos & Additional Info",
  "Talep Adım 4/4: Talebi Gözden Geçir": "Step 4/4: Review Request",
  "Hizmet & Öncelik": "Service & Priority",
  "Konum & İş Detayı": "Location & Job Details",
  "Fotoğraflar & Ek Bilgi": "Photos & Additional Info",
  "Talebi Gözden Geçir": "Review Request",
  "Hizmet Kategorisi Seç": "Select Service Category",
  "Öncelik Durumu": "Priority Level",
  "Acil (En geç 24 saat içinde)": "Urgent (Within 24 hours)",
  "Normal (Bu hafta içi)": "Normal (This week)",
  "Planlı (İleriki bir tarihte)": "Planned (Later date)",
  "2. Adıma Devam Et": "Continue to Step 2",
  "3. Adıma Devam Et": "Continue to Step 3",
  "4. Adıma Devam Et": "Continue to Step 4",
  "2. adıma devam et": "Continue to Step 2",
  "3. adıma devam et": "Continue to Step 3",
  "4. adıma devam et": "Continue to Step 4",
  "Talebi Yayınla": "Publish Request",
  "İl / İlçe Seçimi": "City / District Selection",
  "Adres Detayı": "Address Details",
  "İş Tanımı ve Detaylar": "Job Description & Details",
  "Fotoğraf veya Video Ekle": "Add Photos or Videos",
  "Talebi Onayla ve Yayınla": "Confirm & Publish Request",
  "Talep Özeti": "Request Summary",
  "Konum": "Location",
  "Fotoğraf Ekle": "Add Photo",
  "Talep Yayınlandı — Teklif Bekleniyor": "Request Published — Awaiting Offers",
  "Müşteri Taleplerim Listesi": "My Requests List",
  "Gelen Teklifler Listesi": "Received Offers List",
  "Teklif Detayı": "Offer Details",
  "Teklif Detayı & Kapsam": "Offer Details & Scope",
  "Teklifi İncele": "View Offer",
  "Teklifi Kabul Et": "Accept Offer",
  "Teklifi Reddet": "Reject Offer",
  "Teklifleri Karşılaştır": "Compare Offers",
  "Fiyat Karşılaştırması": "Price Comparison",
  "Kapsam": "Scope",
  "Tahmini Süre": "Estimated Duration",
  "Usta Puanı": "Pro Rating",
  "Değerlendirmeler": "Reviews",
  "Hizmet Profesyoneli Profili": "Service Pro Profile",
  "Usta Profili": "Pro Profile",
  "Hakkında": "About",
  "Geçmiş İşler ve Yorumlar": "Past Work & Reviews",
  "Sertifikalar & Belgeler": "Certificates & Documents",
  "Teklif Kabul Onayı": "Offer Acceptance Confirmation",
  "Güvence Havuzu ile Güvenli Ödeme": "Secure Payment with Escrow",
  "Ödeme Tutarı": "Payment Amount",
  "Randevu Zamanı Seç": "Select Appointment Time",
  "Randevuyu Onayla": "Confirm Appointment",
  "Randevu Talebi İletildi": "Appointment Request Sent",
  "Güvence Havuzu": "Escrow Protection",
  "Toplam Tutar": "Total Amount",
  "Randevu Onaylandı": "Appointment Confirmed",
  "İş Alanı — Randevu Onaylandı": "Workspace — Appointment Confirmed",
  "Usta ile Mesajlaşma": "Chat with Pro",
  "İş Aşamaları ve İlerleme Takibi": "Job Milestones & Progress Tracking",
  "İş Başladı": "Job Started",
  "Malzeme Temini": "Material Procurement",
  "Uygulama": "Execution",
  "Tamamlandı": "Completed",
  "Teslim Onayı Ver": "Approve Delivery",
  "İş Tamamlama ve Teslim Onayı": "Work Completion & Delivery Approval",
  "Hizmet Değerlendirme ve Puanlama": "Service Rating & Review",
  "Hizmeti Puanla": "Rate Service",
  "Puan ve Yorum Bırak": "Leave Rating & Review",
  "Şikayet ve Uyuşmazlık Bildirimi": "Dispute & Complaint Report",
  "Şikayet Bildir": "Report Dispute",
  "Şikayet Durumu": "Dispute Status",
  "Şikayet İletildi ve Durum Takibi": "Dispute Submitted & Status Tracking",
  "Randevu İptal / Değişiklik Talebi": "Cancel / Reschedule Appointment",
  "Randevuyu İptal Et": "Cancel Appointment",
  "Randevu Saatini Değiştir": "Change Appointment Time",
  "Müşteri Profil & Ayarlar": "Customer Profile & Settings",
  "Hesap Bilgileri": "Account Details",
  "Kayıtlı Adreslerim": "Saved Addresses",
  "Ödeme Yöntemleri": "Payment Methods",
  "Yardım & Destek": "Help & Support",
  "Usta Moduna Geç": "Switch to Pro Mode",
  "Bildirim Tercihleri": "Notification Preferences",
  "Güvenlik": "Security",
  "Usta Kayıt & Belge Yükleme": "Pro Registration & Document Upload",
  "Kimlik & Vergi Levhası": "ID & Tax Plate",
  "Mesleki Yeterlilik Belgesi": "Vocational Qualification Certificate",
  "Usta Belge İncelemede Bekleme": "Pro Document Verification Pending",
  "Belgeler İnceleniyor": "Documents Under Review",
  "Usta Eşleşen Talepler Akışı": "Pro Matching Requests Feed",
  "Eşleşen Talepler": "Matching Requests",
  "Usta Teklif Hazırlama": "Pro Offer Preparation",
  "Teklif Hazırla": "Prepare Offer",
  "Teklif Gönder": "Send Offer",
  "Usta Teklif Gönderildi Onayı": "Pro Offer Sent Confirmation",
  "Teklif Gönderildi": "Offer Sent",
  "Usta Profil & Müsaitlik Yönetimi": "Pro Profile & Availability Management",
  "Müsaitlik Yönetimi": "Manage Availability",
  "Usta İş Yürütme & Aşama Yönetimi": "Pro Job Execution & Milestone Management",
  "Usta Randevu İptali Bildirimi": "Pro Cancellation Notice",
  "Usta Teslim Bildirimi İletildi": "Pro Delivery Notice Sent",
  "İşi Başlat": "Start Job",
  "İşi Bitirdim & Teslim Et": "Finish Job & Deliver",
  "Müşteri Moduna Geç": "Switch to Customer Mode",
  "Yönetici Web: Belge İnceleme": "Admin Web: Document Review",
  "Yönetici Web: Şikayet Merkezi": "Admin Web: Disputes Center",
  "Yönetici Web: Hesap Yönetimi": "Admin Web: Account Management",
  "Belge İnceleme": "Document Review",
  "Şikayet Merkezi": "Disputes Center",
  "Hesap Yönetimi": "Account Management",
  "Reddet": "Reject",
  "Özellikler": "Features",
  "Nasıl Çalışır?": "How It Works?",
  "Usta Ol / Başvur": "Become a Pro / Apply",
  "Sıkça Sorulan Sorular (SSS)": "FAQ",
  "Uygulamayı İndir": "Download App",
  "GÜVENİLİR USTA AĞI": "TRUSTED PRO NETWORK",
  "Evinizin tadilat ve onarımında güvenilir adres": "Your trusted platform for home renovation and repairs",
  "Hemen Usta Çağır / Talep Oluştur": "Request a Pro / Create Request Now",
  "Usta Olarak Katıl": "Join as a Professional",
  "Garantili Hizmet": "Guaranteed Service",
  "Şeffaf Fiyatlandırma": "Transparent Pricing",
  "Güvenli Ödeme": "Secure Payment"
}
I18N_DICT_JSON = json.dumps(I18N_DICT_DATA, ensure_ascii=False)

# 2. Inject clean, targeted navigation & i18n controller to each HTML screen
def inject_clean_controller(s):
    sid = s['id']
    fpath = os.path.join(screens_dir, f'{sid}.html')
    if not os.path.exists(fpath):
        print(f'Warning: {fpath} does not exist!')
        return

    with open(fpath, 'r', encoding='utf-8') as f:
        html = f.read()

    # Clean any old scripts
    html = re.sub(r'<!-- BiTadilat Authoritative Navigation Controller -->.*?</script>', '', html, flags=re.DOTALL)
    
    spec_json = json.dumps(s, ensure_ascii=False)

    controller_template = '''
<!-- BiTadilat Authoritative Navigation Controller -->
<script>
(function() {
  const SPEC = __SPEC_JSON__;
  const CURRENT_SID = "__SID__";

  // Save current role in session storage
  if (SPEC.role === 'PRO') {
    sessionStorage.setItem('bitadilat_active_role', 'PRO');
  } else if (SPEC.role === 'CUSTOMER') {
    sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
  }

  // --- i18n Bilingual (TR / EN) Engine ---
  const I18N_DICT = __I18N_DICT_JSON__;
  const sortedKeys = Object.keys(I18N_DICT).sort((a, b) => b.length - a.length);

  function translateText(text) {
    if (!text || typeof text !== 'string') return text;
    const trimmed = text.trim();
    if (!trimmed) return text;
    if (I18N_DICT[trimmed]) {
      return text.replace(trimmed, I18N_DICT[trimmed]);
    }
    let res = text;
    for (let i = 0; i < sortedKeys.length; i++) {
      const k = sortedKeys[i];
      if (k.length > 2 && res.includes(k)) {
        res = res.split(k).join(I18N_DICT[k]);
      }
    }
    return res;
  }

  function updateToggleButtons(lang) {
    const isEn = (lang === 'EN');
    document.querySelectorAll('button').forEach(btn => {
      const txt = (btn.innerText || '').trim().toUpperCase();
      if (txt === 'TR') {
        if (isEn) {
          btn.classList.remove('bg-primary-container', 'text-on-primary', 'bg-white', 'text-[#0F4C5C]', 'shadow-xs', 'shadow-sm');
          btn.classList.add('text-text-secondary', 'text-[#5F6F73]');
        } else {
          if (CURRENT_SID === '164cd33666284338b929a8325dc5ea20') {
            btn.className = 'px-2.5 py-1 bg-white text-[#0F4C5C] rounded-md shadow-xs font-bold';
          } else {
            btn.className = 'px-3 py-1 text-label-sm font-label-sm bg-primary-container text-on-primary rounded-full transition-all font-semibold';
          }
        }
      } else if (txt === 'EN') {
        if (isEn) {
          if (CURRENT_SID === '164cd33666284338b929a8325dc5ea20') {
            btn.className = 'px-2.5 py-1 bg-white text-[#0F4C5C] rounded-md shadow-xs font-bold';
          } else {
            btn.className = 'px-3 py-1 text-label-sm font-label-sm bg-primary-container text-on-primary rounded-full transition-all font-semibold';
          }
        } else {
          btn.classList.remove('bg-primary-container', 'text-on-primary', 'bg-white', 'text-[#0F4C5C]', 'shadow-xs', 'shadow-sm');
          btn.classList.add('text-text-secondary', 'text-[#5F6F73]');
        }
      }
    });
  }

  window.applyBitadilatLanguage = function(lang) {
    const isEn = (lang === 'EN');
    updateToggleButtons(lang);

    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
      acceptNode: function(node) {
        if (!node.parentElement) return NodeFilter.FILTER_REJECT;
        const tag = node.parentElement.tagName.toLowerCase();
        if (tag === 'script' || tag === 'style' || tag === 'noscript') return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });

    let node;
    while (node = walker.nextNode()) {
      const pTag = node.parentElement.tagName.toLowerCase();
      const txt = node.nodeValue.trim().toUpperCase();
      if (pTag === 'button' && (txt === 'TR' || txt === 'EN')) continue;

      if (node._origTr === undefined) {
        node._origTr = node.nodeValue;
      }

      if (isEn) {
        node.nodeValue = translateText(node._origTr);
      } else {
        node.nodeValue = node._origTr;
      }
    }

    document.querySelectorAll('input, textarea').forEach(el => {
      if (el.hasAttribute('placeholder')) {
        if (el._origPlaceholder === undefined) {
          el._origPlaceholder = el.getAttribute('placeholder') || '';
        }
        if (isEn) {
          el.setAttribute('placeholder', translateText(el._origPlaceholder));
        } else {
          el.setAttribute('placeholder', el._origPlaceholder);
        }
      }
      if (el.tagName.toLowerCase() === 'input' && (el.type === 'submit' || el.type === 'button')) {
        if (el._origValue === undefined) {
          el._origValue = el.value || '';
        }
        if (isEn) {
          el.value = translateText(el._origValue);
        } else {
          el.value = el._origValue;
        }
      }
    });

    if (document._origTitle === undefined) {
      document._origTitle = document.title;
    }
    if (isEn) {
      document.title = translateText(document._origTitle);
    } else {
      document.title = document._origTitle;
    }
  };

  window.bitadilatNav = function(targetSid, label) {
    if (!targetSid) return;
    console.log('[BiTadilat Router] Navigating:', CURRENT_SID, '->', targetSid, '(', label || '', ')');
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({
        type: 'NAVIGATE',
        from: CURRENT_SID,
        to: targetSid,
        label: label || ''
      }, '*');
    } else {
      window.location.href = './' + targetSid + '.html';
    }
  };

  document.addEventListener('DOMContentLoaded', function() {
    // 1. Remove all disabled locks on interactive prototype triggers
    document.querySelectorAll('button, [role="button"], input[type="submit"]').forEach(btn => {
      btn.style.cursor = 'pointer';
      btn.removeAttribute('disabled');
      btn.classList.remove('pointer-events-none');
    });

    // 2. Prevent default forms from blocking navigation
    document.querySelectorAll('form').forEach(form => {
      form.onsubmit = function(e) {
        e.preventDefault();
        if (SPEC.next_sid) window.bitadilatNav(SPEC.next_sid, 'Form Submitted');
        return false;
      };
    });

    // 3. Bind TR / EN Language Toggle Buttons
    document.querySelectorAll('button').forEach(btn => {
      const txt = (btn.innerText || '').trim().toUpperCase();
      if (txt === 'TR' || txt === 'EN') {
        btn.style.cursor = 'pointer';
        btn.onclick = function(e) {
          e.preventDefault();
          e.stopPropagation();
          const targetLang = txt;
          sessionStorage.setItem('bitadilat_lang', targetLang);
          window.applyBitadilatLanguage(targetLang);
          if (window.parent && window.parent !== window) {
            window.parent.postMessage({
              type: 'LANG_CHANGED',
              lang: targetLang
            }, '*');
          }
        };
      }
    });

    // 4. Listen for language changes from parent simulator frame
    window.addEventListener('message', function(event) {
      if (event.data && event.data.type === 'SET_LANG') {
        const lang = event.data.lang;
        sessionStorage.setItem('bitadilat_lang', lang);
        window.applyBitadilatLanguage(lang);
      }
    });

    // 5. Check stored language and apply on load
    const savedLang = sessionStorage.getItem('bitadilat_lang') || 'TR';
    if (savedLang === 'EN') {
      window.applyBitadilatLanguage('EN');
    } else {
      updateToggleButtons('TR');
    }

    // Helper: Normalize Turkish characters and casing for deterministic button matching
    function normText(el) {
      if (!el) return '';
      return (el.innerText || el.getAttribute('aria-label') || el.value || '')
        .toLocaleLowerCase('tr-TR')
        .replace(/\\u0307/g, '')
        .replace(/\\s+/g, ' ')
        .trim();
    }

    // 6. Bind Universal Header Back Buttons
    if (SPEC.back_sid) {
      document.querySelectorAll('button, a').forEach(el => {
        const text = normText(el);
        const html = el.innerHTML || '';
        if (text.includes('geri') || text.includes('don') || text.includes('dön') || text.includes('back') ||
            html.includes('arrow_back') || html.includes('chevron_left') || html.includes('arrow_back_ios')) {
          el.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            window.bitadilatNav(SPEC.back_sid, 'Back Target');
          };
        }
      });
    }

    // 7. Bind Explicit data-nav-target elements
    document.querySelectorAll('[data-nav-target]').forEach(el => {
      el.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        window.bitadilatNav(el.getAttribute('data-nav-target'), 'Direct Data Nav');
      };
    });

    // 8. Screen-Specific Deterministic Handlers
    if (CURRENT_SID === '0c06b06e422b40daacbc0b8e6e8fb7bf') {
      let chosenRole = 'homeowner';
      const cHome = document.getElementById('role-homeowner');
      const cPro = document.getElementById('role-professional');
      const btnCont = document.getElementById('btn-continue');
      
      function activateRole(role) {
        chosenRole = role;
        if (btnCont) {
          btnCont.removeAttribute('disabled');
          btnCont.style.backgroundColor = '#0F4C5C';
          btnCont.style.color = '#FFFFFF';
          btnCont.style.cursor = 'pointer';
        }
      }

      if (cHome) cHome.addEventListener('click', () => activateRole('homeowner'));
      if (cPro) cPro.addEventListener('click', () => activateRole('pro'));

      if (btnCont) {
        btnCont.onclick = function(e) {
          e.preventDefault();
          if (chosenRole === 'pro') {
            sessionStorage.setItem('bitadilat_active_role', 'PRO');
            window.bitadilatNav(SPEC.role_pro, 'Seçilen Rol: Usta Kayıt');
          } else {
            sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
            window.bitadilatNav(SPEC.role_homeowner, 'Seçilen Rol: Müşteri Giriş');
          }
        };
      }
    }

    else if (CURRENT_SID === 'fbbe0f405e1f4531a14dcdd6b1c5736a') {
      const submitBtn = document.getElementById('submit-btn');
      if (submitBtn) {
        submitBtn.onclick = function(e) {
          e.preventDefault();
          window.bitadilatNav(SPEC.next_sid, 'Telefon Doğrulandı -> SMS');
        };
      }
    }

    else if (CURRENT_SID === '42c148a1fb25400ca549481fa6abe01f') {
      const verifyBtn = document.getElementById('verify-submit-btn');
      if (verifyBtn) {
        verifyBtn.removeAttribute('disabled');
        verifyBtn.classList.remove('opacity-60', 'pointer-events-none');
        verifyBtn.onclick = function(e) {
          e.preventDefault();
          window.bitadilatNav(SPEC.next_sid, 'SMS Onaylandı -> Müşteri Ana Sayfa');
        };
      }
    }

    else if (CURRENT_SID === 'cc1f55661a1a4036a890b43d9f15596a') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('talep') || t.includes('başla') || t.includes('oluştur') || t.includes('request') || t.includes('start') || t.includes('create')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talep Oluştur Adım 1'); };
        }
      });
      document.querySelectorAll('.grid > div, .grid > button').forEach(c => {
        c.style.cursor = 'pointer';
        c.onclick = () => window.bitadilatNav(SPEC.next_sid, 'Kategori Seçimi -> Adım 1');
      });
      const navLinks = document.querySelectorAll('footer a, nav a, [role="tablist"] a');
      if (navLinks.length >= 4) {
        navLinks[0].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); };
        navLinks[1].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); };
        navLinks[2].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); };
        navLinks[3].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Müşteri Profil'); };
      }
    }

    else if (CURRENT_SID === '44c003fee81d4a188f187608554efdd5') {
      const cta = document.getElementById('wizard-primary-cta') || document.querySelector('button.bg-primary');
      if (cta) {
        cta.removeAttribute('disabled');
        cta.classList.remove('pointer-events-none', 'bg-surface-disabled', 'text-text-secondary');
        cta.classList.add('bg-primary-container', 'text-white');
        cta.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2'); };
      }
      document.querySelectorAll('button').forEach(b => {
        const t = normText(b);
        if (t.includes('2. adıma') || t.includes('devam et') || t.includes('step 2') || t.includes('continue')) {
          b.removeAttribute('disabled');
          b.classList.remove('pointer-events-none');
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2'); };
        }
      });
    }

    else if (CURRENT_SID === 'b3c3c2845017451fb1b85b89f04fd4b8') {
      // Enliven prompt chips
      const taskDesc = document.getElementById('task-description');
      const counter = document.getElementById('char-counter');
      document.querySelectorAll('.prompt-chip').forEach(chip => {
        chip.style.cursor = 'pointer';
        chip.onclick = function(e) {
          e.preventDefault();
          const p = chip.getAttribute('data-prompt') || chip.innerText.trim();
          if (taskDesc) {
            taskDesc.value = (taskDesc.value ? taskDesc.value + ' ' : '') + p;
            if (counter) counter.innerText = taskDesc.value.length + ' / 500';
            chip.classList.add('bg-primary-container', 'text-white');
          }
        };
      });

      const cta = document.getElementById('wizard-primary-cta');
      if (cta) {
        cta.removeAttribute('disabled');
        cta.classList.remove('pointer-events-none', 'bg-surface-disabled', 'text-text-secondary');
        cta.classList.add('bg-primary-container', 'text-white');
        cta.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 2 -> Adım 3'); };
      }

      document.querySelectorAll('button').forEach(b => {
        const t = normText(b);
        if (t.includes('3. adıma') || t.includes('devam et') || t.includes('step 3') || t.includes('continue')) {
          b.removeAttribute('disabled');
          b.classList.remove('pointer-events-none');
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 2 -> Adım 3'); };
        }
      });
    }

    else if (CURRENT_SID === '585d649f4ea046ffa70e4cb481ddd030') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('4. adıma') || t.includes('devam et') || t.includes('gözden geçir') || t.includes('step 4') || t.includes('continue') || t.includes('review')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 3 -> Adım 4'); };
        }
      });
    }

    else if (CURRENT_SID === 'a0949c91cbe34557b16273c8e91d067a') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('yayınla') || t.includes('onayla') || t.includes('tamamla') || t.includes('publish') || t.includes('confirm')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talep Yayınlandı'); };
        }
      });
      const edits = document.querySelectorAll('[data-edit-step]');
      edits.forEach(el => {
        const step = el.getAttribute('data-edit-step');
        if (step === '1' && SPEC.edit_step1) el.onclick = () => window.bitadilatNav(SPEC.edit_step1, 'Düzenle Adım 1');
        if (step === '2' && SPEC.edit_step2) el.onclick = () => window.bitadilatNav(SPEC.edit_step2, 'Düzenle Adım 2');
        if (step === '3' && SPEC.edit_step3) el.onclick = () => window.bitadilatNav(SPEC.edit_step3, 'Düzenle Adım 3');
      });
    }

    else if (CURRENT_SID === '94a730cef5374f2ab9632d9acf0d7e19') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('bekle') || t.includes('incele') || t.includes('offers')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.see_offers_sid, 'Teklifleri Gör'); };
        }
        if (t.includes('ana sayfa') || t.includes('talepler') || t.includes('kapat') || t.includes('home')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Taleplerim Listesi'); };
        }
      });
    }

    else if (CURRENT_SID === '86fe79e681034183a8681bb0d2893e29') {
      document.querySelectorAll('.cursor-pointer, [role="button"], button').forEach(card => {
        const t = (card.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('banyo') || t.includes('onarım') || t.includes('borusu') || t.includes('offers')) {
          card.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Gelen Teklifler'); };
        }
      });
      const navLinks = document.querySelectorAll('footer a, nav a');
      if (navLinks.length >= 4) {
        navLinks[0].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); };
        navLinks[1].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); };
        navLinks[2].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); };
        navLinks[3].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Profil'); };
      }
    }

    else if (CURRENT_SID === '994e3b4ffce942ce8778f7a6cfaa42c0') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('karşılaştır') || t.includes('matris') || t.includes('compare')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.compare_sid, 'Teklifleri Karşılaştır'); };
        }
        if (t.includes('incele') || t.includes('detay') || t.includes('view') || t.includes('details')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Detayı'); };
        }
      });
      document.querySelectorAll('.offer-card, .bg-surface').forEach(card => {
        const t = (card.innerText || '').toLowerCase();
        if (t.includes('mehmet') || t.includes('usta') || t.includes('ahmet') || t.includes('₺')) {
          card.style.cursor = 'pointer';
          card.onclick = () => window.bitadilatNav(SPEC.next_sid, 'Teklif Detayı');
        }
      });
    }

    else if (CURRENT_SID === 'ea7af2d7298b4b6cb24e4603935503f0') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('kabul') || t.includes('onayla') || t.includes('accept')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Kabul Edildi -> Ödeme Onayı'); };
        }
        if (t.includes('reddet') || t.includes('vazgeç') || t.includes('reject')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.reject_sid, 'Teklif Reddetme'); };
        }
        if (t.includes('mesaj') || t.includes('chat') || t.includes('soru sor')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Usta ile Mesajlaş'); };
        }
      });
      document.querySelectorAll('.pro-profile-link, [data-goto-profile]').forEach(el => {
        el.style.cursor = 'pointer';
        el.onclick = () => window.bitadilatNav(SPEC.profile_sid, 'Usta Profili');
      });
    }

    else if (CURRENT_SID === '45350ca7f3de4ee6bedcde20b5a1b385') {
      // Müşteri Teklif Reddetme (SCR-C-OFFER-REJ)
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('reddet') || t.includes('onayla') || t.includes('tamamla') || t.includes('gönder') || t.includes('reject')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Reddedildi -> Teklif Listesine Dön'); };
        }
        if (t.includes('vazgeç') || t.includes('geri') || t.includes('iptal') || t.includes('cancel')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.back_sid, 'Vazgeç -> Teklif Detayı'); };
        }
      });
    }

    else if (CURRENT_SID === '1fc70722168942c4a1933cd9c641ad68') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('seç') || t.includes('kabul') || t.includes('detay') || t.includes('select')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Karşılaştırmadan Teklife Git'); };
        }
      });
    }

    else if (CURRENT_SID === '98cd20d6ab4e4f8fbc29bc462ce55cca') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('kabul') || t.includes('dön')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklife Dön'); };
        }
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Usta ile Mesaj'); };
        }
      });
    }

    else if (CURRENT_SID === '58f9993b5f444ff3a9f9361cb8d3b731') {
      document.querySelectorAll('button').forEach(b => {
        const t = normText(b);
        if (t.includes('onayla') || t.includes('öde') || t.includes('ode') || t.includes('randevu') || t.includes('confirm') || t.includes('pay')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Güvence Havuzu Onaylandı -> Randevu Seç'); };
        }
        if (t.includes('hata simüle') || t.includes('başarısız') || t.includes('3d secure') || t.includes('simüle et')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.pay_error_sid, 'Ödeme Hatası Senaryosu (SCR-C-PAY-ERR)'); };
        }
      });
    }

    else if (CURRENT_SID === '1476367258dd4a7aa4b9cbda6b0091c0') {
      // SCR-C-PAY-ERR Handlers
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('tekrar dene') || t.includes('farklı kart') || t.includes('ödeme yap') || t.includes('retry')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.retry_sid, 'Ödeme Tekrar Deneniyor -> Onay Ekranı'); };
        }
        if (t.includes('teklife dön') || t.includes('teklif detay') || t.includes('iptal') || t.includes('vazgeç') || t.includes('cancel')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.offer_sid, 'Ödeme İptal -> Teklif Detayı'); };
        }
      });
    }

    else if (CURRENT_SID === '7c6ec3a02d3347a997a3fc5b1a2c91d0') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('onayla') || t.includes('randevu') || t.includes('saat') || t.includes('tamamla') || t.includes('confirm')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Randevu Oluşturuldu'); };
        }
      });
    }

    else if (CURRENT_SID === '3bd2afe80ced4d2498ec9f16c7099326') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iş alanı') || t.includes('takip') || t.includes('detay') || t.includes('workspace')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'İş Alanına Git'); };
        }
      });
    }

    else if (CURRENT_SID === 'f3e7de808fdb49c18e3c5d430cb72528') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlaşma'); };
        }
        if (t.includes('aşama') || t.includes('ilerleme') || t.includes('milestone')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.milestones_sid, 'İş Aşamaları'); };
        }
        if (t.includes('tamamla') || t.includes('teslim') || t.includes('onayla') || t.includes('complete')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayı'); };
        }
        if (t.includes('iptal') || t.includes('değiştir') || t.includes('saat') || t.includes('cancel')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.reschedule_sid, 'Randevu Değişiklik / İptal'); };
        }
      });
    }

    else if (CURRENT_SID === 'c9aa92f5a4e04897952d05f30c2aef10') {
      const backBtn = document.querySelector('button[aria-label="Geri"], button:has(span.material-symbols-outlined)');
      if (backBtn) {
        backBtn.onclick = (e) => {
          e.preventDefault();
          const role = sessionStorage.getItem('bitadilat_active_role');
          if (role === 'PRO') {
            window.bitadilatNav(SPEC.pro_back_sid, 'Geri -> Usta İş Yönetimi');
          } else {
            window.bitadilatNav(SPEC.back_sid, 'Geri -> Müşteri İş Alanı');
          }
        };
      }
    }

    else if (CURRENT_SID === 'b89d998c02d34e67b8e8f34334f87f02') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teslim') || t.includes('onayla') || t.includes('bitir') || t.includes('approve')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayı'); };
        }
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlaşma'); };
        }
        if (t.includes('şikayet') || t.includes('uyuşmazlık') || t.includes('sorun') || t.includes('dispute')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.dispute_sid, 'Uyuşmazlık Bildir'); };
        }
      });
    }

    else if (CURRENT_SID === '6acc9307352f497ca6bd878d628c6a1a') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iptal et') || t.includes('onayla') || t.includes('vazgeç') || t.includes('randevuyu iptal') || t.includes('cancel')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Randevu İptal Bildirimi'); };
        }
        if (t.includes('koru') || t.includes('vazgeç') || t.includes('dön') || t.includes('keep')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.keep_sid, 'İş Alanına Dön'); };
        }
      });
    }

    else if (CURRENT_SID === 'd485263b3ae244a9b35500665b5c759b') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('onayla') || t.includes('puanla') || t.includes('kabul') || t.includes('değerlendir') || t.includes('approve') || t.includes('rate')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Hizmet Değerlendirme'); };
        }
        if (t.includes('şikayet') || t.includes('sorun') || t.includes('dispute')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.dispute_sid, 'Şikayet Bildirimi'); };
        }
      });
    }

    else if (CURRENT_SID === 'db8a1b368a7749cbb5fd6cf497f34de6') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('gonder') || t.includes('gönder') || t.includes('tamamla') || t.includes('kaydet') || t.includes('yayinla') || t.includes('yayınla') || t.includes('degerlendirme') || t.includes('değerlendirme') || t.includes('submit')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Ana Sayfaya Dön'); };
        }
      });
    }

    else if (CURRENT_SID === '488f3698f93c454099ca2382585aeb66') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('şikayet') && (t.includes('oluştur') || t.includes('ilet') || t.includes('gönder') || t.includes('submit'))) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Şikayet Durumu'); };
        }
      });
    }

    else if (CURRENT_SID === '3bb4b954e5224b0097b2bee12be9bcbf') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('ana sayfa') || t.includes('taleplerime') || t.includes('home')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Ana Sayfa'); };
        }
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlar'); };
        }
      });
    }

    else if (CURRENT_SID === '20de80b8dc984e86be873761409a2396') {
      // Customer Profile
      document.querySelectorAll('button, a').forEach(b => {
        const t = normText(b);
        if ((t.includes('usta') || t.includes('pro')) && (t.includes('modu') || t.includes('gec') || t.includes('geç') || t.includes('profesyoneli') || t.includes('switch'))) {
          b.onclick = (e) => {
            e.preventDefault();
            sessionStorage.setItem('bitadilat_active_role', 'PRO');
            window.bitadilatNav(SPEC.switch_to_pro, 'Usta Moduna Geç (Onboarding)');
          };
        }
        if (t.includes('cikis') || t.includes('çıkış') || t.includes('oturumu kapat') || t.includes('logout')) {
          b.onclick = (e) => {
            e.preventDefault();
            sessionStorage.clear();
            window.bitadilatNav(SPEC.logout_sid, 'Çıkış Yap');
          };
        }
      });
      const navLinks = document.querySelectorAll('footer a, nav a, footer button, nav button, [role="tablist"] button, [role="tablist"] a');
      if (navLinks.length >= 4) {
        navLinks[0].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); };
        navLinks[1].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); };
        navLinks[2].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); };
        navLinks[3].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Profil'); };
      }
    }

    // FLOW 6: USTA HANDLERS
    else if (CURRENT_SID === 'a512d0928f11b9cb02877746d580c548') {
      const submitBtn = document.getElementById('btn-submit-pro');
      if (submitBtn) {
        submitBtn.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Belge İncelemede Bekleme'); };
      }
    }

    else if (CURRENT_SID === 'def294a930bf4bb78f7ba4f857611884') {
      // SCR-P-PENDING Handlers
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('demo') || t.includes('göz at') || t.includes('örnek talep')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Eşleşen Talepler Akışı'); };
        }
        if (t.includes('müşteri moduna') || t.includes('müşteri olarak') || t.includes('switch to customer')) {
          b.onclick = (e) => {
            e.preventDefault();
            sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
            window.bitadilatNav(SPEC.switch_customer_sid, 'Müşteri Moduna Geç');
          };
        }
      });
    }

    else if (CURRENT_SID === '11b9cb02877746d580c5484512d0928f') {
      document.querySelectorAll('button, .bg-surface').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('hazırla') || t.includes('banyo lavabo') || t.includes('borusu onarımı') || t.includes('prepare offer')) {
          b.style.cursor = 'pointer';
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Teklif Hazırlama'); };
        }
      });
      const tabs = document.querySelectorAll('nav a, footer a');
      if (tabs.length >= 4) {
        tabs[0].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Talepler'); };
        tabs[1].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_active_jobs, 'İşlerim'); };
        tabs[2].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); };
        tabs[3].onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); };
      }
    }

    else if (CURRENT_SID === 'b9086f1030784def8eb267fd9110addd') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('gönder') || t.includes('send')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Gönderildi Onayı'); };
        }
      });
    }

    else if (CURRENT_SID === '82f9d783b88b40ec8ca6260566c0f5cb') {
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('akışına dön') || t.includes('taleplere dön') || t.includes('close')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Taleplere Dön'); };
        }
        if (t.includes('müsaitlik') || t.includes('availability')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); };
        }
      });
    }

    else if (CURRENT_SID === 'fc6f0f8e9b724365a5a0f124617dbe7a') {
      const btnSwitch = document.getElementById('btn-switch-to-customer');
      const btnLogout = document.getElementById('btn-pro-logout');
      if (btnSwitch) {
        btnSwitch.onclick = (e) => {
          e.preventDefault();
          sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
          window.bitadilatNav(SPEC.switch_to_customer, 'Müşteri Moduna Geç');
        };
      }
      if (btnLogout) {
        btnLogout.onclick = (e) => {
          e.preventDefault();
          sessionStorage.clear();
          window.bitadilatNav(SPEC.logout_sid, 'Usta Çıkış Yap');
        };
      }
      document.querySelectorAll('button').forEach(b => {
        const t = normText(b);
        if (t.includes('talepler') || t.includes('kaydet') || t.includes('guncelle') || t.includes('güncelle') || t.includes('ayar') || t.includes('save')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talepler Akışı'); };
        }
      });
    }

    else if (CURRENT_SID === '8ba8c346d11c46f39163fd6ebf06dae1') {
      document.querySelectorAll('button').forEach(b => {
        const t = normText(b);
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Müşteriye Mesaj'); };
        }
        if (t.includes('bitirdim') || t.includes('teslim') || t.includes('finish') || t.includes('deliver')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Teslim Bildirimi'); };
        }
        if (t.includes('anlasmazlik') || t.includes('anlaşmazlık') || t.includes('durum bildir') || t.includes('destek') || t.includes('dispute')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.cancel_sid, 'Usta Randevu İptal / Anlaşmazlık'); };
        }
      });
    }

    else if (CURRENT_SID === 'dbf40b28dba64bd1bedb40e075662c42') {
      // SCR-P-CANCEL Handlers
      document.querySelectorAll('button').forEach(b => {
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('fırsat') || t.includes('yeni iş') || t.includes('opportunities')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Yeni İş Fırsatları'); };
        }
        if (t.includes('mesaj') || t.includes('chat')) {
          b.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Müşteri ile Mesajlaş'); };
        }
      });
    }

    else if (CURRENT_SID === 'c6ebf06dae18ba8c346d11c46f39163f') {
      const btnReturn = document.getElementById('btn-return-feed');
      const btnAvail = document.getElementById('btn-goto-availability');
      const btnClose = document.getElementById('btn-close');
      if (btnReturn) btnReturn.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talepler Feed'); };
      if (btnAvail) btnAvail.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); };
      if (btnClose) btnClose.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Kapat'); };
    }

    // FLOW 7: ADMIN & WEB
    else if (CURRENT_SID === '612429fdea1b42a1bf9e628883f7e58f') {
      document.querySelectorAll('a, button').forEach(el => {
        const t = normText(el);
        if (t.includes('sikayet') || t.includes('şikayet') || t.includes('uyusmazlik') || t.includes('uyuşmazlık') || t.includes('dispute')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); };
        if (t.includes('hesap') || t.includes('kullanici') || t.includes('kullanıcı') || t.includes('account')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); };
        if (t.includes('cikis') || t.includes('çıkış') || t.includes('logout')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav('0c06b06e422b40daacbc0b8e6e8fb7bf', 'Çıkış Yap'); };
      });
    }

    else if (CURRENT_SID === 'cb00d67723e34ec990786a82d25c77ca') {
      document.querySelectorAll('a, button').forEach(el => {
        const t = normText(el);
        if (t.includes('belge') || t.includes('profil') || t.includes('document')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); };
        if (t.includes('hesap') || t.includes('kullanici') || t.includes('kullanıcı') || t.includes('account')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); };
        if (t.includes('cikis') || t.includes('çıkış') || t.includes('logout')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav('0c06b06e422b40daacbc0b8e6e8fb7bf', 'Çıkış Yap'); };
      });
    }

    else if (CURRENT_SID === '5ce8968e2703443ca129c0e7c9e9d145') {
      document.querySelectorAll('a, button').forEach(el => {
        const t = normText(el);
        if (t.includes('belge') || t.includes('profil') || t.includes('document')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); };
        if (t.includes('sikayet') || t.includes('şikayet') || t.includes('uyusmazlik') || t.includes('uyuşmazlık') || t.includes('dispute')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); };
        if (t.includes('cikis') || t.includes('çıkış') || t.includes('logout')) el.onclick = (e) => { e.preventDefault(); window.bitadilatNav('0c06b06e422b40daacbc0b8e6e8fb7bf', 'Çıkış Yap'); };
      });
    }

    else if (CURRENT_SID === '164cd33666284338b929a8325dc5ea20') {
      document.querySelectorAll('a, button').forEach(el => {
        const t = normText(el);
        if (t.includes('indir') || t.includes('app store') || t.includes('google play') || t.includes('uygulama') || t.includes('talep') || t.includes('başla') || t.includes('basla') || t.includes('usta çağır') || t.includes('usta cagir') || t.includes('download') || t.includes('request a pro') || t.includes('create request')) {
          el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.start_customer, 'Müşteri Başlat'); };
        }
        if (t.includes('usta ol') || t.includes('usta olarak') || t.includes('katıl') || t.includes('katil') || t.includes('join')) {
          el.onclick = (e) => { e.preventDefault(); window.bitadilatNav(SPEC.start_pro, 'Usta Başlat'); };
        }
      });
    }

  });
})();
</script>
'''

    controller_code = controller_template.replace('__SPEC_JSON__', spec_json).replace('__SID__', sid).replace('__I18N_DICT_JSON__', I18N_DICT_JSON)

    if '</body>' in html:
        html = html.replace('</body>', controller_code + '\n</body>')
    else:
        html += controller_code

    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'Injected i18n controller into [{sid[:8]}] - {s["title"]}')

for s in screens_spec:
    inject_clean_controller(s)

print('All 41 screens updated with clean authoritative navigation controllers!')
