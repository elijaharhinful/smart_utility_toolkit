import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/unit_converter/unit_converter_screen.dart';
import 'features/currency/currency_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/converter/:category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return UnitConverterScreen(initialCategory: category);
      },
    ),
    GoRoute(path: '/currency', builder: (_, _) => const CurrencyScreen()),
  ],
);
