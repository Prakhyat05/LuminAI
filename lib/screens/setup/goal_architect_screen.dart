import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../models/exercise.dart';
import '../../services/auth_service.dart';

/// Screen 9: Goal Architect — Primary goal + step targets + intensity
class GoalArchitectScreen extends StatefulWidget {
  const GoalArchitectScreen({super.key});
  @override
  State<GoalArchitectScreen> createState() => _GoalArchitectScreenState();
}

class _GoalArchitectScreenState extends State<GoalArchitectScreen> {
  FitnessGoal _primaryGoal = FitnessGoal.generalFitness;
  double _stepGoal = 15000;
  int _workoutsPerWeek = 4;
  String _intensity = 'Medium';
  final _auth = AuthService();

  Future<void> _startTraining() async {
    await _auth.updateProfile(goal: _primaryGoal.name);
    await _auth.completeOnboarding();
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Goal Architect')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STEP 4 OF 4', style: AppTypography.labelCaps),
              const SizedBox(height: 4),
              const LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: AlwaysStoppedAnimation(AppColors.deepNavy),
                  minHeight: 4),
              const SizedBox(height: 32),
              Text('Set Your Targets', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text('Define your fitness goals and daily activity targets.',
                  style:
                      AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
              const SizedBox(height: 32),
    
              // Primary Goal
              Text('PRIMARY GOAL', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FitnessGoal.values.map((goal) {
                  final selected = goal == _primaryGoal;
                  return GestureDetector(
                    onTap: () => setState(() => _primaryGoal = goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.deepNavy : AppColors.pureWhite,
                        border: Border.all(
                            color: selected
                                ? AppColors.deepNavy
                                : AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(goal.icon,
                              size: 18,
                              color: selected
                                  ? AppColors.pureWhite
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(goal.label,
                              style: AppTypography.labelSm.copyWith(
                                  color: selected
                                      ? AppColors.pureWhite
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              SolidGlassCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: AppColors.deepNavy.withOpacity(0.04),
                child: Row(
                  children: [
                    Icon(_primaryGoal.icon, color: AppColors.deepNavy, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_primaryGoal.description,
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
    
              // Step goal
              SolidGlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DAILY STEPS', style: AppTypography.labelCaps),
                        const Icon(Icons.directions_walk,
                            color: AppColors.textTertiary, size: 20),
                      ]),
                  const SizedBox(height: 20),
                  Text(
                      _stepGoal.toInt().toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},'),
                      style: AppTypography.displayMetrics),
                  const SizedBox(height: 4),
                  Text('STEPS', style: AppTypography.metricUnit),
                  const SizedBox(height: 16),
                  Slider(
                      value: _stepGoal,
                      min: 5000,
                      max: 30000,
                      divisions: 50,
                      activeColor: AppColors.deepNavy,
                      inactiveColor: AppColors.progressTrack,
                      onChanged: (v) => setState(() => _stepGoal = v)),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5,000', style: AppTypography.labelSm),
                        Text('Recommended: 10K–15K',
                            style: AppTypography.labelSm),
                        Text('30,000', style: AppTypography.labelSm),
                      ]),
                ]),
              ),
              const SizedBox(height: 16),
    
              // Workouts per week
              SolidGlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('WORKOUTS / WEEK', style: AppTypography.labelCaps),
                        const Icon(Icons.fitness_center,
                            color: AppColors.textTertiary, size: 20),
                      ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final n = i + 1;
                      final active = n == _workoutsPerWeek;
                      return GestureDetector(
                        onTap: () => setState(() => _workoutsPerWeek = n),
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: active
                                    ? AppColors.deepNavy
                                    : Colors.transparent,
                                border: Border.all(
                                    color: active
                                        ? AppColors.deepNavy
                                        : AppColors.outlineVariant),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Text('$n',
                                    style: AppTypography.button.copyWith(
                                        color: active
                                            ? AppColors.pureWhite
                                            : AppColors.textSecondary)))),
                      );
                    }),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
    
              // Intensity
              Text('TRAINING INTENSITY', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              Row(
                children: ['Low', 'Medium', 'High', 'Extreme'].map((l) {
                  final active = l == _intensity;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _intensity = l),
                      child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                              color: active
                                  ? AppColors.deepNavy
                                  : AppColors.pureWhite,
                              border: Border.all(
                                  color: active
                                      ? AppColors.deepNavy
                                      : AppColors.outlineVariant),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(l,
                                  style: AppTypography.labelSm.copyWith(
                                      color: active
                                          ? AppColors.pureWhite
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600)))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _startTraining,
                      child: const Text('Start Training'))),
            ],
          ),
        ),
      ),
    );
  }
}
