import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/appearance_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/app_info_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 24),
              const AppearanceSection(),
              const SizedBox(height: 16),
              const PreferencesSection(),
              const SizedBox(height: 24),
              const AppInfoSection(),
            ],
          ),
        ),
      ),
    );
  }
}
