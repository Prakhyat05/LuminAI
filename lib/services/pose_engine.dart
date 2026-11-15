import 'dart:math';
import 'exercise_tracking_config.dart';

/// Pose Engine — Multi-Exercise Joint Angle Calculation & Rep Validation
///
/// Uses atan2 coordinate geometry to calculate joint angles from
/// ML Kit landmark positions. Supports 15+ exercises with per-exercise
/// angle thresholds, bilateral/unilateral rep counting, form analysis,
/// and accuracy scoring.
class PoseEngine {
  // ─── Active Profile ──────────────────────────────────────
  ExerciseTrackingProfile? _activeProfile;
  ExerciseTrackingProfile? get activeProfile => _activeProfile;

  // ─── Rep State ─────────────────────────────────────────────
  int _leftRepCount = 0;
  int _rightRepCount = 0;
  RepPhase _leftPhase = RepPhase.idle;
  RepPhase _rightPhase = RepPhase.idle;

  // ─── Form Tracking ────────────────────────────────────────
  int _totalFrames = 0;
  int _goodFormFrames = 0;
  double _currentLeftAngle = 0.0;
  double _currentRightAngle = 0.0;
  int _lastLeftRepFrame = 0;
  int _lastRightRepFrame = 0;

  // Track form violations during rep movement
  bool _leftFormViolatedDuringRep = false;
  bool _rightFormViolatedDuringRep = false;
  bool _leftWasInRepMovement = false;
  bool _rightWasInRepMovement = false;

  static const int _debounceFrames = 12; // ~400ms at 30fps
  static const double _hysteresis = 5.0; // 5 degrees of margin

  // ─── Smoothing (average last N angles to reduce noise) ────
  final List<double> _leftAngleBuffer = [];
  final List<double> _rightAngleBuffer = [];
  static const int _smoothingWindow = 5;

  // ─── Hold Tracking (plank, etc.) ──────────────────────────
  int _holdFramesInPosition = 0;
  bool _isInHoldPosition = false;

  // ─── Getters ──────────────────────────────────────────────
  int get leftRepCount => _leftRepCount;
  int get rightRepCount => _rightRepCount;
  double get currentLeftAngle => _currentLeftAngle;
  double get currentRightAngle => _currentRightAngle;
  bool get isInHoldPosition => _isInHoldPosition;
  double get holdSeconds => _holdFramesInPosition / 30.0;

  int get totalRepCount {
    if (_activeProfile == null) return 0;
    if (_activeProfile!.bilateral) {
      // For bilateral: use max of left/right (they should be similar)
      return max(_leftRepCount, _rightRepCount);
    }
    return _leftRepCount + _rightRepCount;
  }

  /// Form accuracy percentage (0.0 to 100.0)
  double get formAccuracy {
    if (_totalFrames == 0) return 100.0;
    return (_goodFormFrames / _totalFrames * 100.0).clamp(0.0, 100.0);
  }

  /// Calculate the angle at joint B formed by segments A→B and B→C.
  ///
  /// Uses atan2 for accurate quadrant-aware angle calculation.
  /// Returns the angle in degrees (0–180).
  static double calculateJointAngle({
    required Point<double> a,
    required Point<double> b,
    required Point<double> c,
  }) {
    final double baX = a.x - b.x;
    final double baY = a.y - b.y;
    final double bcX = c.x - b.x;
    final double bcY = c.y - b.y;

    final double angleBA = atan2(baY, baX);
    final double angleBC = atan2(bcY, bcX);

    double angle = (angleBA - angleBC).abs();
    if (angle > pi) angle = 2 * pi - angle;

    return angle * 180.0 / pi;
  }

  /// Smooth an angle value using a running average buffer
  double _smoothAngle(List<double> buffer, double rawAngle) {
    buffer.add(rawAngle);
    if (buffer.length > _smoothingWindow) {
      buffer.removeAt(0);
    }
    return buffer.reduce((a, b) => a + b) / buffer.length;
  }

  /// Set the active exercise profile for tracking
  void setExercise(TrackableExercise type) {
    _activeProfile = ExerciseTrackingRegistry.getProfile(type);
    reset();
  }

  /// Set the active exercise profile directly
  void setProfile(ExerciseTrackingProfile profile) {
    _activeProfile = profile;
    reset();
  }

