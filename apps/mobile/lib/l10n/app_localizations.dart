import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'BiTadilat'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In tr, this message translates to:
  /// **'Evdeki tamir işi için teklif al, ustanı seç.'**
  String get welcomeTagline;

  /// No description provided for @welcomeBody.
  ///
  /// In tr, this message translates to:
  /// **'Talebini aç, ustalardan teklif gelsin. Ödemeni güvence havuzunda tut, iş bitince onayla.'**
  String get welcomeBody;

  /// No description provided for @actionLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get actionLogin;

  /// No description provided for @actionRegister.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get actionRegister;

  /// No description provided for @languageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languageLabel;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSwitchHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini seç'**
  String get languageSwitchHint;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @showPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get loading;

  /// No description provided for @genericErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu'**
  String get genericErrorTitle;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get loginTitle;

  /// No description provided for @loginIntro.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınla devam et.'**
  String get loginIntro;

  /// No description provided for @fieldIdentifier.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya telefon'**
  String get fieldIdentifier;

  /// No description provided for @hintIdentifier.
  ///
  /// In tr, this message translates to:
  /// **'ad@ornek.com veya 5XX XXX XX XX'**
  String get hintIdentifier;

  /// No description provided for @fieldPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get fieldPassword;

  /// No description provided for @hintPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni gir'**
  String get hintPassword;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPasswordLink;

  /// No description provided for @loginNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get loginNoAccount;

  /// No description provided for @errRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alanı doldur.'**
  String get errRequired;

  /// No description provided for @errEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi hatalı. Örnek: ad@ornek.com'**
  String get errEmailInvalid;

  /// No description provided for @errPhoneInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası eksik. 5XX XXX XX XX biçiminde 10 hane gir.'**
  String get errPhoneInvalid;

  /// No description provided for @errIdentifierInvalid.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini ya da 5XX XXX XX XX biçiminde telefon numaranı gir.'**
  String get errIdentifierInvalid;

  /// No description provided for @errPasswordShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifren en az 8 karakter olmalı.'**
  String get errPasswordShort;

  /// No description provided for @errPasswordWeak.
  ///
  /// In tr, this message translates to:
  /// **'Şifrende en az bir harf ve bir rakam olmalı.'**
  String get errPasswordWeak;

  /// No description provided for @errNameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Adını ve soyadını gir.'**
  String get errNameInvalid;

  /// No description provided for @errCodeInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Kod 6 haneli olmalı. E-postanı kontrol et.'**
  String get errCodeInvalid;

  /// No description provided for @errRoleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bir seçenek belirle.'**
  String get errRoleRequired;

  /// No description provided for @errConsentRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bu onayı vermelisin.'**
  String get errConsentRequired;

  /// No description provided for @errFieldInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan hatalı. Kontrol edip tekrar dene.'**
  String get errFieldInvalid;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get registerTitle;

  /// No description provided for @registerIntro.
  ///
  /// In tr, this message translates to:
  /// **'Birkaç bilgiyle başla.'**
  String get registerIntro;

  /// No description provided for @roleSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı nasıl kullanacaksın?'**
  String get roleSectionTitle;

  /// No description provided for @roleCustomer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri'**
  String get roleCustomer;

  /// No description provided for @roleCustomerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tamir talebi açar, ustalardan teklif alırım.'**
  String get roleCustomerDesc;

  /// No description provided for @rolePro.
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get rolePro;

  /// No description provided for @roleProDesc.
  ///
  /// In tr, this message translates to:
  /// **'Müşterilerin taleplerine teklif veririm.'**
  String get roleProDesc;

  /// No description provided for @fieldFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad'**
  String get fieldFullName;

  /// No description provided for @hintFullName.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Ayşe Yılmaz'**
  String get hintFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get fieldEmail;

  /// No description provided for @hintEmail.
  ///
  /// In tr, this message translates to:
  /// **'ad@ornek.com'**
  String get hintEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @hintPhone.
  ///
  /// In tr, this message translates to:
  /// **'5XX XXX XX XX'**
  String get hintPhone;

  /// No description provided for @helperPassword.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter; harf ve rakam içermeli.'**
  String get helperPassword;

  /// No description provided for @consentKvkk.
  ///
  /// In tr, this message translates to:
  /// **'KVKK aydınlatma metnini okudum.'**
  String get consentKvkk;

  /// No description provided for @consentKvkkRead.
  ///
  /// In tr, this message translates to:
  /// **'KVKK metnini oku'**
  String get consentKvkkRead;

  /// No description provided for @consentTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım koşullarını kabul ediyorum.'**
  String get consentTerms;

  /// No description provided for @consentTermsRead.
  ///
  /// In tr, this message translates to:
  /// **'Koşulları oku'**
  String get consentTermsRead;

  /// No description provided for @registerHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get registerHaveAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotTitle;

  /// No description provided for @forgotIntro.
  ///
  /// In tr, this message translates to:
  /// **'Hesabındaki e-posta adresini gir. Sana 6 haneli bir kod göndereceğiz.'**
  String get forgotIntro;

  /// No description provided for @forgotSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönder'**
  String get forgotSubmit;

  /// No description provided for @forgotSent.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi kayıtlıysa kod gönderildi. Gelen kutunu kontrol et.'**
  String get forgotSent;

  /// No description provided for @resetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre belirle'**
  String get resetTitle;

  /// No description provided for @resetIntro.
  ///
  /// In tr, this message translates to:
  /// **'E-postana gelen 6 haneli kodu ve yeni şifreni gir.'**
  String get resetIntro;

  /// No description provided for @fieldCode.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kod'**
  String get fieldCode;

  /// No description provided for @hintCode.
  ///
  /// In tr, this message translates to:
  /// **'123456'**
  String get hintCode;

  /// No description provided for @fieldNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get fieldNewPassword;

  /// No description provided for @resetSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi değiştir'**
  String get resetSubmit;

  /// No description provided for @resetDone.
  ///
  /// In tr, this message translates to:
  /// **'Şifren değişti. Yeni şifrenle giriş yap.'**
  String get resetDone;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get settingsLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılsın mı?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun bu cihazda kapanır. İstediğin zaman tekrar giriş yapabilirsin.'**
  String get logoutConfirmBody;

  /// No description provided for @tabHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get tabHome;

  /// No description provided for @tabRequests.
  ///
  /// In tr, this message translates to:
  /// **'Taleplerim'**
  String get tabRequests;

  /// No description provided for @tabMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get tabMessages;

  /// No description provided for @tabProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabFeed.
  ///
  /// In tr, this message translates to:
  /// **'Talepler'**
  String get tabFeed;

  /// No description provided for @tabJobs.
  ///
  /// In tr, this message translates to:
  /// **'İşlerim'**
  String get tabJobs;

  /// No description provided for @comingSoonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm hazırlanıyor'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In tr, this message translates to:
  /// **'Hazır olunca burada göreceksin.'**
  String get comingSoonBody;

  /// No description provided for @profileSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get profileSettings;

  /// No description provided for @switchToPro.
  ///
  /// In tr, this message translates to:
  /// **'Usta moduna geç'**
  String get switchToPro;

  /// No description provided for @applyAsPro.
  ///
  /// In tr, this message translates to:
  /// **'Usta olarak başvur'**
  String get applyAsPro;

  /// No description provided for @switchToCustomer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri moduna geç'**
  String get switchToCustomer;

  /// No description provided for @proApplyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Usta başvurusu'**
  String get proApplyTitle;

  /// No description provided for @proApplicationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru durumu'**
  String get proApplicationTitle;

  /// No description provided for @backToCustomerMode.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri moduna dön'**
  String get backToCustomerMode;

  /// No description provided for @statusPendingReview.
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get statusPendingReview;

  /// No description provided for @statusNeedsDocuments.
  ///
  /// In tr, this message translates to:
  /// **'Belge eksik'**
  String get statusNeedsDocuments;

  /// No description provided for @statusRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get statusRejected;

  /// No description provided for @statusSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Askıya alındı'**
  String get statusSuspended;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @chatTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet'**
  String get chatTitle;

  /// No description provided for @notFoundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa bulunamadı'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın sayfa taşınmış ya da hiç var olmamış olabilir.'**
  String get notFoundBody;

  /// No description provided for @notFoundAction.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfaya dön'**
  String get notFoundAction;

  /// No description provided for @legalKvkkTitle.
  ///
  /// In tr, this message translates to:
  /// **'KVKK aydınlatma metni'**
  String get legalKvkkTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım koşulları'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Bu metin yayına alınmadan önce hazırlanacak.'**
  String get legalPlaceholder;

  /// No description provided for @splashErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun açılamadı'**
  String get splashErrorTitle;

  /// No description provided for @noticeAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici hesabıyla web panelinden giriş yap.'**
  String get noticeAdmin;

  /// No description provided for @noticeSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunun süresi doldu. Tekrar giriş yap.'**
  String get noticeSessionExpired;

  /// No description provided for @apiErrorValidationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğin bilgilerde eksik ya da hatalı alan var. Alanları kontrol edip tekrar dene.'**
  String get apiErrorValidationFailed;

  /// No description provided for @apiErrorUnauthenticated.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun geçerli değil. Tekrar giriş yap.'**
  String get apiErrorUnauthenticated;

  /// No description provided for @apiErrorTokenExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunun süresi doldu. Tekrar giriş yap.'**
  String get apiErrorTokenExpired;

  /// No description provided for @apiErrorBadCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta, telefon veya şifre hatalı. Bilgilerini kontrol edip tekrar dene.'**
  String get apiErrorBadCredentials;

  /// No description provided for @apiErrorAccountSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındı. Destek ekibiyle iletişime geç.'**
  String get apiErrorAccountSuspended;

  /// No description provided for @apiErrorForbidden.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok.'**
  String get apiErrorForbidden;

  /// No description provided for @apiErrorProNotApproved.
  ///
  /// In tr, this message translates to:
  /// **'Usta başvurun henüz onaylanmadı. Başvuru durumunu kontrol et.'**
  String get apiErrorProNotApproved;

  /// No description provided for @apiErrorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın içerik bulunamadı. Ana sayfaya dönüp tekrar dene.'**
  String get apiErrorNotFound;

  /// No description provided for @apiErrorIllegalState.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem artık yapılamıyor, ekran güncellendi.'**
  String get apiErrorIllegalState;

  /// No description provided for @apiErrorEmailTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi zaten kayıtlı. Giriş yap ya da başka bir e-posta kullan.'**
  String get apiErrorEmailTaken;

  /// No description provided for @apiErrorPhoneTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu telefon numarası zaten kayıtlı. Giriş yap ya da başka bir numara kullan.'**
  String get apiErrorPhoneTaken;

  /// No description provided for @apiErrorTooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptın. Birkaç dakika bekleyip tekrar dene.'**
  String get apiErrorTooManyAttempts;

  /// No description provided for @apiErrorPaymentDeclined.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme bankan tarafından onaylanmadı. Başka bir kart dene.'**
  String get apiErrorPaymentDeclined;

  /// No description provided for @apiErrorInvalidCard.
  ///
  /// In tr, this message translates to:
  /// **'Kart bilgileri hatalı. Numarayı, son kullanma tarihini ve güvenlik kodunu kontrol et.'**
  String get apiErrorInvalidCard;

  /// No description provided for @apiErrorDuplicateAttempt.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem zaten gönderildi. Birkaç saniye bekle.'**
  String get apiErrorDuplicateAttempt;

  /// No description provided for @apiErrorPaymentInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Ödemen işleniyor. Sonuç gelene kadar bekle.'**
  String get apiErrorPaymentInProgress;

  /// No description provided for @apiErrorOfferExpired.
  ///
  /// In tr, this message translates to:
  /// **'Bu teklifin süresi doldu. Teklif listesine dön.'**
  String get apiErrorOfferExpired;

  /// No description provided for @apiErrorAlreadyOffered.
  ///
  /// In tr, this message translates to:
  /// **'Bu talebe zaten teklif verdin.'**
  String get apiErrorAlreadyOffered;

  /// No description provided for @apiErrorGatewayError.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme sistemine şu an ulaşılamıyor. Birkaç dakika sonra tekrar dene.'**
  String get apiErrorGatewayError;

  /// No description provided for @apiErrorInternalError.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir sorun oluştu. Biraz sonra tekrar dene.'**
  String get apiErrorInternalError;

  /// No description provided for @apiErrorNetworkError.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantına ulaşılamıyor. Bağlantını kontrol edip tekrar dene. Girdiğin bilgiler korundu.'**
  String get apiErrorNetworkError;

  /// No description provided for @apiErrorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Tekrar dene.'**
  String get apiErrorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
