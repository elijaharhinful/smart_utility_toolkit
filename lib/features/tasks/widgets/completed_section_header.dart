import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CompletedSectionHeader extends StatelessWidget {
  const CompletedSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'RECENTLY COMPLETED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
