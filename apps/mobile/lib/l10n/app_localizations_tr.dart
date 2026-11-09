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

  @override
  String get save => 'Kaydet';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get close => 'Kapat';

  @override
  String get done => 'Bitti';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get searchLabel => 'Ara';

  @override
  String get noSearchResults => 'Sonuç bulunamadı';

  @override
  String get pickerNone => 'Seç';

  @override
  String get photoLoadFailed => 'Fotoğraf yüklenemedi';

  @override
  String get goHome => 'Ana sayfaya git';

  @override
  String get goToMyRequests => 'Taleplerime git';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String get reasonRequired => 'Devam etmek için bir gerekçe seç.';

  @override
  String get total => 'Toplam';

  @override
  String get labor => 'İşçilik';

  @override
  String get materials => 'Malzeme';

  @override
  String get totalVatIncluded => 'Toplam tutar (KDV dahil)';

  @override
  String get vatIncluded => 'KDV dahil';

  @override
  String get warranty => 'İşçilik garantisi';

  @override
  String get warrantyNone => 'Yok';

  @override
  String warrantyMonths(int months) {
    return '$months ay';
  }

  @override
  String get warrantyHelp => 'Platform garanti vermez; garantiyi sen verirsin.';

  @override
  String get arrival => 'Varış aralığı';

  @override
  String get urgencyUrgent => 'Acil onarım';

  @override
  String get urgencyPlanned => 'Planlı iş';

  @override
  String get tabActive => 'Aktif';

  @override
  String get tabPast => 'Geçmiş';

  @override
  String get dateToday => 'Bugün';

  @override
  String get dateTomorrow => 'Yarın';

  @override
  String get requestAwaitingOffers => 'Teklif bekleniyor';

  @override
  String requestOffersCount(int count) {
    return '$count teklif geldi';
  }

  @override
  String get requestAssigned => 'Usta seçildi';

  @override
  String get requestCancelled => 'İptal edildi';

  @override
  String get requestExpired => 'Süresi doldu';

  @override
  String get offerPending => 'Bekliyor';

  @override
  String get offerAccepted => 'Kabul edildi';

  @override
  String get offerDeclined => 'Reddedildi';

  @override
  String get offerWithdrawn => 'Geri çekildi';

  @override
  String get offerSuperseded => 'Başka teklif seçildi';

  @override
  String get offerExpired => 'Süresi doldu';

  @override
  String get statusApproved => 'Doğrulandı';

  @override
  String get proVerified => 'Doğrulandı';

  @override
  String get photoAdd => 'Fotoğraf ekle';

  @override
  String get photoFromCamera => 'Kamerayla çek';

  @override
  String get photoFromGallery => 'Galeriden seç';

  @override
  String get photoRemove => 'Fotoğrafı kaldır';

  @override
  String get photoUploading => 'Yükleniyor';

  @override
  String get photoUploaded => 'Yüklendi';

  @override
  String photoLimitReached(int count) {
    return 'En fazla $count fotoğraf eklenebilir';
  }

  @override
  String get photoTooLarge =>
      'Fotoğraf 1,5 MB sınırını aşıyor. Daha küçük bir fotoğraf seç.';

  @override
  String get addressesTitle => 'Adreslerim';

  @override
  String get addressAdd => 'Adres ekle';

  @override
  String get addressDefault => 'Varsayılan';

  @override
  String get addressMakeDefault => 'Varsayılan yap';

  @override
  String get addressesEmptyTitle => 'Kayıtlı adresin yok';

  @override
  String get addressesEmptyBody =>
      'Talep oluştururken kullanmak için bir adres ekle.';

  @override
  String get addressDeleteTitle => 'Adres silinsin mi?';

  @override
  String addressDeleteMessage(String label) {
    return '\"$label\" adresi silinir. Bu işlem geri alınamaz.';
  }

  @override
  String get addressLabelField => 'Adres adı';

  @override
  String get addressLabelHint => 'Örn. Ev, İş';

  @override
  String get addressDistrict => 'İlçe';

  @override
  String get addressNeighborhood => 'Mahalle';

  @override
  String get addressLine => 'Açık adres';

  @override
  String get addressLineHint => 'Cadde, sokak, bina ve daire no';

  @override
  String get addressDoorNote => 'Kapı notu (isteğe bağlı)';

  @override
  String get addressDoorNoteHelp =>
      'Tam adres ve kapı notu yalnızca usta seçildikten sonra paylaşılır.';

  @override
  String get createRequest => 'Talep oluştur';

  @override
  String homeGreeting(String name) {
    return 'Merhaba $name';
  }

  @override
  String get homeActiveRequest => 'Aktif talebin';

  @override
  String get homeNoActiveTitle => 'Aktif talebin yok';

  @override
  String get homeNoActiveBody =>
      'Evdeki tamir işi için talep aç, ustalardan teklif gelsin.';

  @override
  String seeOffers(int count) {
    return 'Teklifleri gör ($count)';
  }

  @override
  String offerRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String get requestsEmptyActiveTitle => 'Aktif talebin yok';

  @override
  String get requestsEmptyActiveBody =>
      'Yeni bir talep açarak ustalardan teklif alabilirsin.';

  @override
  String get requestsEmptyPastTitle => 'Geçmiş talebin yok';

  @override
  String get requestsEmptyPastBody =>
      'İptal ettiğin ya da süresi dolan talepler burada görünür.';

  @override
  String get requestDetailTitle => 'Talep detayı';

  @override
  String get requestCode => 'Talep kodu';

  @override
  String get requestLocation => 'Konum';

  @override
  String get requestExpiresOn => 'Son gün';

  @override
  String get requestAnswers => 'Cevapların';

  @override
  String get requestPhotos => 'Fotoğraflar';

  @override
  String get requestCancel => 'Talebi iptal et';

  @override
  String get keepRequest => 'Vazgeç, talebi koru';

  @override
  String get cancelReasonTitle => 'İptal gerekçesi';

  @override
  String get cancelReasonPlansChanged => 'Planlarım değişti';

  @override
  String get cancelReasonSolved => 'Sorunu çözdüm';

  @override
  String get cancelReasonNoSuitableOffer => 'Uygun teklif gelmedi';

  @override
  String get cancelReasonOther => 'Diğer';

  @override
  String get cancelConfirmTitle => 'Talep iptal edilsin mi?';

  @override
  String get cancelConfirmMessage =>
      'Bekleyen tüm teklifler kapanır. Bu işlem geri alınamaz.';

  @override
  String get publishedTitle => 'Talebin yayınlandı';

  @override
  String publishedMatchTitle(int count) {
    return '$count usta eşleşti';
  }

  @override
  String get publishedMatchBody =>
      'Eşleşen ustalara bildirim gitti. Teklifler geldikçe Taleplerim sekmesinde göreceksin.';

  @override
  String get publishedNoMatchTitle => 'Şu an eşleşen usta yok';

  @override
  String get publishedNoMatchBody =>
      'Talebin açık kalırsa bölgene yeni ustalar katıldığında görebilir. İstersen talebi düzenleyip kategori ya da konumu değiştir.';

  @override
  String get matchReasons => 'Neden eşleşti';

  @override
  String get matchCategory => 'Kategoriye uygun';

  @override
  String get matchDistrict => 'İlçende hizmet veriyor';

  @override
  String get matchAvailability => 'Şu an müsait';

  @override
  String get keepOpen => 'Açık tut';

  @override
  String get wizTitle => 'Yeni talep';

  @override
  String get wizEditTitle => 'Talebi düzenle';

  @override
  String wizStepOf(int step, int total) {
    return 'Adım $step / $total';
  }

  @override
  String get wizContinue => 'Devam';

  @override
  String get wizBackToReview => 'Gözden geçir';

  @override
  String get wizPublish => 'Talebi yayınla';

  @override
  String get wizSaveChanges => 'Değişiklikleri kaydet';

  @override
  String get wizStep1Title => 'Kategori ve aciliyet';

  @override
  String get wizStep2Title => 'Konum ve detaylar';

  @override
  String get wizStep3Title => 'Fotoğraf ve açıklama';

  @override
  String get wizStep4Title => 'Gözden geçir';

  @override
  String get wizCategory => 'Kategori';

  @override
  String get wizUrgency => 'Aciliyet';

  @override
  String get wizUrgentHint => 'Mümkün olan en kısa sürede';

  @override
  String get wizPlannedHint => 'Uygun olduğun tarih aralığını seç';

  @override
  String get wizDates => 'Tarih aralığı';

  @override
  String get wizDateFrom => 'En erken';

  @override
  String get wizDateTo => 'En geç';

  @override
  String get wizAddress => 'Adres';

  @override
  String get wizAddAddress => 'Yeni adres ekle';

  @override
  String get wizFieldTitle => 'Başlık';

  @override
  String get wizFieldTitleHint => 'Örn. Mutfak musluğu damlatıyor';

  @override
  String get wizFieldDescription => 'Açıklama';

  @override
  String get wizFieldDescriptionHint =>
      'Sorunu ve ustanın bilmesi gerekenleri yaz';

  @override
  String wizDescriptionCount(int count, int min) {
    return '$count / en az $min karakter';
  }

  @override
  String wizPhotos(int max) {
    return 'Fotoğraflar (en fazla $max)';
  }

  @override
  String get wizPhotosHint =>
      'Sorunu gösteren net fotoğraflar teklif almanı kolaylaştırır.';

  @override
  String get wizPhotosCount => 'Fotoğraf sayısı';

  @override
  String get wizReviewNote => 'Yayınladığında eşleşen ustalara bildirim gider.';

  @override
  String get wizErrCategory => 'Devam etmek için bir kategori seç.';

  @override
  String get wizErrDateFrom => 'En erken tarihi seç.';

  @override
  String get wizErrDateTo => 'En geç tarihi seç.';

  @override
  String get wizErrDateOrder => 'Bitiş, başlangıçtan sonra olmalı.';

  @override
  String get wizErrDatePast => 'Başlangıç ileri bir zamanda olmalı.';

  @override
  String get wizErrDateRange =>
      'Tarih aralığı en fazla 30 gün sonrasına kadar olabilir.';

  @override
  String get wizErrAddress => 'Bir adres seç ya da yeni adres ekle.';

  @override
  String get wizErrAnswers => 'Tüm soruları cevapla.';

  @override
  String wizErrTitle(int min, int max) {
    return 'Başlık $min-$max karakter olmalı.';
  }

  @override
  String wizErrDescription(int min) {
    return 'Açıklama en az $min karakter olmalı.';
  }

  @override
  String get wizErrPhotosBusy => 'Fotoğraflar yüklenirken bekle.';

  @override
  String get wizErrPhotosFailed =>
      'Yüklenemeyen fotoğrafı yeniden dene ya da kaldır.';

  @override
  String get offersTitle => 'Gelen teklifler';

  @override
  String offersResultCount(int count) {
    return '$count teklif';
  }

  @override
  String offersDeclinedCount(int count) {
    return '$count teklifi reddettin.';
  }

  @override
  String get offersEmptyTitle => 'Henüz teklif yok';

  @override
  String get offersEmptyBody => 'Ustalar teklif verdikçe burada göreceksin.';

  @override
  String get offersEmptyFilteredTitle => 'Filtreye uyan teklif yok';

  @override
  String get offersEmptyFilteredBody => 'Filtreleri gevşetip tekrar dene.';

  @override
  String get offersClearFilters => 'Filtreleri temizle';

  @override
  String get offersFilterTitle => 'Filtrele ve sırala';

  @override
  String get sortBy => 'Sıralama';

  @override
  String get sortRecommended => 'Önerilen';

  @override
  String get sortPrice => 'En düşük fiyat';

  @override
  String get sortRating => 'En yüksek puan';

  @override
  String get sortArrival => 'En hızlı varış';

  @override
  String get filterMaxPrice => 'Üst fiyat sınırı';

  @override
  String get filterMaxPriceLabel => 'En çok (₺)';

  @override
  String get filterMaxPriceHelp =>
      'İşçilik ve malzeme dahil. Boş bırakırsan sınır olmaz.';

  @override
  String get filterMinRating => 'Usta puanı';

  @override
  String get filterAnyRating => 'Hepsi';

  @override
  String filterRatingOrMore(String rating) {
    return '$rating+';
  }

  @override
  String get applyFilters => 'Sonuçları uygula';

  @override
  String get compare => 'Karşılaştır';

  @override
  String get compareCancel => 'Vazgeç';

  @override
  String get compareHint => '2 ya da 3 teklif seç.';

  @override
  String compareSelected(int count) {
    return 'Karşılaştır ($count)';
  }

  @override
  String get compareTitle => 'Karşılaştırma';

  @override
  String get compareTotal => 'Toplam (KDV dahil)';

  @override
  String get compareGoneTitle => 'Teklifler artık listede yok';

  @override
  String get compareGoneBody =>
      'Teklifler geri çekilmiş ya da süresi dolmuş olabilir.';

  @override
  String get compareBackToOffers => 'Tekliflere dön';

  @override
  String get viewOffer => 'Teklifi gör';

  @override
  String get proRating => 'Puan';

  @override
  String get proCompletedJobs => 'Tamamlanan iş';

  @override
  String get noRatingYet => 'Henüz puan yok';

  @override
  String ratingWithCount(String avg, int count) {
    return '$avg ($count)';
  }

  @override
  String get offerDetailTitle => 'Teklif';

  @override
  String get offerBreakdown => 'Teklif dökümü';

  @override
  String get offerNote => 'Usta notu';

  @override
  String get offerValidUntil => 'Geçerlilik';

  @override
  String get offerAccept => 'Teklifi kabul et';

  @override
  String get offerDecline => 'Teklifi reddet';

  @override
  String get viewProfile => 'Profili görüntüle';

  @override
  String declineIntro(String pro, String amount) {
    return '$pro tarafından gelen $amount tutarındaki teklifi reddetmek üzeresin.';
  }

  @override
  String get declineIrreversible =>
      'Bu işlem geri alınamaz; ustanın profiline olumsuz yansımaz.';

  @override
  String get declineReasonTitle => 'Reddetme sebebi';

  @override
  String get declineReasonPrice => 'Fiyat bütçeme uygun değil';

  @override
  String get declineReasonSchedule => 'Zamanlama planıma uymuyor';

  @override
  String get declineReasonOtherOffer =>
      'Başka bir teklifle ilerlemeye karar verdim';

  @override
  String get declineReasonNotNeeded => 'Artık bu hizmete ihtiyacım kalmadı';

  @override
  String get declineReasonOther => 'Diğer';

  @override
  String get declineKeepOpen => 'Talebim açık kalsın';

  @override
  String get declineKeepOpenHelp => 'Kapalıysa talebin de iptal edilir.';

  @override
  String get declineCloseNeedsReason =>
      'Talebi kapatmak için \"Artık ihtiyacım kalmadı\" ya da \"Diğer\" seç.';

  @override
  String get declineConfirmTitle => 'Teklif reddedilsin mi?';

  @override
  String get declineConfirmKeepOpen =>
      'Teklif reddedilir, talebin açık kalır. Bu işlem geri alınamaz.';

  @override
  String get declineConfirmClose =>
      'Teklif reddedilir ve talebin iptal edilir. Bu işlem geri alınamaz.';

  @override
  String get declineBack => 'Vazgeç, teklife dön';

  @override
  String get proProfileTitle => 'Usta profili';

  @override
  String get proReviews => 'Değerlendirmeler';

  @override
  String get proAbout => 'Hakkında';

  @override
  String get proExperience => 'Deneyim';

  @override
  String experienceYears(int years) {
    return '$years yıl';
  }

  @override
  String get proMemberSince => 'Üyelik';

  @override
  String get proVerifiedDocuments => 'Doğrulanmış belgeler';

  @override
  String get proNoVerifiedDocs => 'Henüz doğrulanmış belge yok.';

  @override
  String get proCategories => 'Kategoriler';

  @override
  String get proServiceAreas => 'Hizmet bölgeleri';

  @override
  String get docIdentity => 'Kimlik';

  @override
  String get docTradeCert => 'Mesleki yeterlilik';

  @override
  String get docTax => 'Vergi levhası';

  @override
  String get docCriminalRecord => 'Adli sicil kaydı';

  @override
  String get reviewsEmptyTitle => 'Henüz değerlendirme yok';

  @override
  String get reviewsEmptyBody =>
      'Müşteriler işi tamamlayınca değerlendirmeler burada görünür.';

  @override
  String starsOutOf5(int rating) {
    return '5 üzerinden $rating yıldız';
  }

  @override
  String get anonymous => 'Anonim';

  @override
  String get applyIntro =>
      'İşletme bilgilerini ve belgelerini gönder; ekibimiz inceleyip dönüş yapar.';

  @override
  String get applyBusinessName => 'İşletme adı';

  @override
  String get applyBusinessNameInvalid => 'İşletme adı en az 2 karakter olmalı.';

  @override
  String get applyAbout => 'Hakkında (isteğe bağlı)';

  @override
  String get applyExperience => 'Deneyim (yıl)';

  @override
  String get applyExperienceInvalid => 'Deneyim 0 ile 60 yıl arasında olmalı.';

  @override
  String get applyCategories => 'Kategoriler';

  @override
  String get applyDistricts => 'Hizmet verdiğin ilçeler';

  @override
  String get applyDocuments => 'Belgeler';

  @override
  String get applyDocumentsHelp =>
      'Belgelerin fotoğrafını yükle. Kimlik ve mesleki yeterlilik zorunlu.';

  @override
  String docRequired(String doc) {
    return '$doc (zorunlu)';
  }

  @override
  String docOptional(String doc) {
    return '$doc (isteğe bağlı)';
  }

  @override
  String docMissing(String doc) {
    return '$doc belgesini yükle.';
  }

  @override
  String get applySubmit => 'Başvuruyu gönder';

  @override
  String get applyResubmit => 'Belgeleri güncelle ve yeniden gönder';

  @override
  String get applicationPendingBody =>
      'Belgelerin ve profilin kalite ekibimiz tarafından inceleniyor. Sonuç çıkınca durumun burada güncellenir.';

  @override
  String get applicationNeedsBody =>
      'Bazı belgelerin eksik ya da okunmuyor. Formu açıp belgeleri güncelleyerek yeniden gönder.';

  @override
  String get applicationRejectedBody =>
      'Başvurun kabul edilmedi. Notu okuyup belgelerini düzelterek yeniden başvurabilirsin.';

  @override
  String get applicationSuspendedBody =>
      'Hesabın askıya alındı. Destek ekibiyle iletişime geç.';

  @override
  String get adminNote => 'İnceleme notu';

  @override
  String get docStatusPending => 'İnceleniyor';

  @override
  String get docStatusAccepted => 'Kabul edildi';

  @override
  String get docStatusRejected => 'Reddedildi';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterUrgent => 'Acil';

  @override
  String get filterPlanned => 'Planlı';

  @override
  String get feedOnBreakTitle => 'Moladasın';

  @override
  String get feedOnBreakBody =>
      'Mola sırasında yeni talepler gelmez. Hazır olduğunda tekrar aktif ol.';

  @override
  String get feedActivate => 'Aktif ol';

  @override
  String get feedEmptyTitle => 'Şu an uygun talep yok';

  @override
  String get feedEmptyBody =>
      'Kategorine ve ilçelerine uyan yeni talepler burada görünür.';

  @override
  String feedPhotos(int count) {
    return '$count fotoğraf';
  }

  @override
  String feedOffers(int count) {
    return '$count teklif';
  }

  @override
  String get feedMyOffer => 'Teklif verdin';

  @override
  String get locationMasked => 'Tam adres, teklifin kabul edilince paylaşılır.';

  @override
  String get prepareOffer => 'Teklif hazırla';

  @override
  String get viewMyOffer => 'Teklifini gör';

  @override
  String get jobsEmptyTitle => 'Henüz işin yok';

  @override
  String get jobsEmptyBody => 'Bir teklifin kabul edilince iş burada görünür.';

  @override
  String get offerFormTitle => 'Teklif hazırla';

  @override
  String get laborAmountLabel => 'İşçilik tutarı';

  @override
  String get laborAmountInvalid =>
      'İşçilik tutarı 0\'dan büyük olmalı. Örnek: 1.200';

  @override
  String get materialsEmpty => 'Malzeme eklemediysen boş bırakabilirsin.';

  @override
  String get materialAdd => 'Malzeme kalemi ekle';

  @override
  String get materialRemove => 'Kalemi sil';

  @override
  String get materialDescription => 'Malzeme';

  @override
  String get materialQuantity => 'Adet';

  @override
  String get materialQuantityInvalid => 'Adet 1 ya da daha fazla olmalı.';

  @override
  String get materialUnitPrice => 'Birim fiyat';

  @override
  String get materialPriceInvalid => 'Geçerli bir tutar gir. Örnek: 350';

  @override
  String get arrivalHelp =>
      'Müşterinin seçeceği varış aralığı: 1-12 saat, en geç 14 gün sonrası.';

  @override
  String get arrivalDay => 'Gün';

  @override
  String get arrivalStart => 'Başlangıç saati';

  @override
  String get arrivalLength => 'Aralık uzunluğu';

  @override
  String hoursShort(int hours) {
    return '$hours sa';
  }

  @override
  String get arrivalMissing => 'Gün ve başlangıç saatini seç.';

  @override
  String get arrivalPast => 'Varış zamanı ileri bir tarih olmalı.';

  @override
  String get arrivalTooShort => 'Aralık en az 1 saat olmalı.';

  @override
  String get arrivalTooLong => 'Aralık en fazla 12 saat olabilir.';

  @override
  String get arrivalTooFar => 'Varış en geç 14 gün sonrası olabilir.';

  @override
  String get offerSummary => 'Özet';

  @override
  String serviceFee(int percent) {
    return 'Hizmet bedeli (%$percent)';
  }

  @override
  String get netEarning => 'Net kazancın';

  @override
  String get offerSend => 'Teklifi gönder';

  @override
  String get offerSentTitle => 'Teklifin';

  @override
  String get offerSentHeadline => 'Teklifin gönderildi';

  @override
  String get offerSentBody =>
      'Müşteri teklifini inceleyecek. Durumu Tekliflerim ekranından takip edebilirsin.';

  @override
  String get goToMyOffers => 'Tekliflerime git';

  @override
  String get backToFeed => 'Taleplere dön';

  @override
  String get myOffersTitle => 'Tekliflerim';

  @override
  String get myOffersEmptyTitle => 'Teklif yok';

  @override
  String get myOffersEmptyBody => 'Verdiğin teklifler burada görünür.';

  @override
  String get withdraw => 'Geri çek';

  @override
  String get withdrawTitle => 'Teklif geri çekilsin mi?';

  @override
  String get withdrawMessage =>
      'Teklif müşteriye artık görünmez. Bu işlem geri alınamaz.';

  @override
  String get availabilityActive => 'Aktifsin';

  @override
  String get availabilityBreak => 'Moladasın';

  @override
  String get availabilityActiveHelp =>
      'Eşleşen yeni talepler akışında görünür.';

  @override
  String get availabilityBreakHelp =>
      'Mola sırasında yeni talep eşleşmez; mevcut işlerin sürer.';

  @override
  String get profileEditTitle => 'Profilini düzenle';

  @override
  String get profileBio => 'Profil yazısı';

  @override
  String get profileSaved => 'Profilin kaydedildi';

  @override
  String get workingHours => 'Çalışma saatleri';

  @override
  String get hoursFrom => 'Başlangıç';

  @override
  String get hoursTo => 'Bitiş';

  @override
  String get hoursAcceptsUrgent => 'Acil işleri de kabul ederim';

  @override
  String get hoursInvalid => 'Bitiş saati başlangıçtan sonra olmalı.';

  @override
  String wizErrServerField(String field) {
    return '“$field” bilgisi kabul edilmedi. Kontrol edip tekrar dene.';
  }

  @override
  String get wizEditOffersTitle => 'Değişiklikler kaydedilsin mi?';

  @override
  String wizEditOffersMessage(int count) {
    return '$count bekleyen teklifin geçersiz olur. Ustalar güncel talebine yeniden teklif verebilir. Bu işlem geri alınamaz.';
  }

  @override
  String get photoDuplicate => 'Bu fotoğrafı zaten ekledin.';

  @override
  String get feedEditProfile => 'Kategori ve ilçelerini düzenle';

  @override
  String get arrivalServerInvalid =>
      'Varış aralığı kabul edilmedi. Gün ve saatleri kontrol edip tekrar dene.';

  @override
  String get offerItemsServerInvalid =>
      'Kalem toplamları tutmadı. Malzeme kalemlerini kontrol edip tekrar dene.';
}
