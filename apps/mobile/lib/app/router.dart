import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/session.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/common/misc_screens.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/tab_shell.dart';
import '../l10n/app_localizations.dart';
import 'guards.dart';

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
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (_, state) =>
            WelcomeScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) =>
            RegisterScreen(next: safeNext(state.uri.queryParameters['next'])),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) =>
            ResetPasswordScreen(initialEmail: state.extra as String?),
      ),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, state) => LegalScreen(doc: state.pathParameters['doc']!),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, _) => PlaceholderScreen(
          title: AppLocalizations.of(context).notificationsTitle,
        ),
      ),
      GoRoute(
        path: '/jobs/:id/chat',
        builder: (context, _) =>
            PlaceholderScreen(title: AppLocalizations.of(context).chatTitle),
      ),
      GoRoute(
        path: '/p/apply',
        builder: (_, _) => const ProApplicationPlaceholder(apply: true),
      ),
      GoRoute(
        path: '/p/application',
        builder: (_, _) => const ProApplicationPlaceholder(apply: false),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final l = AppLocalizations.of(context);
          return TabShell(
            shell: shell,
            tabs: [
              TabSpec(Icons.home_outlined, Icons.home, l.tabHome),
              TabSpec(
                Icons.assignment_outlined,
                Icons.assignment,
                l.tabRequests,
              ),
              TabSpec(
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                l.tabMessages,
              ),
              TabSpec(Icons.person_outline, Icons.person, l.tabProfile),
            ],
          );
        },
        branches: [
          _tab(
            '/c/home',
            (l) => l.tabHome,
          ),
          _tab('/c/requests', (l) => l.tabRequests),
          _tab('/c/messages', (l) => l.tabMessages),
          StatefulShellBranch(
            routes: [
              GoRoute(
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
              TabSpec(Icons.search_outlined, Icons.search, l.tabFeed),
              TabSpec(Icons.handyman_outlined, Icons.handyman, l.tabJobs),
              TabSpec(
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                l.tabMessages,
              ),
              TabSpec(Icons.person_outline, Icons.person, l.tabProfile),
            ],
          );
        },
        branches: [
          _tab('/p/feed', (l) => l.tabFeed),
          _tab('/p/jobs', (l) => l.tabJobs),
          _tab('/p/messages', (l) => l.tabMessages),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/p/profile',
                builder: (_, _) => const ProfileTab(proMode: true),
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

StatefulShellBranch _tab(String path, String Function(AppLocalizations) title) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, _) =>
            TabRootPlaceholder(title: title(AppLocalizations.of(context))),
      ),
    ],
  );
}
