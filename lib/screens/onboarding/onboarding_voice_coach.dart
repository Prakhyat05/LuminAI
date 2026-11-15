import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 3: Onboarding Portal 2 — AI Voice Coach
///
/// Overview of the asynchronous voice coach and real-time form correction.
class OnboardingVoiceCoachScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingVoiceCoachScreen({super.key, required this.onNext});

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
                // ─── Voice Waveform Visual ─────────────────────
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.deepNavy.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepNavy.withOpacity(0.06),
                      ),
                      child: const Icon(
                        Icons.mic_none_rounded,
                        size: 48,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sound wave bars
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(20, (i) {
                      final heights = [
                        12.0, 20.0, 30.0, 45.0, 35.0, 50.0, 40.0, 25.0, 38.0,
                        55.0,
                        48.0, 32.0, 42.0, 28.0, 52.0, 36.0, 22.0, 44.0, 30.0,
                        18.0,
                      ];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 3,
                        height: heights[i],
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withOpacity(0.3 + (i % 3) * 0.2),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 40),

                // ─── Page Indicator ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(active: false),
                    const SizedBox(width: 8),
                    _dot(active: true),
                    const SizedBox(width: 8),
                    _dot(active: false),
                  ],
                ),
                const SizedBox(height: 40),

                // ─── Content ───────────────────────────────────
                Text(
                  'AI Voice Coach',
                  style: AppTypography.headlineLg,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Asynchronous voice engine provides real-time rep counting '
                  'and form correction cues without interrupting your flow. '
                  '4-second intelligent cooldowns prevent audio clutter.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.slateGrey,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ─── Feature Cards ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SolidGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.repeat_rounded,
                                color: AppColors.deepNavy, size: 24),
                            const SizedBox(height: 8),
                            Text('Rep Counting',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(height: 4),
                            Text(
                              '"Rep 5... Rep 6..."',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SolidGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.warningOrange, size: 24),
                            const SizedBox(height: 8),
                            Text('Form Alerts',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(height: 4),
                            Text(
                              '"Tuck your elbow"',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/auth'),
                  child: Text(
                    'Skip Onboarding',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textTertiary,
                    ),
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
