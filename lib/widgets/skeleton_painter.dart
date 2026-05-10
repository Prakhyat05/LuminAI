import 'dart:math';
import 'package:flutter/material.dart';
import '../services/pose_engine.dart';
import '../services/exercise_tracking_config.dart';

/// Paints the detected skeleton overlay on top of the camera preview.
/// Draws joints as circles and bones as connecting lines.
/// Color-codes based on form quality alerts.
class SkeletonPainter extends CustomPainter {
  final List<Point<double>> landmarks;
  final Size imageSize;
  final List<FormAlert> alerts;
  final bool isFrontCamera;
  final double formAccuracy;
  final double leftAngle;
  final double rightAngle;
  final ExerciseTrackingProfile? activeProfile;

  SkeletonPainter({
    required this.landmarks,
    required this.imageSize,
    this.alerts = const [],
    this.isFrontCamera = true,
    this.formAccuracy = 100.0,
    this.leftAngle = 0.0,
    this.rightAngle = 0.0,
    this.activeProfile,
  });

  // ML Kit bone connections (pairs of landmark indices)
  static const List<List<int>> _boneConnections = [
    // Face
    [0, 1], [1, 2], [2, 3], [3, 7], [0, 4], [4, 5], [5, 6], [6, 8],
    // Torso
    [11, 12], [11, 23], [12, 24], [23, 24],
    // Left arm
    [11, 13], [13, 15],
    // Right arm
    [12, 14], [14, 16],
    // Left leg
    [23, 25], [25, 27],
    // Right leg
    [24, 26], [26, 28],
  ];

  // Key joint indices to draw as larger dots
  static const Set<int> _keyJoints = {
    11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || landmarks.length < 29) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // Determine skeleton color based on form accuracy
    final Color skeletonColor;
    if (formAccuracy >= 85) {
      skeletonColor = const Color(0xFF00E676); // Green
    } else if (formAccuracy >= 60) {
      skeletonColor = const Color(0xFFFFAB00); // Amber
    } else {
      skeletonColor = const Color(0xFFFF5252); // Red
    }

    final bonePaint = Paint()
      ..color = skeletonColor.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final jointOutlinePaint = Paint()
      ..color = skeletonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final keyJointPaint = Paint()
      ..color = skeletonColor
      ..style = PaintingStyle.fill;

    // Alert joint indices (joints with form issues)
    final alertJoints = <int>{};
    for (final alert in alerts) {
      // Mark commonly problematic joints
      if (alert.type == FormAlertType.elbowDrift) {
        alertJoints.addAll([13, 14]); // elbows
      } else if (alert.type == FormAlertType.poorPosture) {
        alertJoints.addAll([11, 12, 23, 24]); // torso
      }
    }

    final alertPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;

    Offset toScreen(Point<double> pt) {
      double x = pt.x * scaleX;
      double y = pt.y * scaleY;
      if (isFrontCamera) {
        x = size.width - x; // Mirror for front camera
      }
      return Offset(x, y);
    }

    // Check if a landmark is valid (not at origin)
    bool isValid(int idx) {
      if (idx >= landmarks.length) return false;
      final pt = landmarks[idx];
      return pt.x != 0 || pt.y != 0;
    }

    // Draw bones
    for (final bone in _boneConnections) {
      final i = bone[0], j = bone[1];
      if (!isValid(i) || !isValid(j)) continue;

      final p1 = toScreen(landmarks[i]);
      final p2 = toScreen(landmarks[j]);

      // Use alert color if either joint has an issue
      if (alertJoints.contains(i) || alertJoints.contains(j)) {
        canvas.drawLine(
          p1,
          p2,
          bonePaint..color = const Color(0xFFFF5252).withOpacity(0.9),
        );
        bonePaint.color = skeletonColor.withOpacity(0.8);
      } else {
        canvas.drawLine(p1, p2, bonePaint);
      }
    }

    // Draw joints
    for (int i = 0; i < landmarks.length && i < 33; i++) {
      if (!isValid(i)) continue;

      final pos = toScreen(landmarks[i]);
      final isKey = _keyJoints.contains(i);
      final isAlert = alertJoints.contains(i);
      final radius = isKey ? 6.0 : 3.5;

      if (isAlert) {
        // Pulsing red for alert joints
        canvas.drawCircle(pos, radius + 3, alertPaint..color = const Color(0xFFFF5252).withOpacity(0.3));
        canvas.drawCircle(pos, radius, alertPaint..color = const Color(0xFFFF5252));
      } else if (isKey) {
        canvas.drawCircle(pos, radius, keyJointPaint);
        canvas.drawCircle(pos, radius, jointOutlinePaint);
      } else {
        canvas.drawCircle(pos, radius, jointPaint);
      }
    }

    // Draw angles if active profile is available
    if (activeProfile != null) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      void drawAngle(double angle, int jointIndex) {
        if (!isValid(jointIndex)) return;
        final pos = toScreen(landmarks[jointIndex]);
        textPainter.text = TextSpan(
          text: '${angle.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
            ],
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(pos.dx + 10, pos.dy - 10));
      }

      drawAngle(leftAngle, activeProfile!.primaryJointLeft.b);
      drawAngle(rightAngle, activeProfile!.primaryJointRight.b);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) => true;
}