  /// Process a new frame of pose landmarks and check for valid reps.
  FrameResult processFrame(List<Point<double>> landmarks) {
    if (_activeProfile == null) {
      return FrameResult.empty();
    }

    final profile = _activeProfile!;
    bool repThisFrame = false;
    List<FormAlert> alerts = [];

    if (landmarks.length > 28) {
      _totalFrames++;

      bool isPointValid(Point<double> p) => p.x != 0 || p.y != 0;
      bool leftValid = isPointValid(landmarks[profile.primaryJointLeft.a]) &&
          isPointValid(landmarks[profile.primaryJointLeft.b]) &&
          isPointValid(landmarks[profile.primaryJointLeft.c]);
      bool rightValid = isPointValid(landmarks[profile.primaryJointRight.a]) &&
          isPointValid(landmarks[profile.primaryJointRight.b]) &&
          isPointValid(landmarks[profile.primaryJointRight.c]);

      // ── Calculate primary joint angles ──
      if (leftValid) {
        final rawLeftAngle = calculateJointAngle(
          a: landmarks[profile.primaryJointLeft.a],
          b: landmarks[profile.primaryJointLeft.b],
          c: landmarks[profile.primaryJointLeft.c],
        );
        _currentLeftAngle = _smoothAngle(_leftAngleBuffer, rawLeftAngle);
      }
      
      if (rightValid) {
        final rawRightAngle = calculateJointAngle(
          a: landmarks[profile.primaryJointRight.a],
          b: landmarks[profile.primaryJointRight.b],
          c: landmarks[profile.primaryJointRight.c],
        );
        _currentRightAngle = _smoothAngle(_rightAngleBuffer, rawRightAngle);
      }

      // ── Timed Hold Mode (Plank, etc.) ──
      if (profile.isTimedHold) {
        final avgAngle = (_currentLeftAngle + _currentRightAngle) / 2;
        final inPosition = profile.holdMinAngle != null &&
            profile.holdMaxAngle != null &&
            avgAngle >= profile.holdMinAngle! &&
            avgAngle <= profile.holdMaxAngle!;

        _isInHoldPosition = inPosition;
        if (inPosition) {
          _holdFramesInPosition++;
        }
      } else {
        // ── Rep-based Counting ──
        repThisFrame = _processRepCounting(profile);
      }

      // ── Form Evaluation ──
      alerts = _evaluateForm(landmarks, profile);

      // Track form violations during rep movement
      if (alerts.isNotEmpty) {
        if (_leftWasInRepMovement) _leftFormViolatedDuringRep = true;
        if (_rightWasInRepMovement) _rightFormViolatedDuringRep = true;
      }

      if (alerts.isEmpty) {
        _goodFormFrames++;
      }
    }

    return FrameResult(
      leftReps: _leftRepCount,
      rightReps: _rightRepCount,
      totalReps: totalRepCount,
      repThisFrame: repThisFrame,
      leftAngle: _currentLeftAngle,
      rightAngle: _currentRightAngle,
      formAccuracy: formAccuracy,
      alerts: alerts,
      isInHoldPosition: _isInHoldPosition,
      holdFrames: _holdFramesInPosition,
    );
  }

  /// Process rep counting using phase-state-machine logic
  bool _processRepCounting(ExerciseTrackingProfile profile) {
    bool repThisFrame = false;

    if (profile.countOnContraction) {
      // Rep on: extended → contracted (e.g., bicep curl down → up)
      // Left
      if (_currentLeftAngle > profile.phaseAThreshold + _hysteresis) {
        _leftPhase = RepPhase.phaseA;
        _leftWasInRepMovement = true;
      }
      if (_leftPhase == RepPhase.phaseA &&
          _currentLeftAngle < profile.phaseBThreshold - _hysteresis) {
        if (_totalFrames - _lastLeftRepFrame > _debounceFrames) {
          // Only count rep if form was good during the movement
          if (!_leftFormViolatedDuringRep) {
            _leftRepCount++;
            repThisFrame = true;
          }
          _leftPhase = RepPhase.idle;
          _leftFormViolatedDuringRep = false;
          _leftWasInRepMovement = false;
          _lastLeftRepFrame = _totalFrames;
        }
      }
      // Right
      if (_currentRightAngle > profile.phaseAThreshold + _hysteresis) {
        _rightPhase = RepPhase.phaseA;
        _rightWasInRepMovement = true;
      }
      if (_rightPhase == RepPhase.phaseA &&
          _currentRightAngle < profile.phaseBThreshold - _hysteresis) {
        if (_totalFrames - _lastRightRepFrame > _debounceFrames) {
          // Only count rep if form was good during the movement
          if (!_rightFormViolatedDuringRep) {
            _rightRepCount++;
            repThisFrame = true;
          }
          _rightPhase = RepPhase.idle;
          _rightFormViolatedDuringRep = false;
          _rightWasInRepMovement = false;
          _lastRightRepFrame = _totalFrames;
        }
      }
    } else {
      // Rep on: contracted → extended (e.g., squat down → up)
      // Left
      if (_currentLeftAngle < profile.phaseBThreshold - _hysteresis) {
        _leftPhase = RepPhase.phaseB;
        _leftWasInRepMovement = true;
      }
      if (_leftPhase == RepPhase.phaseB &&
          _currentLeftAngle > profile.phaseAThreshold + _hysteresis) {
        if (_totalFrames - _lastLeftRepFrame > _debounceFrames) {
          if (!_leftFormViolatedDuringRep) {
            _leftRepCount++;
            repThisFrame = true;
          }
          _leftPhase = RepPhase.idle;
          _leftFormViolatedDuringRep = false;
          _leftWasInRepMovement = false;
          _lastLeftRepFrame = _totalFrames;
        }
      }
      // Right
      if (_currentRightAngle < profile.phaseBThreshold - _hysteresis) {
        _rightPhase = RepPhase.phaseB;
        _rightWasInRepMovement = true;
      }
      if (_rightPhase == RepPhase.phaseB &&
          _currentRightAngle > profile.phaseAThreshold + _hysteresis) {
        if (_totalFrames - _lastRightRepFrame > _debounceFrames) {
          if (!_rightFormViolatedDuringRep) {
            _rightRepCount++;
            repThisFrame = true;
          }
          _rightPhase = RepPhase.idle;
          _rightFormViolatedDuringRep = false;
          _rightWasInRepMovement = false;
          _lastRightRepFrame = _totalFrames;
        }
      }
    }

    return repThisFrame;
  }

