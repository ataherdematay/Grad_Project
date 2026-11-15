// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'BiTadilat Yönetim';

  @override
  String get language => 'Dil';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get refresh => 'Yenile';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get back => 'Geri';

  @override
  String get close => 'Kapat';

  @override
  String get search => 'Ara';

  @override
  String get filterStatus => 'Durum';

  @override
  String get filterRole => 'Rol';

  @override
  String get filterAll => 'Tümü';

  @override
  String get loadFailedTitle => 'Liste yüklenemedi';

  @override
  String get staleNotice =>
      'Kayıt bu arada değişti, bu işlem artık yapılamıyor. Ekranı güncelledik.';

  @override
  String get apiErrorValidationFailed =>
      'Girdiğin bilgilerde eksik ya da hatalı alan var. Alanları kontrol edip tekrar dene.';

  @override
  String get apiErrorSessionExpired => 'Oturumun sona erdi. Tekrar giriş yap.';

  @override
  String get apiErrorBadCredentials =>
      'E-posta ya da şifre hatalı. Bilgilerini kontrol edip tekrar dene.';

  @override
  String get apiErrorAccountSuspended =>
      'Hesabın askıya alındı. Başka bir yöneticiyle iletişime geç.';

  @override
  String get apiErrorForbidden => 'Bu işlem için yetkin yok.';

  @override
  String get apiErrorNotFound =>
      'Aradığın kayıt bulunamadı. Listeye dönüp tekrar dene.';

  @override
  String get apiErrorIllegalState =>
      'Bu işlem artık yapılamıyor, ekran güncellendi.';

  @override
  String get apiErrorTooManyAttempts =>
      'Çok fazla deneme yaptın. Birkaç dakika bekleyip tekrar dene.';

  @override
  String get apiErrorGatewayError =>
      'Ödeme sistemine şu an ulaşılamıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String get apiErrorInternalError =>
      'Beklenmeyen bir sorun oluştu. Biraz sonra tekrar dene.';

  @override
  String get apiErrorNetworkError =>
      'Sunucuya ulaşılamıyor. Bağlantını kontrol edip tekrar dene.';

  @override
  String get apiErrorUnknown => 'Bir sorun oluştu. Tekrar dene.';

  @override
  String get loginTitle => 'Yönetici girişi';

  @override
  String get loginSubtitle =>
      'BiTadilat yönetim paneline e-posta ve şifrenle gir.';

  @override
  String get email => 'E-posta';

  @override
  String get emailInvalid => 'Geçerli bir e-posta adresi gir.';

  @override
  String get password => 'Şifre';

  @override
  String get passwordRequired => 'Şifreni gir.';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get login => 'Giriş yap';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get loginNotAdmin =>
      'Bu hesap yönetici hesabı değil, oturum açılmadı. Yönetici hesabınla giriş yap.';

  @override
  String get noticeSessionExpired =>
      'Oturumunun süresi doldu. Devam etmek için tekrar giriş yap.';

  @override
  String get noticeAccountSuspended =>
      'Hesabın askıya alındı, oturumun kapatıldı.';

  @override
  String get navLabel => 'Yönetim menüsü';

  @override
  String get openMenu => 'Menüyü aç';

  @override
  String get navHome => 'Genel bakış';

  @override
  String get navApplications => 'Başvurular';

  @override
  String get navComplaints => 'Şikayetler';

  @override
  String get navAccounts => 'Hesaplar';

  @override
  String get navPayments => 'Ödemeler';

  @override
  String get dashboardTitle => 'Genel bakış';

  @override
  String dashboardWelcome(String name) {
    return 'Merhaba $name, bekleyen işler aşağıda.';
  }

  @override
  String get statPendingApplications => 'İncelenmeyi bekleyen başvuru';

  @override
  String get statOpenComplaints => 'Açık şikayet';

  @override
  String get statActiveJobs => 'Süren iş';

  @override
  String get statLockedEscrow => 'Güvence havuzundaki tutar';

  @override
  String get reviewPending => 'İnceleniyor';

  @override
  String get reviewNeedsDocuments => 'Eksik belge';

  @override
  String get reviewApproved => 'Doğrulandı';

  @override
  String get reviewRejected => 'Reddedildi';

  @override
  String get reviewSuspended => 'Askıda';

  @override
  String get complaintOpen => 'Açık';

  @override
  String get complaintInReview => 'İncelemede';

  @override
  String get complaintResolved => 'Çözüldü';

  @override
  String get complaintDismissed => 'Reddedildi';

  @override
  String get reasonNoShow => 'Usta gelmedi';

  @override
  String get reasonIncompleteWork => 'İş eksik ya da hatalı';

  @override
  String get reasonExtraCharge => 'Ek ücret istendi';

  @override
  String get reasonRudeBehaviour => 'Saygısız davranış';

  @override
  String get reasonOther => 'Diğer';

  @override
  String get accountActive => 'Aktif';

  @override
  String get accountSuspended => 'Askıda';

  @override
  String get accountDeleted => 'Silindi';

  @override
  String get roleCustomer => 'Müşteri';

  @override
  String get rolePro => 'Usta';

  @override
  String get roleAdmin => 'Yönetici';

  @override
  String get actorSystem => 'Sistem';

  @override
  String get docIdentity => 'Kimlik';

  @override
  String get docTradeCert => 'Esnaf / ticaret belgesi';

  @override
  String get docTax => 'Vergi levhası';

  @override
  String get docCriminalRecord => 'Sabıka kaydı';

  @override
  String get docPending => 'Bekliyor';

  @override
  String get docAccepted => 'Kabul edildi';

  @override
  String get docRejected => 'Reddedildi';

  @override
  String get jobAwaitingAppointment => 'Randevu bekleniyor';

  @override
  String get jobScheduled => 'Randevu onaylandı';

  @override
  String get jobArrived => 'Usta adreste';

  @override
  String get jobInProgress => 'İş sürüyor';

  @override
  String get jobWorkFinished => 'Müşteri onayı bekleniyor';

  @override
  String get jobCompleted => 'Tamamlandı';

  @override
  String get jobDisputed => 'Şikayet inceleniyor';

  @override
  String get jobCancelled => 'İptal edildi';

  @override
  String get jobResolved => 'Sonuçlandı';

  @override
  String get escrowInitialized => 'Başlatıldı';

  @override
  String get escrowLocked => 'Güvence havuzunda';

  @override
  String get escrowFailed => 'Başarısız';

  @override
  String get escrowDisputed => 'Şikayette';

  @override
  String get escrowReleased => 'Ustaya aktarıldı';

  @override
  String get escrowRefunded => 'Müşteriye iade edildi';

  @override
  String get escrowSplit => 'İkiye bölündü';

  @override
  String get actionApproved => 'Onayladı';

  @override
  String get actionRejected => 'Reddetti';

  @override
  String get actionDocumentsRequested => 'Eksik belge istedi';

  @override
  String get actionSuspended => 'Askıya aldı';

  @override
  String get actionReactivated => 'Yeniden aktifleştirdi';

  @override
  String get actionReviewed => 'İncelemeye aldı';

  @override
  String get actionDecided => 'Karar verdi';

  @override
  String get actionWarned => 'Ustaya uyarı yazdı';

  @override
  String get decisionResultWarned => 'Ustaya uyarı yazıldı.';

  @override
  String get decisionResultSuspended => 'Usta profili askıya alındı.';

  @override
  String get paymentMissing => 'Bu iş için güvence havuzu kaydı yok.';

  @override
  String get colPro => 'Usta';

  @override
  String get colCategories => 'Kategoriler';

  @override
  String get colDistricts => 'İlçeler';

  @override
  String get colSubmitted => 'Başvuru tarihi';

  @override
  String get colDocuments => 'Belge';

  @override
  String get colStatus => 'Durum';

  @override
  String get colComplaint => 'Şikayet';

  @override
  String get colJob => 'İş';

  @override
  String get colAmount => 'Tutar';

  @override
  String get colDate => 'Tarih';

  @override
  String get colReason => 'Neden';

  @override
  String get colAccount => 'Hesap';

  @override
  String get colRole => 'Rol';

  @override
  String get colRegistered => 'Kayıt tarihi';

  @override
  String get colActions => 'İşlem';

  @override
  String get colRef => 'Ödeme no';

  @override
  String get colProvider => 'Sağlayıcı';

  @override
  String get colParties => 'Müşteri / usta';

  @override
  String get colTotal => 'Toplam tutar';

  @override
  String get colServiceFee => 'Hizmet bedeli';

  @override
  String get colProPayout => 'Ustaya ödeme';

  @override
  String get colRefunded => 'İade';

  @override
  String get applicationsTitle => 'Usta başvuruları';

  @override
  String get applicationsSubtitle =>
      'En eski başvuru en üstte; sırayla incele.';

  @override
  String get applicationsSearchHint => 'Ad, işletme, e-posta ya da telefon';

  @override
  String get applicationsEmptyTitle => 'Bu durumda başvuru yok';

  @override
  String get applicationsEmptyMessage =>
      'Başka bir durum seç ya da aramanı değiştir.';

  @override
  String get applicationDetailTitle => 'Başvuru';

  @override
  String get personAndBusiness => 'Kişi ve işletme';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get phone => 'Telefon';

  @override
  String get businessName => 'İşletme adı';

  @override
  String get experience => 'Deneyim';

  @override
  String yearsCount(int count) {
    return '$count yıl';
  }

  @override
  String get bio => 'Tanıtım yazısı';

  @override
  String get documentsTitle => 'Belgeler';

  @override
  String get documentsEmpty => 'Bu başvuruda belge yok.';

  @override
  String get documentPreview => 'Belge önizlemesi';

  @override
  String get previewUnavailable => 'Önizleme yok';

  @override
  String get openInNewTab => 'Yeni sekmede aç';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get historyEmpty => 'Henüz işlem yapılmamış.';

  @override
  String get decisionTitle => 'Karar';

  @override
  String get reviewNoteLabel => 'İnceleme notu';

  @override
  String get noActionsForStatus => 'Bu başvuru için yapılacak bir işlem yok.';

  @override
  String get approve => 'Onayla';

  @override
  String get approveTitle => 'Başvuruyu onayla';

  @override
  String approveMessage(String business) {
    return '$business onaylanır, tüm belgeleri kabul edilir ve usta talepleri görmeye başlar. Ustaya bildirim gider.';
  }

  @override
  String get approvedNotice => 'Başvuru onaylandı.';

  @override
  String get reject => 'Reddet';

  @override
  String get rejectTitle => 'Başvuruyu reddet';

  @override
  String get rejectMessage =>
      'Gerekçen ustaya bildirimle gider. Başvuru reddedilmiş olarak kapanır.';

  @override
  String get rejectNoteLabel => 'Ret gerekçesi';

  @override
  String get rejectedNotice => 'Başvuru reddedildi.';

  @override
  String get requestDocs => 'Eksik belge iste';

  @override
  String get requestDocsTitle => 'Eksik belge iste';

  @override
  String get requestDocsMessage =>
      'Seçtiğin belgeler reddedilmiş sayılır ve usta bunları yeniden yükler.';

  @override
  String get requestDocsTypes => 'İstenen belgeler';

  @override
  String get requestDocsPickOne => 'En az bir belge türü seç.';

  @override
  String get requestDocsNoteLabel => 'Ustaya not';

  @override
  String get requestDocsDoneNotice => 'Eksik belge istendi.';

  @override
  String noteHelper(int min, int max) {
    return '$min-$max karakter';
  }

  @override
  String noteOptionalHelper(int max) {
    return 'İsteğe bağlı, en fazla $max karakter';
  }

  @override
  String get approveNoteLabel => 'Onay notu (isteğe bağlı)';

  @override
  String noteTooShort(int min) {
    return 'Not en az $min karakter olmalı.';
  }

  @override
  String noteTooLong(int max) {
    return 'Not en fazla $max karakter olabilir.';
  }

  @override
  String get complaintsTitle => 'Şikayetler';

  @override
  String get complaintsSubtitle => 'En eski şikayet en üstte.';

  @override
  String get complaintsActive => 'Açık ve incelemede';

  @override
  String get complaintsEmptyTitle => 'Bu durumda şikayet yok';

  @override
  String get complaintsEmptyMessage => 'Başka bir durum seçmeyi dene.';

  @override
  String get complaintDetailTitle => 'Şikayet';

  @override
  String complaintDetailHeading(String code) {
    return 'Şikayet $code';
  }

  @override
  String get complaintSection => 'Şikayet';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get evidenceTitle => 'Kanıt';

  @override
  String get evidenceEmpty => 'Kanıt eklenmemiş.';

  @override
  String get timelineTitle => 'İş zaman çizelgesi';

  @override
  String get timelineEmpty => 'İşte kayıtlı olay yok.';

  @override
  String get eventNote => 'Not eklendi';

  @override
  String get eventPhoto => 'Fotoğraf eklendi';

  @override
  String get eventAppointmentProposed => 'Randevu önerildi';

  @override
  String get eventAppointmentAccepted => 'Randevu kabul edildi';

  @override
  String get chatTitle => 'Sohbet kaydı';

  @override
  String get chatEmpty => 'Bu işte mesaj yok.';

  @override
  String get paymentSummaryTitle => 'Ödeme özeti';

  @override
  String get partiesTitle => 'Taraflar';

  @override
  String get warningCount => 'Ustanın uyarı sayısı';

  @override
  String get cancellationCount => 'Ustanın iptal sayısı';

  @override
  String get reviewComplaint => 'İncelemeye al';

  @override
  String get reviewComplaintTitle => 'Şikayeti incelemeye al';

  @override
  String reviewComplaintMessage(String code) {
    return '$code incelemeye alınır. Kararı bundan sonra verebilirsin.';
  }

  @override
  String get reviewComplaintDone => 'Şikayet incelemeye alındı.';

  @override
  String get decide => 'Karar ver';

  @override
  String get decisionResultTitle => 'Verilen karar';

  @override
  String get decisionFullRefund => 'Tam iade';

  @override
  String get decisionFullRefundDesc =>
      'Müşteriye tutarın tamamı iade edilir. İş iptal edilir, hizmet bedeli alınmaz.';

  @override
  String get decisionSplit => '%50 / %50';

  @override
  String get decisionSplitDesc =>
      'Tutar müşteri ile usta arasında yarı yarıya bölünür. Hizmet bedeli alınmaz.';

  @override
  String get decisionRelease => 'Şikayeti reddet, ustaya aktar';

  @override
  String get decisionReleaseDesc =>
      'Şikayet reddedilir, tutar ustaya aktarılır ve %10 hizmet bedeli alınır.';

  @override
  String get outcomeCustomerRefund => 'Müşteriye iade';

  @override
  String get outcomeProPayout => 'Ustaya ödeme';

  @override
  String decisionDialogTitle(String code) {
    return '$code için karar';
  }

  @override
  String decisionDialogIntro(String total) {
    return 'Güvence havuzundaki tutar $total. İade ve usta payını karar verilince sunucu hesaplar; sonuç şikayet ekranında görünür.';
  }

  @override
  String get decisionDialogIntroNoPayment =>
      'Bu iş için güvence havuzu kaydı bulunamadı. İade ve usta payını karar verilince sunucu hesaplar.';

  @override
  String get decisionPickOne => 'Bir karar seç.';

  @override
  String get decisionNoteLabel => 'Karar gerekçesi';

  @override
  String get warnPro => 'Ustaya uyarı yaz';

  @override
  String get warnProHint => 'Ustanın uyarı sayısı 1 artar.';

  @override
  String get suspendProProfile => 'Usta profilini askıya al';

  @override
  String get suspendProProfileHint =>
      'Bekleyen teklifleri geri çekilir. Kullanıcı hesabı askıya alınmaz.';

  @override
  String get decisionSubmit => 'Kararı ver';

  @override
  String get decisionConfirmTitle => 'Kararı kesinleştir';

  @override
  String decisionConfirmMessage(String decision) {
    return 'Seçtiğin karar: $decision.\n\nTutarları sunucu hesaplar; sonuç şikayet ekranında görünür.\n\nBu karar geri alınamaz. Para hareketi hemen yapılır, karar iki tarafa bildirilir ve şikayet kapanır.';
  }

  @override
  String get decisionConfirmWarn => 'Ustaya uyarı kaydı da düşülecek.';

  @override
  String get decisionConfirmSuspend => 'Usta profili de askıya alınacak.';

  @override
  String get decisionConfirmAction => 'Kararı kesinleştir';

  @override
  String get decisionGatewayFailed =>
      'Ödeme sistemine ulaşılamadı, hiçbir şey değişmedi. Biraz sonra tekrar dene.';

  @override
  String get decisionDone => 'Karar verildi, iki taraf bilgilendirildi.';

  @override
  String get accountsTitle => 'Hesaplar';

  @override
  String get accountsSubtitle => 'Müşteri, usta ve yönetici hesapları.';

  @override
  String get accountsSearchHint => 'Ad, e-posta ya da telefon';

  @override
  String get accountsEmptyTitle => 'Hesap bulunamadı';

  @override
  String get accountsEmptyMessage => 'Aramanı ya da süzgeçleri değiştir.';

  @override
  String proRoleLine(String business, String status) {
    return 'Usta: $business ($status)';
  }

  @override
  String get suspend => 'Askıya al';

  @override
  String suspendAccountTitle(String name) {
    return '$name hesabını askıya al';
  }

  @override
  String get suspendAccountMessage =>
      'Kullanıcının tüm oturumları kapanır ve bekleyen teklifleri geri çekilir. Süren işlere dokunulmaz.';

  @override
  String get suspendNoteLabel => 'Askıya alma gerekçesi';

  @override
  String get suspendedNotice => 'Hesap askıya alındı.';

  @override
  String suspendedWithJobsNotice(int count) {
    return 'Hesap askıya alındı. Süren $count iş var, bunlara dokunulmadı.';
  }

  @override
  String get reactivate => 'Yeniden aktifleştir';

  @override
  String reactivateTitle(String name) {
    return '$name hesabını yeniden aktifleştir';
  }

  @override
  String get reactivateMessage => 'Kullanıcı yeniden giriş yapabilir.';

  @override
  String get reactivatedNotice => 'Hesap yeniden aktifleştirildi.';

  @override
  String get reactivatePro => 'Usta profilini aç';

  @override
  String reactivateProTitle(String business) {
    return '$business usta profilini yeniden aç';
  }

  @override
  String get reactivateProMessage =>
      'Askıdaki usta profili yeniden doğrulanmış duruma döner ve usta yeniden talep görür.';

  @override
  String get proReactivatedNotice => 'Usta profili yeniden açıldı.';

  @override
  String get cannotSuspendSelf => 'Kendi hesabını askıya alamazsın.';

  @override
  String get cannotSuspendAdmin => 'Yönetici hesapları askıya alınamaz.';

  @override
  String get paymentsTitle => 'Ödeme defteri';

  @override
  String get paymentsSubtitle => 'Güvence havuzu kayıtları ve toplamlar.';

  @override
  String get paymentsEmptyTitle => 'Bu durumda ödeme yok';

  @override
  String get paymentsEmptyMessage => 'Başka bir durum seçmeyi dene.';

  @override
  String get totalLocked => 'Güvence havuzunda';

  @override
  String get totalReleased => 'Ustalara aktarılan';

  @override
  String get totalCommission => 'Hizmet bedeli toplamı';

  @override
  String get totalRefunded => 'İade edilen';
}
