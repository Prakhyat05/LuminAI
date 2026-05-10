import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 18: Mid-Session Controls — Voice volume + rest timers
class MidSessionControlsScreen extends StatefulWidget {
  const MidSessionControlsScreen({super.key});
  @override
  State<MidSessionControlsScreen> createState() => _MidSessionControlsScreenState();
}

class _MidSessionControlsScreenState extends State<MidSessionControlsScreen> {
  double _voiceVolume = 0.8;
  int _restSeconds = 60;
  bool _voiceEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Session Controls')),
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
                      Text('Controls', style: AppTypography.headlineLg),
                      const SizedBox(height: 32),
                      // Voice coach
                      SolidGlassCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('VOICE COACH', style: AppTypography.labelCaps),
                          Switch(value: _voiceEnabled, onChanged: (v) => setState(() => _voiceEnabled = v)),
                        ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Icon(Icons.volume_down, color: AppColors.textTertiary, size: 20),
                          Expanded(child: Slider(value: _voiceVolume, onChanged: _voiceEnabled ? (v) => setState(() => _voiceVolume = v) : null, activeColor: AppColors.deepNavy, inactiveColor: AppColors.progressTrack)),
                          const Icon(Icons.volume_up, color: AppColors.deepNavy, size: 20),
                        ]),
                        Center(child: Text('${(_voiceVolume * 100).toInt()}%', style: AppTypography.metricSm)),
                      ])),
                      const SizedBox(height: 16),
                      // Rest timer
                      SolidGlassCard(padding: const EdgeInsets.all(20), child: Column(children: [
                        Text('REST INTERVAL', style: AppTypography.labelCaps),
                        const SizedBox(height: 20),
                        Text('$_restSeconds', style: AppTypography.displayMetrics),
                        Text('SECONDS', style: AppTypography.metricUnit),
                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [30, 45, 60, 90, 120].map((s) {
                          final active = s == _restSeconds;
                          return GestureDetector(onTap: () => setState(() => _restSeconds = s),
                            child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 48, height: 40, decoration: BoxDecoration(color: active ? AppColors.deepNavy : Colors.transparent, border: Border.all(color: active ? AppColors.deepNavy : AppColors.outlineVariant), borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text('${s}s', style: AppTypography.labelSm.copyWith(color: active ? AppColors.pureWhite : AppColors.textSecondary, fontWeight: FontWeight.w600)))));
                        }).toList()),
                      ])),
                      const Spacer(),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Resume'))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/session-recap'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed), child: const Text('End Session'))),
                      ]),
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
}
