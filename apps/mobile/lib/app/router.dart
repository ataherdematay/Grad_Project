import 'package:bitadilat_api/bitadilat_api.dart' show PartyRole;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/data.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/session.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/common/misc_screens.dart';
import '../features/customer/addresses.dart';
import '../features/customer/offers_screens.dart';
import '../features/customer/pro_profile_screens.dart';
import '../features/customer/requests_screens.dart';
import '../features/customer/wizard_screen.dart';
import '../features/jobs/customer_jobs.dart';
import '../features/jobs/pro_jobs.dart';
import '../features/payment/payment_screens.dart';
import '../features/pro/pro_apply.dart';
import '../features/pro/pro_feed.dart';
import '../features/pro/pro_profile.dart';
import '../features/pro/pro_requests.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/tab_shell.dart';
import '../l10n/app_localizations.dart';
import 'guards.dart';

/// Tüm rotalar `MaterialPage` ile açılır: sayfa geçişi temadan gelir ve iOS'ta
/// soldan kaydırarak geri (Cupertino geçişi) çalışır. go_router'ın varsayılan
/// özel geçiş sayfası bu hareketi vermez.
GoRoute appRoute({
  required String path,
  required Widget Function(BuildContext context, GoRouterState state) builder,
}) => GoRoute(
  path: path,
  pageBuilder: (context, state) => MaterialPage<void>(
    key: state.pageKey,
    name: state.name ?? state.path,
    arguments: state.extra,
    child: builder(context, state),
  ),
);

