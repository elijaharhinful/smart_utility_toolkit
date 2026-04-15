import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/shell/app_shell.dart';
import 'features/home/home_screen.dart';
import 'features/converter/converter_list_screen.dart';
import 'features/unit_converter/unit_converter_screen.dart';
import 'features/currency/currency_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/settings/settings_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/converter',
          builder: (_, _) => const ConverterListScreen(),
        ),
        GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/converter/:category',
      builder: (context, state) => UnitConverterScreen(
        initialCategory: state.pathParameters['category']!,
      ),
    ),
    GoRoute(path: '/currency', builder: (_, _) => const CurrencyScreen()),
  ],
);
