import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'section_card.dart';
import 'setting_row.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        SettingRow(
          title: 'Dark Mode',
          subtitle: 'Coming soon',
          trailing: Switch(
            value: false,
            onChanged: null,
            activeThumbColor: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
