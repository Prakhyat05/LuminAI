import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminai/services/pose_engine.dart';
import 'package:luminai/services/exercise_tracking_config.dart';

void main() {
  group('PoseEngine Biomechanical Geometry', () {
    test('calculateJointAngle calculates exact 90-degree right angle', () {
      const a = Point<double>(0.0, 100.0);
      const b = Point<double>(0.0, 0.0);
      const c = Point<double>(100.0, 0.0);

      final angle = PoseEngine.calculateJointAngle(a: a, b: b, c: c);
      expect(angle, closeTo(90.0, 0.01));
    });

    test('calculateJointAngle calculates 180-degree straight arm/leg alignment', () {
      const a = Point<double>(0.0, 100.0);
      const b = Point<double>(0.0, 0.0);
      const c = Point<double>(0.0, -100.0);

      final angle = PoseEngine.calculateJointAngle(a: a, b: b, c: c);
      expect(angle, closeTo(180.0, 0.01));
    });

    test('calculateJointAngle calculates 45-degree acute angle', () {
      const a = Point<double>(0.0, 100.0);
      const b = Point<double>(0.0, 0.0);
      const c = Point<double>(100.0, 100.0);

      final angle = PoseEngine.calculateJointAngle(a: a, b: b, c: c);
      expect(angle, closeTo(45.0, 0.01));
    });
  });

  group('PoseEngine State Machine & Rep Counting', () {
    late PoseEngine engine;

    setUp(() {
      engine = PoseEngine();
    });

    test('Initializes with default zero counts and 100% form accuracy', () {
      expect(engine.leftRepCount, equals(0));
      expect(engine.rightRepCount, equals(0));
      expect(engine.totalRepCount, equals(0));
      expect(engine.formAccuracy, equals(100.0));
      expect(engine.activeProfile, isNull);
    });

    test('Setting exercise profile maps correctly', () {
      engine.setExercise(TrackableExercise.bicepCurl);
      expect(engine.activeProfile, isNotNull);
      expect(engine.activeProfile!.type, equals(TrackableExercise.bicepCurl));
      expect(engine.activeProfile!.bilateral, isFalse);
    });

    test('Reset clears counts and frame metrics', () {
      engine.setExercise(TrackableExercise.bicepCurl);
      engine.reset();
      expect(engine.leftRepCount, equals(0));
      expect(engine.rightRepCount, equals(0));
      expect(engine.totalRepCount, equals(0));
      expect(engine.formAccuracy, equals(100.0));
    });

    test('Handles empty landmark points safely without throwing', () {
      engine.setExercise(TrackableExercise.bicepCurl);
      final emptyResult = engine.processFrame([]);
      expect(emptyResult.leftReps, equals(0));
      expect(emptyResult.repThisFrame, isFalse);
      expect(emptyResult.formAccuracy, equals(100.0));
    });
  });
}
