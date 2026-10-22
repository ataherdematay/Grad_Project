import 'package:go_router/go_router.dart';
import '../../features/screens/s01_welcome_role_screen.dart';
import '../../features/screens/s02_phone_auth_screen.dart';
import '../../features/screens/s03_otp_verification_screen.dart';
import '../../features/screens/s04_customer_home_screen.dart';
import '../../features/screens/s05_wizard_category_screen.dart';
import '../../features/screens/s06_wizard_location_screen.dart';
import '../../features/screens/s07_wizard_photos_screen.dart';
import '../../features/screens/s08_wizard_review_screen.dart';
import '../../features/screens/s09_wizard_published_screen.dart';
import '../../features/screens/s10_my_requests_screen.dart';
import '../../features/screens/s11_offers_list_screen.dart';
import '../../features/screens/s12_offer_detail_screen.dart';
import '../../features/screens/s13_offers_compare_matrix_screen.dart';
import '../../features/screens/s14_pro_profile_screen.dart';
import '../../features/screens/s15_escrow_checkout_screen.dart';
import '../../features/screens/s16_appointment_time_screen.dart';
import '../../features/screens/s17_appointment_sent_screen.dart';
import '../../features/screens/s18_job_workspace_screen.dart';
import '../../features/screens/s19_in_app_chat_screen.dart';
import '../../features/screens/s20_live_tracking_screen.dart';
import '../../features/screens/s21_reschedule_cancel_screen.dart';
import '../../features/screens/s22_completion_pin_screen.dart';
import '../../features/screens/s23_rating_review_screen.dart';
import '../../features/screens/s24_dispute_report_screen.dart';
import '../../features/screens/s25_dispute_tracking_screen.dart';
import '../../features/screens/s26_customer_profile_screen.dart';
import '../../features/screens/s27_pro_onboarding_docs_screen.dart';
import '../../features/screens/s28_pro_job_feed_screen.dart';
import '../../features/screens/s29_pro_bid_creation_screen.dart';
import '../../features/screens/s30_pro_bid_sent_screen.dart';
import '../../features/screens/s31_pro_schedule_profile_screen.dart';
import '../../features/screens/s32_pro_execution_work_screen.dart';
import '../../features/screens/s33_pro_delivery_done_screen.dart';

