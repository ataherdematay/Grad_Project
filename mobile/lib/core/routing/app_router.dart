import 'package:go_router/go_router.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/phone_auth_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/customer_home/customer_shell_screen.dart';
import '../../features/wizard/wizard_flow_screen.dart';
import '../../features/offers/offers_list_screen.dart';
import '../../features/offers/escrow_checkout_screen.dart';
import '../../features/offers/payment_success_screen.dart';
import '../../features/tracking/job_tracking_screen.dart';
import '../../features/tracking/chat_screen.dart';
import '../../features/tracking/escrow_completion_screen.dart';
import '../../features/pro_home/pro_shell_screen.dart';
import '../../features/pro_job_detail/pro_job_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/phone-auth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) => const OtpVerificationScreen(),
    ),

    // Customer Routes
    GoRoute(
      path: '/customer/home',
      builder: (context, state) => const CustomerShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/customer/my-jobs',
      builder: (context, state) => const CustomerShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/customer/profile',
      builder: (context, state) => const CustomerShellScreen(initialTab: 2),
    ),
    GoRoute(
      path: '/customer/wizard',
      builder: (context, state) {
        final cat = state.uri.queryParameters['category'];
        return WizardFlowScreen(initialCategoryId: cat);
      },
    ),
    GoRoute(
      path: '/customer/offers/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return OffersListScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/customer/checkout/:jobId/:offerId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        final offerId = state.pathParameters['offerId'] ?? 'off-01';
        return EscrowCheckoutScreen(jobId: jobId, offerId: offerId);
      },
    ),
    GoRoute(
      path: '/customer/payment-success/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return PaymentSuccessScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/customer/active-job/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return JobTrackingScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/customer/chat/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return ChatScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/customer/complete/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return EscrowCompletionScreen(jobId: jobId);
      },
    ),

    // Pro (Usta) Routes
    GoRoute(
      path: '/pro/home',
      builder: (context, state) => const ProShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/pro/jobs/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? 'job-84920';
        return ProJobDetailScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/pro/active-job',
      builder: (context, state) => const ProShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/pro/profile',
      builder: (context, state) => const ProShellScreen(initialTab: 2),
    ),
  ],
);
