import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 14: Environment Calibration — Pre-workout diagnostic
class EnvironmentCalibrationScreen extends StatefulWidget {
  const EnvironmentCalibrationScreen({super.key});
  @override
  State<EnvironmentCalibrationScreen> createState() =>
      _EnvironmentCalibrationScreenState();
}

class _EnvironmentCalibrationScreenState
    extends State<EnvironmentCalibrationScreen> {
  bool _lightingOk = false, _distanceOk = false, _cameraOk = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _lightingOk = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _distanceOk = true);
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _cameraOk = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allOk = _lightingOk && _distanceOk && _cameraOk;
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Environment Check')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pre-Workout Diagnostic', style: AppTypography.headlineLg),
                      const SizedBox(height: 8),
                      Text('Optimizing Google ML Kit landmarker detection...',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
                      const SizedBox(height: 40),
                      _checkItem(Icons.light_mode_outlined, 'Lighting Conditions',
                          'Adequate ambient light detected', _lightingOk),
                      const SizedBox(height: 16),
                      _checkItem(Icons.straighten_outlined, 'Camera Distance',
                          'Optimal range: 1.5m – 3m', _distanceOk),
                      const SizedBox(height: 16),
                      _checkItem(Icons.camera_outlined, 'Camera Ready',
                          'Front camera initialized', _cameraOk),
                      const Spacer(),
                      if (allOk) ...[
                        SolidGlassCard(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: AppColors.successGreen.withOpacity(0.08),
                            child: Row(children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.successGreen, size: 20),
                              const SizedBox(width: 12),
                              Text('All checks passed. Ready to train.',
                                  style: AppTypography.bodySm.copyWith(
                                      color: AppColors.successGreen,
                                      fontWeight: FontWeight.w600))
                            ])),
                        const SizedBox(height: 24),
                      ],
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: allOk
                                  ? () => Navigator.pushNamed(context, '/active-hud')
                                  : null,
                              child: const Text('Start Session'))),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _checkItem(IconData icon, String title, String sub, bool ok) {
    return SolidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: ok
                      ? AppColors.successGreen.withOpacity(0.1)
                      : AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12)),
              child: ok
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.successGreen, size: 22)
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.deepNavy))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(sub, style: AppTypography.labelSm),
              ])),
        ]));
  }
}
