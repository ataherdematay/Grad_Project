import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/accounts_screen.dart';
import '../features/applications/application_detail_screen.dart';
import '../features/applications/applications_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/session.dart';
import '../features/complaints/complaint_detail_screen.dart';
import '../features/complaints/complaints_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/shell/admin_shell.dart';

/// Testlerde başlangıç rotasını değiştirmek için.
final initialLocationProvider = Provider<String>((ref) => '/');

abstract final class Routes {
  static const login = '/login';
  static const home = '/';
  static const applications = '/applications';
  static const complaints = '/complaints';
  static const accounts = '/accounts';
  static const payments = '/payments';

  static String application(String proId) => '/applications/$proId';
  static String complaint(String id) => '/complaints/$id';
  static String decision(String id) => '/complaints/$id/decision';
}

Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(sessionProvider).isSignedIn;
      final atLogin = state.uri.path == Routes.login;
      if (!signedIn) return atLogin ? null : Routes.login;
      if (atLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => _page(state, const LoginScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) =>
                _page(state, const DashboardScreen()),
          ),
          GoRoute(
            path: Routes.applications,
            pageBuilder: (context, state) =>
                _page(state, const ApplicationsScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => _page(
                  state,
                  ApplicationDetailScreen(proId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.complaints,
            pageBuilder: (context, state) =>
                _page(state, const ComplaintsScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => _page(
                  state,
                  ComplaintDetailScreen(
                    complaintId: state.pathParameters['id']!,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'decision',
                    pageBuilder: (context, state) => _page(
                      state,
                      ComplaintDetailScreen(
                        complaintId: state.pathParameters['id']!,
                        openDecision: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.accounts,
            pageBuilder: (context, state) =>
                _page(state, const AccountsScreen()),
          ),
          GoRoute(
            path: Routes.payments,
            pageBuilder: (context, state) =>
                _page(state, const PaymentsScreen()),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
