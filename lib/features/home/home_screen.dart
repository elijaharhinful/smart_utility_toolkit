import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolItem(
        'Length',
        Icons.straighten_rounded,
        '/converter/Length',
        const Color(0xFF6C63FF),
      ),
      _ToolItem(
        'Weight',
        Icons.monitor_weight_outlined,
        '/converter/Weight',
        const Color(0xFF03DAC6),
      ),
      _ToolItem(
        'Temperature',
        Icons.thermostat_rounded,
        '/converter/Temperature',
        const Color(0xFFFF6584),
      ),
      _ToolItem(
        'Area',
        Icons.square_foot_rounded,
        '/converter/Area',
        const Color(0xFFFFA726),
      ),
      _ToolItem(
        'Speed',
        Icons.speed_rounded,
        '/converter/Speed',
        const Color(0xFF26C6DA),
      ),
      _ToolItem(
        'Volume',
        Icons.water_drop_outlined,
        '/converter/Volume',
        const Color(0xFF66BB6A),
      ),
      _ToolItem(
        'Currency',
        Icons.currency_exchange_rounded,
        '/currency',
        const Color(0xFFAB47BC),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Smart',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Unit Converter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All your conversions in one place.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Scrollbar(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: tools.length,
                    itemBuilder: (context, index) =>
                        _ToolCard(tool: tools[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  const _ToolItem(this.title, this.icon, this.route, this.color);
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push(tool.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool.icon, color: tool.color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                tool.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