/// Testlerde belirli bir rotadan başlamak için ezilir.
final initialLocationProvider = Provider<String>((ref) => '/');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<SessionState>(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    redirect: (context, state) =>
        guardRedirect(ref.read(sessionProvider), state.uri),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      appRoute(path: '/', builder: (_, _) => const SplashScreen()),
      appRoute(
        path: '/welcome',
        builder: (_, state) =>
            WelcomeScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      appRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      appRoute(
        path: '/register',
        builder: (_, state) =>
            RegisterScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      appRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      appRoute(
        path: '/reset-password',
        builder: (_, state) =>
            ResetPasswordScreen(initialEmail: state.extra as String?),
      ),
      appRoute(
        path: '/legal/:doc',
        builder: (_, state) => LegalScreen(doc: state.pathParameters['doc']!),
      ),
      appRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      appRoute(
        path: '/notifications',
        builder: (context, _) => PlaceholderScreen(
          title: AppLocalizations.of(context).notificationsTitle,
        ),
      ),
      appRoute(
        path: '/jobs/:id/chat',
        builder: (_, state) => ChatScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(path: '/p/apply', builder: (_, _) => const ProApplyScreen()),
      appRoute(
        path: '/p/application',
        builder: (_, _) => const ProApplicationScreen(),
      ),
      // Müşteri: kabuğun üstünde açılan tam ekran rotalar.
      appRoute(
        path: '/c/addresses',
        builder: (_, _) => const AddressesScreen(),
      ),
      appRoute(
        path: '/c/requests/new',
        builder: (_, _) => const RequestWizardScreen(),
      ),
      appRoute(
        path: '/c/requests/:id',
        builder: (_, state) =>
            RequestDetailScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/requests/:id/edit',
        builder: (_, state) =>
            RequestWizardScreen(editId: state.pathParameters['id']),
      ),
      appRoute(
        path: '/c/requests/:id/cancel',
        builder: (_, state) =>
            CancelRequestScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/requests/:id/published',
        builder: (_, state) => PublishedScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/requests/:id/offers',
        builder: (_, state) =>
            RequestOffersScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/requests/:id/compare',
        builder: (_, state) => CompareOffersScreen(
          id: state.pathParameters['id']!,
          ids: (state.uri.queryParameters['ids'] ?? '')
              .split(',')
              .where((e) => e.isNotEmpty)
              .toList(),
        ),
      ),
      appRoute(
        path: '/c/offers/:id',
        builder: (_, state) =>
            OfferDetailScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/offers/:id/decline',
        builder: (_, state) =>
            DeclineOfferScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/offers/:id/accept',
        builder: (_, state) =>
            AcceptOfferScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/offers/:id/pay',
        builder: (_, state) => PayScreen(offerId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/payments/:ref/3ds',
        builder: (_, state) => ThreeDsScreen(
          paymentRef: state.pathParameters['ref']!,
          html: state.extra as String?,
        ),
      ),
      appRoute(
        path: '/c/payments/:ref/result',
        builder: (_, state) =>
            PaymentResultScreen(paymentRef: state.pathParameters['ref']!),
      ),
      appRoute(
        path: '/c/jobs/:id',
        builder: (_, state) =>
            CustomerJobScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/jobs/:id/appointment',
        builder: (_, state) =>
            AppointmentScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/jobs/:id/cancel',
        builder: (_, state) =>
            CancelJobScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/jobs/:id/complete',
        builder: (_, state) =>
            CompleteJobScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/jobs/:id/review',
        builder: (_, state) => ReviewScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/jobs/:id/complaint',
        builder: (_, state) =>
            ComplaintScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/complaints/:id',
        builder: (_, state) =>
            ComplaintStatusScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/pros/:id',
        builder: (_, state) =>
            ProPublicProfileScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/c/pros/:id/reviews',
        builder: (_, state) =>
            ProReviewsScreen(id: state.pathParameters['id']!),
      ),
      // Usta
      appRoute(
        path: '/p/requests/:id',
        builder: (_, state) =>
            ProRequestScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/requests/:id/offer',
        builder: (_, state) =>
            OfferFormScreen(requestId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/jobs/:id',
        builder: (_, state) => ProJobScreen(id: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/jobs/:id/appointment',
        builder: (_, state) =>
            AppointmentScreen(jobId: state.pathParameters['id']!, pro: true),
      ),
      appRoute(
        path: '/p/jobs/:id/cancel',
        builder: (_, state) =>
            CancelJobScreen(jobId: state.pathParameters['id']!, pro: true),
      ),
      appRoute(
        path: '/p/jobs/:id/cancelled',
        builder: (_, state) =>
            ProCancelledScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/jobs/:id/finish',
        builder: (_, state) =>
            ProFinishScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/jobs/:id/finished',
        builder: (_, state) =>
            ProFinishedScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(
        path: '/p/jobs/:id/note',
        builder: (_, state) =>
            ProNoteScreen(jobId: state.pathParameters['id']!),
      ),
      appRoute(path: '/p/earnings', builder: (_, _) => const EarningsScreen()),
      appRoute(path: '/p/offers', builder: (_, _) => const ProOffersScreen()),
      appRoute(
        path: '/p/offers/:id/sent',
        builder: (_, state) => OfferSentScreen(id: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final l = AppLocalizations.of(context);
          return TabShell(
            shell: shell,
            tabs: [
              TabSpec(
                Icons.home_outlined,
                Icons.home,
                l.tabHome,
                refresh: (ref) => ref
                  ..invalidate(requestsProvider)
                  ..invalidate(jobsProvider),
              ),
              TabSpec(
                Icons.assignment_outlined,
                Icons.assignment,
                l.tabRequests,
                refresh: (ref) => ref
                  ..invalidate(requestsProvider)
                  ..invalidate(jobsProvider),
              ),
              TabSpec(
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                l.tabMessages,
                refresh: (ref) => ref.invalidate(conversationsProvider),
              ),
              TabSpec(Icons.person_outline, Icons.person, l.tabProfile),
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/c/home',
                builder: (_, _) => const CustomerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/c/requests',
                builder: (_, _) => const RequestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/c/messages',
                builder: (_, _) =>
                    const ConversationsScreen(role: PartyRole.customer),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/c/profile',
                builder: (_, _) => const ProfileTab(proMode: false),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final l = AppLocalizations.of(context);
          return TabShell(
            shell: shell,
            tabs: [
              TabSpec(
                Icons.search_outlined,
                Icons.search,
                l.tabFeed,
                refresh: (ref) => ref
                  ..invalidate(feedProvider)
                  ..invalidate(proOffersProvider),
              ),
              TabSpec(
                Icons.handyman_outlined,
                Icons.handyman,
                l.tabJobs,
                refresh: (ref) => ref.invalidate(jobsProvider),
              ),
              TabSpec(
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                l.tabMessages,
                refresh: (ref) => ref.invalidate(conversationsProvider),
              ),
              TabSpec(
                Icons.person_outline,
                Icons.person,
                l.tabProfile,
                refresh: (ref) => ref
                  ..invalidate(proProfileProvider)
                  ..invalidate(earningsProvider),
              ),
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/p/feed',
                builder: (_, _) => const ProFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/p/jobs',
                builder: (_, _) => const ProJobsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/p/messages',
                builder: (_, _) =>
                    const ConversationsScreen(role: PartyRole.pro),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              appRoute(
                path: '/p/profile',
                builder: (_, _) => const ProProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
