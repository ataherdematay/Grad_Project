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

    controller_code = f'''
<!-- BiTadilat Authoritative Navigation Controller -->
<script>
(function() {{
  const SPEC = {spec_json};
  const CURRENT_SID = "{sid}";

  // Save current role in session storage
  if (SPEC.role === 'PRO') {{
    sessionStorage.setItem('bitadilat_active_role', 'PRO');
  }} else if (SPEC.role === 'CUSTOMER') {{
    sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
  }}

  window.bitadilatNav = function(targetSid, label) {{
    if (!targetSid) return;
    console.log('[BiTadilat Router] Navigating:', CURRENT_SID, '->', targetSid, '(', label || '', ')');
    if (window.parent && window.parent !== window) {{
      window.parent.postMessage({{
        type: 'NAVIGATE',
        from: CURRENT_SID,
        to: targetSid,
        label: label || ''
      }}, '*');
    }} else {{
      window.location.href = './' + targetSid + '.html';
    }}
  }};

  document.addEventListener('DOMContentLoaded', function() {{
    // 1. Remove all disabled locks on interactive prototype triggers
    document.querySelectorAll('button, [role="button"], input[type="submit"]').forEach(btn => {{
      btn.style.cursor = 'pointer';
    }});

    // 2. Prevent default forms from blocking navigation
    document.querySelectorAll('form').forEach(form => {{
      form.onsubmit = function(e) {{
        e.preventDefault();
        if (SPEC.next_sid) window.bitadilatNav(SPEC.next_sid, 'Form Submitted');
        return false;
      }};
    }});

    // 3. Bind Universal Header Back Buttons
    if (SPEC.back_sid) {{
      document.querySelectorAll('button, a').forEach(el => {{
        const text = (el.innerText || '').toLowerCase();
        const aria = (el.getAttribute('aria-label') || '').toLowerCase();
        const html = el.innerHTML || '';
        if (aria.includes('geri') || text.includes('geri') || text.includes('dön') || 
            html.includes('arrow_back') || html.includes('chevron_left') || html.includes('arrow_back_ios')) {{
          el.onclick = function(e) {{
            e.preventDefault();
            e.stopPropagation();
            window.bitadilatNav(SPEC.back_sid, 'Back Target');
          }};
        }}
      }});
    }}

    // 4. Bind Explicit data-nav-target elements
    document.querySelectorAll('[data-nav-target]').forEach(el => {{
      el.onclick = function(e) {{
        e.preventDefault();
        e.stopPropagation();
        window.bitadilatNav(el.getAttribute('data-nav-target'), 'Direct Data Nav');
      }};
    }});

    // 5. Screen-Specific Deterministic Handlers
    if (CURRENT_SID === '0c06b06e422b40daacbc0b8e6e8fb7bf') {{
      let chosenRole = 'homeowner';
      const cHome = document.getElementById('role-homeowner');
      const cPro = document.getElementById('role-professional');
      const btnCont = document.getElementById('btn-continue');
      
      function activateRole(role) {{
        chosenRole = role;
        if (btnCont) {{
          btnCont.removeAttribute('disabled');
          btnCont.style.backgroundColor = '#0F4C5C';
          btnCont.style.color = '#FFFFFF';
          btnCont.style.cursor = 'pointer';
        }}
      }}

      if (cHome) cHome.addEventListener('click', () => activateRole('homeowner'));
      if (cPro) cPro.addEventListener('click', () => activateRole('pro'));

      if (btnCont) {{
        btnCont.onclick = function(e) {{
          e.preventDefault();
          if (chosenRole === 'pro') {{
            sessionStorage.setItem('bitadilat_active_role', 'PRO');
            window.bitadilatNav(SPEC.role_pro, 'Seçilen Rol: Usta Kayıt');
          }} else {{
            sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
            window.bitadilatNav(SPEC.role_homeowner, 'Seçilen Rol: Müşteri Giriş');
          }}
        }};
      }}
    }}

    else if (CURRENT_SID === 'fbbe0f405e1f4531a14dcdd6b1c5736a') {{
      const submitBtn = document.getElementById('submit-btn');
      if (submitBtn) {{
        submitBtn.onclick = function(e) {{
          e.preventDefault();
          window.bitadilatNav(SPEC.next_sid, 'Telefon Doğrulandı -> SMS');
        }};
      }}
    }}

    else if (CURRENT_SID === '42c148a1fb25400ca549481fa6abe01f') {{
      const verifyBtn = document.getElementById('verify-submit-btn');
      if (verifyBtn) {{
        verifyBtn.removeAttribute('disabled');
        verifyBtn.classList.remove('opacity-60', 'pointer-events-none');
        verifyBtn.onclick = function(e) {{
          e.preventDefault();
          window.bitadilatNav(SPEC.next_sid, 'SMS Onaylandı -> Müşteri Ana Sayfa');
        }};
      }}
    }}

    else if (CURRENT_SID === 'cc1f55661a1a4036a890b43d9f15596a') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('talep') || t.includes('başla') || t.includes('oluştur')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talep Oluştur Adım 1'); }};
        }}
      }});
      document.querySelectorAll('.grid > div, .grid > button').forEach(c => {{
        c.style.cursor = 'pointer';
        c.onclick = () => window.bitadilatNav(SPEC.next_sid, 'Kategori Seçimi -> Adım 1');
      }});
      const navLinks = document.querySelectorAll('footer a, nav a, [role="tablist"] a');
      if (navLinks.length >= 4) {{
        navLinks[0].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); }};
        navLinks[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); }};
        navLinks[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); }};
        navLinks[3].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Müşteri Profil'); }};
      }}
    }}

    else if (CURRENT_SID === '44c003fee81d4a188f187608554efdd5') {{
      const cta = document.getElementById('wizard-primary-cta') || document.querySelector('button.bg-primary');
      if (cta) {{
        cta.removeAttribute('disabled');
        cta.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2'); }};
      }}
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('2. adıma') || t.includes('devam et')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'b3c3c2845017451fb1b85b89f04fd4b8') {{
      // Enliven prompt chips
      const taskDesc = document.getElementById('task-description');
      const counter = document.getElementById('char-counter');
      document.querySelectorAll('.prompt-chip').forEach(chip => {{
        chip.style.cursor = 'pointer';
        chip.onclick = function(e) {{
          e.preventDefault();
          const p = chip.getAttribute('data-prompt') || chip.innerText.trim();
          if (taskDesc) {{
            taskDesc.value = (taskDesc.value ? taskDesc.value + ' ' : '') + p;
            if (counter) counter.innerText = taskDesc.value.length + ' / 500';
            chip.classList.add('bg-primary-container', 'text-white');
          }}
        }};
      }});

      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('3. adıma') || t.includes('devam et')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 2 -> Adım 3'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '585d649f4ea046ffa70e4cb481ddd030') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('4. adıma') || t.includes('devam et') || t.includes('gözden geçir')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Adım 3 -> Adım 4'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'a0949c91cbe34557b16273c8e91d067a') {{
      // Bind Edit Buttons
      const editBtns = document.querySelectorAll('button.cursor-pointer');
      if (editBtns.length >= 4) {{
        editBtns[0].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.edit_step1, 'Düzenle: Hizmet'); }};
        editBtns[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.edit_step2, 'Düzenle: Konum'); }};
        editBtns[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.edit_step2, 'Düzenle: Detay'); }};
        editBtns[3].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.edit_step3, 'Düzenle: Fotoğraflar'); }};
      }}
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('yayınla') || t.includes('onayla')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talebi Yayınla'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '94a730cef5374f2ab9632d9acf0d7e19') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('taleplerime')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.see_offers_sid || SPEC.next_sid, 'Gelen Teklifler'); }};
        }}
        if (t.includes('ana sayfa')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav('cc1f55661a1a4036a890b43d9f15596a', 'Ana Sayfaya Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '86fe79e681034183a8681bb0d2893e29') {{
      document.querySelectorAll('button, [data-card]').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('gör') || t.includes('incele')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Gelen Teklifler'); }};
        }}
        if (t.includes('yeni') || t.includes('başlat') || t.includes('talep oluştur')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav('44c003fee81d4a188f187608554efdd5', 'Yeni Talep'); }};
        }}
      }});
      const navLinks = document.querySelectorAll('footer a, nav a');
      if (navLinks.length >= 4) {{
        navLinks[0].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); }};
        navLinks[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); }};
        navLinks[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); }};
        navLinks[3].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Profil'); }};
      }}
    }}

    else if (CURRENT_SID === '994e3b4ffce942ce8778f7a6cfaa42c0') {{
      document.querySelectorAll('button, .bg-surface').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('karşılaştır')) {{
          b.onclick = (e) => {{ e.preventDefault(); e.stopPropagation(); window.bitadilatNav(SPEC.compare_sid, 'Karşılaştır'); }};
        }} else if (t.includes('incele') || t.includes('detay') || (b.innerText || '').includes('Mavi Hat')) {{
          b.style.cursor = 'pointer';
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Detayı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'ea7af2d7298b4b6cb24e4603935503f0') {{
      const acceptBtn = document.getElementById('acceptOfferBtn') || document.querySelector('button.bg-primary-container');
      const rejectBtn = document.getElementById('rejectOfferBtn');
      const askBtn = document.getElementById('askQuestionBtn');

      if (acceptBtn) {{
        acceptBtn.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Kabul Onayı'); }};
      }}
      if (rejectBtn) {{
        rejectBtn.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.reject_sid, 'Teklif Reddetme'); }};
      }}
      if (askBtn) {{
        askBtn.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Ustaya Soru Sor'); }};
      }}
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('soru sor') || t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Ustaya Soru Sor'); }};
        }}
        if (t.includes('profil') || t.includes('hakkında')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.profile_sid, 'Usta Profili'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '45350ca7f3de4ee6bedcde20b5a1b385') {{
      // SCR-C-OFFER-REJ Handlers
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('reddet')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Reddedildi -> Teklifler'); }};
        }}
        if (t.includes('vazgeç') || t.includes('teklife dön')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.back_sid, 'Vazgeç -> Teklife Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '1fc70722168942c4a1933cd9c641ad68') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('incele') || t.includes('seç')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Detayı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '98cd20d6ab4e4f8fbc29bc462ce55cca') {{
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklife dön') || t.includes('teklif')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklife Dön'); }};
        }}
        if (t.includes('soru sor')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Ustaya Mesaj'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '58f9993b5f444ff3a9f9361cb8d3b731') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('kabul et') || t.includes('onayla') || t.includes('randevu')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Randevu Seçimi'); }};
        }}
        if (t.includes('vazgeç')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.back_sid, 'Teklif Detayına Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '1476367258dd4a7aa4b9cbda6b0091c0') {{
      // SCR-C-PAY-ERR Handlers
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('tekrar dene') || t.includes('farklı bir kart')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.retry_sid, 'Ödemeyi Tekrar Dene'); }};
        }}
        if (t.includes('teklif detayına')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.offer_sid, 'Teklif Detayına Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '7c6ec3a02d3347a997a3fc5b1a2c91d0') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('randevu') && (t.includes('gönder') || t.includes('onayla') || t.includes('talebi'))) {{
          b.removeAttribute('disabled');
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Randevu İletildi'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '3bd2afe80ced4d2498ec9f16c7099326') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iş alanı') || t.includes('detayına git') || t.includes('talep')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'İş Alanına Git'); }};
        }}
        if (t.includes('ana sayfa')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav('cc1f55661a1a4036a890b43d9f15596a', 'Ana Sayfaya Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'f3e7de808fdb49c18e3c5d430cb72528') {{
      document.querySelectorAll('button, a, div.cursor-pointer').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlaşma'); }};
        }}
        if (t.includes('ilerlemesi') || t.includes('aşama')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.milestones_sid, 'Aşama Takibi'); }};
        }}
        if (t.includes('değiştir') || t.includes('iptal')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.reschedule_sid, 'Randevu İptal'); }};
        }}
        if (t.includes('teslim') || t.includes('tamamla')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'c9aa92f5a4e04897952d05f30c2aef10') {{
      // Chat Dynamic Persona & Message Submission
      const isPro = sessionStorage.getItem('bitadilat_active_role') === 'PRO';
      if (isPro) {{
        // Switch Header to Client: Ali Yılmaz
        const titleEl = document.querySelector('h1');
        if (titleEl) titleEl.innerText = 'Ali Yılmaz (Müşteri)';
        const avatarEl = document.querySelector('.bg-primary-container span');
        if (avatarEl) avatarEl.innerText = 'AY';
        const backBtn = document.querySelector('header button');
        if (backBtn) {{
          backBtn.onclick = (e) => {{
            e.preventDefault();
            e.stopPropagation();
            window.bitadilatNav(SPEC.pro_back_sid, 'Usta İş Alanına Geri Dön');
          }};
        }}
      }}

      const sendBtn = document.querySelector('button[aria-label="Gönder"]') || document.querySelector('button.send') || document.querySelector('button:has(.material-symbols-outlined)');
      const inp = document.querySelector('input[type="text"]');
      const chatStream = document.querySelector('section.flex-1');

      function sendMessage() {{
        if (!inp || !inp.value.trim() || !chatStream) return;
        const msgText = inp.value.trim();
        const now = new Date();
        const timeStr = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
        
        const bubble = document.createElement('div');
        bubble.className = 'flex flex-col items-end max-w-[85%] ml-auto animate-fade-in';
        bubble.innerHTML = `
          <div class="bg-primary-container rounded-2xl rounded-tr-sm p-3.5 text-white shadow-none">
            <p class="font-body-md text-body-md text-white leading-relaxed">${{msgText}}</p>
            <div class="flex justify-end items-center gap-1 mt-1.5 pt-0.5 text-on-primary-container">
              <span class="font-label-sm text-label-sm text-surface-variant">${{timeStr}}</span>
              <span class="material-symbols-outlined text-[15px] text-surface-variant">done</span>
            </div>
          </div>
        `;
        chatStream.appendChild(bubble);
        inp.value = '';
        chatStream.scrollTop = chatStream.scrollHeight;
      }}

      if (sendBtn) {{
        sendBtn.onclick = (e) => {{
          e.preventDefault();
          sendMessage();
        }};
      }}
      if (inp) {{
        inp.addEventListener('keydown', (e) => {{
          if (e.key === 'Enter') {{
            e.preventDefault();
            sendMessage();
          }}
        }});
      }}
    }}

    else if (CURRENT_SID === 'b89d998c02d34e67b8e8f34334f87f02') {{
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlaş'); }};
        }}
        if (t.includes('sorun') || t.includes('destek') || t.includes('şikayet')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.dispute_sid, 'Şikayet Bildir'); }};
        }}
        if (t.includes('teslim') || t.includes('tamamla')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '6acc9307352f497ca6bd878d628c6a1a') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iptal etmeyi onayla')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Randevu İptali Bildirimi'); }};
        }}
        if (t.includes('koru') || t.includes('vazgeç')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.keep_sid, 'İş Alanına Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'd485263b3ae244a9b35500665b5c759b') {{
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('onayla') || t.includes('değerlendirme')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Puanlama'); }};
        }}
        if (t.includes('sorun') || t.includes('destek') || t.includes('şikayet')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.dispute_sid, 'Şikayet Bildir'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'db8a1b368a7749cbb5fd6cf497f34de6') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('gönder') || t.includes('tamamla') || t.includes('kaydet')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Ana Sayfaya Dön'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '488f3698f93c454099ca2382585aeb66') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('şikayet') && (t.includes('oluştur') || t.includes('ilet') || t.includes('gönder'))) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Şikayet Durumu'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '3bb4b954e5224b0097b2bee12be9bcbf') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('ana sayfa') || t.includes('taleplerime')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Ana Sayfa'); }};
        }}
        if (t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlar'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '20de80b8dc984e86be873761409a2396') {{
      // Customer Profile
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('usta') && (t.includes('moduna geç') || t.includes('profesyoneli'))) {{
          b.onclick = (e) => {{
            e.preventDefault();
            sessionStorage.setItem('bitadilat_active_role', 'PRO');
            window.bitadilatNav(SPEC.switch_to_pro, 'Usta Moduna Geç (Onboarding)');
          }};
        }}
        if (t.includes('çıkış') || t.includes('oturumu kapat')) {{
          b.onclick = (e) => {{
            e.preventDefault();
            sessionStorage.clear();
            window.bitadilatNav(SPEC.logout_sid, 'Çıkış Yap');
          }};
        }}
      }});
      const navLinks = document.querySelectorAll('footer a, nav a');
      if (navLinks.length >= 4) {{
        navLinks[0].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_home, 'Ana Sayfa'); }};
        navLinks[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); }};
        navLinks[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); }};
        navLinks[3].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_profile, 'Profil'); }};
      }}
    }}

    // FLOW 6: USTA HANDLERS
    else if (CURRENT_SID === 'a512d0928f11b9cb02877746d580c548') {{
      const submitBtn = document.getElementById('btn-submit-pro');
      if (submitBtn) {{
        submitBtn.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Belge İncelemede Bekleme'); }};
      }}
    }}

    else if (CURRENT_SID === 'def294a930bf4bb78f7ba4f857611884') {{
      // SCR-P-PENDING Handlers
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('demo') || t.includes('göz at') || t.includes('örnek talep')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Eşleşen Talepler Akışı'); }};
        }}
        if (t.includes('müşteri moduna') || t.includes('müşteri olarak')) {{
          b.onclick = (e) => {{
            e.preventDefault();
            sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
            window.bitadilatNav(SPEC.switch_customer_sid, 'Müşteri Moduna Geç');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '11b9cb02877746d580c5484512d0928f') {{
      document.querySelectorAll('button, .bg-surface').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('hazırla') || t.includes('banyo lavabo') || t.includes('borusu onarımı')) {{
          b.style.cursor = 'pointer';
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Teklif Hazırlama'); }};
        }}
      }});
      const tabs = document.querySelectorAll('nav a, footer a');
      if (tabs.length >= 4) {{
        tabs[0].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Talepler'); }};
        tabs[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_active_jobs, 'İşlerim'); }};
        tabs[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); }};
        tabs[3].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); }};
      }}
    }}

    else if (CURRENT_SID === 'b9086f1030784def8eb267fd9110addd') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('gönder')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teklif Gönderildi Onayı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '82f9d783b88b40ec8ca6260566c0f5cb') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('akışına dön') || t.includes('taleplere dön') || t.includes('close')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Taleplere Dön'); }};
        }}
        if (t.includes('müsaitlik')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'fc6f0f8e9b724365a5a0f124617dbe7a') {{
      const btnSwitch = document.getElementById('btn-switch-to-customer');
      const btnLogout = document.getElementById('btn-pro-logout');
      if (btnSwitch) {{
        btnSwitch.onclick = (e) => {{
          e.preventDefault();
          sessionStorage.setItem('bitadilat_active_role', 'CUSTOMER');
          window.bitadilatNav(SPEC.switch_to_customer, 'Müşteri Moduna Geç');
        }};
      }}
      if (btnLogout) {{
        btnLogout.onclick = (e) => {{
          e.preventDefault();
          sessionStorage.clear();
          window.bitadilatNav(SPEC.logout_sid, 'Usta Çıkış Yap');
        }};
      }}
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('talepler') || t.includes('kaydet')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talepler Akışı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '8ba8c346d11c46f39163fd6ebf06dae1') {{
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Müşteriye Mesaj'); }};
        }}
        if (t.includes('bitirdim') || t.includes('teslim')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Usta Teslim Bildirimi'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'dbf40b28dba64bd1bedb40e075662c42') {{
      // SCR-P-CANCEL Handlers
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('fırsat') || t.includes('yeni iş')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Yeni İş Fırsatları'); }};
        }}
        if (t.includes('mesaj')) {{
          b.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Müşteri ile Mesajlaş'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'c6ebf06dae18ba8c346d11c46f39163f') {{
      const btnReturn = document.getElementById('btn-return-feed');
      const btnAvail = document.getElementById('btn-goto-availability');
      const btnClose = document.getElementById('btn-close');
      if (btnReturn) btnReturn.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talepler Feed'); }};
      if (btnAvail) btnAvail.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); }};
      if (btnClose) btnClose.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Kapat'); }};
    }}

    // FLOW 7: ADMIN & WEB
    else if (CURRENT_SID === '612429fdea1b42a1bf9e628883f7e58f') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('şikayet') || t.includes('uyuşmazlık')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); }};
        if (t.includes('hesap') || t.includes('kullanıcı')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); }};
      }});
    }}

    else if (CURRENT_SID === 'cb00d67723e34ec990786a82d25c77ca') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('belge') || t.includes('profil')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); }};
        if (t.includes('hesap') || t.includes('kullanıcı')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); }};
      }});
    }}

    else if (CURRENT_SID === '5ce8968e2703443ca129c0e7c9e9d145') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('belge') || t.includes('profil')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); }};
        if (t.includes('şikayet') || t.includes('uyuşmazlık')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); }};
      }});
    }}

    else if (CURRENT_SID === '164cd33666284338b929a8325dc5ea20') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('usta çağır') || t.includes('başla') || t.includes('talep')) {{
          el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.start_customer, 'Müşteri Başlat'); }};
        }}
        if (t.includes('usta ol') || t.includes('usta olarak') || t.includes('katıl')) {{
          el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.start_pro, 'Usta Başlat'); }};
        }}
      }});
    }}

  }});
}})();
</script>
'''

    if '</body>' in html:
        html = html.replace('</body>', controller_code + '\n</body>')
    else:
        html += controller_code

    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'Injected controller into [{sid[:8]}] - {s["title"]}')

for s in screens_spec:
    inject_clean_controller(s)

print('All 41 screens updated with clean authoritative navigation controllers!')
