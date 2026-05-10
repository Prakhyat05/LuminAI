import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../models/exercise.dart';
import '../data/exercise_database.dart';
import '../services/exercise_tracking_config.dart';

/// Screen 13: Instructional Detail — Dynamic exercise detail with AI form tips.
class InstructionalDetailScreen extends StatelessWidget {
  const InstructionalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get exercise from route arguments, fallback to first in database
    final exercise = ModalRoute.of(context)?.settings.arguments as Exercise? ??
        ExerciseDatabase.all.first;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(exercise.icon,
                        size: 48, color: AppColors.deepNavy),
                    const SizedBox(height: 8),
                    Text(exercise.category.label,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.deepNavy)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info bar
            Row(
              children: [
                _infoChip(exercise.muscleGroup, exercise.difficulty.color),
                const SizedBox(width: 8),
                _infoChip(exercise.difficulty.label, exercise.difficulty.color),
                const SizedBox(width: 8),
                _infoChip('${exercise.durationMinutes} min',
                    AppColors.deepNavy),
                const SizedBox(width: 8),
                _infoChip('${exercise.estimatedCalories} kcal',
                    AppColors.deepNavy),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text(exercise.description,
                style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 24),

            if (exercise.requiresEquipment)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: AppColors.warningOrange.withOpacity(0.06),
                  borderColor: AppColors.warningOrange.withOpacity(0.2),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          color: AppColors.warningOrange, size: 18),
                      const SizedBox(width: 10),
                      Text('Equipment required',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.warningOrange,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

            // Step-by-step instructions
            Text('Step-by-Step', style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            ...exercise.steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: AppColors.deepNavy,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text('${i + 1}',
                              style: AppTypography.button
                                  .copyWith(color: AppColors.pureWhite)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(step,
                            style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // AI Form Tips
            Text('AI Form Tips', style: AppTypography.headlineMd),
            const SizedBox(height: 4),
            Text('Common mistakes to avoid',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 16),
            ...exercise.aiFormTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SolidGlassCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: AppColors.warningOrange.withOpacity(0.04),
                    borderColor: AppColors.warningOrange.withOpacity(0.15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.warningOrange, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(tip,
                              style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                )),
            // AI Tracking indicator
            Builder(builder: (context) {
              final trackable = ExerciseTrackingRegistry.mapExerciseId(exercise.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: trackable != null
                      ? AppColors.successGreen.withOpacity(0.06)
                      : AppColors.surfaceLow,
                  borderColor: trackable != null
                      ? AppColors.successGreen.withOpacity(0.2)
                      : AppColors.outlineVariant,
                  child: Row(children: [
                    Icon(
                      trackable != null
                          ? Icons.auto_awesome
                          : Icons.info_outline,
                      color: trackable != null
                          ? AppColors.successGreen
                          : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        trackable != null
                            ? 'AI Real-Time Tracking Available — form analysis, rep counting & voice coaching'
                            : 'Manual tracking mode — AI form detection not available for this exercise',
                        style: AppTypography.bodySm.copyWith(
                          color: trackable != null
                              ? AppColors.successGreen
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }),

            // Start workout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text('Start AI Workout'),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/live-ai',
                  arguments: exercise,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: AppTypography.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11)),
      );
}
