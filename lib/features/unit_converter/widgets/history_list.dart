import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../history/conversion_history_provider.dart';

class ConverterHistoryList extends StatelessWidget {
  final String iconType;

  const ConverterHistoryList({super.key, required this.iconType});

  @override
  Widget build(BuildContext context) {
    final history = context
        .watch<ConversionHistoryProvider>()
        .all
        .where((e) => e.iconType == iconType)
        .toList();

    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: const [
            Icon(Icons.history_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 6),
            Text(
              'Recent History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...history.map(
          (e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(e.icon, size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.dark,
                        ),
                      ),
                      Text(
                        e.result,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<ConversionHistoryProvider>().removeEntry(e),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.danger,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
