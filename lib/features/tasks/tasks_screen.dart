import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tasks_provider.dart';
import 'widgets/tasks_header.dart';
import 'widgets/task_card.dart';
import 'widgets/tasks_empty_state.dart';
import 'widgets/completed_section_header.dart';
import 'widgets/add_task_fab.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TasksProvider>(
          builder: (context, provider, _) {
            final pending = provider.pending;
            final completed = provider.completed;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: TasksHeader(pendingCount: pending.length),
                    ),
                    if (pending.isEmpty && completed.isEmpty)
                      const SliverFillRemaining(child: TasksEmptyState()),
                    if (pending.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) =>
                                TaskCard(task: pending[i], provider: provider),
                            childCount: pending.length,
                          ),
                        ),
                      ),
                    if (completed.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: CompletedSectionHeader()),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => TaskCard(
                              task: completed[i],
                              provider: provider,
                            ),
                            childCount: completed.length,
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
                AddTaskFab(provider: provider),
              ],
            );
          },
        ),
      ),
    );
  }
}
