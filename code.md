import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../tasks/tasks_provider.dart';
import '../currency/currency_provider.dart';
import '../tasks/task_model.dart';

// ---------------------------------------------------------------------------
// Model for a recent conversion history entry.
// Add this to your conversion provider / history service when ready.
// For now it is self-contained so the screen compiles immediately.
// ---------------------------------------------------------------------------
class ConversionHistoryEntry {
  final String label; // e.g. "5 Miles to Kilometers"
  final String result; // e.g. "8.04672 km"
  final IconData icon;
  const ConversionHistoryEntry({
    required this.label,
    required this.result,
    required this.icon,
  });
}

// ---------------------------------------------------------------------------
// Dashboard Screen
// ---------------------------------------------------------------------------
class DashboardScreen extends StatelessWidget {
  /// Passed as a query param from the router when it's the first launch.
  final bool isFirstTime;

  const DashboardScreen({super.key, this.isFirstTime = false});

  @override
  Widget build(BuildContext context) {
    return isFirstTime
        ? const _FirstTimeDashboard()
        : const _ReturningDashboard();
  }
}

// ===========================================================================
// FIRST-TIME DASHBOARD  (Dashboard-1)
// ===========================================================================
class _FirstTimeDashboard extends StatelessWidget {
  const _FirstTimeDashboard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _Header(),
              const SizedBox(height: 4),
              _OverviewLabel(dateStr: dateStr),
              const SizedBox(height: 24),

              // Welcome card
              _WelcomeCard(),
              const SizedBox(height: 28),

