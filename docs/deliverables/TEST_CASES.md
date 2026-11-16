# BiTadilat — Test Senaryoları ve İzlenebilirlik

Kod tabanı: `feature/flutter-app` 565bfb4. Plan: `TEST_PLAN.md`. Sonuç raporu: `TEST_REPORT_TEMPLATE.md`.

## Okuma kılavuzu

**Durum sütunu** (bu belgenin yazıldığı andaki durum):

| Durum | Anlamı |
|---|---|
| Otomatik, geçti | Aşağıda adı verilen otomatik test(ler) var ve 565bfb4 üzerinde tam koşuda yeşil (backend 308, mobil 525, admin 87, ui 27, api 101) |
| Kısmi | Bir kısmı otomatik test ile kapsanıyor, eksik kısım "Not" olarak yazıldı |
| Boşluk | Otomatik test **yok**. Elle test planı ya da yeni test gerekiyor |
| Elle, bekliyor | Yalnızca elle yapılabilir (sandbox, Simulator, insanla), henüz kanıtlı koşusu yok |
| Gerçekleştirilmedi | Özellik yok, test edilemez |

**Referans biçimi:** Java için `Sınıf#yöntem`, Dart için `dosya` + "test adı" (testin tam veya baş kısmı). Backend testleri `backend/src/test/java/com/bitadilat/` altında, Dart testleri `apps/mobile/test`, `apps/admin/test`, `packages/*/test` altındadır. "Geçti" yalnızca otomatik testin yeşil olduğunu söyler; senaryonun her adımının o testle kapsandığını **garanti etmez**, kapsam farkı Not'ta yazıldı.

**Kısaltmalar:** MOB = `apps/mobile/test`, ADM = `apps/admin/test`, API = `packages/bitadilat_api/test`, UI = `packages/bitadilat_ui/test`. Öncelik: Y yüksek, O orta, D düşük (RAD).

---

