import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 17: Form Alert Dashboard — Dark Orange floating notifications
class FormAlertScreen extends StatelessWidget {
  const FormAlertScreen({super.key});
  static const _alerts = [
    {'type': 'Elbow Drift', 'msg': 'Right elbow drifting 48px from torso. Tuck your elbow.', 'severity': 'HIGH', 'time': '0:42'},
    {'type': 'Incomplete ROM', 'msg': 'Left arm only reached 82°. Extend past 140° for valid rep.', 'severity': 'MEDIUM', 'time': '0:38'},
    {'type': 'Posture', 'msg': 'Forward lean detected. Keep torso vertical.', 'severity': 'LOW', 'time': '0:25'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Form Alerts'), actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('3 alerts', style: AppTypography.labelCaps.copyWith(color: AppColors.warningOrange))))]),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Text('Active Session Alerts', style: AppTypography.headlineMd),
        const SizedBox(height: 4),
        Text('Real-time form correction notifications', style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 24),
        ..._alerts.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SolidGlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: a['severity'] == 'HIGH' ? AppColors.warningOrange : AppColors.outlineVariant,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a['severity'] == 'HIGH' ? AppColors.warningOrange : a['severity'] == 'MEDIUM' ? AppColors.warningOrange.withOpacity(0.7) : AppColors.textTertiary, borderRadius: BorderRadius.circular(6)),
                child: Text(a['severity']!, style: AppTypography.labelSm.copyWith(color: AppColors.pureWhite, fontWeight: FontWeight.w700, fontSize: 9))),
              const SizedBox(width: 8),
              Text(a['type']!, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700, color: a['severity'] == 'HIGH' ? AppColors.warningOrange : AppColors.textPrimary)),
              const Spacer(),
              Text(a['time']!, style: AppTypography.labelSm),
            ]),
            const SizedBox(height: 8),
            Text(a['msg']!, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ]),
        ))),
      ]),
    );
  }
}
