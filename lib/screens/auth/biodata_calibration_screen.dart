import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';

/// Screen 7: Bio-Data Calibration
class BiodataCalibrationScreen extends StatefulWidget {
  const BiodataCalibrationScreen({super.key});
  @override
  State<BiodataCalibrationScreen> createState() =>
      _BiodataCalibrationScreenState();
}

class _BiodataCalibrationScreenState extends State<BiodataCalibrationScreen> {
  double _weightKg = 70.0;
  double _heightCm = 170.0;
  final _auth = AuthService();

  Future<void> _continue() async {
    await _auth.updateProfile(weightKg: _weightKg, heightCm: _heightCm);
    if (mounted) Navigator.pushNamed(context, '/community-setup');
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Bio-Data Calibration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STEP 2 OF 4', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            const LinearProgressIndicator(
                value: 0.5,
                backgroundColor: AppColors.progressTrack,
                valueColor: AlwaysStoppedAnimation(AppColors.deepNavy),
                minHeight: 4),
            const SizedBox(height: 32),
            Text('Calibrate Your Body', style: AppTypography.headlineLg),
            const SizedBox(height: 8),
            Text('Weight and height optimize center-of-mass detection.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
            const SizedBox(height: 32),
            _metricCard(
                'WEIGHT',
                _weightKg.toStringAsFixed(1),
                'KG',
                Icons.monitor_weight_outlined,
                Slider(
                    value: _weightKg,
                    min: 30,
                    max: 200,
                    divisions: 340,
                    activeColor: AppColors.deepNavy,
                    inactiveColor: AppColors.progressTrack,
                    onChanged: (v) => setState(() => _weightKg = v))),
            const SizedBox(height: 16),
            _metricCard(
                'HEIGHT',
                _heightCm.toStringAsFixed(0),
                'CM',
                Icons.height_outlined,
                Slider(
                    value: _heightCm,
                    min: 100,
                    max: 230,
                    divisions: 130,
                    activeColor: AppColors.deepNavy,
                    inactiveColor: AppColors.progressTrack,
                    onChanged: (v) => setState(() => _heightCm = v))),
            const SizedBox(height: 24),
            SolidGlassCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.deepNavy.withOpacity(0.04),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: AppColors.deepNavy, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'BMI: ${bmi.toStringAsFixed(1)} — Calibrates center-of-mass algorithms.',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.deepNavy))),
              ]),
            ),
            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _continue, child: const Text('Continue'))),
          ]),
        ),
      ),
    );
  }

  Widget _metricCard(
      String label, String value, String unit, IconData icon, Widget slider) {
    return SolidGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: AppTypography.labelCaps),
          Icon(icon, color: AppColors.textTertiary, size: 20),
        ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.displayMetrics),
              const SizedBox(width: 8),
              Text(unit, style: AppTypography.metricUnit),
            ]),
        const SizedBox(height: 16),
        slider,
      ]),
    );
  }
}
