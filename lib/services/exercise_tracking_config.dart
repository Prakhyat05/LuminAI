/// Exercise Tracking Configuration Registry

/// Defines which joints to track, angle thresholds, and form rules
/// for each trackable exercise type.
///
/// ML Kit PoseLandmark indices:
///   0: nose, 11/12: shoulders, 13/14: elbows, 15/16: wrists,
///   23/24: hips, 25/26: knees, 27/28: ankles
enum TrackableExercise {
  bicepCurl,
  pushUp,
  squat,
  lunge,
  shoulderPress,
  plank,
  crunch,
  jumpingJack,
  deadlift,
  lateralRaise,
  tricepDip,
  mountainClimber,
  burpee,
  pullUp,
  bodyweightSquat,
  calfRaise,
  gluteBridge,
}

/// Which phase of a rep the user is in
enum RepPhase { idle, phaseA, phaseB }

/// Joint triplet for angle calculation: angle at joint B formed by A-B-C
class JointTriplet {
  final int a, b, c;
  const JointTriplet(this.a, this.b, this.c);
}

/// Form check: monitors a specific angle or distance for bad form
class FormRule {
  final String id;
  final String warningMessage;
  final String goodMessage;

  /// Type of check
  final FormCheckType checkType;

  /// For angle checks: the joint triplet
  final JointTriplet? jointTriplet;

  /// For distance checks: two landmark indices
  final int? landmarkA;
  final int? landmarkB;

  /// Threshold values
  final double? minAngle;
  final double? maxAngle;
  final double? maxDriftPx;

  const FormRule({
    required this.id,
    required this.warningMessage,
    required this.goodMessage,
    required this.checkType,
    this.jointTriplet,
    this.landmarkA,
    this.landmarkB,
    this.minAngle,
    this.maxAngle,
    this.maxDriftPx,
  });
}

enum FormCheckType { angleBounds, horizontalDrift, verticalAlignment }

/// Full tracking configuration for one exercise
class ExerciseTrackingProfile {
  final TrackableExercise type;
  final String displayName;

  /// Primary joint angle to track for rep counting (left side)
  final JointTriplet primaryJointLeft;

  /// Primary joint angle to track for rep counting (right side)
  final JointTriplet primaryJointRight;

  /// Is this a bilateral exercise (both sides count as 1 rep)?
  final bool bilateral;

  /// Is this a timed hold (plank) vs rep-based?
  final bool isTimedHold;

  /// Phase A threshold (e.g., extended arm > 140°)
  final double phaseAThreshold;

  /// Phase B threshold (e.g., contracted arm < 70°)
  final double phaseBThreshold;

  /// true = rep counts on going FROM phaseA TO phaseB
  /// false = rep counts on going FROM phaseB TO phaseA
  final bool countOnContraction;

  /// Form rules to evaluate each frame
  final List<FormRule> formRules;

  /// Estimated calories burned per rep
  final double caloriesPerRep;

  /// For timed holds: target angle range to be "in position"
  final double? holdMinAngle;
  final double? holdMaxAngle;

  const ExerciseTrackingProfile({
    required this.type,
    required this.displayName,
    required this.primaryJointLeft,
    required this.primaryJointRight,
    this.bilateral = true,
    this.isTimedHold = false,
    required this.phaseAThreshold,
    required this.phaseBThreshold,
    this.countOnContraction = true,
    this.formRules = const [],
    this.caloriesPerRep = 1.0,
    this.holdMinAngle,
    this.holdMaxAngle,
  });
}

/// Master registry of all exercise tracking profiles
class ExerciseTrackingRegistry {
  ExerciseTrackingRegistry._();

  static const _shoulderL = 11, _shoulderR = 12;
  static const _elbowL = 13, _elbowR = 14;
  static const _wristL = 15, _wristR = 16;
  static const _hipL = 23, _hipR = 24;
  static const _kneeL = 25, _kneeR = 26;
  static const _ankleL = 27, _ankleR = 28;
  static const _footL = 31, _footR = 32;

