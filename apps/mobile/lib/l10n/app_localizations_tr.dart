// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'BiTadilat';

  @override
  String get welcomeTagline => 'Evdeki tamir işi için teklif al, ustanı seç.';

  @override
  String get welcomeBody =>
      'Talebini aç, ustalardan teklif gelsin. Ödemeni güvence havuzunda tut, iş bitince onayla.';

  @override
  String get actionLogin => 'Giriş yap';

  @override
  String get actionRegister => 'Hesap oluştur';

  @override
  String get languageLabel => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwitchHint => 'Uygulama dilini seç';

  @override
  String get back => 'Geri';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get genericErrorTitle => 'Bir sorun oluştu';

  @override
  String get loginTitle => 'Giriş yap';

  @override
  String get loginIntro => 'Hesabınla devam et.';

  @override
  String get fieldIdentifier => 'E-posta veya telefon';

  @override
  String get hintIdentifier => 'ad@ornek.com veya 5XX XXX XX XX';

  @override
  String get fieldPassword => 'Şifre';

  @override
  String get hintPassword => 'Şifreni gir';

  @override
  String get forgotPasswordLink => 'Şifremi unuttum';

  @override
  String get loginNoAccount => 'Hesabın yok mu?';

  @override
  String get errRequired => 'Bu alanı doldur.';

  @override
  String get errEmailInvalid => 'E-posta adresi hatalı. Örnek: ad@ornek.com';

  @override
  String get errPhoneInvalid =>
      'Telefon numarası eksik. 5XX XXX XX XX biçiminde 10 hane gir.';

  @override
  String get errIdentifierInvalid =>
      'E-posta adresini ya da 5XX XXX XX XX biçiminde telefon numaranı gir.';

  @override
  String get errPasswordShort => 'Şifren en az 8 karakter olmalı.';

  @override
  String get errPasswordWeak => 'Şifrende en az bir harf ve bir rakam olmalı.';

  @override
  String get errNameInvalid => 'Adını ve soyadını gir.';

  @override
  String get errCodeInvalid => 'Kod 6 haneli olmalı. E-postanı kontrol et.';

  @override
  String get errRoleRequired => 'Devam etmek için bir seçenek belirle.';

  @override
  String get errConsentRequired => 'Devam etmek için bu onayı vermelisin.';

  @override
  String get errFieldInvalid => 'Bu alan hatalı. Kontrol edip tekrar dene.';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerIntro => 'Birkaç bilgiyle başla.';

  @override
  String get roleSectionTitle => 'Hesabı nasıl kullanacaksın?';

  @override
  String get roleCustomer => 'Müşteri';

  @override
  String get roleCustomerDesc => 'Tamir talebi açar, ustalardan teklif alırım.';

  @override
  String get rolePro => 'Usta';

  @override
  String get roleProDesc => 'Müşterilerin taleplerine teklif veririm.';

  @override
  String get fieldFullName => 'Ad soyad';

  @override
  String get hintFullName => 'Örn. Ayşe Yılmaz';

  @override
  String get fieldEmail => 'E-posta';

  @override
  String get hintEmail => 'ad@ornek.com';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get hintPhone => '5XX XXX XX XX';

  @override
  String get helperPassword => 'En az 8 karakter; harf ve rakam içermeli.';

  @override
  String get consentKvkk => 'KVKK aydınlatma metnini okudum.';

  @override
  String get consentKvkkRead => 'KVKK metnini oku';

  @override
  String get consentTerms => 'Kullanım koşullarını kabul ediyorum.';

  @override
  String get consentTermsRead => 'Koşulları oku';

  @override
  String get registerHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get forgotTitle => 'Şifremi unuttum';

  @override
  String get forgotIntro =>
      'Hesabındaki e-posta adresini gir. Sana 6 haneli bir kod göndereceğiz.';

  @override
  String get forgotSubmit => 'Kod gönder';

  @override
  String get forgotSent =>
      'E-posta adresi kayıtlıysa kod gönderildi. Gelen kutunu kontrol et.';

  @override
  String get resetTitle => 'Yeni şifre belirle';

  @override
  String get resetIntro => 'E-postana gelen 6 haneli kodu ve yeni şifreni gir.';

  @override
  String get fieldCode => '6 haneli kod';

  @override
  String get hintCode => '123456';

  @override
  String get fieldNewPassword => 'Yeni şifre';

  @override
  String get resetSubmit => 'Şifreyi değiştir';

  @override
  String get resetDone => 'Şifren değişti. Yeni şifrenle giriş yap.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLogout => 'Çıkış yap';

  @override
  String get logoutConfirmTitle => 'Çıkış yapılsın mı?';

  @override
  String get logoutConfirmBody =>
      'Oturumun bu cihazda kapanır. İstediğin zaman tekrar giriş yapabilirsin.';

  @override
  String get tabHome => 'Ana sayfa';

  @override
  String get tabRequests => 'Taleplerim';

  @override
  String get tabMessages => 'Mesajlar';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabFeed => 'Talepler';

  @override
  String get tabJobs => 'İşlerim';

  @override
  String get comingSoonTitle => 'Bu bölüm hazırlanıyor';

  @override
  String get comingSoonBody => 'Hazır olunca burada göreceksin.';

  @override
  String get profileSettings => 'Ayarlar';

  @override
  String get switchToPro => 'Usta moduna geç';

  @override
  String get applyAsPro => 'Usta olarak başvur';

  @override
  String get switchToCustomer => 'Müşteri moduna geç';

  @override
  String get proApplyTitle => 'Usta başvurusu';

  @override
  String get proApplicationTitle => 'Başvuru durumu';

  @override
  String get backToCustomerMode => 'Müşteri moduna dön';

  @override
  String get statusPendingReview => 'İnceleniyor';

  @override
  String get statusNeedsDocuments => 'Belge eksik';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String get statusSuspended => 'Askıya alındı';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get chatTitle => 'Sohbet';

  @override
  String get notFoundTitle => 'Sayfa bulunamadı';

  @override
  String get notFoundBody =>
      'Aradığın sayfa taşınmış ya da hiç var olmamış olabilir.';

  @override
  String get notFoundAction => 'Ana sayfaya dön';

  @override
  String get legalKvkkTitle => 'KVKK aydınlatma metni';

  @override
  String get legalTermsTitle => 'Kullanım koşulları';

  @override
  String get legalPrivacyTitle => 'Gizlilik politikası';

  @override
  String get legalPlaceholder => 'Bu metin yayına alınmadan önce hazırlanacak.';

  @override
  String get splashErrorTitle => 'Oturumun açılamadı';

  @override
  String get noticeAdmin => 'Yönetici hesabıyla web panelinden giriş yap.';

  @override
  String get noticeSessionExpired =>
      'Oturumunun süresi doldu. Tekrar giriş yap.';

  @override
  String get apiErrorValidationFailed =>
      'Girdiğin bilgilerde eksik ya da hatalı alan var. Alanları kontrol edip tekrar dene.';

  @override
  String get apiErrorUnauthenticated =>
      'Oturumun geçerli değil. Tekrar giriş yap.';

  @override
  String get apiErrorTokenExpired =>
      'Oturumunun süresi doldu. Tekrar giriş yap.';

  @override
  String get apiErrorBadCredentials =>
      'E-posta, telefon veya şifre hatalı. Bilgilerini kontrol edip tekrar dene.';

  @override
  String get apiErrorAccountSuspended =>
      'Hesabın askıya alındı. Destek ekibiyle iletişime geç.';

  @override
  String get apiErrorForbidden => 'Bu işlem için yetkin yok.';

  @override
  String get apiErrorProNotApproved =>
      'Usta başvurun henüz onaylanmadı. Başvuru durumunu kontrol et.';

  @override
  String get apiErrorNotFound =>
      'Aradığın içerik bulunamadı. Ana sayfaya dönüp tekrar dene.';

  @override
  String get apiErrorIllegalState =>
      'Bu işlem artık yapılamıyor, ekran güncellendi.';

  @override
  String get apiErrorEmailTaken =>
      'Bu e-posta adresi zaten kayıtlı. Giriş yap ya da başka bir e-posta kullan.';

  @override
  String get apiErrorPhoneTaken =>
      'Bu telefon numarası zaten kayıtlı. Giriş yap ya da başka bir numara kullan.';

  @override
  String get apiErrorTooManyAttempts =>
      'Çok fazla deneme yaptın. Birkaç dakika bekleyip tekrar dene.';

  @override
  String get apiErrorPaymentDeclined =>
      'Ödeme bankan tarafından onaylanmadı. Başka bir kart dene.';

  @override
  String get apiErrorInvalidCard =>
      'Kart bilgileri hatalı. Numarayı, son kullanma tarihini ve güvenlik kodunu kontrol et.';

  @override
  String get apiErrorDuplicateAttempt =>
      'Bu işlem zaten gönderildi. Birkaç saniye bekle.';

  @override
  String get apiErrorPaymentInProgress =>
      'Ödemen işleniyor. Sonuç gelene kadar bekle.';

  @override
  String get apiErrorOfferExpired =>
      'Bu teklifin süresi doldu. Teklif listesine dön.';

  @override
  String get apiErrorAlreadyOffered => 'Bu talebe zaten teklif verdin.';

  @override
  String get apiErrorGatewayError =>
      'Ödeme sistemine şu an ulaşılamıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String get apiErrorInternalError =>
      'Beklenmeyen bir sorun oluştu. Biraz sonra tekrar dene.';

  @override
  String get apiErrorNetworkError =>
      'İnternet bağlantına ulaşılamıyor. Bağlantını kontrol edip tekrar dene. Girdiğin bilgiler korundu.';

  @override
  String get apiErrorUnknown => 'Bir sorun oluştu. Tekrar dene.';
}
