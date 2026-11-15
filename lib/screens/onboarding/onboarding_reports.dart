import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 4: Onboarding Portal 3 — Performance Reports
///
/// Preview of institutional progress tracking and ATS-friendly performance reports.
class OnboardingReportsScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingReportsScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 400 ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // ─── Branding ──────────────────────────────────
                Image.asset(
                  'assets/LuminAI.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                // ─── Report Preview Visual ─────────────────────
                SolidGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PERFORMANCE REPORT',
                              style: AppTypography.labelCaps),
                          const Icon(Icons.download_outlined,
                              size: 20, color: AppColors.textTertiary),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Mini bar chart
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _miniBar(0.4, 'W1'),
                          _miniBar(0.6, 'W2'),
                          _miniBar(0.75, 'W3'),
                          _miniBar(0.9, 'W4'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statItem('Total Reps', '1,248'),
                          _statItem('Avg Form', '94%'),
                          _statItem('Sessions', '28'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ─── Page Indicator ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(active: false),
                    const SizedBox(width: 8),
                    _dot(active: false),
                    const SizedBox(width: 8),
                    _dot(active: true),
                  ],
                ),
                const SizedBox(height: 40),

                // ─── Content ───────────────────────────────────
                Text(
                  'Progress Tracking',
                  style: AppTypography.headlineLg,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Institutional-grade performance reports and ATS-friendly '
                  'analytics. Track strength volume, rep-speed trends, and '
                  'form accuracy over 30-day periods.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.slateGrey,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ─── Feature highlights ────────────────────────
                SolidGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: AppColors.deepNavy,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Faculty Review Ready',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(height: 2),
                            Text(
                              'Share progress with mentors and project guides',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ─── Button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Get Started'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBar(double fraction, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 80 * fraction,
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textTertiary,
            )),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.metricSm.copyWith(
              color: AppColors.deepNavy,
            )),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSm),
      ],
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.deepNavy : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
