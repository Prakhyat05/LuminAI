import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../services/user_state.dart';
import '../services/ai_plan_service.dart';

/// Screen 11: Main Dashboard (Home) — Central HUD wired to real data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringAnimController;
  late Animation<double> _ringAnim;

  // We'll use local state since we don't have InheritedWidget yet.
  // Reading from UserState singleton pattern.
  final _userState = UserState();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ringAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(parent: _ringAnimController, curve: Curves.easeOutCubic));
    _loadData();
  }

  Future<void> _loadData() async {
    await _userState.initialize();
    if (mounted) {
      setState(() => _loaded = true);
      _ringAnimController.forward();
    }
  }

  @override
  void dispose() {
    _ringAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _loaded ? _userState.userName : 'User';
    final greeting = _loaded ? _userState.greeting : 'Good day';
    final steps = _loaded ? _userState.todaySteps : 0;
    final stepGoal = _loaded ? _userState.stepGoal : 20000;
    final calories = _loaded ? _userState.todayCalories.toInt() : 0;
    final protein = _loaded ? _userState.todayProtein.toInt() : 0;
    final activeMin = _loaded ? _userState.todayActiveMinutes : 0;
    final stepProgress = stepGoal > 0 ? (steps / stepGoal).clamp(0.0, 1.0) : 0.0;
    final dailyTip = AIPlanService.getDailyTip();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepNavy.withOpacity(0.08)),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.deepNavy, size: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$greeting, $name',
                          style: AppTypography.headlineSm),
                      Text('Let\'s crush your goals today.',
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.outlineVariant)),
                    child: const Icon(Icons.notifications_none,
                        color: AppColors.deepNavy, size: 20)),
              ]),
              const SizedBox(height: 32),

              // Step ring hero
              Center(
                child: AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (_, __) => SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                              value: stepProgress * _ringAnim.value,
                              strokeWidth: 10,
                              backgroundColor: AppColors.progressTrack,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.deepNavy)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_formatNumber(steps),
                                style: AppTypography.displayMetrics),
                            Text('STEPS', style: AppTypography.metricUnit),
                            const SizedBox(height: 4),
                            Text('/ ${_formatNumber(stepGoal)}',
                                style: AppTypography.labelSm),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Stats row
              Row(children: [
                Expanded(
                    child: _statCard('Calories', '$calories', 'kcal',
                        (calories / 2800).clamp(0.0, 1.0), Icons.local_fire_department_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Protein', '$protein', 'g',
                        (protein / 150).clamp(0.0, 1.0), Icons.restaurant_outlined)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _statCard('Active', '$activeMin', 'min',
                        (activeMin / 60).clamp(0.0, 1.0), Icons.timer_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Heart Rate', '--', 'bpm', 0.0,
                        Icons.favorite_border)),
              ]),
              const SizedBox(height: 32),

              // AI Daily Tip
              SolidGlassCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.deepNavy.withOpacity(0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.deepNavy, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI TIP',
                              style: AppTypography.labelCaps
                                  .copyWith(fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(dailyTip,
                              style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Quick Actions', style: AppTypography.headlineSm),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _actionCard('Start Workout',
                        Icons.play_arrow_rounded, () => Navigator.pushNamed(context, '/exercise-library'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionCard('AI Plan',
                        Icons.auto_awesome_outlined, () => Navigator.pushNamed(context, '/ai-plan'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _actionCard('Nutrition',
                        Icons.restaurant_outlined, () => Navigator.pushNamed(context, '/nutrition'))),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionCard('Live AI Track',
                        Icons.camera_alt_outlined, () => Navigator.pushNamed(context, '/live-ai'))),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K'
          .replaceFirst('K', ',${(n % 1000).toString().padLeft(3, '0')}')
          .replaceFirst(RegExp(r'\..*,'), ',');
    }
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Widget _statCard(String label, String value, String unit, double progress,
      IconData icon) {
    return SolidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(),
                  style:
                      AppTypography.labelCaps.copyWith(fontSize: 10)),
              Icon(icon, color: AppColors.deepNavy, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.metricMd),
              const SizedBox(width: 4),
              Text(unit, style: AppTypography.labelSm),
            ],
          ),
          if (progress > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.progressTrack,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.deepNavy),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2)),
          ],
        ],
      ),
    );
  }

  Widget _actionCard(String label, IconData icon, VoidCallback onTap) {
    return SolidGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Icon(icon, color: AppColors.deepNavy, size: 28),
        const SizedBox(height: 8),
        Text(label,
            style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ]),
    );
  }
}