              // What you can do
              const Text(
                'What you can do',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 14),
              _FeatureRow(
                icon: Icons.swap_horiz_rounded,
                title: 'Convert anything',
                subtitle: 'Currency, distance, weight & more',
                onTap: () => context.go('/converter'),
              ),
              const SizedBox(height: 12),
              _FeatureRow(
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

// ===========================================================================
// RETURNING USER DASHBOARD  (Dashboard-2)
// ===========================================================================
class _ReturningDashboard extends StatelessWidget {
  const _ReturningDashboard();

  // ---------------------------------------------------------------------------
  // Sample / stub conversion history.
  // Replace with data from your actual conversion history provider.
  // ---------------------------------------------------------------------------
  static const List<ConversionHistoryEntry> _sampleHistory = [
    ConversionHistoryEntry(
      label: '5 Miles to Kilometers',
      result: '8.04672 km',
      icon: Icons.straighten_rounded,
    ),
    ConversionHistoryEntry(
      label: '5 US Dollars to Ghana Cedis',
      result: '50 GHS',
      icon: Icons.currency_exchange_rounded,
    ),
    ConversionHistoryEntry(
      label: '5 Miles to Kilometers',
      result: '8.04672 km',
      icon: Icons.straighten_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    final tasksProvider = context.watch<TasksProvider>();

    // Show only the 3 nearest due tasks (or all if fewer than 3)
    final dueTasks = _getTopTasks(tasksProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _Header(),
              const SizedBox(height: 4),
              _OverviewLabel(dateStr: dateStr),
              const SizedBox(height: 20),

              // Quick-action pills
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Convert now',
                      onTap: () => context.go('/converter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.checklist_rounded,
                      label: 'Create a task',
                      onTap: () => context.go('/tasks'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Due Tasks section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Due Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/tasks'),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              dueTasks.isEmpty
                  ? _EmptyState(
                      message: 'No tasks yet',
                      actionLabel: 'Create one',
                      onAction: () => context.go('/tasks'),
                    )
                  : _TaskList(tasks: dueTasks),

              const SizedBox(height: 28),

              // Recent Conversions section
              const Text(
                'Recent Conversions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 12),
              _ConversionHistory(entries: _sampleHistory),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<Task> _getTopTasks(TasksProvider provider) {
    final all = List<Task>.from(provider.tasks)
      ..sort((a, b) {
        // Sort by due date ascending, nulls last
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return all.take(3).toList();
  }
}

// ===========================================================================
// SHARED WIDGETS
// ===========================================================================

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Nex',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dark,
                ),
              ),
              TextSpan(
                text: 'Kit',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Smart Utility Toolkit',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OverviewLabel extends StatelessWidget {
  final String dateStr;
  const _OverviewLabel({required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S OVERVIEW",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.dark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome card (first-time only)
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Feature row (first-time only)
// ---------------------------------------------------------------------------
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action pill (returning user)
// ---------------------------------------------------------------------------
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dark,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task list (returning user) — reads from TasksProvider model
// ---------------------------------------------------------------------------
class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: tasks.asMap().entries.map((entry) {
          final i = entry.key;
          final task = entry.value;
          final isLast = i == tasks.length - 1;
          return Column(
            children: [
              _TaskRow(task: task),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Task task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    final priorityLabel = _priorityLabel(task.priority);
    final dueLabel = _dueLabel(task.dueDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Priority stripe
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dueLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              priorityLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: priorityColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppTheme.danger;
      case TaskPriority.medium:
        return AppTheme.primary;
      case TaskPriority.low:
        return const Color(0xFF94A3B8);
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  String _dueLabel(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    if (diff.isNegative) return 'Overdue';
    if (diff.inMinutes < 60) return 'Due in ${diff.inMinutes}m';
    if (diff.inHours < 24)
      return 'Due in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays} days';
  }
}

// ---------------------------------------------------------------------------
// Conversion history (returning user)
// ---------------------------------------------------------------------------
class _ConversionHistory extends StatelessWidget {
  final List<ConversionHistoryEntry> entries;
  const _ConversionHistory({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == entries.length - 1;
          return Column(
            children: [
              _ConversionRow(entry: item),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ConversionRow extends StatelessWidget {
  final ConversionHistoryEntry entry;
  const _ConversionRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.result,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _formatDate(DateTime dt) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const days = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return '${days[dt.weekday]}, ${months[dt.month]} ${dt.day}';


  ================================================================

  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'currency_provider.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'GHS';
  final _inputController = TextEditingController(text: '1');
  final List<String> _popularCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'GHS',
    'NGN',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'ZAR',
    'KES',
    'EGP',
    'MAD',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CurrencyProvider>().fetchRates(_fromCurrency),
    );
  }

  String _convert() {
    final provider = context.read<CurrencyProvider>();
    final input = double.tryParse(_inputController.text);
    if (input == null || provider.rates.isEmpty) return '—';
    final rate = provider.rates[_toCurrency] ?? 0;
    return (input * rate).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildCurrencyDropdown('From', _fromCurrency, (v) {
                        setState(() => _fromCurrency = v!);
                        provider.fetchRates(v!);
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconButton.filled(
                        onPressed: () => setState(() {
                          final tmp = _fromCurrency;
                          _fromCurrency = _toCurrency;
                          _toCurrency = tmp;
                          provider.fetchRates(_fromCurrency);
                        }),
                        icon: const Icon(Icons.swap_horiz),
                      ),
                    ),
                    Expanded(
                      child: _buildCurrencyDropdown(
                        'To',
                        _toCurrency,
                        (v) => setState(() => _toCurrency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_inputController.text} $_fromCurrency =',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_convert()} $_toCurrency',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rate: 1 $_fromCurrency = ${provider.rates[_toCurrency]?.toStringAsFixed(4) ?? '—'} $_toCurrency',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => provider.fetchRates(_fromCurrency),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Rates'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: _popularCurrencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

=======================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'tasks_provider.dart';
import 'task_model.dart';
import 'task_form_sheet.dart';

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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Tasks',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.dark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (pending.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'You have ${pending.length} task${pending.length == 1 ? '' : 's'} to complete',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (pending.isEmpty && completed.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All clear!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Text(
                                'Add a task to get started.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (pending.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) =>
                                _TaskCard(task: pending[i], provider: provider),
                            childCount: pending.length,
                          ),
                        ),
                      ),
                    if (completed.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
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
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _TaskCard(
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
                Positioned(
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final TasksProvider provider;
  const _TaskCard({required this.task, required this.provider});

  Color _priorityColor() {
    switch (task.priority) {
      case 'High':
        return AppTheme.danger;
      case 'Medium':
        return AppTheme.primary;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => provider.toggleComplete(task.id),
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: task.isCompleted
                      ? AppTheme.primary
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                color: task.isCompleted ? AppTheme.primary : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          // color: AppTheme.dark,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppTheme.textSecondary
                              : AppTheme.dark,
                        ),
                      ),
                    ),
                    if (task.priority == 'High' && !task.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'High',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger,
                          ),
                        ),
                      ),
                  ],
                ),
                if (task.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (task.dueDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: _priorityColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDue(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _priorityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!task.isCompleted)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        TaskFormSheet(provider: provider, task: task),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppTheme.danger,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDue(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(d.year, d.month, d.day);
    if (due == today) return 'Today, ${DateFormat('h:mm a').format(d)}';
    if (due == today.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('MMM d').format(d);
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delete Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete this task?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.deleteTask(task.id);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

================================
```dart
class Task {
  final String id;
  String title;
  String note;
  String priority; // 'Low', 'Medium', 'High'
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.note = '',
    this.priority = 'Medium',
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    title: j['title'],
    note: j['note'] ?? '',
    priority: j['priority'] ?? 'Medium',
    dueDate: j['dueDate'] != null ? DateTime.parse(j['dueDate']) : null,
    isCompleted: j['isCompleted'] ?? false,
    createdAt: DateTime.parse(j['createdAt']),
  );
}

```


```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFE8A020);
  static const dark = Color(0xFF1E1E32);
  static const background = Color(0xFFF4F4F4);
  static const cardBg = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF64748B);
  static const colorAlternative1 = Color(0xFFD6C4AE);
  static const colorAlternative2 = Color(0xFF514534);
  static const colorAlternative3 = Color(0xFFB45309);
  static const colorAlternative4 = Color(0xFFB91C1C);
  static const colorAlternative5 = Color(0xFF847562);
  static const danger = Color(0xFFEF4444);
  static const iconBg = Color(0xFFFFF3DC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: background,
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w800,
      ),
      displayMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: dark,
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

```


```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class TasksProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get pending => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completed => _tasks.where((t) => t.isCompleted).toList();

  TasksProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks_v1');
    if (data != null) {
      _tasks = (jsonDecode(data) as List).map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tasks_v1',
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  void addTask(String title, String note, String priority, DateTime? dueDate) {
    _tasks.insert(
      0,
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        note: note,
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      ),
    );
    _save();
    notifyListeners();
  }

  void updateTask(
    String id,
    String title,
    String note,
    String priority,
    DateTime? dueDate,
  ) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) {
      _tasks[i].title = title;
      _tasks[i].note = note;
      _tasks[i].priority = priority;
      _tasks[i].dueDate = dueDate;
      _save();
      notifyListeners();
    }
  }

  void toggleComplete(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) {
      _tasks[i].isCompleted = !_tasks[i].isCompleted;
      _save();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }
}

```



```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/shell/app_shell.dart';
import 'features/home/dashboard_screen.dart';
import 'features/home/splash_screen.dart';
import 'features/converter/converter_list_screen.dart';
import 'features/unit_converter/unit_converter_screen.dart';
import 'features/currency/currency_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/settings/settings_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final isFirst = state.uri.queryParameters['first'] == 'true';
            return DashboardScreen(isFirstTime: isFirst);
          },
        ),
        GoRoute(
          path: '/converter',
          builder: (_, __) => const ConverterListScreen(),
        ),
        GoRoute(
          path: '/converter/:category',
          builder: (context, state) => UnitConverterScreen(
            initialCategory: state.pathParameters['category']!,
          ),
        ),
        GoRoute(path: '/currency', builder: (_, __) => const CurrencyScreen()),
        GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);


```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class UnitConverterScreen extends StatefulWidget {
  final String initialCategory;
  const UnitConverterScreen({super.key, required this.initialCategory});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  late String _fromUnit, _toUnit;
  final _inputController = TextEditingController();
  String _result = '';
  String _rateLabel = '';
  final List<Map<String, String>> _history = [];

  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'Meter (m)': 1,
      'Kilometer (km)': 0.001,
      'Centimeter (cm)': 100,
      'Millimeter (mm)': 1000,
      'Mile (mi)': 0.000621371,
      'Yard (yd)': 1.09361,
      'Feet (ft)': 3.28084,
      'Inch (in)': 39.3701,
    },
    'Weight': {
      'Kilogram (kg)': 1,
      'Gram (g)': 1000,
      'Milligram (mg)': 1000000,
      'Pound (lb)': 2.20462,
      'Ounce (oz)': 35.274,
      'Ton': 0.001,
      'Stone (st)': 0.157473,
    },
    'Temperature': {'Celsius (°C)': 1, 'Fahrenheit (°F)': 1, 'Kelvin (K)': 1},
    'Area': {
      'Square Meter (m²)': 1,
      'Square Kilometer (km²)': 0.000001,
      'Square Mile': 3.861e-7,
      'Square Foot (ft²)': 10.7639,
      'Hectare (ha)': 0.0001,
      'Acre': 0.000247105,
    },
    'Speed': {
      'm/s': 1,
      'km/h': 3.6,
      'mph': 2.23694,
      'knot': 1.94384,
      'ft/s': 3.28084,
    },
    'Volume': {
      'Liter (L)': 1,
      'Milliliter (mL)': 1000,
      'Cubic Meter (m³)': 0.001,
      'Gallon (US)': 0.264172,
      'Fluid Ounce (fl oz)': 33.814,
      'Cup': 4.22675,
      'Pint (pt)': 2.11338,
    },
  };

  List<String> get _units =>
      _conversions[widget.initialCategory]!.keys.toList();

  @override
  void initState() {
    super.initState();
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
  }

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() {
        _result = '';
        _rateLabel = '';
      });
      return;
    }

    double result;
    if (widget.initialCategory == 'Temperature') {
      result = _convertTemp(input, _fromUnit, _toUnit);
    } else {
      final base = input / _conversions[widget.initialCategory]![_fromUnit]!;
      result = base * _conversions[widget.initialCategory]![_toUnit]!;
    }

    String fmt(double v) {
      if (v == v.roundToDouble()) return v.toInt().toString();
      return v
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    // Rate label
    double rate;
    if (widget.initialCategory == 'Temperature') {
      rate = _convertTemp(1, _fromUnit, _toUnit);
    } else {
      rate =
          _conversions[widget.initialCategory]![_toUnit]! /
          _conversions[widget.initialCategory]![_fromUnit]!;
    }

    final resultStr = fmt(result);
    final rateStr =
        '1 ${_fromUnit.split(' ').first} = ${fmt(rate)} ${_toUnit.split(' ').first}';

    // Auto-save to history when input ends with a digit (not mid-typing)
    final rawInput = _inputController.text;
    if (rawInput.isNotEmpty && RegExp(r'\d$').hasMatch(rawInput)) {
      final from = _fromUnit.split(' ').first;
      final to = _toUnit.split(' ').first;
      final entry = {
        'label': '$rawInput $from to $to',
        'result': '$resultStr $to',
      };
      // Only add if different from last entry
      if (_history.isEmpty || _history.first['label'] != entry['label']) {
        _history.insert(0, entry);
        if (_history.length > 5) _history.removeLast();
      }
    }

    setState(() {
      _result = resultStr;
      _rateLabel = rateStr;
    });
  }

  double _convertTemp(double v, String from, String to) {
    double c;
    if (from.contains('°F')) {
      c = (v - 32) * 5 / 9;
    } else if (from.contains('K')) {
      c = v - 273.15;
    } else {
      c = v;
    }
    if (to.contains('°F')) return c * 9 / 5 + 32;
    if (to.contains('K')) return c + 273.15;
    return c;
  }

  void _saveToHistory() {
    if (_result.isEmpty || _inputController.text.isEmpty) return;
    final from = _fromUnit.split(' ').first;
    final to = _toUnit.split(' ').first;
    final entry = {
      'label': '${_inputController.text} $from to $to',
      'result': '$_result $to',
    };
    setState(() {
      _history.insert(0, entry);
      if (_history.length > 5) _history.removeLast();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toShort = _toUnit.contains('(')
        ? _toUnit.split('(')[1].replaceAll(')', '')
        : _toUnit;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.initialCategory} Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _inputController.clear();
                      setState(() {
                        _result = '';
                        _rateLabel = '';
                      });
                    },
                  ),
                ),
                onChanged: (_) => _convert(),
                onEditingComplete: _saveToHistory,
              ),
            ),
            const SizedBox(height: 40),

            // From / Swap / To
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    _fromUnit,
                    (v) => setState(() {
                      _fromUnit = v!;
                      _convert();
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      final t = _fromUnit;
                      _fromUnit = _toUnit;
                      _toUnit = t;
                      _convert();
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    _toUnit,
                    (v) => setState(() {
                      _toUnit = v!;
                      _convert();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Result card
            Container(
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
                      Text(
                        _result.isEmpty ? '—' : _result,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.dark,
                        ),
                      ),
                      if (_result.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            toShort,
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
                  if (_rateLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _rateLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colorAlternative1,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // History
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(
                    Icons.history_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
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
              ..._history.asMap().entries.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                        child: const Icon(
                          Icons.straighten_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value['label']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.dark,
                              ),
                            ),
                            Text(
                              e.value['result']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _history.removeAt(e.key)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
          items: _units
              .map(
                (u) => DropdownMenuItem(
                  value: u,
                  child: Text(u, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
