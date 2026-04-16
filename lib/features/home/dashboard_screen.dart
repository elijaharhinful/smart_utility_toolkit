import 'package:flutter/material.dart';
import 'first_time_dashboard.dart';
import 'returning_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  final bool isFirstTime;
  const DashboardScreen({super.key, this.isFirstTime = false});

  @override
  Widget build(BuildContext context) =>
      isFirstTime ? const FirstTimeDashboard() : const ReturningDashboard();
}
