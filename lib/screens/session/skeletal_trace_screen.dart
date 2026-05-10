import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Screen 16: Skeletal Trace Overlay — Real-time digital skeleton
class SkeletalTraceScreen extends StatelessWidget {
  const SkeletalTraceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Stack(children: [
        // Skeleton overlay
        Center(child: SizedBox(width: 300, height: 500, child: CustomPaint(painter: _LiveSkeletonPainter()))),
        // Joint angle indicators
        SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite), onPressed: () => Navigator.pop(context)),
            Text('SKELETAL TRACE', style: AppTypography.labelCaps.copyWith(color: AppColors.pureWhite)),
            const SizedBox(width: 40),
          ]),
          const Spacer(),
          // Bottom metrics
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.pureWhite.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.pureWhite.withOpacity(0.15))),
            child: Column(children: [
              Text('JOINT ANGLES', style: AppTypography.labelCaps.copyWith(color: AppColors.pureWhite.withOpacity(0.6))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _angleDisplay('L.SHOULDER', '165°', 11),
                _angleDisplay('L.ELBOW', '72°', 13),
                _angleDisplay('L.WRIST', '148°', 15),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _angleDisplay('R.SHOULDER', '162°', 12),
                _angleDisplay('R.ELBOW', '68°', 14),
                _angleDisplay('R.WRIST', '152°', 16),
              ]),
            ])),
        ]))),
      ]),
    );
  }

  Widget _angleDisplay(String label, String angle, int landmark) {
    final isAlert = angle.contains('68') || angle.contains('72');
    return Column(children: [
      Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.pureWhite.withOpacity(0.5), fontSize: 9)),
      const SizedBox(height: 4),
      Text(angle, style: AppTypography.metricSm.copyWith(color: isAlert ? AppColors.warningOrange : AppColors.pureWhite)),
      Text('#$landmark', style: AppTypography.labelSm.copyWith(color: AppColors.pureWhite.withOpacity(0.3), fontSize: 9)),
    ]);
  }
}

class _LiveSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()..color = AppColors.pureWhite.withOpacity(0.8)..strokeWidth = 2..style = PaintingStyle.stroke;
    final jointPaint = Paint()..color = AppColors.pureWhite..style = PaintingStyle.fill;
    final alertPaint = Paint()..color = AppColors.warningOrange..style = PaintingStyle.fill;
    final cx = size.width / 2;
    // Head
    canvas.drawCircle(Offset(cx, 40), 22, bonePaint);
    // Spine
    canvas.drawLine(Offset(cx, 62), Offset(cx, 220), bonePaint);
    // Shoulders
    canvas.drawLine(Offset(cx - 70, 100), Offset(cx + 70, 100), bonePaint);
    // Arms
    canvas.drawLine(Offset(cx - 70, 100), Offset(cx - 90, 170), bonePaint);
    canvas.drawLine(Offset(cx - 90, 170), Offset(cx - 70, 240), bonePaint);
    canvas.drawLine(Offset(cx + 70, 100), Offset(cx + 90, 170), bonePaint);
    canvas.drawLine(Offset(cx + 90, 170), Offset(cx + 70, 240), bonePaint);
    // Hips
    canvas.drawLine(Offset(cx - 50, 220), Offset(cx + 50, 220), bonePaint);
    // Legs
    canvas.drawLine(Offset(cx - 50, 220), Offset(cx - 60, 340), bonePaint);
    canvas.drawLine(Offset(cx - 60, 340), Offset(cx - 50, 440), bonePaint);
    canvas.drawLine(Offset(cx + 50, 220), Offset(cx + 60, 340), bonePaint);
    canvas.drawLine(Offset(cx + 60, 340), Offset(cx + 50, 440), bonePaint);
    // Joints
    final joints = [Offset(cx, 40), Offset(cx - 70, 100), Offset(cx + 70, 100), Offset(cx - 90, 170), Offset(cx + 90, 170), Offset(cx - 70, 240), Offset(cx + 70, 240), Offset(cx - 50, 220), Offset(cx + 50, 220), Offset(cx - 60, 340), Offset(cx + 60, 340), Offset(cx - 50, 440), Offset(cx + 50, 440)];
    for (int i = 0; i < joints.length; i++) {
      final isElbow = i == 3 || i == 4;
      canvas.drawCircle(joints[i], isElbow ? 7 : 5, isElbow ? alertPaint : jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
