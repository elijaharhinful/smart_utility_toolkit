import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final String result;
  final String unitShort;
  final String rateLabel;

  const ResultCard({
    super.key,
    required this.result,
    required this.unitShort,
    required this.rateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            'CONVERTED RESULT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.colorAlternative5,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: AutoSizeText(
                  result.isEmpty ? '—' : result,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.dark,
                  ),
                  minFontSize: 20,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (result.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unitShort,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (rateLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rateLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.colorAlternative1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
