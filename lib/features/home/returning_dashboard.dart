import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../tasks/tasks_provider.dart';
import '../tasks/task_model.dart';
import '../history/conversion_history_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_quick_action.dart';
import 'widgets/dashboard_task_list.dart';
import 'widgets/dashboard_conversion_history.dart';
import 'widgets/dashboard_empty_state.dart';

class ReturningDashboard extends StatelessWidget {
  const ReturningDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tasks = _getTopTasks(context.watch<TasksProvider>());
    final history = context.watch<ConversionHistoryProvider>().recent;

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
              const SizedBox(height: 20),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: DashboardQuickAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Convert now',
                      onTap: () => context.go('/converter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardQuickAction(
                      icon: Icons.checklist_rounded,
                      label: 'Create a task',
                      onTap: () => context.go('/tasks'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Due Tasks
              _SectionHeader(
                title: 'Due Tasks',
                actionLabel: 'View All',
                onAction: () => context.go('/tasks'),
              ),
              const SizedBox(height: 12),
              tasks.isEmpty
                  ? DashboardEmptyState(
                      message: 'No tasks yet',
                      actionLabel: 'Create one',
                      onAction: () => context.go('/tasks'),
                    )
                  : DashboardTaskList(tasks: tasks),
              const SizedBox(height: 28),

              // Recent Conversions
              const Text(
                'Recent Conversions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 12),
              history.isEmpty
                  ? DashboardEmptyState(
                      message: 'No conversions yet',
                      actionLabel: 'Convert now',
                      onAction: () => context.go('/converter'),
                    )
                  : DashboardConversionHistory(entries: history),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<Task> _getTopTasks(TasksProvider provider) {
    final sorted = provider.tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return sorted.take(3).toList();
  }
}

// ignore: prefer_constructors_over_static_methods — local helper widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.dark,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
