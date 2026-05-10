import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/exercise_library_screen.dart';
import '../screens/ai/ai_plan_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Main bottom navigation shell for the core app tabs.
///
/// 5 tabs: Dashboard, Exercises, AI Coach, Analytics, Settings
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const <Widget>[
    DashboardScreen(),
    ExerciseLibraryScreen(),
    AIPlanScreen(),
    _AnalyticsHub(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: AppColors.outlineVariant, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center),
                label: 'Exercises'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'AI Plan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Analytics'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

/// Analytics hub with sub-navigation
class _AnalyticsHub extends StatelessWidget {
  const _AnalyticsHub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text('Track your training performance',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 24),
              _analyticsLink(context, Icons.gps_fixed_outlined,
                  'Form Accuracy', 'Perfect form percentage analysis', '/form-accuracy'),
              const SizedBox(height: 12),
              _analyticsLink(context, Icons.calendar_month_outlined,
                  'Consistency Heatmap', 'Monthly workout frequency grid', '/consistency-heatmap'),
              const SizedBox(height: 12),
              _analyticsLink(context, Icons.trending_up,
                  'Performance Trends', '30-day strength volume & rep speed', '/performance-trends'),
              const SizedBox(height: 12),
              _analyticsLink(context, Icons.leaderboard_outlined,
                  'Community Leaderboard', 'LuminAI community rankings', '/team-leaderboard'),
              const SizedBox(height: 12),
              _analyticsLink(context, Icons.assessment_outlined,
                  'Progress Report', 'Monthly shareable report', '/progress-report'),
              const SizedBox(height: 12),
              _analyticsLink(context, Icons.auto_awesome_outlined,
                  'AI Form Tips', 'Common mistakes & corrections', '/ai-tips'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analyticsLink(
      BuildContext ctx, IconData icon, String title, String sub, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(ctx, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.pureWhite,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.deepNavy, size: 22)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMd
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(sub, style: AppTypography.labelSm),
                ]),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: 20),
        ]),
      ),
    );
  }
}
