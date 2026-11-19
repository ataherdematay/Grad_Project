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

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'BiTadilat Yönetim'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @filterStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get filterStatus;

  /// No description provided for @filterRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get filterRole;

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @loadFailedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Liste yüklenemedi'**
  String get loadFailedTitle;

  /// No description provided for @staleNotice.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bu arada değişti, bu işlem artık yapılamıyor. Ekranı güncelledik.'**
  String get staleNotice;

  /// No description provided for @apiErrorValidationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğin bilgilerde eksik ya da hatalı alan var. Alanları kontrol edip tekrar dene.'**
  String get apiErrorValidationFailed;

  /// No description provided for @apiErrorSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturumun sona erdi. Tekrar giriş yap.'**
  String get apiErrorSessionExpired;

  /// No description provided for @apiErrorBadCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ya da şifre hatalı. Bilgilerini kontrol edip tekrar dene.'**
  String get apiErrorBadCredentials;

  /// No description provided for @apiErrorAccountSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındı. Başka bir yöneticiyle iletişime geç.'**
  String get apiErrorAccountSuspended;

  /// No description provided for @apiErrorForbidden.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok.'**
  String get apiErrorForbidden;

  /// No description provided for @apiErrorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Aradığın kayıt bulunamadı. Listeye dönüp tekrar dene.'**
  String get apiErrorNotFound;

  /// No description provided for @apiErrorIllegalState.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem artık yapılamıyor, ekran güncellendi.'**
  String get apiErrorIllegalState;

  /// No description provided for @apiErrorTooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptın. Birkaç dakika bekleyip tekrar dene.'**
  String get apiErrorTooManyAttempts;

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
  /// **'Sunucuya ulaşılamıyor. Bağlantını kontrol edip tekrar dene.'**
  String get apiErrorNetworkError;

  /// No description provided for @apiErrorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Tekrar dene.'**
  String get apiErrorUnknown;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici girişi'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'BiTadilat yönetim paneline e-posta ve şifrenle gir.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @emailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi gir.'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni gir.'**
  String get passwordRequired;

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

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get logout;

  /// No description provided for @loginNotAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap yönetici hesabı değil, oturum açılmadı. Yönetici hesabınla giriş yap.'**
  String get loginNotAdmin;

  /// No description provided for @noticeSessionExpired.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunun süresi doldu. Devam etmek için tekrar giriş yap.'**
  String get noticeSessionExpired;

  /// No description provided for @noticeAccessDenied.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici yetkin bu işlem için geçerli değil, oturumun kapatıldı. Gerekirse yeniden giriş yap.'**
  String get noticeAccessDenied;

  /// No description provided for @noticeAccountSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındı, oturumun kapatıldı.'**
  String get noticeAccountSuspended;

  /// No description provided for @navLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yönetim menüsü'**
  String get navLabel;

  /// No description provided for @openMenu.
  ///
  /// In tr, this message translates to:
  /// **'Menüyü aç'**
  String get openMenu;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Genel bakış'**
  String get navHome;

  /// No description provided for @navApplications.
  ///
  /// In tr, this message translates to:
  /// **'Başvurular'**
  String get navApplications;

  /// No description provided for @navComplaints.
  ///
  /// In tr, this message translates to:
  /// **'Şikayetler'**
  String get navComplaints;

  /// No description provided for @navAccounts.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplar'**
  String get navAccounts;

  /// No description provided for @navPayments.
  ///
  /// In tr, this message translates to:
  /// **'Ödemeler'**
  String get navPayments;

  /// No description provided for @dashboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Genel bakış'**
  String get dashboardTitle;

  /// No description provided for @dashboardWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba {name}, bekleyen işler aşağıda.'**
  String dashboardWelcome(String name);

  /// No description provided for @statPendingApplications.
  ///
  /// In tr, this message translates to:
  /// **'İncelenmeyi bekleyen başvuru'**
  String get statPendingApplications;

  /// No description provided for @statOpenComplaints.
  ///
  /// In tr, this message translates to:
  /// **'Açık şikayet'**
  String get statOpenComplaints;

  /// No description provided for @statActiveJobs.
  ///
  /// In tr, this message translates to:
  /// **'Süren iş'**
  String get statActiveJobs;

  /// No description provided for @statLockedEscrow.
  ///
  /// In tr, this message translates to:
  /// **'Güvence havuzundaki tutar'**
  String get statLockedEscrow;

  /// No description provided for @reviewPending.
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get reviewPending;

  /// No description provided for @reviewNeedsDocuments.
  ///
  /// In tr, this message translates to:
  /// **'Eksik belge'**
  String get reviewNeedsDocuments;

  /// No description provided for @reviewApproved.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulandı'**
  String get reviewApproved;

  /// No description provided for @reviewRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get reviewRejected;

  /// No description provided for @reviewSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Askıda'**
  String get reviewSuspended;

  /// No description provided for @complaintOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get complaintOpen;

  /// No description provided for @complaintInReview.
  ///
  /// In tr, this message translates to:
  /// **'İncelemede'**
  String get complaintInReview;

  /// No description provided for @complaintResolved.
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get complaintResolved;

  /// No description provided for @complaintDismissed.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get complaintDismissed;

  /// No description provided for @reasonNoShow.
  ///
  /// In tr, this message translates to:
  /// **'Usta gelmedi'**
  String get reasonNoShow;

  /// No description provided for @reasonIncompleteWork.
  ///
  /// In tr, this message translates to:
  /// **'İş eksik ya da hatalı'**
  String get reasonIncompleteWork;

  /// No description provided for @reasonExtraCharge.
  ///
  /// In tr, this message translates to:
  /// **'Ek ücret istendi'**
  String get reasonExtraCharge;

  /// No description provided for @reasonRudeBehaviour.
  ///
  /// In tr, this message translates to:
  /// **'Saygısız davranış'**
  String get reasonRudeBehaviour;

  /// No description provided for @reasonOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get reasonOther;

  /// No description provided for @accountActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get accountActive;

  /// No description provided for @accountSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Askıda'**
  String get accountSuspended;

  /// No description provided for @accountDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Silindi'**
  String get accountDeleted;

  /// No description provided for @roleCustomer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri'**
  String get roleCustomer;

  /// No description provided for @rolePro.
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get rolePro;

  /// No description provided for @roleAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get roleAdmin;

  /// No description provided for @actorSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get actorSystem;

  /// No description provided for @docIdentity.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik'**
  String get docIdentity;

  /// No description provided for @docTradeCert.
  ///
  /// In tr, this message translates to:
  /// **'Esnaf / ticaret belgesi'**
  String get docTradeCert;

  /// No description provided for @docTax.
  ///
  /// In tr, this message translates to:
  /// **'Vergi levhası'**
  String get docTax;

  /// No description provided for @docCriminalRecord.
  ///
  /// In tr, this message translates to:
  /// **'Sabıka kaydı'**
  String get docCriminalRecord;

  /// No description provided for @docPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get docPending;

  /// No description provided for @docAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Kabul edildi'**
  String get docAccepted;

  /// No description provided for @docRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get docRejected;

  /// No description provided for @jobAwaitingAppointment.
  ///
  /// In tr, this message translates to:
  /// **'Randevu bekleniyor'**
  String get jobAwaitingAppointment;

  /// No description provided for @jobScheduled.
  ///
  /// In tr, this message translates to:
  /// **'Randevu onaylandı'**
  String get jobScheduled;

  /// No description provided for @jobArrived.
  ///
  /// In tr, this message translates to:
  /// **'Usta adreste'**
  String get jobArrived;

  /// No description provided for @jobInProgress.
  ///
  /// In tr, this message translates to:
  /// **'İş sürüyor'**
  String get jobInProgress;

  /// No description provided for @jobWorkFinished.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri onayı bekleniyor'**
  String get jobWorkFinished;

  /// No description provided for @jobCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get jobCompleted;

  /// No description provided for @jobDisputed.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet inceleniyor'**
  String get jobDisputed;

  /// No description provided for @jobCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get jobCancelled;

  /// No description provided for @jobResolved.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçlandı'**
  String get jobResolved;

  /// No description provided for @escrowInitialized.
  ///
  /// In tr, this message translates to:
  /// **'Başlatıldı'**
  String get escrowInitialized;

  /// No description provided for @escrowLocked.
  ///
  /// In tr, this message translates to:
  /// **'Güvence havuzunda'**
  String get escrowLocked;

  /// No description provided for @escrowFailed.
  ///
  /// In tr, this message translates to:
  /// **'Başarısız'**
  String get escrowFailed;

  /// No description provided for @escrowDisputed.
  ///
  /// In tr, this message translates to:
  /// **'Şikayette'**
  String get escrowDisputed;

  /// No description provided for @escrowReleased.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya aktarıldı'**
  String get escrowReleased;

  /// No description provided for @escrowRefunded.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriye iade edildi'**
  String get escrowRefunded;

  /// No description provided for @escrowSplit.
  ///
  /// In tr, this message translates to:
  /// **'İkiye bölündü'**
  String get escrowSplit;

  /// No description provided for @actionApproved.
  ///
  /// In tr, this message translates to:
  /// **'Onayladı'**
  String get actionApproved;

  /// No description provided for @actionRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddetti'**
  String get actionRejected;

  /// No description provided for @actionDocumentsRequested.
  ///
  /// In tr, this message translates to:
  /// **'Eksik belge istedi'**
  String get actionDocumentsRequested;

  /// No description provided for @actionSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Askıya aldı'**
  String get actionSuspended;

  /// No description provided for @actionReactivated.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden aktifleştirdi'**
  String get actionReactivated;

  /// No description provided for @actionReviewed.
  ///
  /// In tr, this message translates to:
  /// **'İncelemeye aldı'**
  String get actionReviewed;

  /// No description provided for @actionDecided.
  ///
  /// In tr, this message translates to:
  /// **'Karar verdi'**
  String get actionDecided;

  /// No description provided for @actionWarned.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya uyarı yazdı'**
  String get actionWarned;

  /// No description provided for @decisionResultWarned.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya uyarı yazıldı.'**
  String get decisionResultWarned;

  /// No description provided for @decisionResultSuspended.
  ///
  /// In tr, this message translates to:
  /// **'Usta profili askıya alındı.'**
  String get decisionResultSuspended;

  /// No description provided for @paymentMissing.
  ///
  /// In tr, this message translates to:
  /// **'Bu iş için güvence havuzu kaydı yok.'**
  String get paymentMissing;

  /// No description provided for @colPro.
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get colPro;

  /// No description provided for @colCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get colCategories;

  /// No description provided for @colDistricts.
  ///
  /// In tr, this message translates to:
  /// **'İlçeler'**
  String get colDistricts;

  /// No description provided for @colSubmitted.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru tarihi'**
  String get colSubmitted;

  /// No description provided for @colDocuments.
  ///
  /// In tr, this message translates to:
  /// **'Belge'**
  String get colDocuments;

  /// No description provided for @colStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get colStatus;

  /// No description provided for @colComplaint.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet'**
  String get colComplaint;

  /// No description provided for @colJob.
  ///
  /// In tr, this message translates to:
  /// **'İş'**
  String get colJob;

  /// No description provided for @colAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get colAmount;

  /// No description provided for @colDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get colDate;

  /// No description provided for @colReason.
  ///
  /// In tr, this message translates to:
  /// **'Neden'**
  String get colReason;

  /// No description provided for @colAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get colAccount;

  /// No description provided for @colRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get colRole;

  /// No description provided for @colRegistered.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt tarihi'**
  String get colRegistered;

  /// No description provided for @colActions.
  ///
  /// In tr, this message translates to:
  /// **'İşlem'**
  String get colActions;

  /// No description provided for @colRef.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme no'**
  String get colRef;

  /// No description provided for @colProvider.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı'**
  String get colProvider;

  /// No description provided for @colParties.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri / usta'**
  String get colParties;

  /// No description provided for @colTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam tutar'**
  String get colTotal;

  /// No description provided for @colServiceFee.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet bedeli'**
  String get colServiceFee;

  /// No description provided for @colProPayout.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya ödeme'**
  String get colProPayout;

  /// No description provided for @paymentAwaitingDecision.
  ///
  /// In tr, this message translates to:
  /// **'Karar bekleyen güvence havuzu tutarı'**
  String get paymentAwaitingDecision;

  /// No description provided for @colRefunded.
  ///
  /// In tr, this message translates to:
  /// **'İade'**
  String get colRefunded;

  /// No description provided for @applicationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Usta başvuruları'**
  String get applicationsTitle;

  /// No description provided for @applicationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'En eski başvuru en üstte; sırayla incele.'**
  String get applicationsSubtitle;

  /// No description provided for @applicationsSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad, işletme, e-posta ya da telefon'**
  String get applicationsSearchHint;

  /// No description provided for @applicationsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu durumda başvuru yok'**
  String get applicationsEmptyTitle;

  /// No description provided for @applicationsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Başka bir durum seç ya da aramanı değiştir.'**
  String get applicationsEmptyMessage;

  /// No description provided for @applicationDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru'**
  String get applicationDetailTitle;

  /// No description provided for @personAndBusiness.
  ///
  /// In tr, this message translates to:
  /// **'Kişi ve işletme'**
  String get personAndBusiness;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @businessName.
  ///
  /// In tr, this message translates to:
  /// **'İşletme adı'**
  String get businessName;

  /// No description provided for @experience.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim'**
  String get experience;

  /// No description provided for @yearsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} yıl'**
  String yearsCount(int count);

  /// No description provided for @bio.
  ///
  /// In tr, this message translates to:
  /// **'Tanıtım yazısı'**
  String get bio;

  /// No description provided for @documentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Belgeler'**
  String get documentsTitle;

  /// No description provided for @documentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu başvuruda belge yok.'**
  String get documentsEmpty;

  /// No description provided for @documentPreview.
  ///
  /// In tr, this message translates to:
  /// **'Belge önizlemesi'**
  String get documentPreview;

  /// No description provided for @previewUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Önizleme yok'**
  String get previewUnavailable;

  /// No description provided for @openInNewTab.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sekmede aç'**
  String get openInNewTab;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz işlem yapılmamış.'**
  String get historyEmpty;

  /// No description provided for @decisionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Karar'**
  String get decisionTitle;

  /// No description provided for @reviewNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'İnceleme notu'**
  String get reviewNoteLabel;

  /// No description provided for @noActionsForStatus.
  ///
  /// In tr, this message translates to:
  /// **'Bu başvuru için yapılacak bir işlem yok.'**
  String get noActionsForStatus;

  /// No description provided for @approve.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  /// No description provided for @approveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu onayla'**
  String get approveTitle;

  /// No description provided for @approveMessage.
  ///
  /// In tr, this message translates to:
  /// **'{business} onaylanır, tüm belgeleri kabul edilir ve usta talepleri görmeye başlar. Ustaya bildirim gider.'**
  String approveMessage(String business);

  /// No description provided for @approvedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru onaylandı.'**
  String get approvedNotice;

  /// No description provided for @reject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  /// No description provided for @rejectTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu reddet'**
  String get rejectTitle;

  /// No description provided for @rejectMessage.
  ///
  /// In tr, this message translates to:
  /// **'Gerekçen ustaya bildirimle gider. Başvuru reddedilmiş olarak kapanır.'**
  String get rejectMessage;

  /// No description provided for @rejectNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ret gerekçesi'**
  String get rejectNoteLabel;

  /// No description provided for @rejectedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru reddedildi.'**
  String get rejectedNotice;

  /// No description provided for @requestDocs.
  ///
  /// In tr, this message translates to:
  /// **'Eksik belge iste'**
  String get requestDocs;

  /// No description provided for @requestDocsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eksik belge iste'**
  String get requestDocsTitle;

  /// No description provided for @requestDocsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin belgeler reddedilmiş sayılır ve usta bunları yeniden yükler.'**
  String get requestDocsMessage;

  /// No description provided for @requestDocsTypes.
  ///
  /// In tr, this message translates to:
  /// **'İstenen belgeler'**
  String get requestDocsTypes;

  /// No description provided for @requestDocsPickOne.
  ///
  /// In tr, this message translates to:
  /// **'En az bir belge türü seç.'**
  String get requestDocsPickOne;

  /// No description provided for @requestDocsNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya not'**
  String get requestDocsNoteLabel;

  /// No description provided for @requestDocsDoneNotice.
  ///
  /// In tr, this message translates to:
  /// **'Eksik belge istendi.'**
  String get requestDocsDoneNotice;

  /// No description provided for @noteHelper.
  ///
  /// In tr, this message translates to:
  /// **'{min}-{max} karakter'**
  String noteHelper(int min, int max);

  /// No description provided for @noteOptionalHelper.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı, en fazla {max} karakter'**
  String noteOptionalHelper(int max);

  /// No description provided for @approveNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Onay notu (isteğe bağlı)'**
  String get approveNoteLabel;

  /// No description provided for @noteTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Not en az {min} karakter olmalı.'**
  String noteTooShort(int min);

  /// No description provided for @noteTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Not en fazla {max} karakter olabilir.'**
  String noteTooLong(int max);

  /// No description provided for @complaintsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şikayetler'**
  String get complaintsTitle;

  /// No description provided for @complaintsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'En eski şikayet en üstte.'**
  String get complaintsSubtitle;

  /// No description provided for @complaintsActive.
  ///
  /// In tr, this message translates to:
  /// **'Açık ve incelemede'**
  String get complaintsActive;

  /// No description provided for @complaintsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu durumda şikayet yok'**
  String get complaintsEmptyTitle;

  /// No description provided for @complaintsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Başka bir durum seçmeyi dene.'**
  String get complaintsEmptyMessage;

  /// No description provided for @complaintDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet'**
  String get complaintDetailTitle;

  /// No description provided for @complaintDetailHeading.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet {code}'**
  String complaintDetailHeading(String code);

  /// No description provided for @complaintSection.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet'**
  String get complaintSection;

  /// No description provided for @descriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get descriptionLabel;

  /// No description provided for @evidenceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kanıt'**
  String get evidenceTitle;

  /// No description provided for @evidenceEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kanıt eklenmemiş.'**
  String get evidenceEmpty;

  /// No description provided for @timelineTitle.
  ///
  /// In tr, this message translates to:
  /// **'İş zaman çizelgesi'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In tr, this message translates to:
  /// **'İşte kayıtlı olay yok.'**
  String get timelineEmpty;

  /// No description provided for @eventNote.
  ///
  /// In tr, this message translates to:
  /// **'Not eklendi'**
  String get eventNote;

  /// No description provided for @eventPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf eklendi'**
  String get eventPhoto;

  /// No description provided for @eventAppointmentProposed.
  ///
  /// In tr, this message translates to:
  /// **'Randevu önerildi'**
  String get eventAppointmentProposed;

  /// No description provided for @eventAppointmentAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Randevu kabul edildi'**
  String get eventAppointmentAccepted;

  /// No description provided for @chatTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet kaydı'**
  String get chatTitle;

  /// No description provided for @chatEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu işte mesaj yok.'**
  String get chatEmpty;

  /// No description provided for @paymentSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme özeti'**
  String get paymentSummaryTitle;

  /// No description provided for @partiesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Taraflar'**
  String get partiesTitle;

  /// No description provided for @warningCount.
  ///
  /// In tr, this message translates to:
  /// **'Ustanın uyarı sayısı'**
  String get warningCount;

  /// No description provided for @cancellationCount.
  ///
  /// In tr, this message translates to:
  /// **'Ustanın iptal sayısı'**
  String get cancellationCount;

  /// No description provided for @reviewComplaint.
  ///
  /// In tr, this message translates to:
  /// **'İncelemeye al'**
  String get reviewComplaint;

  /// No description provided for @reviewComplaintTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şikayeti incelemeye al'**
  String get reviewComplaintTitle;

  /// No description provided for @reviewComplaintMessage.
  ///
  /// In tr, this message translates to:
  /// **'{code} incelemeye alınır. Kararı bundan sonra verebilirsin.'**
  String reviewComplaintMessage(String code);

  /// No description provided for @reviewComplaintDone.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet incelemeye alındı.'**
  String get reviewComplaintDone;

  /// No description provided for @decide.
  ///
  /// In tr, this message translates to:
  /// **'Karar ver'**
  String get decide;

  /// No description provided for @decisionResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verilen karar'**
  String get decisionResultTitle;

  /// No description provided for @decisionFullRefund.
  ///
  /// In tr, this message translates to:
  /// **'Tam iade'**
  String get decisionFullRefund;

  /// No description provided for @decisionFullRefundDesc.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriye tutarın tamamı iade edilir. İş iptal edilir, hizmet bedeli alınmaz.'**
  String get decisionFullRefundDesc;

  /// No description provided for @decisionSplit.
  ///
  /// In tr, this message translates to:
  /// **'%50 / %50'**
  String get decisionSplit;

  /// No description provided for @decisionSplitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tutar müşteri ile usta arasında yarı yarıya bölünür. Hizmet bedeli alınmaz.'**
  String get decisionSplitDesc;

  /// No description provided for @decisionRelease.
  ///
  /// In tr, this message translates to:
  /// **'Şikayeti reddet, ustaya aktar'**
  String get decisionRelease;

  /// No description provided for @decisionReleaseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet reddedilir, tutar ustaya aktarılır ve %10 hizmet bedeli alınır.'**
  String get decisionReleaseDesc;

  /// No description provided for @outcomeCustomerRefund.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriye iade'**
  String get outcomeCustomerRefund;

  /// No description provided for @outcomeProPayout.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya ödeme'**
  String get outcomeProPayout;

  /// No description provided for @decisionDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'{code} için karar'**
  String decisionDialogTitle(String code);

  /// No description provided for @decisionDialogIntro.
  ///
  /// In tr, this message translates to:
  /// **'Güvence havuzundaki tutar {total}. İade ve usta payını karar verilince sunucu hesaplar; sonuç şikayet ekranında görünür.'**
  String decisionDialogIntro(String total);

  /// No description provided for @decisionDialogIntroNoPayment.
  ///
  /// In tr, this message translates to:
  /// **'Bu iş için güvence havuzu kaydı bulunamadı. İade ve usta payını karar verilince sunucu hesaplar.'**
  String get decisionDialogIntroNoPayment;

  /// No description provided for @decisionPickOne.
  ///
  /// In tr, this message translates to:
  /// **'Bir karar seç.'**
  String get decisionPickOne;

  /// No description provided for @decisionNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Karar gerekçesi'**
  String get decisionNoteLabel;

  /// No description provided for @warnPro.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya uyarı yaz'**
  String get warnPro;

  /// No description provided for @warnProHint.
  ///
  /// In tr, this message translates to:
  /// **'Ustanın uyarı sayısı 1 artar.'**
  String get warnProHint;

  /// No description provided for @suspendProProfile.
  ///
  /// In tr, this message translates to:
  /// **'Usta profilini askıya al'**
  String get suspendProProfile;

  /// No description provided for @suspendProProfileHint.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen teklifleri geri çekilir. Kullanıcı hesabı askıya alınmaz.'**
  String get suspendProProfileHint;

  /// No description provided for @decisionSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Kararı ver'**
  String get decisionSubmit;

  /// No description provided for @decisionConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kararı kesinleştir'**
  String get decisionConfirmTitle;

  /// No description provided for @decisionConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Seçtiğin karar: {decision}.\n\nTutarları sunucu hesaplar; sonuç şikayet ekranında görünür.\n\nBu karar geri alınamaz. Para hareketi hemen yapılır, karar iki tarafa bildirilir ve şikayet kapanır.'**
  String decisionConfirmMessage(String decision);

  /// No description provided for @decisionConfirmWarn.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya uyarı kaydı da düşülecek.'**
  String get decisionConfirmWarn;

  /// No description provided for @decisionConfirmSuspend.
  ///
  /// In tr, this message translates to:
  /// **'Usta profili de askıya alınacak.'**
  String get decisionConfirmSuspend;

  /// No description provided for @decisionConfirmAction.
  ///
  /// In tr, this message translates to:
  /// **'Kararı kesinleştir'**
  String get decisionConfirmAction;

  /// No description provided for @decisionGatewayFailed.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme sistemine ulaşılamadı, hiçbir şey değişmedi. Biraz sonra tekrar dene.'**
  String get decisionGatewayFailed;

  /// No description provided for @decisionDone.
  ///
  /// In tr, this message translates to:
  /// **'Karar verildi, iki taraf bilgilendirildi.'**
  String get decisionDone;

  /// No description provided for @accountsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplar'**
  String get accountsTitle;

  /// No description provided for @accountsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri, usta ve yönetici hesapları.'**
  String get accountsSubtitle;

  /// No description provided for @accountsSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad, e-posta ya da telefon'**
  String get accountsSearchHint;

  /// No description provided for @accountsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap bulunamadı'**
  String get accountsEmptyTitle;

  /// No description provided for @accountsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Aramanı ya da süzgeçleri değiştir.'**
  String get accountsEmptyMessage;

  /// No description provided for @proRoleLine.
  ///
  /// In tr, this message translates to:
  /// **'Usta: {business} ({status})'**
  String proRoleLine(String business, String status);

  /// No description provided for @suspend.
  ///
  /// In tr, this message translates to:
  /// **'Askıya al'**
  String get suspend;

  /// No description provided for @suspendAccountTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} hesabını askıya al'**
  String suspendAccountTitle(String name);

  /// No description provided for @suspendAccountMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcının tüm oturumları kapanır ve bekleyen teklifleri geri çekilir. Süren işlere dokunulmaz.'**
  String get suspendAccountMessage;

  /// No description provided for @suspendNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Askıya alma gerekçesi'**
  String get suspendNoteLabel;

  /// No description provided for @suspendedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Hesap askıya alındı.'**
  String get suspendedNotice;

  /// No description provided for @suspendedWithJobsNotice.
  ///
  /// In tr, this message translates to:
  /// **'Hesap askıya alındı. Süren {count} iş var, bunlara dokunulmadı.'**
  String suspendedWithJobsNotice(int count);

  /// No description provided for @reactivate.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden aktifleştir'**
  String get reactivate;

  /// No description provided for @reactivateTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} hesabını yeniden aktifleştir'**
  String reactivateTitle(String name);

  /// No description provided for @reactivateMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı yeniden giriş yapabilir.'**
  String get reactivateMessage;

  /// No description provided for @reactivatedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Hesap yeniden aktifleştirildi.'**
  String get reactivatedNotice;

  /// No description provided for @reactivatePro.
  ///
  /// In tr, this message translates to:
  /// **'Usta profilini aç'**
  String get reactivatePro;

  /// No description provided for @reactivateProTitle.
  ///
  /// In tr, this message translates to:
  /// **'{business} usta profilini yeniden aç'**
  String reactivateProTitle(String business);

  /// No description provided for @reactivateProMessage.
  ///
  /// In tr, this message translates to:
  /// **'Askıdaki usta profili yeniden doğrulanmış duruma döner ve usta yeniden talep görür.'**
  String get reactivateProMessage;

  /// No description provided for @proReactivatedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Usta profili yeniden açıldı.'**
  String get proReactivatedNotice;

  /// No description provided for @cannotSuspendSelf.
  ///
  /// In tr, this message translates to:
  /// **'Kendi hesabını askıya alamazsın.'**
  String get cannotSuspendSelf;

  /// No description provided for @cannotSuspendAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici hesapları askıya alınamaz.'**
  String get cannotSuspendAdmin;

  /// No description provided for @paymentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme defteri'**
  String get paymentsTitle;

  /// No description provided for @paymentsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvence havuzu kayıtları ve toplamlar.'**
  String get paymentsSubtitle;

  /// No description provided for @paymentsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu durumda ödeme yok'**
  String get paymentsEmptyTitle;

  /// No description provided for @paymentsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Başka bir durum seçmeyi dene.'**
  String get paymentsEmptyMessage;

  /// No description provided for @totalLocked.
  ///
  /// In tr, this message translates to:
  /// **'Güvence havuzunda'**
  String get totalLocked;

  /// No description provided for @totalReleased.
  ///
  /// In tr, this message translates to:
  /// **'Ustalara aktarılan'**
  String get totalReleased;

  /// No description provided for @totalCommission.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet bedeli toplamı'**
  String get totalCommission;

  /// No description provided for @totalRefunded.
  ///
  /// In tr, this message translates to:
  /// **'İade edilen'**
  String get totalRefunded;

  /// No description provided for @reviewSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'İncelemedeki ödemeler'**
  String get reviewSectionTitle;

  /// No description provided for @reviewSectionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik iade veya ustaya aktarım durdu. Çözmeden önce Craftgate\'teki gerçek durum sorulur; para iki kez hareket etmez.'**
  String get reviewSectionSubtitle;

  /// No description provided for @reviewEmpty.
  ///
  /// In tr, this message translates to:
  /// **'İncelemede ödeme yok.'**
  String get reviewEmpty;

  /// No description provided for @reviewCodeRefund.
  ///
  /// In tr, this message translates to:
  /// **'İade incelemede'**
  String get reviewCodeRefund;

  /// No description provided for @reviewCodePayout.
  ///
  /// In tr, this message translates to:
  /// **'Aktarım incelemede'**
  String get reviewCodePayout;

  /// No description provided for @reviewAttempts.
  ///
  /// In tr, this message translates to:
  /// **'{count} deneme'**
  String reviewAttempts(int count);

  /// No description provided for @reviewCheck.
  ///
  /// In tr, this message translates to:
  /// **'Craftgate\'e sor ve çöz'**
  String get reviewCheck;

  /// No description provided for @reviewGatewayState.
  ///
  /// In tr, this message translates to:
  /// **'Craftgate: {state}, iade edilen {amount}'**
  String reviewGatewayState(String state, String amount);

  /// No description provided for @reviewStateNotRefunded.
  ///
  /// In tr, this message translates to:
  /// **'iade yok'**
  String get reviewStateNotRefunded;

  /// No description provided for @reviewStatePartial.
  ///
  /// In tr, this message translates to:
  /// **'kısmi iade'**
  String get reviewStatePartial;

  /// No description provided for @reviewStatePending.
  ///
  /// In tr, this message translates to:
  /// **'iade sonucu bekleniyor'**
  String get reviewStatePending;

  /// No description provided for @reviewStateFull.
  ///
  /// In tr, this message translates to:
  /// **'tam iade edilmiş'**
  String get reviewStateFull;

  /// No description provided for @reviewNoResolution.
  ///
  /// In tr, this message translates to:
  /// **'Craftgate\'in şu anki yanıtı hiçbir çözüme izin vermiyor (iade sonucu bekleniyor ya da tutarlar tutarsız). Biraz sonra yeniden sor veya Craftgate panelinden düzelt.'**
  String get reviewNoResolution;

  /// No description provided for @reviewNoResolutionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an çözülemez'**
  String get reviewNoResolutionTitle;

  /// No description provided for @reviewResolveTitle.
  ///
  /// In tr, this message translates to:
  /// **'{ref} ödemesini çöz'**
  String reviewResolveTitle(String ref);

  /// No description provided for @reviewResolutionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Çözüm'**
  String get reviewResolutionLabel;

  /// No description provided for @reviewResolutionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bir çözüm seç.'**
  String get reviewResolutionRequired;

  /// No description provided for @resolutionMarkRefunded.
  ///
  /// In tr, this message translates to:
  /// **'İade edildi olarak işaretle (para gönderilmez)'**
  String get resolutionMarkRefunded;

  /// No description provided for @resolutionRetryRefund.
  ///
  /// In tr, this message translates to:
  /// **'Kalan tutarı iade et'**
  String get resolutionRetryRefund;

  /// No description provided for @resolutionRelease.
  ///
  /// In tr, this message translates to:
  /// **'Ustaya aktar'**
  String get resolutionRelease;

  /// No description provided for @resolveNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not (10-1000 karakter)'**
  String get resolveNoteLabel;

  /// No description provided for @reviewResolve.
  ///
  /// In tr, this message translates to:
  /// **'Çöz'**
  String get reviewResolve;

  /// No description provided for @reviewResolvedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme çözüldü.'**
  String get reviewResolvedNotice;

  /// No description provided for @filterDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get filterDistrict;
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
