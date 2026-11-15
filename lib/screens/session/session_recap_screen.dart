import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 19: Session Recap — Celebration + validated rep tally
class SessionRecapScreen extends StatelessWidget {
  const SessionRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Celebration icon
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successGreen.withOpacity(0.1)),
                    child: const Icon(Icons.emoji_events_outlined,
                        size: 40, color: AppColors.successGreen)),
                const SizedBox(height: 24),
                Text('Session Complete!', style: AppTypography.headlineLg),
                const SizedBox(height: 8),
                Text('Bicep Curls — 4 Sets',
                    style:
                        AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
                const SizedBox(height: 40),
                // Rep tally
                Row(children: [
                  Expanded(
                      child: SolidGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Text('LEFT ARM', style: AppTypography.labelCaps),
                            const SizedBox(height: 12),
                            Text('24',
                                style: AppTypography.displayMetrics
                                    .copyWith(color: AppColors.deepNavy)),
                            Text('REPS', style: AppTypography.metricUnit),
                          ]))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SolidGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Text('RIGHT ARM', style: AppTypography.labelCaps),
                            const SizedBox(height: 12),
                            Text('22',
                                style: AppTypography.displayMetrics
                                    .copyWith(color: AppColors.deepNavy)),
                            Text('REPS', style: AppTypography.metricUnit),
                          ]))),
                ]),
                const SizedBox(height: 16),
                // Stats
                SolidGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _statRow('Total Validated Reps', '46'),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Perfect Form', '94%'),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Duration', '12:34'),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Calories Burned', '186 kcal'),
                    ])),
                const SizedBox(height: 48),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to Dashboard'))),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/form-accuracy'),
                    child: Text('View Detailed Analytics',
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTypography.metricSm.copyWith(color: AppColors.deepNavy)),
      ]);
}