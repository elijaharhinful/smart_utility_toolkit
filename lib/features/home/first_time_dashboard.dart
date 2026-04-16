import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_feature_row.dart';
import '../../core/theme/app_theme.dart';

class FirstTimeDashboard extends StatelessWidget {
  const FirstTimeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const DashboardHeader(),
              OverviewLabel(dateStr: formatDate(now)),
              const SizedBox(height: 24),
              _WelcomeCard(),
              const SizedBox(height: 28),
              const Text(
                'What you can do',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 14),
              DashboardFeatureRow(
                icon: Icons.swap_horiz_rounded,
                title: 'Convert anything',
                subtitle: 'Currency, distance, weight & more',
                onTap: () => context.go('/converter'),
              ),
              const SizedBox(height: 12),
              DashboardFeatureRow(
                icon: Icons.checklist_rounded,
                title: 'Create and manage tasks',
                subtitle: 'Set priorities, due dates & reminders',
                onTap: () => context.go('/tasks'),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'No account needed.\nStart right away!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.hub_rounded, color: AppTheme.primary, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to NexKit',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your all-in-one toolkit for quick\nconversions and staying on top of tasks.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