/// BiTadilat Authoritative Router
/// Covers all 33 Mobile Screens mapped 1:1 to Steps 01 through 33
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Root default
    GoRoute(
      path: '/',
      builder: (context, state) => const S01WelcomeRoleScreen(),
    ),

    // Flow 1: Müşteri Giriş & Onboarding (Steps 01-03)
    GoRoute(
      path: '/step/1',
      builder: (context, state) => const S01WelcomeRoleScreen(),
    ),
    GoRoute(
      path: '/step/2',
      builder: (context, state) => const S02PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/step/3',
      builder: (context, state) => const S03OtpVerificationScreen(),
    ),

    // Flow 2: Müşteri Talep Sihirbazı (Steps 04-10)
    GoRoute(
      path: '/step/4',
      builder: (context, state) => const S04CustomerHomeScreen(),
    ),
    GoRoute(
      path: '/step/5',
      builder: (context, state) => const S05WizardCategoryScreen(),
    ),
    GoRoute(
      path: '/step/6',
      builder: (context, state) => const S06WizardLocationScreen(),
    ),
    GoRoute(
      path: '/step/7',
      builder: (context, state) => const S07WizardPhotosScreen(),
    ),
    GoRoute(
      path: '/step/8',
      builder: (context, state) => const S08WizardReviewScreen(),
    ),
    GoRoute(
      path: '/step/9',
      builder: (context, state) => const S09WizardPublishedScreen(),
    ),
    GoRoute(
      path: '/step/10',
      builder: (context, state) => const S10MyRequestsScreen(),
    ),

    // Flow 3: Teklif Karşılaştırma & Randevu (Steps 11-17)
    GoRoute(
      path: '/step/11',
      builder: (context, state) => const S11OffersListScreen(),
    ),
    GoRoute(
      path: '/step/12',
      builder: (context, state) => const S12OfferDetailScreen(),
    ),
    GoRoute(
      path: '/step/13',
      builder: (context, state) => const S13OffersCompareMatrixScreen(),
    ),
    GoRoute(
      path: '/step/14',
      builder: (context, state) => const S14ProProfileScreen(),
    ),
    GoRoute(
      path: '/step/15',
      builder: (context, state) => const S15EscrowCheckoutScreen(),
    ),
    GoRoute(
      path: '/step/16',
      builder: (context, state) => const S16AppointmentTimeScreen(),
    ),
    GoRoute(
      path: '/step/17',
      builder: (context, state) => const S17AppointmentSentScreen(),
    ),

    // Flow 4: Aktif İş, Mesajlaşma & Teslim (Steps 18-25)
    GoRoute(
      path: '/step/18',
      builder: (context, state) => const S18JobWorkspaceScreen(),
    ),
    GoRoute(
      path: '/step/19',
      builder: (context, state) => const S19InAppChatScreen(),
    ),
    GoRoute(
      path: '/step/20',
      builder: (context, state) => const S20LiveTrackingScreen(),
    ),
    GoRoute(
      path: '/step/21',
      builder: (context, state) => const S21RescheduleCancelScreen(),
    ),
    GoRoute(
      path: '/step/22',
      builder: (context, state) => const S22CompletionPinScreen(),
    ),
    GoRoute(
      path: '/step/23',
      builder: (context, state) => const S23RatingReviewScreen(),
    ),
    GoRoute(
      path: '/step/24',
      builder: (context, state) => const S24DisputeReportScreen(),
    ),
    GoRoute(
      path: '/step/25',
      builder: (context, state) => const S25DisputeTrackingScreen(),
    ),

    // Flow 5: Müşteri Profil & Ayarlar (Step 26)
    GoRoute(
      path: '/step/26',
      builder: (context, state) => const S26CustomerProfileScreen(),
    ),

    // Flow 6: Hizmet Profesyoneli (Usta) (Steps 27-33)
    GoRoute(
      path: '/step/27',
      builder: (context, state) => const S27ProOnboardingDocsScreen(),
    ),
    GoRoute(
      path: '/step/28',
      builder: (context, state) => const S28ProJobFeedScreen(),
    ),
    GoRoute(
      path: '/step/29',
      builder: (context, state) => const S29ProBidCreationScreen(),
    ),
    GoRoute(
      path: '/step/30',
      builder: (context, state) => const S30ProBidSentScreen(),
    ),
    GoRoute(
      path: '/step/31',
      builder: (context, state) => const S31ProScheduleProfileScreen(),
    ),
    GoRoute(
      path: '/step/32',
      builder: (context, state) => const S32ProExecutionWorkScreen(),
    ),
    GoRoute(
      path: '/step/33',
      builder: (context, state) => const S33ProDeliveryDoneScreen(),
    ),

    // Named convenience aliases
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const S01WelcomeRoleScreen(),
    ),
    GoRoute(
      path: '/phone-auth',
      builder: (context, state) => const S02PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) => const S03OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/customer/home',
      builder: (context, state) => const S04CustomerHomeScreen(),
    ),
    GoRoute(
      path: '/customer/my-jobs',
      builder: (context, state) => const S10MyRequestsScreen(),
    ),
    GoRoute(
      path: '/customer/profile',
      builder: (context, state) => const S26CustomerProfileScreen(),
    ),
    GoRoute(
      path: '/pro/home',
      builder: (context, state) => const S28ProJobFeedScreen(),
    ),
    GoRoute(
      path: '/pro/profile',
      builder: (context, state) => const S31ProScheduleProfileScreen(),
    ),
  ],
);
