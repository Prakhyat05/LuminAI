import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Screen 15: Active AI HUD — Full-screen camera with glassmorphism overlays
class ActiveAiHudScreen extends StatelessWidget {
  const ActiveAiHudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Stack(children: [
        // Camera placeholder (full screen)
        Container(color: AppColors.deepNavy.withOpacity(0.85)),
        // Top overlay
        SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          // Top bar - glass
          ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: AppColors.pureWhite.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.glassStroke)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('BICEP CURLS', style: AppTypography.labelCaps.copyWith(color: AppColors.pureWhite)),
                Text('SET 2 / 4', style: AppTypography.labelCaps.copyWith(color: AppColors.pureWhite.withOpacity(0.7))),
              ])))),
          const Spacer(),
          // Bottom overlay
          ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.pureWhite.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.glassStroke)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _metricCol('LEFT', '6', 'reps'),
                  Container(width: 1, height: 40, color: AppColors.pureWhite.withOpacity(0.2)),
                  _metricCol('RIGHT', '5', 'reps'),
                  Container(width: 1, height: 40, color: AppColors.pureWhite.withOpacity(0.2)),
                  _metricCol('FORM', '94', '%'),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/mid-session'), style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.pureWhite.withOpacity(0.3)), foregroundColor: AppColors.pureWhite), child: const Text('Controls'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/session-recap'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.pureWhite, foregroundColor: AppColors.deepNavy), child: const Text('End Set'))),
                ]),
              ])))),
        ]))),
        // Center rep counter
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('11', style: AppTypography.displayMetrics.copyWith(color: AppColors.pureWhite, fontSize: 96)),
          Text('TOTAL REPS', style: AppTypography.metricUnit.copyWith(color: AppColors.pureWhite.withOpacity(0.6))),
        ])),
      ]),
    );
  }

  Widget _metricCol(String label, String value, String unit) {
    return Column(children: [
      Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.pureWhite.withOpacity(0.6), fontSize: 10)),
      const SizedBox(height: 4),
      Text(value, style: AppTypography.metricMd.copyWith(color: AppColors.pureWhite)),
      Text(unit, style: AppTypography.labelSm.copyWith(color: AppColors.pureWhite.withOpacity(0.5))),
    ]);
  }
}
