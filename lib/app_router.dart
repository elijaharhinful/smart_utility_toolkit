import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/shell/app_shell.dart';
import 'features/home/dashboard_screen.dart';
import 'features/home/splash_screen.dart';
import 'features/converter/converter_list_screen.dart';
import 'features/unit_converter/unit_converter_screen.dart';
import 'features/currency/currency_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/settings/settings_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final isFirst = state.uri.queryParameters['first'] == 'true';
            return DashboardScreen(isFirstTime: isFirst);
          },
        ),
        GoRoute(
          path: '/converter',
          builder: (_, __) => const ConverterListScreen(),
        ),
        GoRoute(
          path: '/converter/:category',
          builder: (context, state) => UnitConverterScreen(
            initialCategory: state.pathParameters['category']!,
          ),
        ),
        GoRoute(path: '/currency', builder: (_, __) => const CurrencyScreen()),
        GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);
