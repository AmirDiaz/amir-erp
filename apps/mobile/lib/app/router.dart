// Amir ERP — go_router configuration.
// Author: Amir Saoudi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../features/about/about_page.dart';
import '../features/accounting/accounting_page.dart';
import '../features/auth/login_page.dart';
import '../features/crm/crm_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/dashboard/shell_page.dart';
import '../features/hr/hr_page.dart';
import '../features/inventory/inventory_page.dart';
import '../features/pos/pos_page.dart';
import '../features/sales/sales_page.dart';
import '../features/settings/settings_page.dart';
import '../features/splash/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (ctx, st) {
      if (auth.status == AuthStatus.unknown) return null;
      final loggedIn = auth.status == AuthStatus.authenticated;
      final loggingIn = st.matchedLocation == '/login';
      if (!loggedIn && !loggingIn && st.matchedLocation != '/') return '/login';
      if (loggedIn && (loggingIn || st.matchedLocation == '/')) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (ctx, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/accounting', builder: (_, __) => const AccountingPage()),
          GoRoute(path: '/sales', builder: (_, __) => const SalesPage()),
          GoRoute(path: '/crm', builder: (_, __) => const CrmPage()),
          GoRoute(path: '/inventory', builder: (_, __) => const InventoryPage()),
          GoRoute(path: '/pos', builder: (_, __) => const PosPage()),
          GoRoute(path: '/hr', builder: (_, __) => const HrPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
        ],
      ),
    ],
  );
});
