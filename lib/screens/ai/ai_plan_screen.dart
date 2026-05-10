import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../models/exercise.dart';
import '../../services/ai_plan_service.dart';

/// AI Fitness Plan Generator screen.
/// Goal selection → generates weekly plan with day-by-day schedule.
class AIPlanScreen extends StatefulWidget {
  const AIPlanScreen({super.key});
  @override
  State<AIPlanScreen> createState() => _AIPlanScreenState();
}

class _AIPlanScreenState extends State<AIPlanScreen>
    with SingleTickerProviderStateMixin {
  FitnessGoal _selectedGoal = FitnessGoal.generalFitness;
  int _daysPerWeek = 4;
  String _fitnessLevel = 'Intermediate';
  AIFitnessPlan? _plan;
  int _expandedDay = -1;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    final plan = await AIPlanService.generatePlanAsync(
      goal: _selectedGoal,
      fitnessLevel: _fitnessLevel,
      daysPerWeek: _daysPerWeek,
    );
    setState(() {
      _plan = plan;
      _expandedDay = 0;
      _isLoading = false;
    });
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('AI Fitness Plan'),
        actions: [
          if (_plan != null)
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: _generatePlan,
              tooltip: 'Regenerate',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_plan == null ? _buildSetup() : _buildPlan()),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_outlined,
                color: AppColors.deepNavy, size: 32),
          ),
          const SizedBox(height: 20),
          Text('Create Your Plan', style: AppTypography.headlineLg),
          const SizedBox(height: 8),
          Text(
            'Our AI engine will build a personalized workout plan based on your goals.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: 32),

          // Goal selection
          Text('PRIMARY GOAL', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          ...FitnessGoal.values.map((goal) {
            final selected = goal == _selectedGoal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor:
                      selected ? AppColors.deepNavy.withOpacity(0.04) : null,
                  borderColor:
                      selected ? AppColors.deepNavy : AppColors.outlineVariant,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.deepNavy
                              : AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(goal.icon,
                            color: selected
                                ? AppColors.pureWhite
                                : AppColors.textSecondary,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.label,
                                style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600)),
                            Text(goal.description,
                                style: AppTypography.labelSm),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle,
                            color: AppColors.deepNavy, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Days per week
          Text('TRAINING DAYS / WEEK', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          SolidGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final n = i + 1;
                final active = n == _daysPerWeek;
                return GestureDetector(
                  onTap: () => setState(() => _daysPerWeek = n),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.deepNavy : Colors.transparent,
                      border: Border.all(
                          color: active
                              ? AppColors.deepNavy
                              : AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('$n',
                          style: AppTypography.button.copyWith(
                              color: active
                                  ? AppColors.pureWhite
                                  : AppColors.textSecondary)),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Fitness level
          Text('FITNESS LEVEL', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
              final active = l == _fitnessLevel;
              return GestureDetector(
                onTap: () => setState(() => _fitnessLevel = l),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? AppColors.deepNavy : AppColors.pureWhite,
                    border: Border.all(
                        color: active
                            ? AppColors.deepNavy
                            : AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(l,
                      style: AppTypography.button.copyWith(
                          color: active
                              ? AppColors.pureWhite
                              : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text('Generate Plan'),
              onPressed: _generatePlan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan() {
    final plan = _plan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          SolidGlassCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.deepNavy,
            borderColor: AppColors.deepNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(plan.goal.icon,
                        color: AppColors.pureWhite, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(plan.title,
                          style: AppTypography.headlineSm
                              .copyWith(color: AppColors.pureWhite)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(plan.summary,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.pureWhite.withOpacity(0.8),
                        height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _planStat(
                        '${plan.days.length}', 'Days', Icons.calendar_today),
                    const SizedBox(width: 20),
                    _planStat('${plan.totalMinutes}', 'Min',
                        Icons.timer_outlined),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Day-by-day schedule
          Text('WEEKLY SCHEDULE', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          ...plan.days.asMap().entries.map((entry) {
            final i = entry.key;
            final day = entry.value;
            final expanded = i == _expandedDay;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(
                    () => _expandedDay = expanded ? -1 : i),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                  day.dayLabel.substring(0, 3),
                                  style: AppTypography.labelSm.copyWith(
                                      color: AppColors.pureWhite,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(day.focus,
                                    style: AppTypography.bodyMd.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    '${day.estimatedMinutes} min • ${day.estimatedCalories} kcal',
                                    style: AppTypography.labelSm),
                              ],
                            ),
                          ),
                          Icon(
                              expanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.textTertiary),
                        ],
                      ),
                      if (expanded) ...[
                        const SizedBox(height: 12),
                        const Divider(
                            height: 1,
                            color: AppColors.outlineVariant),
                        const SizedBox(height: 12),
                        ...day.exercises.map((pe) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(pe.exercise.icon,
                                      color: AppColors.deepNavy,
                                      size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(pe.exercise.name,
                                        style: AppTypography.bodySm),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepNavy
                                          .withOpacity(0.06),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(pe.workDescription,
                                        style: AppTypography.labelSm
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.w600,
                                                color:
                                                    AppColors.deepNavy)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Nutrition tips
          Text('NUTRITION TIPS', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          SolidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: plan.nutritionTips
                  .map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.restaurant_outlined,
                                size: 16, color: AppColors.deepNavy),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(tip,
                                  style: AppTypography.bodySm
                                      .copyWith(height: 1.4)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Recovery tips
          Text('RECOVERY', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          SolidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: plan.recoveryTips
                  .map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.spa_outlined,
                                size: 16,
                                color: AppColors.successGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(tip,
                                  style: AppTypography.bodySm
                                      .copyWith(height: 1.4)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _planStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            color: AppColors.pureWhite.withOpacity(0.7), size: 16),
        const SizedBox(width: 6),
        Text(value,
            style: AppTypography.metricSm
                .copyWith(color: AppColors.pureWhite)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.labelSm.copyWith(
                color: AppColors.pureWhite.withOpacity(0.7))),
      ],
    );
  }
}
