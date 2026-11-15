import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 2: Onboarding Portal 1 — Skeletal Tracking
///
/// Introduction to real-time skeletal tracking and joint-angle precision.
/// Features a visual of connected landmarks with angle indicators.
class OnboardingSkeletalScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingSkeletalScreen({super.key, required this.onNext});

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
                // ─── Skeleton Visualization ────────────────────
                SizedBox(
                  height: 320,
                  child: CustomPaint(
                    painter: _SkeletonPainter(),
                    size: const Size(280, 320),
                  ),
                ),
                const SizedBox(height: 40),
                // ─── Page Indicator ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(active: true),
                    const SizedBox(width: 8),
                    _dot(active: false),
                    const SizedBox(width: 8),
                    _dot(active: false),
                  ],
                ),
                const SizedBox(height: 40),
                // ─── Content ───────────────────────────────────
                Text(
                  'Skeletal Tracking',
                  style: AppTypography.headlineLg,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Real-time joint-angle precision powered by Google ML Kit. '
                  'We track 33 skeletal landmarks to ensure every rep is '
                  'biomechanically perfect.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.slateGrey,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // ─── Features ──────────────────────────────────
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
                          Icons.visibility_outlined,
                          color: AppColors.deepNavy,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Joint-Angle Precision',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(height: 2),
                            Text(
                              'atan2 coordinate geometry for exact angle measurement',
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
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
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

/// Custom painter for skeleton landmark visualization
class _SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepNavy
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = AppColors.deepNavy
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;

    // Head
    canvas.drawCircle(Offset(cx, 40), 20, paint);

    // Torso
    canvas.drawLine(Offset(cx, 60), Offset(cx, 180), paint);

    // Shoulders
    canvas.drawLine(Offset(cx - 60, 90), Offset(cx + 60, 90), paint);

    // Left arm
    canvas.drawLine(Offset(cx - 60, 90), Offset(cx - 80, 150), paint);
    canvas.drawLine(Offset(cx - 80, 150), Offset(cx - 60, 210), paint);

    // Right arm
    canvas.drawLine(Offset(cx + 60, 90), Offset(cx + 80, 150), paint);
    canvas.drawLine(Offset(cx + 80, 150), Offset(cx + 60, 210), paint);

    // Hips
    canvas.drawLine(Offset(cx - 40, 180), Offset(cx + 40, 180), paint);

    // Left leg
    canvas.drawLine(Offset(cx - 40, 180), Offset(cx - 50, 260), paint);
    canvas.drawLine(Offset(cx - 50, 260), Offset(cx - 40, 310), paint);

    // Right leg
    canvas.drawLine(Offset(cx + 40, 180), Offset(cx + 50, 260), paint);
    canvas.drawLine(Offset(cx + 50, 260), Offset(cx + 40, 310), paint);

    // Joint dots
    final joints = [
      Offset(cx, 40), // head
      Offset(cx - 60, 90), Offset(cx + 60, 90), // shoulders
      Offset(cx - 80, 150), Offset(cx + 80, 150), // elbows
      Offset(cx - 60, 210), Offset(cx + 60, 210), // wrists
      Offset(cx - 40, 180), Offset(cx + 40, 180), // hips
      Offset(cx - 50, 260), Offset(cx + 50, 260), // knees
      Offset(cx - 40, 310), Offset(cx + 40, 310), // ankles
    ];

    for (final joint in joints) {
      canvas.drawCircle(joint, 5, jointPaint);
    }

    // Angle indicator at right elbow
    final anglePaint = Paint()
      ..color = AppColors.warningOrange
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + 80, 150),
        width: 30,
        height: 30,
      ),
      0.5,
      1.8,
      false,
      anglePaint,
    );

    // Angle text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '72°',
        style: AppTypography.metricSm.copyWith(
          color: AppColors.warningOrange,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx + 98, 138));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
