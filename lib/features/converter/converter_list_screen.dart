import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ConverterListScreen extends StatelessWidget {
  const ConverterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(
        'Length',
        'Convert distances',
        Icons.straighten_rounded,
        '/converter/Length',
      ),
      _Item(
        'Weight',
        'Convert mass',
        Icons.monitor_weight_outlined,
        '/converter/Weight',
      ),
      _Item(
        'Temperature',
        'Convert temps',
        Icons.thermostat_rounded,
        '/converter/Temperature',
      ),
      _Item(
        'Area',
        'Covert areas',
        Icons.square_foot_rounded,
        '/converter/Area',
      ),
      _Item(
        'Speed',
        'Convert velocity',
        Icons.speed_rounded,
        '/converter/Speed',
      ),
      _Item(
        'Volume',
        'Convert capacity',
        Icons.water_drop_outlined,
        '/converter/Volume',
      ),
      _Item(
        'Currency',
        'Exchange rates',
        Icons.currency_exchange_rounded,
        '/currency',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Converters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _ConverterCard(item: items[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  final String title, subtitle, route;
  final IconData icon;
  const _Item(this.title, this.subtitle, this.icon, this.route);
}

class _ConverterCard extends StatelessWidget {
  final _Item item;
  const _ConverterCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