## 1. UC01 — Kayıt, giriş, şifre, hesap (Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-AUTH-01 | UC01 | Müşteri kaydı | Ad, e-posta, telefon, şifre, KVKK + koşul onayı ile `POST /auth/register` | 201, access + refresh token, `me`; usta profili oluşmaz | `auth/AuthFlowTest#registerReturnsTokensAndMe`, `#wantsProCreatesNoProProfile`; MOB `auth_screens_test` "müşteri kaydı -> /c/home; gövde sözleşmeye uyar" | Otomatik, geçti |
| TC-AUTH-02 | UC01 | Telefon E.164 normalleşir | `0532 123 45 67` gibi yazımlarla kayıt ve giriş | Hepsi `+90...` olarak saklanır; yabancı/sabit numara reddedilir | `AuthFlowTest#registerNormalizesPhoneToE164`, `#loginWorksWithEmailAndWithEveryPhoneSpelling`; `common/CommonRulesTest#phoneNumbersNormalizeToE164`, `#nonMobileOrForeignNumbersAreRejected`; MOB "telefon +90 biçiminde normalleşir" | Otomatik, geçti |
| TC-AUTH-03 | UC01 | Tekrarlı e-posta ya da telefon | Aynı e-posta/telefonla ikinci kayıt, eşzamanlı kayıt | 409/alan hatası, doğru alan adı | `AuthFlowTest#duplicateEmailAndPhoneAreRejected`; `AuthHardeningTest#registrationRaceMapsConstraintToTheRightField` | Otomatik, geçti |
| TC-AUTH-04 | UC01 | Alan doğrulama | Boş alan, zayıf şifre, eksik telefon, KVKK işaretsiz | İstek gitmez (istemci) ya da 400 alan adıyla (sunucu) | `AuthFlowTest#validationErrorsNameTheField`; `CommonRulesTest#passwordRule`; MOB "boş gönderimde doğrulama hataları, istek gitmez", "zayıf şifre ve eksik telefon hataları" | Otomatik, geçti |
| TC-AUTH-05 | UC01 | Giriş (e-posta / telefon) | Doğru kimlik ile giriş | 200 ve token çifti | `AuthFlowTest#loginWorksWithEmailAndWithEveryPhoneSpelling`; `dev/DevSeedTest#allSeedAccountsCanLogInWithDemoPassword` | Otomatik, geçti |
| TC-AUTH-06 | UC01, hedef 5 | Yanlış şifre ile hesap varlığı sızmaz | Yanlış şifre ve olmayan hesap | İkisi de aynı `BAD_CREDENTIALS` | `AuthFlowTest#wrongPasswordAndUnknownUserGiveSameError` | Otomatik, geçti |
| TC-AUTH-07 | UC01, hedef 5 | Kaba kuvvet sınırı | 5 başarısız giriş, sonra doğru şifre; e-posta ve telefon karışık; eşzamanlı | 6. deneme `429 TOO_MANY_ATTEMPTS`; sayaç tek; başarılı giriş sayacı sıfırlar | `AuthFlowTest#sixthFailedAttemptIsThrottledEvenWithCorrectPassword`, `#successfulLoginResetsFailureCount`; `AuthHardeningTest#emailAndPhoneShareOneFailureCounter`, `#parallelWrongPasswordsCannotExceedTheLimit`; MOB `session_audit_test` "429 geçicidir: token silinmez, tekrar dene çıkar" | Otomatik, geçti |
| TC-AUTH-08 | UC01, UC13 | Askıya alınmış hesap | Askıdaki hesapla giriş / açık oturumda istek | `401 ACCOUNT_SUSPENDED`, oturum kapanır, açıklama gösterilir | `AuthFlowTest#suspendedAccountCannotLogin`; MOB `session_audit_test` "401 ACCOUNT_SUSPENDED: oturum kapanır, açıklamalı karşılama"; ADM `auth_test` "askıdaki hesabın girişi açık mesajla reddedilir" | Otomatik, geçti |
| TC-AUTH-09 | UC01, hedef 5 | Refresh token döndürme | Yenile, eski token ile tekrar yenile | Yeni çift; eski token tekrar gelirse tüm aile iptal | `AuthFlowTest#refreshRotatesAndStoresOnlyHash`, `#reusingOldRefreshTokenRevokesWholeFamily`, `#unknownRefreshTokenIsRejected`; `AuthHardeningTest#parallelRefreshWithSameTokenYieldsAtMostOneSession`, `#expiredRefreshTokenIsUnauthenticatedNotTokenExpired` | Otomatik, geçti |
| TC-AUTH-10 | UC01 | İstemci 401 sonrası sessiz yenileme | Süresi dolmuş token ile istek | Bir kez yenilenir, istek yeni token ile tekrarlanır; çıkış sırasında yenileme token yazmaz | API `auth_interceptor_audit_test` "tekrar denenen istek yeni token ile gider", "refresh sürerken çıkış yapılırsa token..." | Otomatik, geçti |
| TC-AUTH-11 | UC01 | Çıkış | Çıkış yap | Aile iptal, cihazda token kalmaz; ikinci çıkış zararsız | `AuthFlowTest#logoutRevokesFamilyAndIsIdempotent`; MOB `secure_token_store_test` "çıkışta depoda hiçbir token kalmaz"; ADM `auth_test` "çıkış girişe döndürür ve token siler" | Otomatik, geçti |
| TC-AUTH-12 | UC01 | Şifre sıfırlama | E-postayla kod iste, kodla yeni şifre | Kod yalnızca bilinen hesaba gider ama yanıt aynı; şifre değişir, oturumlar kapanır; 5 yanlış denemede, 15 dk sonra, saatte 5 koddan sonra geçersiz | `AuthFlowTest#forgotAlwaysAcceptedAndOnlySendsForKnownAccounts`, `#resetFlowChangesPasswordAndEndsSessions`, `#fiveWrongAttemptsInvalidateTheCode`, `#expiredCodeIsRejected`, `#resetForUnknownEmailLooksLikeWrongCode`; `AuthHardeningTest#forgotIssuesAtMostFiveCodesPerHour`; MOB `auth_screens_test` "istek -> kod ve yeni şifre -> giriş ekranı, geri tuşu forma dönmez" | Otomatik, geçti. Not: gerçek e-posta yok (kod log'a yazılır) |
| TC-AUTH-13 | UC01, hedef 5 | Token sahteciliği | Bozuk, `alg=none`, başka sırla imzalı, süresi dolmuş token | 401 JSON; süresi dolan için `TOKEN_EXPIRED` | `AuthFlowTest#garbageTokenReturnsUnauthenticated`, `#expiredAccessTokenReturnsTokenExpired`, `#tokenSignedWithOtherSecretIsRejected`, `#protectedEndpointWithoutTokenReturnsJson401`; `AuthHardeningTest#unsignedAlgNoneTokenIsRejected`, `#onlyHs256WithOurSecretAndIssuerIsAccepted` | Otomatik, geçti |
| TC-AUTH-14 | UC01 | Şifre değiştirme | Mevcut şifre ile yeni şifre | Mevcut şifre gerekli; diğer oturumlar kapanır, geçerli oturum kalır | `user/AccountTest#changePasswordRequiresCurrentPassword`, `#changePasswordRevokesOtherSessionsButKeepsCurrentFamily` | Otomatik, geçti. Not: mobil ekran testi yok |
| TC-AUTH-15 | UC01, KVKK | Hesap silme (sunucu) | Hesabı sil; açık işi ya da kilitli emaneti olan hesap | Anonimleşir, giriş yapılamaz; açık iş/kilitli ödeme varsa reddedilir | `AccountTest#deletedAccountIsAnonymizedAndCannotLogIn`; `job/JobFlowTest#accountWithOpenJobCannotBeDeleted`, `#accountWithLockedOrInFlightPaymentCannotBeDeleted` | Otomatik, geçti |
| TC-AUTH-16 | UC01 | Hesap silme (mobil arayüz) | Ayarlar > Hesabı sil, onay diyaloğu | Onay sonrası `DELETE /me`, çıkış | — | **Boşluk** (mobilde `DELETE /me` çağrısı ve onay diyaloğu için test bulunamadı) |
| TC-AUTH-17 | UC01 | Müşteri/usta mod geçişi | Usta profili yokken usta moduna geç; onaylı usta modu | Profil yoksa reddedilir; son mod kaydedilir ve açılışta uygulanır | `AccountTest#proModeNeedsProProfile`; MOB `wave3_extras_test` "lastMode PRO + onaysız usta: giriş /p/application açar", "lastMode PRO + onaylı usta: usta akışı"; `notifications_wave4_test` "mod değişimi diyaloğu" | Otomatik, geçti |
| TC-AUTH-18 | UC01 | Rota korumaları | Oturumsuz korumalı rota, rol sınırı, açık yönlendirme, onaysız usta | `/welcome?next=`; rol dışı rota yönlendirilir; `next` dış adres olamaz | MOB `router_guards_test` "oturumsuz /c/requests -> /welcome?next=/c/requests", "rol sınırı: usta modunda /c/requests -> /p/jobs", "next dış adres olamaz: açık yönlendirme engellenir", "pro == null iken /p/feed -> /p/apply" | Otomatik, geçti |
| TC-AUTH-19 | UC01, UC12 | Yönetici ayrımı | Admin hesabı ile mobil giriş; admin dışı hesapla panel girişi | Mobil: reddedilir, token silinir; panel: reddedilir, oturum kapanır | MOB `router_guards_test` "admin hesabı girişi reddedilir, token silinir"; ADM `auth_test` "yönetici olmayan hesap reddedilir ve oturum kapatılır" | Otomatik, geçti |
| TC-AUTH-20 | UC01, NFR | Açılış güvenliği ve dil | TR → EN geçişi kalıcı; token Keychain'de | Metin değişir ve saklanır; iCloud eşitlemesi kapalı | MOB `auth_screens_test` "TR -> EN değişince metin değişir ve kalıcı olur"; `secure_token_store_test` "iOS: first_unlock_this_device, iCloud eşitlemesi kapalı" | Otomatik, geçti |

## 2. UC02 — Talep oluştur (Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-REQ-01 | UC02, hedef 1 | Acil talep yayımla | Geçerli gövde ile `POST /requests` (URGENT) | 201, `BD-#####` kodu, sunucu hesaplı alanlar, süre sonu | `request/RequestFlowTest#urgentRequestIsPublishedWithServerComputedFields` | Otomatik, geçti |
| TC-REQ-02 | UC02, hedef 1 | Planlı talep penceresi | Geçmiş/30 günden uzak/ters pencere | 400; geçerli pencere kabul | `RequestFlowTest#plannedRequestNeedsValidFutureWindowWithin30Days` | Otomatik, geçti |
| TC-REQ-03 | UC02, hedef 1 | Eksik gönderim engellenir | Eksik/kısa alanlar, başkasının adresi/medyası | Alan hatası; başkasının kaynağı reddedilir | `RequestFlowTest#fieldValidationAndOwnershipOfAddressAndMedia`, `#lengthRulesApplyToTrimmedTextOnCreateAndPatch`; MOB `customer_wave2_test` "adım 3: başlık 5-150, açıklama en az 20, fotoğraflar", "doğrulama geçmeden ilerlenmez, geri tuşu önceki adıma gider" | Otomatik, geçti |
| TC-REQ-04 | UC02 | Sihirbaz adımları | 4 adımlı sihirbaz, kategori soruları | Adımlar sırayla; planlı tarih aralığı | MOB `customer_wave2_test` "adım 1: kategori ve planlı tarih aralığı", "adım 2: adres ve kategori soruları", "sihirbaz 4 adım ve 2x yazı" | Otomatik, geçti |
| TC-REQ-05 | UC02 | Fotoğraf sınırları | 5'ten fazla, 1,5 MB üstü, aynı fotoğraf iki kez/iki talepte | 5 ile sınırlı; büyük dosya sıkıştırılır ya da reddedilir; tek talebe bağlanır | MOB "en fazla 5 fotoğraf eklenir", "sıkıştırma küçültürse küçük dosya yüklenir", "1,5 MB reddi yerelleştirilmiş hata gösterir", `audit_wave2_test` "aynı fotoğraf iki kez eklenmez"; `RequestFlowTest#samePhotoCannotBeAttachedToTwoRequestsEvenConcurrently`; `media/MediaTest#sizeLimitsAre1_5MbForPhotosAnd5MbForDocuments` | Otomatik, geçti |
| TC-REQ-06 | UC02 | Taslak kalıcılığı | Sihirbazı yarım bırak, uygulamayı kapat/aç | Taslak geri gelir; yayından sonra silinir; başka kullanıcı görmez | MOB "uygulama kapanıp açılınca taslak geri gelir", "yayından sonra geri tuşu forma dönmez; taslak silinir", `audit_wave2_test` "başka kullanıcı önceki kullanıcının taslağını görmez" | Otomatik, geçti |
| TC-REQ-07 | UC02 | Çift dokunuş | Yayınla düğmesine iki kez bas | Tek istek gider | MOB "çift dokunuşta tek istek gider" | Otomatik, geçti |
| TC-REQ-08 | UC02 | Talep listesi | Aktif/Geçmiş, sayfalama | Durum ve süreye göre ayrım, imleçle gezinme | `RequestFlowTest#activeAndPastListsSplitByStatusAndExpiry`, `#cursorPagingWalksTheList`; MOB "Aktif ve Geçmiş sekmeleri, boş durumlar, durum etiketleri" | Otomatik, geçti |
| TC-REQ-09 | UC02 | Talep düzenleme | Açık talebi düzenle; bekleyen teklif varsa | Bekleyen teklifler `EXPIRED`, ustaya bildirim; onay istenir | `RequestFlowTest#patchEditsOpenRequestAndExpiresPendingOffers`; `common/Wave3CarryOverTest#editingARequestNotifiesProsWithAPendingOffer`; MOB "talep düzenleme sihirbazı dolu açılır ve PATCH eder", `audit_wave2_test` "bekleyen teklifi olan talep düzenlenirken onay istenir" | Otomatik, geçti |
| TC-REQ-10 | UC02, UC11 | Talep iptali | Gerekçe, onay, iptal; tekrar iptal | Talep `CANCELLED`, teklifler `EXPIRED`; tekrar iptal reddedilir | `RequestFlowTest#cancelExpiresOffersAndRejectsRepeat`; MOB "talep iptali: gerekçe, onay diyaloğu, POST" | Otomatik, geçti |
| TC-REQ-11 | UC02, hedef 5 | Başkasının talebi | Başka kullanıcının talebini oku | 404; tam adres görünmez | `RequestFlowTest#otherUsersGet404ForRequestAndNeverSeeFullAddress`, `#anonymousRequestsAreRejected` | Otomatik, geçti |
| TC-REQ-12 | UC02 | Talep süre aşımı | 7 gün kabul yok | Talep `EXPIRED`, teklifler `EXPIRED` | `offer/OfferFlowTest#schedulerExpiresDueRequestsAndOffers`, `#schedulerSkipsOffersWhoseRequestIsLockedByAUserAction` | Otomatik, geçti |
| TC-REQ-13 | UC02 | İlk talep < 3 dk | Yeni müşteri ilk talebi 3 dakikadan kısa sürede oluşturur | Süre ≤ 180 sn | — | **Elle, bekliyor** (`USABILITY_STUDY.md` görev G2) |

## 3. UC03 — Kural tabanlı eşleştirme (Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-MATCH-01 | UC03, hedef 2 | Eşleşen usta sayısı | Kategori, ilçe, müsaitlik, onay durumu farklı ustalar | Yalnız uyanlar sayılır; talep sahibi hariç | `RequestFlowTest#matchedProCountUsesCategoryDistrictAvailabilityApprovalAndExcludesOwner` | Otomatik, geçti |
| TC-MATCH-02 | UC03 | Sıfır eşleşme | Hiçbir usta uymuyor | Talep yine `OPEN` yayımlanır; müşteriye "açık tut/düzenle" | `RequestFlowTest#requestWithZeroMatchesIsStillPublished`; MOB `customer_wave2_test` "eşleşme 0 ise \"Açık tut\" ve \"Düzenle\" seçenekleri çıkar" | Otomatik, geçti |
| TC-MATCH-03 | UC03 | Usta akışı yalnız uygun talepleri gösterir | Acil/planlı filtre, moladaki usta | Uygun açık talepler; mola iken boş durum | `pro/ProFlowTest#feedShowsOnlyMatchingOpenRequestsAndHonoursUrgencyAndBreak`; MOB `pro_wave2_test` "kartlar ve Acil/Planlı filtresi sorguya gider", "onBreak: Moladasın boş durumu ve Aktif ol" | Otomatik, geçti |
| TC-MATCH-04 | UC03, hedef 5 | Usta için maskeli talep ayrıntısı | Eşleşmeyen usta, eşleşen usta | Eşleşmeyene 404; eşleşende adres maskeli | `ProFlowTest#proRequestDetailIsMaskedAndLimitedToMatchingPros` | Otomatik, geçti |
| TC-MATCH-05 | UC03, hedef 2 | Eşleşme nedenleri API'de | Talep ayrıntısında `matchFactors` | `CATEGORY`, `DISTRICT`, `AVAILABILITY` | `RequestFlowTest` (satır 37–38, `matchFactors` doğrulaması `urgentRequestIsPublishedWithServerComputedFields` içinde) | Otomatik, geçti |
| TC-MATCH-06 | UC03, hedef 2 | Eşleşme nedenleri ekranda | Müşteri talep ayrıntısında nedenleri görür | Etiketler görünür | — | **Kısmi / Boşluk** (`requests_screens.dart` nedenleri çiziyor; ekranın bu bölümü için ayrı widget testi yok) |

## 4. UC04 — Yapılandırılmış teklif (Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-OFR-01 | UC04, hedef 3 | Teklif doğrulama | Sıfır tutar, ters aralık, geçmiş başlangıç, hatalı kalem | 400 alan hatası; toplam = emek + malzeme | `offer/OfferFlowTest#offerValidationRules`, `#totalAboveColumnPrecisionIs400NotServerError`; MOB `pro_wave2_test` "boş form gönderilmez, pencere hatası görünür", "geçmiş başlangıç reddedilir", "varış penceresi sözleşme sınırları" | Otomatik, geçti |
| TC-OFR-02 | UC04 | Geçerlilik süresi | Varış sonu ve 72 saatten küçük olan | `validUntil = min(varış sonu, 72 saat)` | `OfferFlowTest#validUntilIsMinOfArrivalEndAnd72Hours`, `#pastDuePendingOfferDoesNotBlockANewOfferBeforeTheSchedulerRuns` | Otomatik, geçti |
| TC-OFR-03 | UC04 | Tek teklif kuralı | Aynı talebe ikinci teklif, kendi talebine teklif, kapalı talep, eşleşmeyen usta | Reddedilir (`ALREADY_OFFERED` vb.) | `OfferFlowTest#alreadyOfferedClosedRequestAndNonMatchingPro`, `#ownerCannotOfferOnOwnRequestEvenIfAPro`; MOB "ALREADY_OFFERED mesajı gösterilir, form korunur" | Otomatik, geçti |
| TC-OFR-04 | UC04 | Idempotency-Key | Aynı anahtarla iki istek; farklı usta aynı anahtar | Tek satır, aynı yanıt; anahtar usta başına | `OfferFlowTest#idempotencyKeyReplaysSameResponseWithSingleRow`, `#idempotencyKeyIsScopedToThePro`; API `wave2_test` "ProApi.createOffer Idempotency-Key başlığını gönderir" | Otomatik, geçti |
| TC-OFR-05 | UC04 | Hizmet bedeli ve net kazanç yalnız ustaya | Usta ve müşteri teklifi okur | Müşteride `serviceFee`/`netEarning` yok; ustada %10 | `OfferFlowTest#feeAndNetEarningAreOnlyVisibleToTheOfferingPro`; MOB "toplam, hizmet bedeli %10 ve net", API "müşteride serviceFee ve netEarning null" | Otomatik, geçti |
| TC-OFR-06 | UC04 | Teklifi geri çek | Bekleyen teklifi geri çek, yeniden ver | Yalnız kendi `PENDING` teklifi; yeni teklif verilebilir | `OfferFlowTest#withdrawIsOwnPendingOnlyAndAllowsNewOffer`, `#myOffersListFiltersByStatus`; MOB "durum filtresi sorguya gider; PENDING geri çekilir (onaylı)" | Otomatik, geçti |
| TC-OFR-07 | UC04 | Müşteriye bildirim | Teklif gelir | Müşteri bildirimi | `OfferFlowTest#offerReceivedNotificationGoesToTheCustomer` | Otomatik, geçti |
| TC-OFR-08 | UC04, NFR | Teklif hazırlama < 90 sn | Usta teklifi 90 saniyeden kısa sürede gönderir | Süre ≤ 90 sn | — | **Elle, bekliyor** (`USABILITY_STUDY.md` görev G6) |

## 5. UC05 — Karşılaştır, kabul et ve öde (Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-ACC-01 | UC05 | Teklif listesi ve karşılaştırma | Sırala, filtrele, 2–3 teklifi karşılaştır | Sıralama sunucuya gider; 4. teklif seçilmez | `OfferFlowTest#offerListSortsFiltersAndCountsDeclined`; MOB `customer_wave2_test` "sıralama ve filtre sorguya yansır, sonuç sayısı görünür", "karşılaştırma: 2-3 teklif seçilir, 4. seçilmez" | Otomatik, geçti |
| TC-ACC-02 | UC05 | Teklifi reddet | Gerekçe ile reddet | Teklif `DECLINED`, ustaya bildirim; gerekçe zorunlu | `OfferFlowTest#declineKeepsOrClosesTheRequestAndNotifiesThePro`; MOB "reddetme: gerekçe zorunlu, onay diyaloğu, gövde doğru" | Otomatik, geçti |
| TC-ACC-03 | UC05, NFR | Kabul onayı | Kabul et düğmesi | Önce kabul onay ekranı, sonra ödeme | MOB "kabul düğmesi kabul onayı rotasını açar, soru sor yok" | Otomatik, geçti |
| TC-ACC-04 | UC05 | Ödeme başlatma, tutar sunucudan | `POST /payments/3ds/init`, istemci tutar gönderir | Tutar tekliften alınır; callback adresi istemciden alınmaz | `payment/PaymentAppTest#initReturnsRefAndBankPageAndUsesServerSideAmount`; `PaymentFlowTest#amountComesFromServerEvenIfClientSendsOne`, `#callbackUrlFromClientIsIgnored` | Otomatik, geçti |
| TC-ACC-05 | UC05, hedef 5 | Başkasının teklifi, kapalı talep, süresi dolmuş teklif | Ödeme başlat | 404 / 409; hiçbir şey çekilmez | `PaymentAppTest#anotherCustomersOfferIs404`, `#expiredOfferIs409AndNothingIsCharged`, `#closedRequestAndNonPendingOfferAreIllegalState`; MOB `payment_wave3_test` "süresi dolmuş teklif kabul edilemez" | Otomatik, geçti |
| TC-ACC-06 | UC05 | Kart doğrulama | Hatalı Luhn, geçmiş tarih, boş alan | Yerelde yakalanır; sunucu 400 ve ağ geçidi çağrılmaz | `PaymentAppTest#invalidCardIs400WithFieldAndGatewayIsNotCalled`; `PaymentFlowTest#invalidCardNeverReachesGateway`; `payment/service/CardValidatorTest`; MOB `payment_wave3_test` "Luhn: test kartı geçer, bozuk numara geçmez", "boş form: alan hataları, istek gitmez", "INVALID_CARD field=number alanın altında, form korunur" | Otomatik, geçti |
| TC-ACC-07 | UC05 | Başarılı ödeme → kabul | 3DS başarılı callback | Emanet `LOCKED`; teklif `ACCEPTED`, diğerleri `SUPERSEDED`, talep `ASSIGNED`, iş `AWAITING_APPOINTMENT` (tek işlem) | `PaymentAppTest#successfulCallbackAcceptsOfferSupersedesOthersAndOpensJob`; `PaymentFlowTest#successfulPaymentLocksEscrow` | Otomatik, geçti |
| TC-ACC-08 | UC05, hedef 3, NFR güvenilirlik | Eşzamanlı kabul (yarış) | Aynı talebe iki müşteri ödemesi aynı anda | Biri işi açar; diğeri otomatik iade edilir | `PaymentAppTest#twoPaymentsRacingForTheSameRequestOneOpensTheJobTheOtherIsRefunded`; kısmi benzersiz indeks `ux_escrow_one_initialized_per_request` (`secondInitWhileFirstIsInitializedIsPaymentInProgress`) | Otomatik, geçti |
| TC-ACC-09 | UC05 | Banka adımında süre dolması | Teklif banka adımında süresi dolar | Ödeme otomatik iade | `PaymentAppTest#offerExpiredDuringBankStepIsRefundedAutomatically`, `#failedAutomaticRefundKeepsRecordLockedAndSweeperRetries` | Otomatik, geçti |
| TC-ACC-10 | UC05 | Banka reddi / ağ geçidi kesintisi | Reddedilen kart; Craftgate erişilemez | 402 `PAYMENT_DECLINED` ya da 502 `GATEWAY_ERROR`; kayıt `FAILED`, talep serbest | `PaymentAppTest#gatewayRejectionIs402WithRefAndFreesTheRequest`, `#gatewayOutageIs502GatewayErrorNotDeclinedAndFreesTheRequest`, `#failedBankResultCreatesNoJobAndLeavesOfferPending`; `PaymentFlowTest#bankFailureMarksFailed`, `#cancelledAtBankWithEmptyPaymentIdMarksFailed` | Otomatik, geçti |
| TC-ACC-11 | UC05, hedef 5 | Sahte / bozuk callback | Sahte başarı, hatalı imza, bilinmeyen konuşma, başka ödemenin numarası, yanlış tutar | Hiçbir şey değişmez; karar Craftgate sorgusuna göre | `PaymentFlowTest#forgedSuccessIsDecidedByCraftgateNotByParams`, `#forgedSuccessWithoutConversationIdChangesNothing`, `#invalidSignatureChangesNothing`, `#unknownConversationIsIgnored`, `#paymentIdFromAnotherPaymentIsRejected`, `#wrongAmountInCompleteResponseDoesNotLock`, `#forgedWaitingFailsWhenCraftgateRefusesToComplete` | Otomatik, geçti. Not: imza doğrulaması callback anahtarı boşsa atlanır |
| TC-ACC-12 | UC05 | Tekrarlı callback | Aynı callback iki kez | İkinci kez işlenmez | `PaymentAppTest#repeatedCallbackIsIdempotent`; `PaymentFlowTest#repeatedCallbackCompletesOnlyOnce`, `#repeatedCallbackCannotOverwriteRefundedPayment` | Otomatik, geçti |
| TC-ACC-13 | UC05 | Kart verisi sızmaz | Loglar, yanıtlar, hata gövdeleri | Kart numarası/CVC yok; yalnız son 4 hane | `PaymentFlowTest#cardDataIsNeverLoggedOrReturned`, `#malformedBodyDoesNotEchoCardData`, `#conversationIdIsNotExposedToBrowser`; API `wave3_test` "CardPaymentRequest.toString kart verisini yazmaz"; MOB "ekrandan çıkınca kart alanları temizlenir" | Otomatik, geçti |
| TC-ACC-14 | UC05 | Terk edilmiş / geciken ödeme | Callback gelmez; Craftgate yanıt vermez | Süpürücü gerçek duruma göre kapatır; belirsizse dokunmaz | `payment/PaymentSweeperTest` (16 test, ör. `#staleInitializedPaymentThatSucceededAtCraftgateOpensTheJob`, `#staleInitializedPaymentNeverCompletedAtCraftgateIsAbandonedAndTheCustomerCanRetry`, `#stalePaymentStillWaitingForTheBankResultIsNotAbandoned`, `#staleInitializedPaymentIsUntouchedWhenCraftgateDoesNotAnswerAndYoungOnesAreIgnored`) | Otomatik, geçti |
| TC-ACC-15 | UC05 | Süpürücü ile callback yarışı | Callback satırı tutarken süpürücü | Çifte işlem yok | `PaymentSweeperTest#sweeperSkipsARowThatARealCallbackHoldsAndNeverBlocksOrDoubleProcesses`, `#callbackArrivingWhileTheSweeperHoldsTheRowWaitsAndThenSeesTheSweepersResult` | Otomatik, geçti |
| TC-ACC-16 | UC05 | Yetim iade yeniden deneme | İade başarısız | Artan aralıkla en çok 8 deneme, sonra elle inceleme; çifte iade yok | `PaymentSweeperTest#backoffGrowsAndIsCapped`, `#afterEightFailedAttemptsTheRecordNeedsReviewAndTheSweeperStopsTrying`, `#alreadyRefundedPaymentOnlyFixesTheLedgerAndNeverSendsASecondRefund`, `#partiallyRefundedPaymentIsNeverSentAFullRefundAndGoesStraightToReview` | Otomatik, geçti |
| TC-ACC-17 | UC05 | Mobil 3DS WebView ve sonuç ekranı | Bitiş adresi yakalanır, yoklama | `INITIALIZED` iken yoklanır, `LOCKED` gelince iş ekranı; 30 sn sonra belirsiz metin; geri tuşu onay ister | MOB `payment_wave3_test` "bitiş adresi yakalanınca sonuç ekranına gidilir", "INITIALIZED iken yoklar, LOCKED gelince yığın değişir", "30 saniye sonra yoklama durur, belirsiz sonuç metni çıkar", "sistem geri tuşu da onay ister" | Otomatik, geçti |
| TC-ACC-18 | UC05 | Gerçek Craftgate sandbox: başarılı kart | `TEST_PLAN.md` S1 | `LOCKED`, iş açılır | — | **Elle, bekliyor** (16 Kasım'da proje sahibi bir koşu yaptığını bildirdi; depoda kanıt yok) |
| TC-ACC-19 | UC05 | Gerçek Craftgate sandbox: ret, terk, çift deneme | S2, S3, S9 | `FAILED`; terk için `THREEDS_ABANDONED`; çift için 409 | — | **Elle, bekliyor** |

## 6. UC06 — Randevu, UC08 — İş ilerlemesi (UC06 O, UC08 Y)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-JOB-01 | UC06 | Randevu önerisi, kabul, yeniden planlama | Müşteri aralık seçer, usta onaylar ya da karşı öneri verir | İş `SCHEDULED`; tek bekleyen öneri; kayıt altında | `job/JobFlowTest#appointmentProposalAcceptanceRescheduleAndCounterProposal`, `#proposalWindowRules`; MOB `jobs_wave3_test` "7 gün, sabit aralıklar, teklifteki aralık önceden seçili", "usta: yeni aralık önerir, iş ekranına döner", "usta: müşterinin önerisini kabul eder", "bugün: başlangıcı geçmiş aralık sunulmaz" | Otomatik, geçti |
| TC-JOB-02 | UC06 | Katılımcı görünürlüğü | İki taraf işi okur | Role özel alanlar; usta payı yalnız ustaya | `JobFlowTest#jobIsVisibleToBothParticipantsWithRoleSpecificFields`, `#listsFilterByRoleAndScope` | Otomatik, geçti |
| TC-JOB-03 | UC08, hedef 4 | Aşamalar sırayla | ulaştım → başladım → bitirdim; sıra dışı çağrı | 409 `ILLEGAL_STATE`; bitirince `auto_complete_at = +48 saat` | `JobFlowTest#stagesRunInOrderAndWrongStateIs409`, `#finishSetsAutoCompleteIn48HoursAndNotifiesCustomer` | Otomatik, geçti |
| TC-JOB-04 | UC08 | Eylem listesi durumdan gelir | Her durumda hangi düğme görünür | İstemci yalnız sunucunun `actions` listesinden düğme çizer | MOB `jobs_wave3_test` "SCHEDULED: adrese ulaştım ve iptal; başladım/bitirdim yok", "ARRIVED: başladım ve not; adrese ulaştım yok", "IN_PROGRESS: bitirdim ve not; iptal yok", "eylem listesi boş: eylem düğmesi yok" | Otomatik, geçti |
| TC-JOB-05 | UC08 | Not ve fotoğraf ekleme | Usta not/foto ekler | Zaman çizelgesinde görünür | MOB "JOB_PHOTO yüklenir, gövde gider, yığın değişir", "not ya da fotoğraf eklenir", "not en az 10 karakter; istek gitmez" | Otomatik, geçti |
| TC-JOB-06 | UC08 | Eşzamanlı güncelleme | Sürüm çakışması | 409 `ILLEGAL_STATE` | `common/Wave3CarryOverTest#optimisticLockConflictIs409IllegalStateGlobally` | Otomatik, geçti |
| TC-JOB-07 | UC08, hedef 4 | Haritada aç | Adres kartından harita | iOS Apple Maps, Android Google Maps; açılamazsa bilgi | MOB `jobs_wave3_test` "Haritada aç sistem harita bağlantısını açar", "harita açılamazsa bilgi verilir", "iOS Apple Maps, Android Google Maps" | Otomatik, geçti |

## 7. UC07 — Mesajlaşma (O)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-CHAT-01 | UC07 | Mesaj akışı ve imleç | Mesaj gönder/oku, `after` imleci | Artan sıra, kendi mesajı işaretli; eşzamanlı gönderimde imleç mesaj atlamaz | `chat/ChatTest#messagesAreCursoredAscendingAndMarkedMine`, `#concurrentSendsToTheSameJobCommitInIdOrderSoTheCursorNeverSkipsAMessage` | Otomatik, geçti |
| TC-CHAT-02 | UC07, hedef 5 | Katılımcı olmayan | Başka kullanıcı mesaj okur/yazar | 404 | `ChatTest#nonParticipantGets404EverywhereAndBodyIsValidated` | Otomatik, geçti |
| TC-CHAT-03 | UC07 | Fotoğraflı mesaj | CHAT amaçlı yükleme | Başka amaçlı medya reddedilir | `ChatTest#photoMessageNeedsOwnChatMedia`; MOB `chat_wave3_test` "fotoğraf CHAT olarak yüklenir, photoId ile gönderilir" | Otomatik, geçti |
| TC-CHAT-04 | UC07 | Kapanış sonrası salt okunur | İş kapandıktan 30 gün sonra | Yazma kapalı | `ChatTest#chatBecomesReadOnly30DaysAfterJobCloses`, `#cancelledJobChatClosesAfter30DaysToo`; MOB "CHAT eylemi yoksa giriş alanı kapalı ve açıklama var" | Otomatik, geçti |
| TC-CHAT-05 | UC07 | Okundu bilgisi ve rozet | Okuma imleci; sohbet listesi | Tekdüze, okunmamış sayısı | `ChatTest#readReceiptsAreMonotonicClampedAndVisibleToTheOtherSide`, `#conversationsAreSortedByLastActivityWithUnreadCounts`, `#newMessageNotificationIsSentOnlyWhenNoUnreadOneExistsForTheJob` | Otomatik, geçti |
| TC-CHAT-06 | UC07 | İstemci yoklama ve hata | 3 sn yoklama, arka planda durur, gönderilemeyen mesaj | Geçici baloncuk, tekrar dene | MOB `chat_wave3_test` "3 saniyede bir after= ile yoklar, yeni mesaj eklenir", "arka plana geçince yoklama durur, dönünce sürer", "hata: gönderilemedi, tekrar dene ile gider" | Otomatik, geçti |
| TC-CHAT-07 | UC07 | Gerçek zamanlı iletim (websocket) | — | RAD yalnızca "uygulama içi" der | — | Gerçekleştirilmedi (yoklama ile çözülü) |

## 8. UC09 — Tamamlama, UC10 — Puan, UC11 — İptal (UC09 Y, UC10 O, UC11 O)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-DONE-01 | UC09, hedef 4 | Müşteri onayı | `POST /jobs/{id}/confirm` | İş `COMPLETED`, emanet `RELEASED_TO_PRO`, defterde `PAYOUT` + `COMMISSION`, usta sayacı +1 | `JobFlowTest#confirmReleasesEscrowWritesLedgerAndCountsCompletedJob`; `PaymentFlowTest#releaseSplitsCommissionAtTenPercent`; MOB `jobs_wave3_test` "onay diyaloğu tutarı anlatır; onaylanınca puana geçilir" | Otomatik, geçti |
| TC-DONE-02 | UC09 | 48 saat otomatik tamamlama | `WORK_FINISHED` + 48 saat, şikayet yok | Tam bir kez `COMPLETED`; şikayet varsa dokunmaz | `JobFlowTest#schedulerCompletesFinishedJobAfter48HoursExactlyOnce`, `#schedulerDoesNotCompleteJobWithComplaint` | Otomatik, geçti |
| TC-DONE-03 | UC09, hedef 3 | Onay ya da şikayet zamanlayıcı ile yarışır | Üçü aynı anda | Emanet iki kez serbest bırakılmaz | `JobFlowTest#confirmOrComplaintRacingTheSchedulerNeverReleasesTwice` | Otomatik, geçti |
| TC-DONE-04 | UC09 | 24. saat hatırlatması | Bitişten 24 saat sonra | Bir kez bildirim | `JobFlowTest#reminderIsSentOnceInTheLast24Hours` | Otomatik, geçti |
| TC-DONE-05 | UC09 | Usta kazançları | Serbest, bekleyen, iade, hizmet bedeli toplamları | Doğru toplamlar | `JobFlowTest#earningsSumReleasedPendingRefundedAndFees`; MOB "toplamlar ve liste" | Otomatik, geçti |
| TC-DONE-06 | UC09 | Ağ geçidi çağrısı yapılmaz | Onay / otomatik tamamlama | Craftgate'e danışılmaz (defter kaydı) | — | **Boşluk** (bilinçli tasarım, spec'te "yayın öncesi sağlamlaştırma listesinde"; testi yok) |
| TC-REV-01 | UC10, hedef 4 | Erken puan engellenir | `COMPLETED` olmayan işte puan | 409; tamamlanmışta bir kez, ortalama güncellenir | `JobFlowTest#reviewOnlyWhenCompletedOnceAndUpdatesRating`; MOB "puan: yıldız zorunlu, istek gitmez", "daha önce puanlanmış iş: bilgi ekranı", "puan hatası: ILLEGAL_STATE açıklaması" | Otomatik, geçti |
| TC-REV-02 | UC10 | Herkese açık usta profili | Ziyaretçi usta profili ve yorumları | İletişim gizli; yalnız onaylı usta | `ProFlowTest#publicProProfileHidesContactAndOnlyShowsApproved`; MOB `audit_wave2_test` "usta değerlendirmeleri" | Otomatik, geçti |
| TC-CAN-01 | UC11 | Müşteri iptali | İş başlamadan iptal | İş ve talep `CANCELLED`, tam iade | `JobFlowTest#customerCancelRefundsInFullAndCancelsRequest`; MOB `jobs_wave3_test` "müşteri: gerekçe zorunlu; onay metni iade tutarını yazar", "vazgeçilirse istek gitmez" | Otomatik, geçti |
| TC-CAN-02 | UC11 | Usta iptali | İş başlamadan usta iptal | Talep yeniden `OPEN`, teklifler geri gelir, usta iptal sayacı +1, tam iade | `JobFlowTest#proCancelReopensRequestRestoresOffersAndCountsCancellation`; MOB "usta: usta gerekçeleri, iade ve talep yeniden açılır" | Otomatik, geçti |
| TC-CAN-03 | UC11, hedef 4 | İptal kuralları | `IN_PROGRESS` sonrası, şikayet açıkken | Reddedilir (409); şikayet yolu | `JobFlowTest#cancelIsRefusedFromInProgressOnward`, `#complaintDisputesJobAndEscrowAndBlocksCancelAndRefund`; MOB "iptal edilemiyorsa açıklama var" | Otomatik, geçti |
| TC-CAN-04 | UC11 | İade başarısızsa | Ağ geçidi iade hatası | 502, hiçbir şey değişmez | `JobFlowTest#refundFailureReturns502AndChangesNothing` | Otomatik, geçti |

## 9. UC12 — Usta başvurusu, UC13 — Şikayet hakemliği (UC12 Y, UC13 O)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-PRO-01 | UC12 | Usta başvurusu | Kimlik + ticaret belgesi, kategori, ilçe | Belgeler kendi medyası olmalı; bir dosya iki belge olamaz | `pro/ProFlowTest#applicationRequiresIdentityAndTradeCertAndOwnDocumentMedia`, `#applicationRejectsOneFileForTwoDocumentsAndPaddedShortName`; MOB `pro_wave2_test` "zorunlu belgeler yoksa gönderilmez; yüklenince gönderilir" | Otomatik, geçti |
| TC-PRO-02 | UC12 | Başvuru yaşam döngüsü | Bekleyen, belge iste, reddedildi, yeniden gönderim | Bekleyende yeniden gönderim yok; `NEEDS_DOCUMENTS` ve `REJECTED` yeniden gönderebilir | `ProFlowTest#applicationLifecyclePendingBlocksResubmitNeedsDocumentsAllowsIt`; MOB "NEEDS_DOCUMENTS: not, durum, dolu form ve yeniden gönderim", "REJECTED: /p/apply dolu açılır (yeniden başvur)", "PENDING_REVIEW: yeniden gönderim yok, müşteri moduna dön" | Otomatik, geçti |
| TC-PRO-03 | UC12, hedef 5 | Onaysız usta engellenir | Onaysız usta usta uç noktaları | 403/yönlendirme | `ProFlowTest#unapprovedProIsBlockedFromProEndpoints`; MOB `router_guards_test` "PENDING_REVIEW iken /p/feed -> /p/application" | Otomatik, geçti |
| TC-ADM-01 | UC12, hedef 5, 7 | Yönetici uç noktaları yetki | Anonim ve müşteri ile tüm `/admin/**` | 401 / 403 | `admin/AdminApplicationTest#everyAdminEndpointRejectsNonAdminsWith403AndAnonymousWith401` | Otomatik, geçti |
| TC-ADM-02 | UC12 | Başvuru onay / ret / belge iste | Onayla, not ile reddet, belge türü seç | Onay tüm belgeleri kabul eder, bildirim ve denetim kaydı; ret notlu; belge iste yalnız listelenenleri reddeder | `AdminApplicationTest#approveAcceptsEveryDocumentSetsApprovedAtNotifiesAndAuditsInOneStep`, `#rejectNeedsANoteSetsRejectedAndNotifiesWithTheNote`, `#requestDocumentsRejectsOnlyTheListedTypesAndNotifies`, `#decisionsOnUnknownOrNonPendingApplicationsFail`; ADM `applications_test` "onayla: onay diyaloğu, istek, yenileme", "reddet: not 10-1000 karakter doğrulanır", "eksik belge iste: not ve en az bir belge türü" | Otomatik, geçti |
| TC-ADM-03 | UC12 | Başvuru listesi ve ayrıntı | Süzgeç, arama, belge görüntüleme | İmzalı medya ile belgeler | `AdminApplicationTest#applicationListFiltersByStatusSearchesAndOrdersOldestFirst`, `#applicationDetailShowsContactDocumentsWithSignedMediaAndHistory`; ADM "kişi, işletme, belgeler ve geçmiş görünür", "görsel büyütülür, yeni sekmede açılır" | Otomatik, geçti |
| TC-CMP-01 | UC13 | Şikayet açma | Neden, ≥ 20 karakter, ≤ 5 kanıt | İş `DISPUTED`, emanet `DISPUTED`, şikayet `OPEN`, yöneticilere bildirim; iptal/iade kapanır | `JobFlowTest#complaintDisputesJobAndEscrowAndBlocksCancelAndRefund`, `#adminsAreNotifiedAndCanReadComplaint`; MOB `jobs_wave3_test` "doğrulama: neden, 20 karakter, onay kutusu", "en çok 5 kanıt fotoğrafı", "onay diyaloğu, COMPLAINT yüklemesi ve gövde; durum ekranı" | Otomatik, geçti |
| TC-CMP-02 | UC13 | Kuyruk ve ayrıntı | Yönetici kuyruğu görür | Gerçek tutarlar; zaman çizelgesi, sohbet, ödeme, kanıt (imzalı URL) | `admin/AdminComplaintTest#queueListsOpenAndInReviewOldestFirstWithRealAmounts`, `#detailCarriesJobTimelinePaymentChatPartiesAndEvidence`, `#evidenceIsOpenableByAdminThroughSignedUrls`, `#reviewMovesOpenToInReviewOnceAndIsAudited`; ADM `complaints_test` "şikayet, zaman çizelgesi, sohbet, ödeme ve taraflar" | Otomatik, geçti |
| TC-CMP-03 | UC13 | Karar: tam iade | Gerekçe ≥ 10 karakter | Craftgate iadesi, iş ve talep `CANCELLED`, defter `REFUND`, komisyon yok | `AdminComplaintTest#fullRefundRefundsThroughGatewayCancelsJobAndRequestAndWritesLedger` | Otomatik, geçti |
| TC-CMP-04 | UC13 | Karar: %50 / %50 | — | Yarı iade, `SPLIT_SETTLED`, komisyon yok | `AdminComplaintTest#split5050RefundsHalfThroughGatewayAndPaysTheProTheOtherHalf`; `PaymentFlowTest#disputeThenSplitRefundsHalfWithoutCommission` | Otomatik, geçti |
| TC-CMP-05 | UC13 | Karar: ustaya aktar | — | Şikayet `DISMISSED`, iş `COMPLETED`, %10 komisyon, ağ geçidi iadesi yok | `AdminComplaintTest#releaseToProDismissesComplaintCompletesJobKeepsTenPercentAndNeverTouchesGatewayRefunds` | Otomatik, geçti |
| TC-CMP-06 | UC13, güvenilirlik | Çifte karar ve eşzamanlılık | İkinci karar; iki paralel karar | İkinci 409; paralelde tek sonuç, para iki kez gitmez | `AdminComplaintTest#secondDecisionOnTheSameComplaintIs409AndMovesNoMoneyTwice`, `#twoParallelDecisionsProduceExactlyOneOutcome` | Otomatik, geçti |
| TC-CMP-07 | UC13, güvenilirlik | Ağ geçidi hatası ve zaman aşımı sonrası yeniden deneme | Craftgate hata; iade ulaşmış ama yanıt kayıp | 502, durum değişmez, yeniden denemede çift iade yok; kısmi/bekleyen/aşırı iade görülürse 409 | `AdminComplaintTest#gatewayFailureReturns502AndChangesNothingThenRetrySucceeds`, `#splitRetryAfterATimedOutButLandedRefundDoesNotRefundTwice`, `#fullRefundRetryAfterATimedOutButLandedRefundDoesNotRefundTwice`, `#fullRefundOnAPartlyRefundedPaymentRefundsOnlyTheRemainderOnce`, `#fullRefundStopsWhenCraftgateShowsAPendingAnUnreadableOrAnOverRefund`, `#releaseToProStopsWhenCraftgateShowsARefund`, `#splitStopsWhenCraftgateShowsAnUnexpectedRefundOrAPendingOne` | Otomatik, geçti |
| TC-CMP-08 | UC13 | Uyarı ve askıya alma | Kararla birlikte | Uyarı sayacı +1; askıda bekleyen teklifler `WITHDRAWN`, hesap aktif kalır | `AdminComplaintTest#warnProAddsOneWarningOnly`, `#suspendProSuspendsTheProfileWithdrawsPendingOffersAndKeepsTheAccountActive` | Otomatik, geçti |
| TC-CMP-09 | UC13 | Karar sonuç tutarları | Karar öncesi / sonrası | Karardan önce tutar yok; sonra gerçek tutarlar | `AdminComplaintTest#amountsAreNullUntilTheComplaintIsDecided`, `#decisionValidationAndUnknownComplaint`; ADM `complaints_test` "karar ve not zorunlu; istek gitmez", "kesinleştirme onayı geri alınamazlığı yazar; vazgeçilebilir", "tutarlar istemcide hesaplanmaz; sunucu toplamı yazılır", "GATEWAY_ERROR: diyalog açık kalır, hiçbir şey değişmedi" | Otomatik, geçti |
| TC-CMP-10 | UC13 | Hesap askı / aç | Kullanıcı listesi, askıya al, yeniden aç | Askıda oturumlar kapanır, bekleyen teklifler çekilir; kendini/admini askıya alamaz | `admin/AdminAccountPaymentTest#suspendEndsEverySessionWithdrawsPendingOffersAndLeavesActiveJobsAlone`, `#suspendRejectsAdminsItselfRepeatsUnknownAndShortNotes`, `#reactivateRestoresLoginAndOnlyWorksOnSuspendedAccounts`; ADM `accounts_payments_test` "kendi hesabında ve yönetici hesaplarında askıya alma kapalı", "askıya al: not zorunlu, istek, açık iş uyarısı" | Otomatik, geçti |
| TC-CMP-11 | UC13 | Ödeme listesi | Emanet satırları ve toplamlar | Defter toplamı ile uyumlu | `AdminAccountPaymentTest#ledgerListsEscrowRowsAndTotalsMatchThePayoutLedger`, `#emptyLedgerHasZeroTotals`; ADM "toplam kartları ve tablo" | Otomatik, geçti |
| TC-CMP-12 | UC13 | Gerçek Craftgate sandbox: iade senaryoları | `TEST_PLAN.md` S5–S8 | Craftgate panelinde iade/bölüşüm görünür | — | **Elle, bekliyor** |

## 10. UC14 ve RAD dışı eklentiler

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-PROMO-01 | UC14, hedef 7 | Tanıtım sitesi: duyarlı sayfa, indirme bağlantıları | Ziyaretçi sayfayı açar | — | — | **Gerçekleştirilmedi** |
| TC-NTF-01 | EK2 | Bildirim merkezi | Liste, okundu, tümünü okundu say, rozet | Yeni → eski; okunmamış sayısı `me`'de | `admin/NotificationCenterTest#listIsNewestFirstPagedAndUnreadCountTracksReadState`, `#markAllReadWorksWithAnEmptyJsonObject`, `#nobodyCanMarkSomeoneElsesNotificationRead`; MOB `notifications_wave4_test` "liste: okunmamış işareti, metinler, Tümünü okundu say", "99 üstü 99+ görünür" | Otomatik, geçti |
| TC-NTF-02 | EK2 | Bildirim sözleşmesi (19 tür) ve hedef rota | Her tür için parametre ve rota | Tür başına metin TR/EN; dış/bozuk hedef reddedilir | `NotificationCenterTest#requestAndOfferNotificationsCarryTheContractParamsAndTargets`, `#jobLifecycleNotificationsCarryTheContractParamsAndTargets`, `#cancellationNotificationsNameWhoCancelledAndTheRefund`, `#complaintNotificationsOpenedAndDecidedReachTheRightPeopleWithTheRightRoutes`; MOB "sözleşmedeki 19 tür tabloda", "dış, bozuk ya da bilinmeyen hedef reddedilir"; API `notifications_test` "sözleşmedeki 19 türün hepsi tanınır" | Otomatik, geçti |
| TC-NTF-03 | NFR (push) | Push bildirimi (FCM/APNs) | Cihaz belirteci kaydı; sunucu push gönderir | Belirteç kaydı var (`PUT /devices`); gönderim yok | `NotificationCenterTest#putDevicesUpsertsByTokenAndMovesItToTheNewOwner` (yalnız belirteç kaydı) | Kısmi: **push gönderimi gerçekleştirilmedi** |
| TC-DEV-01 | Test altyapısı | Tohum veri ve sıfırlama | `POST /dev/reset` | Katalog korunur, veri yeniden yüklenir; loopback dışından reddedilir | `dev/DevSeedTest#resetDeletesAllDataButKeepsCatalog`, `#resetIsRefusedFromNonLoopbackAddress`; `dev/DevProfileGuardTest`; `AdminDevSeedTest` | Otomatik, geçti |
| TC-CAT-01 | UC02 | Katalog | 8 kategori, 39 ilçe, soru şablonları | Kimlik gerekmez; doğru yazım ve sıra | `catalog/CatalogTest#eightCategoriesWithoutAuthentication`, `#thirtyNineDistrictsWithSides`, `#districtsAreCompleteCorrectlySpelledAndInTurkishAlphabeticalOrder` | Otomatik, geçti |

## 11. İşlevsel olmayan gereksinimler (NFR)

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-NFR-USB-01 | 3.3.1, hedef 6 | Yardımsız görev tamamlama ≥ %80, ≥ 5 katılımcı | `USABILITY_STUDY.md` oturumları | ≥ %80 | — | **Boşluk** (çalışma yapılmadı) |
| TC-NFR-USB-02 | 3.3.1 | İlk talep < 3 dk, teklif < 90 sn | Zamanlı görevler | Hedef sürelerin altında | — | **Boşluk** (ölçülmedi; TC-REQ-13, TC-OFR-08) |
| TC-NFR-USB-03 | 3.3.1 | TR/EN canlı geçiş | Dil anahtarı | Yeniden başlatma olmadan değişir ve saklanır; ARB anahtarları eşit; her hata kodunun iki dilde mesajı var | MOB `auth_screens_test` "TR -> EN değişince metin değişir ve kalıcı olur", "her ApiErrorCode için TR ve EN mesaj var"; `notifications_wave4_test` "TR ve EN ARB anahtarları aynı"; ADM `layout_l10n_test` "dil anahtarı arayüzü değiştirir ve tercihi saklar", "Türkçe metin lib/ içinde gömülü değil (l10n dışında)" | Otomatik, geçti |
| TC-NFR-USB-04 | 3.3.1 | Onay diyaloğu: kabul, iptal, tamamlama | Üç eylem | Onay istenir, vazgeçilirse istek gitmez | MOB `customer_wave2_test` "kabul düğmesi kabul onayı rotasını açar, soru sor yok"; `jobs_wave3_test` "vazgeçilirse istek gitmez", "onay diyaloğu tutarı anlatır; onaylanınca puana geçilir"; UI `components_test` "showConfirmDialog taşmaz; onay true, vazgeç false" | Otomatik, geçti |
| TC-NFR-USB-05 | 3.3.1 | Dokunma hedefi 48 dp | İkon düğmesi, düğme, alan | ≥ 48 dp (düğme ve alan 52) | UI `components_test` "AppIconButton en az 48x48 ve tooltip taşır", "AppButton yüksekliği en az 52", "AppTextField yüksekliği en az 52" | Kısmi (ortak bileşenler sınanıyor; her ekranın her öğesi taranmıyor) |
| TC-NFR-USB-06 | 3.3.1 | Kontrast WCAG 2.1 AA (≥ 4.5:1) | Metin token çiftleri, durum çipleri | ≥ 4.5:1 | UI `contrast_test` "metin token çiftleri AA (4.5:1) geçer", "her StatusChip tonunda etiket AA geçer" | Kısmi (token çiftleri; ekran üstü gerçek renkler elle) |
| TC-NFR-USB-07 | 3.3.1 | Küçük ekran ve büyük yazı | 320 px, 2x yazı | Taşma yok | UI `components_test` "AppButton 320px ve 2x yazıda taşmaz; üç varyant"; MOB `auth_screens_test` "karşılama 320 px ve 3x yazıda taşmaz"; `wave3_extras_test` "320 px ve 2x yazıda üç teklif de görünür"; ADM `layout_l10n_test` "en dar ekranda (360 px) tablolar taşmaz" | Otomatik, geçti |
| TC-NFR-REL-01 | 3.3.2 | API erişilebilirliği ≥ %99,5 | Çalışma saatlerinde sağlık ölçümü | ≥ %99,5 | — | **Boşluk** (sağlık uç noktası ve izleme yok, ölçülemez) |
| TC-NFR-REL-02 | 3.3.2, hedef 3 | İşlem atomikliği | Kabul = teklif/talep/iş tek işlemde; rakipler `SUPERSEDED` | Kısmi sonuç kalmaz | `PaymentAppTest#successfulCallbackAcceptsOfferSupersedesOthersAndOpensJob`, `#twoPaymentsRacingForTheSameRequestOneOpensTheJobTheOtherIsRefunded`; `OfferFlowTest#stateMachinesRejectIllegalTransitions` | Otomatik, geçti |
| TC-NFR-PERF-01 | 3.3.3 | Okuma gecikmesi < 500 ms (4G) | Gecikme betiği | p95 < 500 ms | — | **Boşluk** (ölçülmedi) |
| TC-NFR-PERF-02 | 3.3.3 | Fotoğraf ≤ 1,5 MB istemci sıkıştırma | Büyük fotoğraf seç | Sıkıştırılır ya da reddedilir; sunucu da sınırlar | MOB `customer_wave2_test` "sıkıştırma küçültürse küçük dosya yüklenir", "1,5 MB reddi yerelleştirilmiş hata gösterir"; `MediaTest#sizeLimitsAre1_5MbForPhotosAnd5MbForDocuments` | Otomatik, geçti |
| TC-NFR-SUP-01 | 3.3.4 | Ayrık istemci/sunucu mimarisi | İstemci yalnız REST ile konuşur | Sözleşme testleri | API `api_test`, `wave2_test`, `wave3_test`, `admin_test` ("uç noktalar, sorgular ve gövdeler") | Otomatik, geçti |
| TC-NFR-SUP-02 | 3.3.4 | Teknoloji yığını | Flutter + PostgreSQL | Şema Flyway ile, `ddl-auto=validate` | Her backend testi şemayı baştan kurar (`TestDatabaseConfig`) | Otomatik, geçti |
| TC-NFR-EXT-01 | 3.3.5 | Kamera/depolama izni | iOS izin metinleri, Android manifest | Kullanım açıklamaları var | — | **Kısmi / Boşluk** (`Info.plist` içinde `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` var; test yok; Android manifestte yalnız INTERNET izni test ediliyor) |
| TC-NFR-EXT-02 | 3.3.5 | Push bildirimi | — | — | — | **Gerçekleştirilmedi** (bkz. TC-NTF-03) |
| TC-NFR-EXT-03 | 3.3.5 | Paketleme: iOS | Bundle id, hedef, ikon, ATS | Debug dışı düz HTTP yok | MOB `platform_config_test` "bundle id her yapılandırmada com.bitadilat.app", "ATS istisnası yalnız Debug plist'inde", "dağıtım hedefi iOS 16.0, görünen ad BiTadilat", "ikon ve açılış görseli: boyutlar tutarlı, ikon alfasız, sRGB" | Otomatik, geçti |
| TC-NFR-EXT-04 | 3.3.5 | Paketleme: Android APK | Derle, kur, çalıştır | APK çalışır | MOB `platform_config_test` "applicationId ve namespace com.bitadilat.app" (yalnız yapılandırma) | **Boşluk** (APK hiç derlenmedi) |
| TC-NFR-EXT-05 | 3.3.5 | Docker ile paketli backend | `docker compose up` | Backend + PostgreSQL ayağa kalkar | — | **Gerçekleştirilmedi** (Dockerfile yok) |
| TC-NFR-LEG-01 | 3.3.6 KVKK | Rıza ve silme | Kayıtta onay kutusu; hesap silme; hukuki metin sayfası | Onay olmadan kayıt olmaz; silme anonimleştirir | `AuthFlowTest#validationErrorsNameTheField` (`kvkkAccepted`); `AccountTest#deletedAccountIsAnonymizedAndCannotLogIn`; MOB `auth_screens_test` "KVKK metni yer tutucu sayfayı açar" | Kısmi (saklama süresi ve dışa aktarım politikası yok; metin yer tutucu; hukuk incelemesi yok) |
| TC-NFR-LEG-02 | 3.3.6, hedef 5 | Adres gizliliği | Kabul öncesi usta, katılımcı olmayan | Yalnız ilçe/mahalle; tam adres yalnız iş tarafları, şifreli saklanır | `ProFlowTest#proRequestDetailIsMaskedAndLimitedToMatchingPros`; `RequestFlowTest#otherUsersGet404ForRequestAndNeverSeeFullAddress`; `AccountTest#addressIsEncryptedAtRestAndReadableThroughApi`, `#sameTextEncryptsDifferentlyEachTime`; `CommonRulesTest#aesGcmRoundTripBindsToAad`, `#badAddressKeyIsRejectedAtStartup` | Otomatik, geçti |
| TC-NFR-SEC-01 | Hedef 5 | Yüklenen dosya erişimi | İmzasız, süresi dolmuş, hatalı imza; başkasının dosyası | Reddedilir; imza yalnız erişim denetiminden sonra üretilir; tür sihirli baytla doğrulanır | `media/MediaTest#signedUrlServesBytesWithoutAuthAndRejectsBadOrExpiredSignatures`, `#signaturesAreOnlyIssuedAfterAccessChecks`, `#typeIsCheckedByMagicBytesNotByNameOrPurpose`, `#purposeAndFileAreRequiredAndAuthIsNeeded`; `Wave3CarryOverTest#uploadQuotaIs60Per24HoursThen429`, `#pdfIsServedAsAttachmentWhilePhotosStayInline` | Otomatik, geçti |
| TC-NFR-SEC-02 | Hedef 5 | Üretim yapılandırması | `prod` profili | Varsayılan gizli anahtar yok, OpenAPI kapalı, dev bean'leri yok, CORS kısıtlı | `common/ProdProfileConfigTest#prodAndBaseHaveNoDefaultSecretsAndNoOpenApi`, `#mediaSigningKeyAndDirHaveNoDefaultInBaseAndProd`, `#devOnlyBeansAreDevOnly`, `#prodCorsExemptsOnlyBankPathsAndKeepsApiRestricted`; `payment/PrototypeApiDisabledTest` | Otomatik, geçti |
| TC-NFR-SEC-03 | Hedef 5 | CORS | İzinli ve izinsiz kaynak | İzinsiz kaynak reddedilir | `AuthFlowTest#corsPreflightAllowsLocalOriginsOnly`, `#corsRejectsActualV1RequestFromUnlistedOrigin`; `PaymentFlowTest#bankCallbackFromBankOriginIsNotBlockedByCors` | Otomatik, geçti |
| TC-NFR-SEC-04 | Hedef 5 | Yönetim paneli oturumu | Sayfa yenileme, süresi dolan oturum | Token bellekte; süre dolunca girişe döner | ADM `auth_test` "sessionExpired sonrası girişe dönülür ve açıklama çıkar" | Otomatik, geçti |
| TC-NFR-SEC-05 | Hedef 5 | Elle sızma listesi | IDOR dolaşımı (başka kullanıcı kimlikleri), yetki yükseltme, aşırı büyük gövde, XSS (admin panelde kullanıcı metinleri) | Reddedilir / kaçırılır | — | **Elle, bekliyor** |

## 12. Uçtan uca (Simulator ve tarayıcı)

Bu senaryoların **otomatik koşusu depoda yoktur** (`integration_test` dizini yok). Önceki Simulator koşularının raporları kaybolmuştur; 25 Aralık'a kadar yeniden koşulup `TEST_REPORT` içine kanıtla (tarih, işlem, ekran görüntüsü) işlenecektir.

| ID | UC / gereksinim | Senaryo | Adımlar | Beklenen | Otomatik test referansı | Durum |
|---|---|---|---|---|---|---|
| TC-E2E-01 | UC01, UC02, UC04, UC05, UC06, UC08, UC09, UC10 | Mutlu yol, tek koşu | Müşteri kaydı → talep → usta teklifi → müşteri kabul + sandbox ödeme → randevu → ulaştım/başladım/bitirdim → onay → puan | Her adım hatasız; emanet `RELEASED_TO_PRO` | Parçaları otomatik testlerle kapsanıyor (bkz. yukarıdaki bölümler); bütünün otomatik koşusu yok | Elle, bekliyor |
| TC-E2E-02 | UC11 | İptal yolu | Ödeme sonrası müşteri iptali | Tam iade, talep iptal | — | Elle, bekliyor |
| TC-E2E-03 | UC13 | Şikayet yolu | Bitirildi → şikayet → Flutter Web panelde karar (3 sonuç) | Her sonuç doğru para ve durum | — | Elle, bekliyor |
| TC-E2E-04 | UC12 | Usta başvurusu | Başvur → panelde onayla → usta akışı | Akış açılır | — | Elle, bekliyor |
| TC-E2E-05 | UC09 | 48 saat otomatik | Zamanlayıcı aralığını kısaltıp bekle | Otomatik tamamlama | Birim düzeyinde `JobFlowTest#schedulerCompletesFinishedJobAfter48HoursExactlyOnce` | Kısmi |
| TC-E2E-06 | NFR | TR/EN, 2x yazı, karanlık/aydınlık | Simulator ayarları | Taşma ve okunabilirlik | Widget düzeyinde testler | Elle, bekliyor |

---

## 13. İzlenebilirlik özeti

| UC / hedef | Otomatik test kapsamı | Not |
|---|---|---|
| UC01 | Yüksek (20 senaryo) | Mobil hesap silme ekranı testi yok |
| UC02 | Yüksek | İlk talep süresi ölçülmedi |
| UC03 | Yüksek (API); UI nedenleri kısmi | |
| UC04 | Yüksek | 90 sn süre ölçülmedi |
| UC05 | Çok yüksek (ağ geçidi sahte) | Gerçek sandbox elle |
| UC06, UC08 | Yüksek | |
| UC07 | Yüksek | Websocket yok |
| UC09 | Yüksek | Craftgate'e danışmadan aktarım testlenmiyor |
| UC10, UC11 | Yüksek | |
| UC12, UC13 | Yüksek | Gerçek sandbox iade elle |
| UC14 | Yok | Gerçekleştirilmedi |
| Hedef 5 (gizlilik, erişim) | Yüksek | Elle sızma listesi bekliyor |
| Hedef 6 (kullanılabilirlik) | Yok | Çalışma yapılmadı |
| Hedef 7 (tanıtım sitesi) | Yok | Yönetim paneli tarafı otomatik testli |

**Kapatılacak başlıca boşluklar (öncelik sırasıyla):** kullanılabilirlik çalışması (hedef 6), sandbox elle koşuları (S1–S9), Simulator E2E kayıtları, mobil hesap silme testi, eşleşme nedenleri ekran testi, kamera izin dizeleri testi, sağlık uç noktası + gecikme betiği (NFR), Android/Docker kararı.
