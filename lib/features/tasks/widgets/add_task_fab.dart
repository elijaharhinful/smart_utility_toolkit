import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../tasks_provider.dart';
import '../task_form_sheet.dart';

class AddTaskFab extends StatelessWidget {
  final TasksProvider provider;
  const AddTaskFab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TaskFormSheet(provider: provider),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
