import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/main_wrapper.dart';
import 'package:mobile/features/fleet/fleet_screen.dart';
import 'package:mobile/features/staff/staff_screen.dart';
import 'package:mobile/features/map/map_screen.dart';
import 'package:mobile/features/analytics/analytics_screen.dart';
import 'package:mobile/features/menu/menu_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/api_setup_screen.dart';
import 'package:mobile/features/auth/yandex_webview_login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login', // Change to '/login' later remind me
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/api-setup',
        builder: (context, state) => const ApiSetupScreen(),
      ),
      GoRoute(
        path: '/yandex-login',
        builder: (context, state) => const YandexWebViewLoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Ветка Автопарк
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fleet',
                builder: (context, state) => const FleetScreen(),
              ),
            ],
          ),
          // Ветка Персонал
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff',
                builder: (context, state) => const StaffScreen(),
              ),
            ],
          ),
          // Ветка Карта
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // Ветка Аналитика
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          // Ветка Меню
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