  static final Map<TrackableExercise, ExerciseTrackingProfile> _profiles = {
    // ─── BICEP CURL ────────────────────────────────
    TrackableExercise.bicepCurl: ExerciseTrackingProfile(
      type: TrackableExercise.bicepCurl,
      displayName: 'Bicep Curl',
      primaryJointLeft: const JointTriplet(_shoulderL, _elbowL, _wristL),
      primaryJointRight: const JointTriplet(_shoulderR, _elbowR, _wristR),
      bilateral: false,
      phaseAThreshold: 150.0,
      phaseBThreshold: 50.0,
      caloriesPerRep: 0.8,
      formRules: [
        const FormRule(
          id: 'elbow_drift_l',
          warningMessage: 'Tuck your left elbow closer',
          goodMessage: 'Left elbow position good',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _shoulderL,
          landmarkB: _elbowL,
          maxDriftPx: 40.0,
        ),
        const FormRule(
          id: 'elbow_drift_r',
          warningMessage: 'Tuck your right elbow closer',
          goodMessage: 'Right elbow position good',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _shoulderR,
          landmarkB: _elbowR,
          maxDriftPx: 40.0,
        ),
      ],
    ),

    // ─── PUSH-UP ───────────────────────────────────
    TrackableExercise.pushUp: ExerciseTrackingProfile(
      type: TrackableExercise.pushUp,
      displayName: 'Push-Up',
      primaryJointLeft: const JointTriplet(_shoulderL, _elbowL, _wristL),
      primaryJointRight: const JointTriplet(_shoulderR, _elbowR, _wristR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.0,
      formRules: [
        const FormRule(
          id: 'hip_sag',
          warningMessage: 'Keep your hips up, don\'t sag',
          goodMessage: 'Body alignment is good',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _ankleL),
          minAngle: 160.0,
          maxAngle: 190.0,
        ),
        const FormRule(
          id: 'elbow_flare',
          warningMessage: 'Don\'t flare elbows out wide',
          goodMessage: 'Elbow angle looks great',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _shoulderL,
          landmarkB: _elbowL,
          maxDriftPx: 60.0,
        ),
      ],
    ),

    // ─── SQUAT ─────────────────────────────────────
    TrackableExercise.squat: ExerciseTrackingProfile(
      type: TrackableExercise.squat,
      displayName: 'Squat',
      primaryJointLeft: const JointTriplet(_hipL, _kneeL, _ankleL),
      primaryJointRight: const JointTriplet(_hipR, _kneeR, _ankleR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.5,
      formRules: [
        const FormRule(
          id: 'knee_cave',
          warningMessage: 'Push knees out, don\'t let them cave',
          goodMessage: 'Knee tracking looks great',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _hipL,
          landmarkB: _kneeL,
          maxDriftPx: 50.0,
        ),
        const FormRule(
          id: 'forward_lean',
          warningMessage: 'Keep chest up, too much forward lean',
          goodMessage: 'Torso position is excellent',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _kneeL),
          minAngle: 40.0,
          maxAngle: 100.0,
        ),
      ],
    ),

    // ─── BODYWEIGHT SQUAT (same as squat) ──────────
    TrackableExercise.bodyweightSquat: ExerciseTrackingProfile(
      type: TrackableExercise.bodyweightSquat,
      displayName: 'Bodyweight Squat',
      primaryJointLeft: const JointTriplet(_hipL, _kneeL, _ankleL),
      primaryJointRight: const JointTriplet(_hipR, _kneeR, _ankleR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.2,
      formRules: [
        const FormRule(
          id: 'knee_cave',
          warningMessage: 'Push knees outward',
          goodMessage: 'Knee tracking good',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _hipL,
          landmarkB: _kneeL,
          maxDriftPx: 50.0,
        ),
      ],
    ),

    // ─── LUNGE ─────────────────────────────────────
    TrackableExercise.lunge: ExerciseTrackingProfile(
      type: TrackableExercise.lunge,
      displayName: 'Lunge',
      primaryJointLeft: const JointTriplet(_hipL, _kneeL, _ankleL),
      primaryJointRight: const JointTriplet(_hipR, _kneeR, _ankleR),
      bilateral: false,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.3,
      formRules: [
        const FormRule(
          id: 'torso_lean',
          warningMessage: 'Keep torso upright',
          goodMessage: 'Torso position is great',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _kneeL),
          minAngle: 60.0,
          maxAngle: 110.0,
        ),
      ],
    ),

    // ─── SHOULDER PRESS ────────────────────────────
    TrackableExercise.shoulderPress: ExerciseTrackingProfile(
      type: TrackableExercise.shoulderPress,
      displayName: 'Shoulder Press',
      primaryJointLeft: const JointTriplet(_shoulderL, _elbowL, _wristL),
      primaryJointRight: const JointTriplet(_shoulderR, _elbowR, _wristR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.2,
      formRules: [
        const FormRule(
          id: 'back_arch',
          warningMessage: 'Don\'t arch your lower back',
          goodMessage: 'Spine alignment is good',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _kneeL),
          minAngle: 165.0,
          maxAngle: 195.0,
        ),
      ],
    ),

    // ─── PLANK (timed hold) ────────────────────────
    TrackableExercise.plank: ExerciseTrackingProfile(
      type: TrackableExercise.plank,
      displayName: 'Plank',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _ankleL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _ankleR),
      bilateral: true,
      isTimedHold: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      holdMinAngle: 160.0,
      holdMaxAngle: 190.0,
      caloriesPerRep: 0.0,
      formRules: [
        const FormRule(
          id: 'hip_sag',
          warningMessage: 'Don\'t let your hips sag down',
          goodMessage: 'Hip position is perfect',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _ankleL),
          minAngle: 160.0,
          maxAngle: 190.0,
        ),
        const FormRule(
          id: 'hip_pike',
          warningMessage: 'Lower your hips, don\'t pike up',
          goodMessage: 'Body line is straight',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderR, _hipR, _ankleR),
          minAngle: 160.0,
          maxAngle: 190.0,
        ),
      ],
    ),

    // ─── CRUNCH ────────────────────────────────────
    TrackableExercise.crunch: ExerciseTrackingProfile(
      type: TrackableExercise.crunch,
      displayName: 'Crunch',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _kneeL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _kneeR),
      bilateral: true,
      phaseAThreshold: 150.0,
      phaseBThreshold: 100.0,
      caloriesPerRep: 0.5,
      formRules: [
        const FormRule(
          id: 'neck_pull',
          warningMessage: 'Don\'t pull on your neck',
          goodMessage: 'Head position is neutral',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_elbowL, _shoulderL, _hipL),
          minAngle: 30.0,
          maxAngle: 120.0,
        ),
      ],
    ),

    // ─── LATERAL RAISE ─────────────────────────────
    TrackableExercise.lateralRaise: ExerciseTrackingProfile(
      type: TrackableExercise.lateralRaise,
      displayName: 'Lateral Raise',
      primaryJointLeft: const JointTriplet(_elbowL, _shoulderL, _hipL),
      primaryJointRight: const JointTriplet(_elbowR, _shoulderR, _hipR),
      bilateral: true,
      phaseAThreshold: 30.0,
      phaseBThreshold: 80.0,
      countOnContraction: false,
      caloriesPerRep: 0.6,
      formRules: [
        const FormRule(
          id: 'shrug',
          warningMessage: 'Don\'t shrug your shoulders up',
          goodMessage: 'Shoulder position relaxed',
          checkType: FormCheckType.verticalAlignment,
          landmarkA: _shoulderL,
          landmarkB: _elbowL,
          maxDriftPx: 20.0,
        ),
      ],
    ),

    // ─── TRICEP DIP ────────────────────────────────
    TrackableExercise.tricepDip: ExerciseTrackingProfile(
      type: TrackableExercise.tricepDip,
      displayName: 'Tricep Dip',
      primaryJointLeft: const JointTriplet(_shoulderL, _elbowL, _wristL),
      primaryJointRight: const JointTriplet(_shoulderR, _elbowR, _wristR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 1.0,
      formRules: [
        const FormRule(
          id: 'depth',
          warningMessage: 'Don\'t go too deep, stop at 90 degrees',
          goodMessage: 'Depth is controlled',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _elbowL, _wristL),
          minAngle: 70.0,
          maxAngle: 170.0,
        ),
      ],
    ),

    // ─── DEADLIFT ──────────────────────────────────
    TrackableExercise.deadlift: ExerciseTrackingProfile(
      type: TrackableExercise.deadlift,
      displayName: 'Deadlift',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _kneeL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _kneeR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      countOnContraction: false,
      caloriesPerRep: 2.0,
      formRules: [
        const FormRule(
          id: 'round_back',
          warningMessage: 'Keep your back flat, don\'t round',
          goodMessage: 'Back position is neutral',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _kneeL),
          minAngle: 40.0,
          maxAngle: 180.0,
        ),
      ],
    ),

    // ─── PULL-UP ───────────────────────────────────
    TrackableExercise.pullUp: ExerciseTrackingProfile(
      type: TrackableExercise.pullUp,
      displayName: 'Pull-Up',
      primaryJointLeft: const JointTriplet(_shoulderL, _elbowL, _wristL),
      primaryJointRight: const JointTriplet(_shoulderR, _elbowR, _wristR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 70.0,
      caloriesPerRep: 1.5,
      formRules: [
        const FormRule(
          id: 'kipping',
          warningMessage: 'Avoid swinging, use strict form',
          goodMessage: 'Movement is controlled',
          checkType: FormCheckType.horizontalDrift,
          landmarkA: _shoulderL,
          landmarkB: _hipL,
          maxDriftPx: 45.0,
        ),
      ],
    ),

    // ─── GLUTE BRIDGE ──────────────────────────────
    TrackableExercise.gluteBridge: ExerciseTrackingProfile(
      type: TrackableExercise.gluteBridge,
      displayName: 'Glute Bridge',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _kneeL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _kneeR),
      bilateral: true,
      phaseAThreshold: 140.0,
      phaseBThreshold: 170.0,
      countOnContraction: false,
      caloriesPerRep: 0.8,
      formRules: [
        const FormRule(
          id: 'knee_angle',
          warningMessage: 'Keep knees at 90 degrees',
          goodMessage: 'Knee bend is correct',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_hipL, _kneeL, _ankleL),
          minAngle: 75.0,
          maxAngle: 105.0,
        ),
      ],
    ),

    // ─── CALF RAISE ────────────────────────────────
    TrackableExercise.calfRaise: ExerciseTrackingProfile(
      type: TrackableExercise.calfRaise,
      displayName: 'Calf Raise',
      primaryJointLeft: const JointTriplet(_kneeL, _ankleL, _footL),
      primaryJointRight: const JointTriplet(_kneeR, _ankleR, _footR),
      bilateral: true,
      phaseAThreshold: 130.0,
      phaseBThreshold: 100.0,
      caloriesPerRep: 0.3,
      formRules: [],
    ),

    // ─── MOUNTAIN CLIMBER ──────────────────────────
    TrackableExercise.mountainClimber: ExerciseTrackingProfile(
      type: TrackableExercise.mountainClimber,
      displayName: 'Mountain Climber',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _kneeL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _kneeR),
      bilateral: false,
      phaseAThreshold: 160.0,
      phaseBThreshold: 100.0,
      caloriesPerRep: 0.5,
      formRules: [
        const FormRule(
          id: 'hip_pike',
          warningMessage: 'Keep your hips down',
          goodMessage: 'Body alignment good',
          checkType: FormCheckType.angleBounds,
          jointTriplet: JointTriplet(_shoulderL, _hipL, _ankleL),
          minAngle: 150.0,
          maxAngle: 190.0,
        ),
      ],
    ),

    // ─── BURPEE ────────────────────────────────────
    TrackableExercise.burpee: ExerciseTrackingProfile(
      type: TrackableExercise.burpee,
      displayName: 'Burpee',
      primaryJointLeft: const JointTriplet(_shoulderL, _hipL, _kneeL),
      primaryJointRight: const JointTriplet(_shoulderR, _hipR, _kneeR),
      bilateral: true,
      phaseAThreshold: 160.0,
      phaseBThreshold: 90.0,
      caloriesPerRep: 1.5,
      formRules: [],
    ),

    // ─── JUMPING JACK ──────────────────────────────
    TrackableExercise.jumpingJack: ExerciseTrackingProfile(
      type: TrackableExercise.jumpingJack,
      displayName: 'Jumping Jack',
      primaryJointLeft: const JointTriplet(_hipL, _shoulderL, _elbowL),
      primaryJointRight: const JointTriplet(_hipR, _shoulderR, _elbowR),
      bilateral: true,
      phaseAThreshold: 40.0,
      phaseBThreshold: 120.0,
      caloriesPerRep: 0.8,
      formRules: [],
    ),
  };

  static ExerciseTrackingProfile? getProfile(TrackableExercise type) =>
      _profiles[type];

  static List<TrackableExercise> get allTypes => _profiles.keys.toList();

  /// Map an exercise database ID to a trackable exercise type
  static TrackableExercise? mapExerciseId(String exerciseId) {
    const mapping = {
      'g1': null, // Bench Press (lying down, hard to track)
      'g2': TrackableExercise.squat,
      'g3': TrackableExercise.deadlift,
      'g4': null, // Lat Pulldown (machine)
      'g5': TrackableExercise.shoulderPress,
      'g6': TrackableExercise.bicepCurl,
      'g7': null, // Leg Press (machine)
      'g8': null, // Cable Fly (machine)
      'c1': null, // Running
      'c2': TrackableExercise.jumpingJack,
      'c3': TrackableExercise.burpee,
      'c4': TrackableExercise.mountainClimber,
      'c5': null, // Cycling
      'c6': null, // Rowing
      'f1': null, // Sun Salutation
      'f2': null, // Hip Openers
      'f3': null, // Shoulder Mobility
      'f4': null, // Foam Rolling
      'f5': null, // Hamstring Stretch
      'b1': TrackableExercise.pushUp,
      'b2': TrackableExercise.pullUp,
      'b3': TrackableExercise.bodyweightSquat,
      'b4': TrackableExercise.plank,
      'b5': TrackableExercise.lunge,
      'b6': TrackableExercise.tricepDip,
      'b7': TrackableExercise.crunch,
      'h1': null, // Tabata (circuit)
      'h2': null, // EMOM (circuit)
      'h3': null, // Sprints
      'h4': null, // AMRAP (circuit)
    };
    return mapping[exerciseId];
  }
}