  /// Evaluate all form rules for the current frame
  List<FormAlert> _evaluateForm(
      List<Point<double>> landmarks, ExerciseTrackingProfile profile) {
    final alerts = <FormAlert>[];

    for (final rule in profile.formRules) {
      switch (rule.checkType) {
        case FormCheckType.angleBounds:
          if (rule.jointTriplet != null) {
            final angle = calculateJointAngle(
              a: landmarks[rule.jointTriplet!.a],
              b: landmarks[rule.jointTriplet!.b],
              c: landmarks[rule.jointTriplet!.c],
            );
            if ((rule.minAngle != null && angle < rule.minAngle!) ||
                (rule.maxAngle != null && angle > rule.maxAngle!)) {
              alerts.add(FormAlert(
                type: FormAlertType.poorPosture,
                message: rule.warningMessage,
                severity: AlertSeverity.medium,
                ruleId: rule.id,
              ));
            }
          }
          break;

        case FormCheckType.horizontalDrift:
          if (rule.landmarkA != null && rule.landmarkB != null) {
            final drift = (landmarks[rule.landmarkB!].x -
                    landmarks[rule.landmarkA!].x)
                .abs();
            if (rule.maxDriftPx != null && drift > rule.maxDriftPx!) {
              alerts.add(FormAlert(
                type: FormAlertType.elbowDrift,
                message: rule.warningMessage,
                severity: drift > rule.maxDriftPx! * 1.5
                    ? AlertSeverity.high
                    : AlertSeverity.medium,
                ruleId: rule.id,
              ));
            }
          }
          break;

        case FormCheckType.verticalAlignment:
          if (rule.landmarkA != null && rule.landmarkB != null) {
            final drift = (landmarks[rule.landmarkB!].y -
                    landmarks[rule.landmarkA!].y)
                .abs();
            if (rule.maxDriftPx != null && drift > rule.maxDriftPx!) {
              alerts.add(FormAlert(
                type: FormAlertType.poorPosture,
                message: rule.warningMessage,
                severity: AlertSeverity.medium,
                ruleId: rule.id,
              ));
            }
          }
          break;
      }
    }

    return alerts;
  }

  /// Reset all counters for a new exercise set
  void reset() {
    _leftRepCount = 0;
    _rightRepCount = 0;
    _leftPhase = RepPhase.idle;
    _rightPhase = RepPhase.idle;
    _totalFrames = 0;
    _goodFormFrames = 0;
    _currentLeftAngle = 0.0;
    _currentRightAngle = 0.0;
    _leftAngleBuffer.clear();
    _rightAngleBuffer.clear();
    _holdFramesInPosition = 0;
    _isInHoldPosition = false;
    _lastLeftRepFrame = 0;
    _lastRightRepFrame = 0;
    _leftFormViolatedDuringRep = false;
    _rightFormViolatedDuringRep = false;
    _leftWasInRepMovement = false;
    _rightWasInRepMovement = false;
  }
}

/// Result of processing a single frame
class FrameResult {
  final int leftReps;
  final int rightReps;
  final int totalReps;
  final bool repThisFrame;
  final double leftAngle;
  final double rightAngle;
  final double formAccuracy;
  final List<FormAlert> alerts;
  final bool isInHoldPosition;
  final int holdFrames;
  double get holdSeconds => holdFrames / 30.0;

  const FrameResult({
    required this.leftReps,
    required this.rightReps,
    required this.totalReps,
    required this.repThisFrame,
    required this.leftAngle,
    required this.rightAngle,
    required this.formAccuracy,
    required this.alerts,
    required this.isInHoldPosition,
    required this.holdFrames,
  });

  factory FrameResult.empty() => const FrameResult(
        leftReps: 0,
        rightReps: 0,
        totalReps: 0,
        repThisFrame: false,
        leftAngle: 0,
        rightAngle: 0,
        formAccuracy: 100.0,
        alerts: [],
        isInHoldPosition: false,
        holdFrames: 0,
      );

  bool get hasAlerts => alerts.isNotEmpty;
  String get primaryAlert => alerts.isNotEmpty ? alerts.first.message : '';
}

/// Form quality alert
class FormAlert {
  final FormAlertType type;
  final String message;
  final AlertSeverity severity;
  final String ruleId;

  const FormAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.ruleId,
  });
}

enum FormAlertType {
  elbowDrift,
  poorPosture,
  incompleteRange,
}

enum AlertSeverity {
  low,
  medium,
  high,
}
