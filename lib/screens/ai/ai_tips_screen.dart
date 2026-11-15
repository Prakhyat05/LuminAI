import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/ai_tips_service.dart';

/// AI Tips & Form Corrections screen.
/// Shows daily tip, exercise form database, and common mistakes.
class AITipsScreen extends StatelessWidget {
  const AITipsScreen({super.key});

  static const _formTips = [
    {
      'exercise': 'Bicep Curls',
      'icon': Icons.fitness_center,
      'mistakes': [
        {'error': 'Swinging the weight', 'fix': 'Keep elbows pinned to torso. Use controlled 2-second concentric.'},
        {'error': 'Partial range of motion', 'fix': 'Fully extend arms past 140° before curling to below 70°.'},
        {'error': 'Wrist rotation', 'fix': 'Keep wrists neutral throughout. Don\'t curl the wrist at top.'},
      ],
    },
    {
      'exercise': 'Squats',
      'icon': Icons.accessibility_new,
      'mistakes': [
        {'error': 'Knees caving inward', 'fix': 'Push knees outward tracking over toes. Engage glutes.'},
        {'error': 'Forward lean', 'fix': 'Keep chest up and core braced. Look forward, not down.'},
        {'error': 'Heels rising', 'fix': 'Drive through heels. Consider elevating heels if ankle mobility is limited.'},
      ],
    },
    {
      'exercise': 'Pushups',
      'icon': Icons.sports_gymnastics,
      'mistakes': [
        {'error': 'Sagging hips', 'fix': 'Engage core and squeeze glutes. Body should form a straight line.'},
        {'error': 'Flared elbows', 'fix': 'Keep elbows at 45° angle to body, not 90°.'},
        {'error': 'Incomplete range', 'fix': 'Lower chest to within 2 inches of ground. Full extension at top.'},
      ],
    },
    {
      'exercise': 'Deadlifts',
      'icon': Icons.fitness_center,
      'mistakes': [
        {'error': 'Rounded lower back', 'fix': 'Maintain neutral spine. Brace core before lifting.'},
        {'error': 'Bar drifting forward', 'fix': 'Keep bar close to shins. Drag it up your legs.'},
        {'error': 'Jerking the weight', 'fix': 'Remove slack from bar first. Smooth pull from the floor.'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dailyTip = AITipsService.getDailyTip();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('AI Tips & Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily tip card
            SolidGlassCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: AppColors.deepNavy,
              borderColor: AppColors.deepNavy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: AppColors.pureWhite, size: 20),
                      const SizedBox(width: 8),
                      Text('TIP OF THE DAY',
                          style: AppTypography.labelCaps.copyWith(
                              color: AppColors.pureWhite.withOpacity(0.7),
                              letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(dailyTip,
                      style: AppTypography.bodyMd.copyWith(
                          color: AppColors.pureWhite, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form correction database
            Text('FORM CORRECTION GUIDE', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            Text('Common mistakes and how to fix them',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 16),

            ..._formTips.map((exercise) {
              final mistakes =
                  exercise['mistakes'] as List<Map<String, String>>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(exercise['icon'] as IconData,
                                color: AppColors.deepNavy, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(exercise['exercise'] as String,
                              style: AppTypography.headlineSm
                                  .copyWith(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...mistakes.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 12, color: AppColors.errorRed),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(m['error']!,
                                          style: AppTypography.bodySm.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.errorRed)),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 2),
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: AppColors.successGreen
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(Icons.check,
                                                size: 10,
                                                color:
                                                    AppColors.successGreen),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(m['fix']!,
                                                style: AppTypography.bodySm
                                                    .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                        height: 1.4)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
