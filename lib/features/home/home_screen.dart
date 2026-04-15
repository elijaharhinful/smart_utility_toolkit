import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool(
        'Length',
        'Convert distances',
        Icons.straighten_rounded,
        '/converter/Length',
      ),
      _Tool(
        'Weight',
        'Convert mass',
        Icons.monitor_weight_outlined,
        '/converter/Weight',
      ),
      _Tool(
        'Temperature',
        'Convert temps',
        Icons.thermostat_rounded,
        '/converter/Temperature',
      ),
      _Tool(
        'Area',
        'Convert areas',
        Icons.square_foot_rounded,
        '/converter/Area',
      ),
      _Tool(
        'Speed',
        'Convert velocity',
        Icons.speed_rounded,
        '/converter/Speed',
      ),
      _Tool(
        'Volume',
        'Convert capacity',
        Icons.water_drop_outlined,
        '/converter/Volume',
      ),
      _Tool(
        'Currency',
        'Exchange rates',
        Icons.currency_exchange_rounded,
        '/currency',
      ),
      _Tool('Tasks', 'Quick Checklist', Icons.checklist_rounded, '/tasks'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nex',
                      style: TextStyle(
                        fontFamily: 'JakartaSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.dark,
                      ),
                    ),
                    TextSpan(
                      text: 'Kit',
                      style: TextStyle(
                        fontFamily: 'JakartaSans',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Smart Utility Toolkit',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: tools.length,
                    itemBuilder: (_, i) => _ToolCard(tool: tools[i]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tool {
  final String title, subtitle, route;
  final IconData icon;
  const _Tool(this.title, this.subtitle, this.icon, this.route);
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(tool.route),
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
              child: Icon(tool.icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              tool.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tool.subtitle,
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
