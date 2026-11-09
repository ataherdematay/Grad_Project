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

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @searchLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get searchLabel;

  /// No description provided for @noSearchResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noSearchResults;

  /// No description provided for @pickerNone.
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get pickerNone;

  /// No description provided for @photoLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf yüklenemedi'**
  String get photoLoadFailed;

  /// No description provided for @goHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfaya git'**
  String get goHome;

  /// No description provided for @goToMyRequests.
  ///
  /// In tr, this message translates to:
  /// **'Taleplerime git'**
  String get goToMyRequests;

  /// No description provided for @noteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get noteOptional;

  /// No description provided for @reasonRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bir gerekçe seç.'**
  String get reasonRequired;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @labor.
  ///
  /// In tr, this message translates to:
  /// **'İşçilik'**
  String get labor;

  /// No description provided for @materials.
  ///
  /// In tr, this message translates to:
  /// **'Malzeme'**
  String get materials;

  /// No description provided for @totalVatIncluded.
  ///
  /// In tr, this message translates to:
  /// **'Toplam tutar (KDV dahil)'**
  String get totalVatIncluded;

  /// No description provided for @vatIncluded.
  ///
  /// In tr, this message translates to:
  /// **'KDV dahil'**
  String get vatIncluded;

  /// No description provided for @warranty.
  ///
  /// In tr, this message translates to:
  /// **'İşçilik garantisi'**
  String get warranty;

  /// No description provided for @warrantyNone.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get warrantyNone;

  /// No description provided for @warrantyMonths.
  ///
  /// In tr, this message translates to:
  /// **'{months} ay'**
  String warrantyMonths(int months);

  /// No description provided for @warrantyHelp.
  ///
  /// In tr, this message translates to:
  /// **'Platform garanti vermez; garantiyi sen verirsin.'**
  String get warrantyHelp;

  /// No description provided for @arrival.
  ///
  /// In tr, this message translates to:
  /// **'Varış aralığı'**
  String get arrival;

  /// No description provided for @urgencyUrgent.
  ///
  /// In tr, this message translates to:
  /// **'Acil onarım'**
  String get urgencyUrgent;

  /// No description provided for @urgencyPlanned.
  ///
  /// In tr, this message translates to:
  /// **'Planlı iş'**
  String get urgencyPlanned;

  /// No description provided for @tabActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get tabActive;

  /// No description provided for @tabPast.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get tabPast;

  /// No description provided for @dateToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get dateTomorrow;

  /// No description provided for @requestAwaitingOffers.
  ///
  /// In tr, this message translates to:
  /// **'Teklif bekleniyor'**
  String get requestAwaitingOffers;

  /// No description provided for @requestOffersCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} teklif geldi'**
  String requestOffersCount(int count);

  /// No description provided for @requestAssigned.
  ///
  /// In tr, this message translates to:
  /// **'Usta seçildi'**
  String get requestAssigned;

  /// No description provided for @requestCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get requestCancelled;

  /// No description provided for @requestExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get requestExpired;

  /// No description provided for @offerPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get offerPending;

  /// No description provided for @offerAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Kabul edildi'**
  String get offerAccepted;

  /// No description provided for @offerDeclined.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get offerDeclined;

  /// No description provided for @offerWithdrawn.
  ///
  /// In tr, this message translates to:
  /// **'Geri çekildi'**
  String get offerWithdrawn;

  /// No description provided for @offerSuperseded.
  ///
  /// In tr, this message translates to:
  /// **'Başka teklif seçildi'**
  String get offerSuperseded;

  /// No description provided for @offerExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get offerExpired;

  /// No description provided for @statusApproved.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulandı'**
  String get statusApproved;

  /// No description provided for @proVerified.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulandı'**
  String get proVerified;

  /// No description provided for @photoAdd.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get photoAdd;

  /// No description provided for @photoFromCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamerayla çek'**
  String get photoFromCamera;

  /// No description provided for @photoFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get photoFromGallery;

  /// No description provided for @photoRemove.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı kaldır'**
  String get photoRemove;

  /// No description provided for @photoUploading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get photoUploading;

  /// No description provided for @photoUploaded.
  ///
  /// In tr, this message translates to:
  /// **'Yüklendi'**
  String get photoUploaded;

  /// No description provided for @photoLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {count} fotoğraf eklenebilir'**
  String photoLimitReached(int count);

  /// No description provided for @photoTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf 1,5 MB sınırını aşıyor. Daha küçük bir fotoğraf seç.'**
  String get photoTooLarge;

  /// No description provided for @addressesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Adreslerim'**
  String get addressesTitle;

  /// No description provided for @addressAdd.
  ///
  /// In tr, this message translates to:
  /// **'Adres ekle'**
  String get addressAdd;

  /// No description provided for @addressDefault.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan'**
  String get addressDefault;

  /// No description provided for @addressMakeDefault.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan yap'**
  String get addressMakeDefault;

  /// No description provided for @addressesEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı adresin yok'**
  String get addressesEmptyTitle;

  /// No description provided for @addressesEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Talep oluştururken kullanmak için bir adres ekle.'**
  String get addressesEmptyBody;

  /// No description provided for @addressDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Adres silinsin mi?'**
  String get addressDeleteTitle;

  /// No description provided for @addressDeleteMessage.
  ///
  /// In tr, this message translates to:
  /// **'\"{label}\" adresi silinir. Bu işlem geri alınamaz.'**
  String addressDeleteMessage(String label);

  /// No description provided for @addressLabelField.
  ///
  /// In tr, this message translates to:
  /// **'Adres adı'**
  String get addressLabelField;

  /// No description provided for @addressLabelHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Ev, İş'**
  String get addressLabelHint;

  /// No description provided for @addressDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get addressDistrict;

  /// No description provided for @addressNeighborhood.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle'**
  String get addressNeighborhood;

  /// No description provided for @addressLine.
  ///
  /// In tr, this message translates to:
  /// **'Açık adres'**
  String get addressLine;

  /// No description provided for @addressLineHint.
  ///
  /// In tr, this message translates to:
  /// **'Cadde, sokak, bina ve daire no'**
  String get addressLineHint;

  /// No description provided for @addressDoorNote.
  ///
  /// In tr, this message translates to:
  /// **'Kapı notu (isteğe bağlı)'**
  String get addressDoorNote;

  /// No description provided for @addressDoorNoteHelp.
  ///
  /// In tr, this message translates to:
  /// **'Tam adres ve kapı notu yalnızca usta seçildikten sonra paylaşılır.'**
  String get addressDoorNoteHelp;

  /// No description provided for @createRequest.
  ///
  /// In tr, this message translates to:
  /// **'Talep oluştur'**
  String get createRequest;

  /// No description provided for @homeGreeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeActiveRequest.
  ///
  /// In tr, this message translates to:
  /// **'Aktif talebin'**
  String get homeActiveRequest;

  /// No description provided for @homeNoActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif talebin yok'**
  String get homeNoActiveTitle;

  /// No description provided for @homeNoActiveBody.
  ///
  /// In tr, this message translates to:
  /// **'Evdeki tamir işi için talep aç, ustalardan teklif gelsin.'**
  String get homeNoActiveBody;

  /// No description provided for @seeOffers.
  ///
  /// In tr, this message translates to:
  /// **'Teklifleri gör ({count})'**
  String seeOffers(int count);

  /// No description provided for @offerRange.
  ///
  /// In tr, this message translates to:
  /// **'{min} - {max}'**
  String offerRange(String min, String max);

  /// No description provided for @requestsEmptyActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif talebin yok'**
  String get requestsEmptyActiveTitle;

  /// No description provided for @requestsEmptyActiveBody.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir talep açarak ustalardan teklif alabilirsin.'**
  String get requestsEmptyActiveBody;

  /// No description provided for @requestsEmptyPastTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş talebin yok'**
  String get requestsEmptyPastTitle;

  /// No description provided for @requestsEmptyPastBody.
  ///
  /// In tr, this message translates to:
  /// **'İptal ettiğin ya da süresi dolan talepler burada görünür.'**
  String get requestsEmptyPastBody;

  /// No description provided for @requestDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep detayı'**
  String get requestDetailTitle;

  /// No description provided for @requestCode.
  ///
  /// In tr, this message translates to:
  /// **'Talep kodu'**
  String get requestCode;

  /// No description provided for @requestLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get requestLocation;

  /// No description provided for @requestExpiresOn.
  ///
  /// In tr, this message translates to:
  /// **'Son gün'**
  String get requestExpiresOn;

  /// No description provided for @requestAnswers.
  ///
  /// In tr, this message translates to:
  /// **'Cevapların'**
  String get requestAnswers;

  /// No description provided for @requestPhotos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar'**
  String get requestPhotos;

  /// No description provided for @requestCancel.
  ///
  /// In tr, this message translates to:
  /// **'Talebi iptal et'**
  String get requestCancel;

  /// No description provided for @keepRequest.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç, talebi koru'**
  String get keepRequest;

  /// No description provided for @cancelReasonTitle.
  ///
  /// In tr, this message translates to:
  /// **'İptal gerekçesi'**
  String get cancelReasonTitle;

  /// No description provided for @cancelReasonPlansChanged.
  ///
  /// In tr, this message translates to:
  /// **'Planlarım değişti'**
  String get cancelReasonPlansChanged;

  /// No description provided for @cancelReasonSolved.
  ///
  /// In tr, this message translates to:
  /// **'Sorunu çözdüm'**
  String get cancelReasonSolved;

  /// No description provided for @cancelReasonNoSuitableOffer.
  ///
  /// In tr, this message translates to:
  /// **'Uygun teklif gelmedi'**
  String get cancelReasonNoSuitableOffer;

  /// No description provided for @cancelReasonOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get cancelReasonOther;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talep iptal edilsin mi?'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen tüm teklifler kapanır. Bu işlem geri alınamaz.'**
  String get cancelConfirmMessage;

  /// No description provided for @publishedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talebin yayınlandı'**
  String get publishedTitle;

  /// No description provided for @publishedMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} usta eşleşti'**
  String publishedMatchTitle(int count);

  /// No description provided for @publishedMatchBody.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen ustalara bildirim gitti. Teklifler geldikçe Taleplerim sekmesinde göreceksin.'**
  String get publishedMatchBody;

  /// No description provided for @publishedNoMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an eşleşen usta yok'**
  String get publishedNoMatchTitle;

  /// No description provided for @publishedNoMatchBody.
  ///
  /// In tr, this message translates to:
  /// **'Talebin açık kalırsa bölgene yeni ustalar katıldığında görebilir. İstersen talebi düzenleyip kategori ya da konumu değiştir.'**
  String get publishedNoMatchBody;

  /// No description provided for @matchReasons.
  ///
  /// In tr, this message translates to:
  /// **'Neden eşleşti'**
  String get matchReasons;

  /// No description provided for @matchCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriye uygun'**
  String get matchCategory;

  /// No description provided for @matchDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçende hizmet veriyor'**
  String get matchDistrict;

  /// No description provided for @matchAvailability.
  ///
  /// In tr, this message translates to:
  /// **'Şu an müsait'**
  String get matchAvailability;

  /// No description provided for @keepOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık tut'**
  String get keepOpen;

  /// No description provided for @wizTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni talep'**
  String get wizTitle;

  /// No description provided for @wizEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Talebi düzenle'**
  String get wizEditTitle;

  /// No description provided for @wizStepOf.
  ///
  /// In tr, this message translates to:
  /// **'Adım {step} / {total}'**
  String wizStepOf(int step, int total);

  /// No description provided for @wizContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get wizContinue;

  /// No description provided for @wizBackToReview.
  ///
  /// In tr, this message translates to:
  /// **'Gözden geçir'**
  String get wizBackToReview;

  /// No description provided for @wizPublish.
  ///
  /// In tr, this message translates to:
  /// **'Talebi yayınla'**
  String get wizPublish;

  /// No description provided for @wizSaveChanges.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri kaydet'**
  String get wizSaveChanges;

  /// No description provided for @wizStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Kategori ve aciliyet'**
  String get wizStep1Title;

  /// No description provided for @wizStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Konum ve detaylar'**
  String get wizStep2Title;

  /// No description provided for @wizStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ve açıklama'**
  String get wizStep3Title;

  /// No description provided for @wizStep4Title.
  ///
  /// In tr, this message translates to:
  /// **'Gözden geçir'**
  String get wizStep4Title;

  /// No description provided for @wizCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get wizCategory;

  /// No description provided for @wizUrgency.
  ///
  /// In tr, this message translates to:
  /// **'Aciliyet'**
  String get wizUrgency;

  /// No description provided for @wizUrgentHint.
  ///
  /// In tr, this message translates to:
  /// **'Mümkün olan en kısa sürede'**
  String get wizUrgentHint;

  /// No description provided for @wizPlannedHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygun olduğun tarih aralığını seç'**
  String get wizPlannedHint;

  /// No description provided for @wizDates.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı'**
  String get wizDates;

  /// No description provided for @wizDateFrom.
  ///
  /// In tr, this message translates to:
  /// **'En erken'**
  String get wizDateFrom;

  /// No description provided for @wizDateTo.
  ///
  /// In tr, this message translates to:
  /// **'En geç'**
  String get wizDateTo;

  /// No description provided for @wizAddress.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get wizAddress;

  /// No description provided for @wizAddAddress.
  ///
  /// In tr, this message translates to:
  /// **'Yeni adres ekle'**
  String get wizAddAddress;

  /// No description provided for @wizFieldTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get wizFieldTitle;

  /// No description provided for @wizFieldTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn. Mutfak musluğu damlatıyor'**
  String get wizFieldTitleHint;

  /// No description provided for @wizFieldDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get wizFieldDescription;

  /// No description provided for @wizFieldDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Sorunu ve ustanın bilmesi gerekenleri yaz'**
  String get wizFieldDescriptionHint;

  /// No description provided for @wizDescriptionCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} / en az {min} karakter'**
  String wizDescriptionCount(int count, int min);

  /// No description provided for @wizPhotos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar (en fazla {max})'**
  String wizPhotos(int max);

  /// No description provided for @wizPhotosHint.
  ///
  /// In tr, this message translates to:
  /// **'Sorunu gösteren net fotoğraflar teklif almanı kolaylaştırır.'**
  String get wizPhotosHint;

  /// No description provided for @wizPhotosCount.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf sayısı'**
  String get wizPhotosCount;

  /// No description provided for @wizReviewNote.
  ///
  /// In tr, this message translates to:
  /// **'Yayınladığında eşleşen ustalara bildirim gider.'**
  String get wizReviewNote;

  /// No description provided for @wizErrCategory.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bir kategori seç.'**
  String get wizErrCategory;

  /// No description provided for @wizErrDateFrom.
  ///
  /// In tr, this message translates to:
  /// **'En erken tarihi seç.'**
  String get wizErrDateFrom;

  /// No description provided for @wizErrDateTo.
  ///
  /// In tr, this message translates to:
  /// **'En geç tarihi seç.'**
  String get wizErrDateTo;

  /// No description provided for @wizErrDateOrder.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş, başlangıçtan sonra olmalı.'**
  String get wizErrDateOrder;

  /// No description provided for @wizErrDatePast.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç ileri bir zamanda olmalı.'**
  String get wizErrDatePast;

  /// No description provided for @wizErrDateRange.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı en fazla 30 gün sonrasına kadar olabilir.'**
  String get wizErrDateRange;

  /// No description provided for @wizErrAddress.
  ///
  /// In tr, this message translates to:
  /// **'Bir adres seç ya da yeni adres ekle.'**
  String get wizErrAddress;

  /// No description provided for @wizErrAnswers.
  ///
  /// In tr, this message translates to:
  /// **'Tüm soruları cevapla.'**
  String get wizErrAnswers;

  /// No description provided for @wizErrTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık {min}-{max} karakter olmalı.'**
  String wizErrTitle(int min, int max);

  /// No description provided for @wizErrDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama en az {min} karakter olmalı.'**
  String wizErrDescription(int min);

  /// No description provided for @wizErrPhotosBusy.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar yüklenirken bekle.'**
  String get wizErrPhotosBusy;

  /// No description provided for @wizErrPhotosFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemeyen fotoğrafı yeniden dene ya da kaldır.'**
  String get wizErrPhotosFailed;

  /// No description provided for @offersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelen teklifler'**
  String get offersTitle;

  /// No description provided for @offersResultCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} teklif'**
  String offersResultCount(int count);

  /// No description provided for @offersDeclinedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} teklifi reddettin.'**
  String offersDeclinedCount(int count);

  /// No description provided for @offersEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz teklif yok'**
  String get offersEmptyTitle;

  /// No description provided for @offersEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Ustalar teklif verdikçe burada göreceksin.'**
  String get offersEmptyBody;

  /// No description provided for @offersEmptyFilteredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtreye uyan teklif yok'**
  String get offersEmptyFilteredTitle;

  /// No description provided for @offersEmptyFilteredBody.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri gevşetip tekrar dene.'**
  String get offersEmptyFilteredBody;

  /// No description provided for @offersClearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get offersClearFilters;

  /// No description provided for @offersFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele ve sırala'**
  String get offersFilterTitle;

  /// No description provided for @sortBy.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sortBy;

  /// No description provided for @sortRecommended.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen'**
  String get sortRecommended;

  /// No description provided for @sortPrice.
  ///
  /// In tr, this message translates to:
  /// **'En düşük fiyat'**
  String get sortPrice;

  /// No description provided for @sortRating.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek puan'**
  String get sortRating;

  /// No description provided for @sortArrival.
  ///
  /// In tr, this message translates to:
  /// **'En hızlı varış'**
  String get sortArrival;

  /// No description provided for @filterMaxPrice.
  ///
  /// In tr, this message translates to:
  /// **'Üst fiyat sınırı'**
  String get filterMaxPrice;

  /// No description provided for @filterMaxPriceLabel.
  ///
  /// In tr, this message translates to:
  /// **'En çok (₺)'**
  String get filterMaxPriceLabel;

  /// No description provided for @filterMaxPriceHelp.
  ///
  /// In tr, this message translates to:
  /// **'İşçilik ve malzeme dahil. Boş bırakırsan sınır olmaz.'**
  String get filterMaxPriceHelp;

  /// No description provided for @filterMinRating.
  ///
  /// In tr, this message translates to:
  /// **'Usta puanı'**
  String get filterMinRating;

  /// No description provided for @filterAnyRating.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get filterAnyRating;

  /// No description provided for @filterRatingOrMore.
  ///
  /// In tr, this message translates to:
  /// **'{rating}+'**
  String filterRatingOrMore(String rating);

  /// No description provided for @applyFilters.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçları uygula'**
  String get applyFilters;

  /// No description provided for @compare.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştır'**
  String get compare;

  /// No description provided for @compareCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get compareCancel;

  /// No description provided for @compareHint.
  ///
  /// In tr, this message translates to:
  /// **'2 ya da 3 teklif seç.'**
  String get compareHint;

  /// No description provided for @compareSelected.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştır ({count})'**
  String compareSelected(int count);

  /// No description provided for @compareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırma'**
  String get compareTitle;

  /// No description provided for @compareTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam (KDV dahil)'**
  String get compareTotal;

  /// No description provided for @compareGoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklifler artık listede yok'**
  String get compareGoneTitle;

  /// No description provided for @compareGoneBody.
  ///
  /// In tr, this message translates to:
  /// **'Teklifler geri çekilmiş ya da süresi dolmuş olabilir.'**
  String get compareGoneBody;

  /// No description provided for @compareBackToOffers.
  ///
  /// In tr, this message translates to:
  /// **'Tekliflere dön'**
  String get compareBackToOffers;

  /// No description provided for @viewOffer.
  ///
  /// In tr, this message translates to:
  /// **'Teklifi gör'**
  String get viewOffer;

  /// No description provided for @proRating.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get proRating;

  /// No description provided for @proCompletedJobs.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan iş'**
  String get proCompletedJobs;

  /// No description provided for @noRatingYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz puan yok'**
  String get noRatingYet;

  /// No description provided for @ratingWithCount.
  ///
  /// In tr, this message translates to:
  /// **'{avg} ({count})'**
  String ratingWithCount(String avg, int count);

  /// No description provided for @offerDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif'**
  String get offerDetailTitle;

  /// No description provided for @offerBreakdown.
  ///
  /// In tr, this message translates to:
  /// **'Teklif dökümü'**
  String get offerBreakdown;

  /// No description provided for @offerNote.
  ///
  /// In tr, this message translates to:
  /// **'Usta notu'**
  String get offerNote;

  /// No description provided for @offerValidUntil.
  ///
  /// In tr, this message translates to:
  /// **'Geçerlilik'**
  String get offerValidUntil;

  /// No description provided for @offerAccept.
  ///
  /// In tr, this message translates to:
  /// **'Teklifi kabul et'**
  String get offerAccept;

  /// No description provided for @offerDecline.
  ///
  /// In tr, this message translates to:
  /// **'Teklifi reddet'**
  String get offerDecline;

  /// No description provided for @viewProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili görüntüle'**
  String get viewProfile;

  /// No description provided for @declineIntro.
  ///
  /// In tr, this message translates to:
  /// **'{pro} tarafından gelen {amount} tutarındaki teklifi reddetmek üzeresin.'**
  String declineIntro(String pro, String amount);

  /// No description provided for @declineIrreversible.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz; ustanın profiline olumsuz yansımaz.'**
  String get declineIrreversible;

  /// No description provided for @declineReasonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Reddetme sebebi'**
  String get declineReasonTitle;

  /// No description provided for @declineReasonPrice.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat bütçeme uygun değil'**
  String get declineReasonPrice;

  /// No description provided for @declineReasonSchedule.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlama planıma uymuyor'**
  String get declineReasonSchedule;

  /// No description provided for @declineReasonOtherOffer.
  ///
  /// In tr, this message translates to:
  /// **'Başka bir teklifle ilerlemeye karar verdim'**
  String get declineReasonOtherOffer;

  /// No description provided for @declineReasonNotNeeded.
  ///
  /// In tr, this message translates to:
  /// **'Artık bu hizmete ihtiyacım kalmadı'**
  String get declineReasonNotNeeded;

  /// No description provided for @declineReasonOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get declineReasonOther;

  /// No description provided for @declineKeepOpen.
  ///
  /// In tr, this message translates to:
  /// **'Talebim açık kalsın'**
  String get declineKeepOpen;

  /// No description provided for @declineKeepOpenHelp.
  ///
  /// In tr, this message translates to:
  /// **'Kapalıysa talebin de iptal edilir.'**
  String get declineKeepOpenHelp;

  /// No description provided for @declineCloseNeedsReason.
  ///
  /// In tr, this message translates to:
  /// **'Talebi kapatmak için \"Artık ihtiyacım kalmadı\" ya da \"Diğer\" seç.'**
  String get declineCloseNeedsReason;

  /// No description provided for @declineConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif reddedilsin mi?'**
  String get declineConfirmTitle;

  /// No description provided for @declineConfirmKeepOpen.
  ///
  /// In tr, this message translates to:
  /// **'Teklif reddedilir, talebin açık kalır. Bu işlem geri alınamaz.'**
  String get declineConfirmKeepOpen;

  /// No description provided for @declineConfirmClose.
  ///
  /// In tr, this message translates to:
  /// **'Teklif reddedilir ve talebin iptal edilir. Bu işlem geri alınamaz.'**
  String get declineConfirmClose;

  /// No description provided for @declineBack.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç, teklife dön'**
  String get declineBack;

  /// No description provided for @proProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Usta profili'**
  String get proProfileTitle;

  /// No description provided for @proReviews.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeler'**
  String get proReviews;

  /// No description provided for @proAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get proAbout;

  /// No description provided for @proExperience.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim'**
  String get proExperience;

  /// No description provided for @experienceYears.
  ///
  /// In tr, this message translates to:
  /// **'{years} yıl'**
  String experienceYears(int years);

  /// No description provided for @proMemberSince.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik'**
  String get proMemberSince;

  /// No description provided for @proVerifiedDocuments.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulanmış belgeler'**
  String get proVerifiedDocuments;

  /// No description provided for @proNoVerifiedDocs.
  ///
  /// In tr, this message translates to:
  /// **'Henüz doğrulanmış belge yok.'**
  String get proNoVerifiedDocs;

  /// No description provided for @proCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get proCategories;

  /// No description provided for @proServiceAreas.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet bölgeleri'**
  String get proServiceAreas;

  /// No description provided for @docIdentity.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik'**
  String get docIdentity;

  /// No description provided for @docTradeCert.
  ///
  /// In tr, this message translates to:
  /// **'Mesleki yeterlilik'**
  String get docTradeCert;

  /// No description provided for @docTax.
  ///
  /// In tr, this message translates to:
  /// **'Vergi levhası'**
  String get docTax;

  /// No description provided for @docCriminalRecord.
  ///
  /// In tr, this message translates to:
  /// **'Adli sicil kaydı'**
  String get docCriminalRecord;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değerlendirme yok'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriler işi tamamlayınca değerlendirmeler burada görünür.'**
  String get reviewsEmptyBody;

  /// No description provided for @starsOutOf5.
  ///
  /// In tr, this message translates to:
  /// **'5 üzerinden {rating} yıldız'**
  String starsOutOf5(int rating);

  /// No description provided for @anonymous.
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get anonymous;

  /// No description provided for @applyIntro.
  ///
  /// In tr, this message translates to:
  /// **'İşletme bilgilerini ve belgelerini gönder; ekibimiz inceleyip dönüş yapar.'**
  String get applyIntro;

  /// No description provided for @applyBusinessName.
  ///
  /// In tr, this message translates to:
  /// **'İşletme adı'**
  String get applyBusinessName;

  /// No description provided for @applyBusinessNameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'İşletme adı en az 2 karakter olmalı.'**
  String get applyBusinessNameInvalid;

  /// No description provided for @applyAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında (isteğe bağlı)'**
  String get applyAbout;

  /// No description provided for @applyExperience.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim (yıl)'**
  String get applyExperience;

  /// No description provided for @applyExperienceInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim 0 ile 60 yıl arasında olmalı.'**
  String get applyExperienceInvalid;

  /// No description provided for @applyCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get applyCategories;

  /// No description provided for @applyDistricts.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet verdiğin ilçeler'**
  String get applyDistricts;

  /// No description provided for @applyDocuments.
  ///
  /// In tr, this message translates to:
  /// **'Belgeler'**
  String get applyDocuments;

  /// No description provided for @applyDocumentsHelp.
  ///
  /// In tr, this message translates to:
  /// **'Belgelerin fotoğrafını yükle. Kimlik ve mesleki yeterlilik zorunlu.'**
  String get applyDocumentsHelp;

  /// No description provided for @docRequired.
  ///
  /// In tr, this message translates to:
  /// **'{doc} (zorunlu)'**
  String docRequired(String doc);

  /// No description provided for @docOptional.
  ///
  /// In tr, this message translates to:
  /// **'{doc} (isteğe bağlı)'**
  String docOptional(String doc);

  /// No description provided for @docMissing.
  ///
  /// In tr, this message translates to:
  /// **'{doc} belgesini yükle.'**
  String docMissing(String doc);

  /// No description provided for @applySubmit.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu gönder'**
  String get applySubmit;

  /// No description provided for @applyResubmit.
  ///
  /// In tr, this message translates to:
  /// **'Belgeleri güncelle ve yeniden gönder'**
  String get applyResubmit;

  /// No description provided for @applicationPendingBody.
  ///
  /// In tr, this message translates to:
  /// **'Belgelerin ve profilin kalite ekibimiz tarafından inceleniyor. Sonuç çıkınca durumun burada güncellenir.'**
  String get applicationPendingBody;

  /// No description provided for @applicationNeedsBody.
  ///
  /// In tr, this message translates to:
  /// **'Bazı belgelerin eksik ya da okunmuyor. Formu açıp belgeleri güncelleyerek yeniden gönder.'**
  String get applicationNeedsBody;

  /// No description provided for @applicationRejectedBody.
  ///
  /// In tr, this message translates to:
  /// **'Başvurun kabul edilmedi. Notu okuyup belgelerini düzelterek yeniden başvurabilirsin.'**
  String get applicationRejectedBody;

  /// No description provided for @applicationSuspendedBody.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındı. Destek ekibiyle iletişime geç.'**
  String get applicationSuspendedBody;

  /// No description provided for @adminNote.
  ///
  /// In tr, this message translates to:
  /// **'İnceleme notu'**
  String get adminNote;

  /// No description provided for @docStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get docStatusPending;

  /// No description provided for @docStatusAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Kabul edildi'**
  String get docStatusAccepted;

  /// No description provided for @docStatusRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get docStatusRejected;

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @filterUrgent.
  ///
  /// In tr, this message translates to:
  /// **'Acil'**
  String get filterUrgent;

  /// No description provided for @filterPlanned.
  ///
  /// In tr, this message translates to:
  /// **'Planlı'**
  String get filterPlanned;

  /// No description provided for @feedOnBreakTitle.
  ///
  /// In tr, this message translates to:
  /// **'Moladasın'**
  String get feedOnBreakTitle;

  /// No description provided for @feedOnBreakBody.
  ///
  /// In tr, this message translates to:
  /// **'Mola sırasında yeni talepler gelmez. Hazır olduğunda tekrar aktif ol.'**
  String get feedOnBreakBody;

  /// No description provided for @feedActivate.
  ///
  /// In tr, this message translates to:
  /// **'Aktif ol'**
  String get feedActivate;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an uygun talep yok'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Kategorine ve ilçelerine uyan yeni talepler burada görünür.'**
  String get feedEmptyBody;

  /// No description provided for @feedPhotos.
  ///
  /// In tr, this message translates to:
  /// **'{count} fotoğraf'**
  String feedPhotos(int count);

  /// No description provided for @feedOffers.
  ///
  /// In tr, this message translates to:
  /// **'{count} teklif'**
  String feedOffers(int count);

  /// No description provided for @feedMyOffer.
  ///
  /// In tr, this message translates to:
  /// **'Teklif verdin'**
  String get feedMyOffer;

  /// No description provided for @locationMasked.
  ///
  /// In tr, this message translates to:
  /// **'Tam adres, teklifin kabul edilince paylaşılır.'**
  String get locationMasked;

  /// No description provided for @prepareOffer.
  ///
  /// In tr, this message translates to:
  /// **'Teklif hazırla'**
  String get prepareOffer;

  /// No description provided for @viewMyOffer.
  ///
  /// In tr, this message translates to:
  /// **'Teklifini gör'**
  String get viewMyOffer;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz işin yok'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir teklifin kabul edilince iş burada görünür.'**
  String get jobsEmptyBody;

  /// No description provided for @offerFormTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif hazırla'**
  String get offerFormTitle;

  /// No description provided for @laborAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'İşçilik tutarı'**
  String get laborAmountLabel;

  /// No description provided for @laborAmountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'İşçilik tutarı 0\'dan büyük olmalı. Örnek: 1.200'**
  String get laborAmountInvalid;

  /// No description provided for @materialsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Malzeme eklemediysen boş bırakabilirsin.'**
  String get materialsEmpty;

  /// No description provided for @materialAdd.
  ///
  /// In tr, this message translates to:
  /// **'Malzeme kalemi ekle'**
  String get materialAdd;

  /// No description provided for @materialRemove.
  ///
  /// In tr, this message translates to:
  /// **'Kalemi sil'**
  String get materialRemove;

  /// No description provided for @materialDescription.
  ///
  /// In tr, this message translates to:
  /// **'Malzeme'**
  String get materialDescription;

  /// No description provided for @materialQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Adet'**
  String get materialQuantity;

  /// No description provided for @materialQuantityInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Adet 1 ya da daha fazla olmalı.'**
  String get materialQuantityInvalid;

  /// No description provided for @materialUnitPrice.
  ///
  /// In tr, this message translates to:
  /// **'Birim fiyat'**
  String get materialUnitPrice;

  /// No description provided for @materialPriceInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar gir. Örnek: 350'**
  String get materialPriceInvalid;

  /// No description provided for @arrivalHelp.
  ///
  /// In tr, this message translates to:
  /// **'Müşterinin seçeceği varış aralığı: 1-12 saat, en geç 14 gün sonrası.'**
  String get arrivalHelp;

  /// No description provided for @arrivalDay.
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get arrivalDay;

  /// No description provided for @arrivalStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç saati'**
  String get arrivalStart;

  /// No description provided for @arrivalLength.
  ///
  /// In tr, this message translates to:
  /// **'Aralık uzunluğu'**
  String get arrivalLength;

  /// No description provided for @hoursShort.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa'**
  String hoursShort(int hours);

  /// No description provided for @arrivalMissing.
  ///
  /// In tr, this message translates to:
  /// **'Gün ve başlangıç saatini seç.'**
  String get arrivalMissing;

  /// No description provided for @arrivalPast.
  ///
  /// In tr, this message translates to:
  /// **'Varış zamanı ileri bir tarih olmalı.'**
  String get arrivalPast;

  /// No description provided for @arrivalTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Aralık en az 1 saat olmalı.'**
  String get arrivalTooShort;

  /// No description provided for @arrivalTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Aralık en fazla 12 saat olabilir.'**
  String get arrivalTooLong;

  /// No description provided for @arrivalTooFar.
  ///
  /// In tr, this message translates to:
  /// **'Varış en geç 14 gün sonrası olabilir.'**
  String get arrivalTooFar;

  /// No description provided for @offerSummary.
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get offerSummary;

  /// No description provided for @serviceFee.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet bedeli (%{percent})'**
  String serviceFee(int percent);

  /// No description provided for @netEarning.
  ///
  /// In tr, this message translates to:
  /// **'Net kazancın'**
  String get netEarning;

  /// No description provided for @offerSend.
  ///
  /// In tr, this message translates to:
  /// **'Teklifi gönder'**
  String get offerSend;

  /// No description provided for @offerSentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklifin'**
  String get offerSentTitle;

  /// No description provided for @offerSentHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Teklifin gönderildi'**
  String get offerSentHeadline;

  /// No description provided for @offerSentBody.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri teklifini inceleyecek. Durumu Tekliflerim ekranından takip edebilirsin.'**
  String get offerSentBody;

  /// No description provided for @goToMyOffers.
  ///
  /// In tr, this message translates to:
  /// **'Tekliflerime git'**
  String get goToMyOffers;

  /// No description provided for @backToFeed.
  ///
  /// In tr, this message translates to:
  /// **'Taleplere dön'**
  String get backToFeed;

  /// No description provided for @myOffersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekliflerim'**
  String get myOffersTitle;

  /// No description provided for @myOffersEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif yok'**
  String get myOffersEmptyTitle;

  /// No description provided for @myOffersEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Verdiğin teklifler burada görünür.'**
  String get myOffersEmptyBody;

  /// No description provided for @withdraw.
  ///
  /// In tr, this message translates to:
  /// **'Geri çek'**
  String get withdraw;

  /// No description provided for @withdrawTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teklif geri çekilsin mi?'**
  String get withdrawTitle;

  /// No description provided for @withdrawMessage.
  ///
  /// In tr, this message translates to:
  /// **'Teklif müşteriye artık görünmez. Bu işlem geri alınamaz.'**
  String get withdrawMessage;

  /// No description provided for @availabilityActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktifsin'**
  String get availabilityActive;

  /// No description provided for @availabilityBreak.
  ///
  /// In tr, this message translates to:
  /// **'Moladasın'**
  String get availabilityBreak;

  /// No description provided for @availabilityActiveHelp.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen yeni talepler akışında görünür.'**
  String get availabilityActiveHelp;

  /// No description provided for @availabilityBreakHelp.
  ///
  /// In tr, this message translates to:
  /// **'Mola sırasında yeni talep eşleşmez; mevcut işlerin sürer.'**
  String get availabilityBreakHelp;

  /// No description provided for @profileEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilini düzenle'**
  String get profileEditTitle;

  /// No description provided for @profileBio.
  ///
  /// In tr, this message translates to:
  /// **'Profil yazısı'**
  String get profileBio;

  /// No description provided for @profileSaved.
  ///
  /// In tr, this message translates to:
  /// **'Profilin kaydedildi'**
  String get profileSaved;

  /// No description provided for @workingHours.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma saatleri'**
  String get workingHours;

  /// No description provided for @hoursFrom.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get hoursFrom;

  /// No description provided for @hoursTo.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get hoursTo;

  /// No description provided for @hoursAcceptsUrgent.
  ///
  /// In tr, this message translates to:
  /// **'Acil işleri de kabul ederim'**
  String get hoursAcceptsUrgent;

  /// No description provided for @hoursInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saati başlangıçtan sonra olmalı.'**
  String get hoursInvalid;
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
