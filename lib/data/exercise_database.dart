import 'package:flutter/material.dart';
import '../models/exercise.dart';

/// Master exercise database with 40+ exercises across all categories.
class ExerciseDatabase {
  ExerciseDatabase._();

  static const _tips = [
    'Keep core engaged',
    'Control the eccentric phase',
    'Breathe out on exertion'
  ];

  static final List<Exercise> all = [
    // ─── GYM ────────────────────────────────────────────────
    const Exercise(
        id: 'g1',
        name: 'Barbell Bench Press',
        category: WorkoutCategory.gym,
        muscleGroup: 'Chest',
        difficulty: Difficulty.intermediate,
        description: 'Compound chest press on a flat bench with barbell.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Lie flat on bench',
          'Grip barbell shoulder-width',
          'Lower to chest',
          'Press up explosively'
        ],
        aiFormTips: [
          'Keep shoulders retracted',
          'Feet flat on floor',
          'Avoid flaring elbows past 45°'
        ],
        estimatedCalories: 80,
        durationMinutes: 15),
    const Exercise(
        id: 'g2',
        name: 'Barbell Squat',
        category: WorkoutCategory.gym,
        muscleGroup: 'Legs',
        difficulty: Difficulty.intermediate,
        description: 'King of leg exercises. Full-depth barbell back squat.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Bar on upper traps',
          'Feet shoulder-width',
          'Break at hips and knees',
          'Descend to parallel',
          'Drive up through heels'
        ],
        aiFormTips: [
          'Knees track over toes',
          'Keep chest up',
          'Avoid butt wink at bottom'
        ],
        estimatedCalories: 100,
        durationMinutes: 20),
    const Exercise(
        id: 'g3',
        name: 'Deadlift',
        category: WorkoutCategory.gym,
        muscleGroup: 'Back',
        difficulty: Difficulty.advanced,
        description: 'Posterior chain compound lift from floor.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Stand over bar mid-foot',
          'Hip hinge to grip bar',
          'Flatten back',
          'Drive hips forward',
          'Lock out at top'
        ],
        aiFormTips: [
          'Neutral spine throughout',
          'Bar stays close to body',
          'Engage lats before pull'
        ],
        estimatedCalories: 110,
        durationMinutes: 20),
    const Exercise(
        id: 'g4',
        name: 'Lat Pulldown',
        category: WorkoutCategory.gym,
        muscleGroup: 'Back',
        difficulty: Difficulty.beginner,
        description: 'Cable machine pulldown targeting lats.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Grip bar wide',
          'Lean back slightly',
          'Pull to upper chest',
          'Squeeze shoulder blades',
          'Control return'
        ],
        aiFormTips: [
          'Avoid pulling behind neck',
          'Initiate with lats not biceps',
          ..._tips
        ],
        estimatedCalories: 60,
        durationMinutes: 12),
    const Exercise(
        id: 'g5',
        name: 'Shoulder Press',
        category: WorkoutCategory.gym,
        muscleGroup: 'Shoulders',
        difficulty: Difficulty.intermediate,
        description: 'Overhead pressing with dumbbells or barbell.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Start at shoulder height',
          'Press overhead',
          'Lock out arms',
          'Lower with control'
        ],
        aiFormTips: [
          'Avoid arching lower back',
          'Keep core braced',
          'Full range of motion'
        ],
        estimatedCalories: 70,
        durationMinutes: 12),
    const Exercise(
        id: 'g6',
        name: 'Bicep Curls',
        category: WorkoutCategory.gym,
        muscleGroup: 'Arms',
        difficulty: Difficulty.beginner,
        description: 'Isolation curl for bicep development.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Stand with dumbbells',
          'Curl to shoulder',
          'Squeeze at top',
          'Lower slowly'
        ],
        aiFormTips: [
          'Tuck elbows to torso',
          'No swinging momentum',
          'Extend past 140° for valid rep'
        ],
        estimatedCalories: 40,
        durationMinutes: 10),
    const Exercise(
        id: 'g7',
        name: 'Leg Press',
        category: WorkoutCategory.gym,
        muscleGroup: 'Legs',
        difficulty: Difficulty.beginner,
        description: 'Machine-based quad and glute press.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Sit in machine',
          'Feet shoulder-width on platform',
          'Lower weight',
          'Press through heels'
        ],
        aiFormTips: [
          'Dont lock out knees',
          'Keep lower back on pad',
          'Full depth without butt lift'
        ],
        estimatedCalories: 80,
        durationMinutes: 15),
    const Exercise(
        id: 'g8',
        name: 'Cable Fly',
        category: WorkoutCategory.gym,
        muscleGroup: 'Chest',
        difficulty: Difficulty.intermediate,
        description: 'Cable crossover for chest isolation.',
        icon: Icons.fitness_center,
        requiresEquipment: true,
        steps: [
          'Stand between cables',
          'Arms slightly bent',
          'Bring hands together',
          'Squeeze chest',
          'Return slowly'
        ],
        aiFormTips: [
          'Maintain slight elbow bend',
          'Control the negative',
          'Focus on chest squeeze'
        ],
        estimatedCalories: 50,
        durationMinutes: 10),

    // ─── CARDIO ─────────────────────────────────────────────
    const Exercise(
        id: 'c1',
        name: 'Running',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.beginner,
        description:
            'Outdoor or treadmill running for cardiovascular endurance.',
        icon: Icons.directions_run,
        steps: [
          'Warm up 5 min walk',
          'Gradually increase pace',
          'Maintain steady pace',
          'Cool down 5 min'
        ],
        aiFormTips: [
          'Land midfoot',
          'Keep cadence 170-180 SPM',
          'Relax shoulders'
        ],
        estimatedCalories: 120,
        durationMinutes: 30),
    const Exercise(
        id: 'c2',
        name: 'Jump Rope',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.intermediate,
        description: 'High-intensity skipping for coordination and cardio.',
        icon: Icons.sports,
        requiresEquipment: true,
        steps: [
          'Hold handles at hip height',
          'Jump with both feet',
          'Small wrist rotations',
          'Land on balls of feet'
        ],
        aiFormTips: [
          'Keep jumps low',
          'Elbows close to body',
          'Breathe rhythmically'
        ],
        estimatedCalories: 140,
        durationMinutes: 15),
    const Exercise(
        id: 'c3',
        name: 'Burpees',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.advanced,
        description: 'Full-body explosive movement for maximum calorie burn.',
        icon: Icons.flash_on,
        steps: [
          'Stand tall',
          'Drop to squat',
          'Kick feet back to plank',
          'Pushup',
          'Jump feet forward',
          'Explosive jump'
        ],
        aiFormTips: [
          'Full pushup at bottom',
          'Land softly on jump',
          'Keep pace sustainable'
        ],
        estimatedCalories: 150,
        durationMinutes: 10),
    const Exercise(
        id: 'c4',
        name: 'Mountain Climbers',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Core',
        difficulty: Difficulty.beginner,
        description: 'Dynamic plank-based cardio drill.',
        icon: Icons.landscape,
        steps: [
          'Start in high plank',
          'Drive knee to chest',
          'Alternate rapidly',
          'Maintain plank position'
        ],
        aiFormTips: [
          'Hips level with shoulders',
          'Core tight throughout',
          'Drive knees fully'
        ],
        estimatedCalories: 100,
        durationMinutes: 10),
    const Exercise(
        id: 'c5',
        name: 'Cycling',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Legs',
        difficulty: Difficulty.beginner,
        description: 'Stationary or outdoor cycling for leg endurance.',
        icon: Icons.pedal_bike,
        steps: [
          'Adjust seat height',
          'Start at moderate resistance',
          'Maintain cadence 80-90 RPM',
          'Cool down'
        ],
        aiFormTips: [
          'Seat at hip height',
          'Avoid knee lock',
          'Engage core for stability'
        ],
        estimatedCalories: 100,
        durationMinutes: 30),
    const Exercise(
        id: 'c6',
        name: 'Rowing Machine',
        category: WorkoutCategory.cardio,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.intermediate,
        description: 'Full-body cardio with rowing ergometer.',
        icon: Icons.rowing,
        requiresEquipment: true,
        steps: [
          'Grip handle',
          'Drive with legs first',
          'Lean back and pull handle to chest',
          'Return forward'
        ],
        aiFormTips: [
          'Legs-back-arms sequence',
          'Dont hunch shoulders',
          'Control the return stroke'
        ],
        estimatedCalories: 110,
        durationMinutes: 20),

    // ─── FLEXIBILITY ────────────────────────────────────────
    const Exercise(
        id: 'f1',
        name: 'Sun Salutation',
        category: WorkoutCategory.flexibility,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.beginner,
        description: 'Yoga flow linking breath with movement.',
        icon: Icons.self_improvement,
        steps: [
          'Mountain pose',
          'Arms up',
          'Forward fold',
          'Half lift',
          'Plank',
          'Chaturanga',
          'Upward dog',
          'Downward dog'
        ],
        aiFormTips: [
          'Sync breath with movement',
          'Engage bandhas',
          'Straight spine in folds'
        ],
        estimatedCalories: 40,
        durationMinutes: 15),
    const Exercise(
        id: 'f2',
        name: 'Hip Openers',
        category: WorkoutCategory.flexibility,
        muscleGroup: 'Hips',
        difficulty: Difficulty.beginner,
        description: 'Targeted hip flexibility routine for desk workers.',
        icon: Icons.self_improvement,
        steps: [
          'Pigeon pose 60s each',
          'Butterfly stretch',
          'Deep lunge stretch',
          '90/90 hip switch'
        ],
        aiFormTips: [
          'Never force a stretch',
          'Hold each for 30-60s',
          'Breathe into the stretch'
        ],
        estimatedCalories: 25,
        durationMinutes: 15),
    const Exercise(
        id: 'f3',
        name: 'Shoulder Mobility',
        category: WorkoutCategory.flexibility,
        muscleGroup: 'Shoulders',
        difficulty: Difficulty.beginner,
        description: 'Dynamic and static shoulder stretches.',
        icon: Icons.self_improvement,
        steps: [
          'Arm circles 20 each',
          'Cross-body stretch',
          'Behind-back clasp',
          'Wall slides'
        ],
        aiFormTips: [
          'Warm up before stretching',
          'Avoid bouncing',
          'Equal time both sides'
        ],
        estimatedCalories: 20,
        durationMinutes: 10),
    const Exercise(
        id: 'f4',
        name: 'Foam Rolling',
        category: WorkoutCategory.flexibility,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.beginner,
        description: 'Self-myofascial release for recovery.',
        icon: Icons.self_improvement,
        requiresEquipment: true,
        steps: [
          'Calves 60s each',
          'Quads 60s each',
          'IT band 60s each',
          'Upper back 60s',
          'Lats 60s each'
        ],
        aiFormTips: [
          'Pause on tender spots',
          'Avoid rolling joints',
          'Moderate pressure only'
        ],
        estimatedCalories: 15,
        durationMinutes: 15),
    const Exercise(
        id: 'f5',
        name: 'Hamstring Stretch',
        category: WorkoutCategory.flexibility,
        muscleGroup: 'Legs',
        difficulty: Difficulty.beginner,
        description: 'Standing and seated hamstring flexibility.',
        icon: Icons.self_improvement,
        steps: [
          'Standing toe touch 30s',
          'Seated forward fold 30s',
          'Single leg stretch each side',
          'PNF contract-relax'
        ],
        aiFormTips: [
          'Hinge at hips not waist',
          'Keep spine neutral',
          'Micro-bend knee if needed'
        ],
        estimatedCalories: 15,
        durationMinutes: 10),

    // ─── BODYWEIGHT ─────────────────────────────────────────
    const Exercise(
        id: 'b1',
        name: 'Push-ups',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Chest',
        difficulty: Difficulty.beginner,
        description: 'Classic bodyweight chest and tricep press.',
        icon: Icons.accessibility_new,
        steps: [
          'Hands shoulder-width',
          'Body in straight line',
          'Lower chest to ground',
          'Press up fully'
        ],
        aiFormTips: [
          'Core tight throughout',
          'Elbows at 45° not 90°',
          'Full lockout at top'
        ],
        estimatedCalories: 70,
        durationMinutes: 10),
    const Exercise(
        id: 'b2',
        name: 'Pull-ups',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Back',
        difficulty: Difficulty.advanced,
        description: 'Vertical pull using bodyweight.',
        icon: Icons.accessibility_new,
        requiresEquipment: true,
        steps: [
          'Grip bar overhand',
          'Hang with straight arms',
          'Pull chin above bar',
          'Lower with control'
        ],
        aiFormTips: [
          'Initiate with lats',
          'No kipping',
          'Full dead hang at bottom'
        ],
        estimatedCalories: 80,
        durationMinutes: 10),
    const Exercise(
        id: 'b3',
        name: 'Bodyweight Squats',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Legs',
        difficulty: Difficulty.beginner,
        description: 'Fundamental lower body movement without equipment.',
        icon: Icons.accessibility_new,
        steps: [
          'Feet shoulder-width',
          'Arms forward for balance',
          'Squat to parallel',
          'Drive up through heels'
        ],
        aiFormTips: [
          'Weight in heels',
          'Knees behind toes',
          'Keep chest proud'
        ],
        estimatedCalories: 60,
        durationMinutes: 10),
    const Exercise(
        id: 'b4',
        name: 'Plank',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Core',
        difficulty: Difficulty.beginner,
        description: 'Isometric core hold for stability.',
        icon: Icons.accessibility_new,
        steps: [
          'Forearms on floor',
          'Body in straight line',
          'Engage core',
          'Hold for target time'
        ],
        aiFormTips: ['Dont let hips sag', 'Squeeze glutes', 'Breathe steadily'],
        estimatedCalories: 30,
        durationMinutes: 5),
    const Exercise(
        id: 'b5',
        name: 'Lunges',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Legs',
        difficulty: Difficulty.beginner,
        description: 'Walking or stationary lunges for legs and glutes.',
        icon: Icons.accessibility_new,
        steps: [
          'Step forward',
          'Lower back knee to ground',
          'Front knee at 90°',
          'Push back to standing'
        ],
        aiFormTips: [
          'Torso upright',
          'Front knee over ankle',
          'Even weight distribution'
        ],
        estimatedCalories: 60,
        durationMinutes: 10),
    const Exercise(
        id: 'b6',
        name: 'Dips',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Arms',
        difficulty: Difficulty.intermediate,
        description: 'Parallel bar or bench dips for triceps.',
        icon: Icons.accessibility_new,
        steps: [
          'Grip bars or bench edge',
          'Lower body by bending arms',
          'Go to 90° elbow bend',
          'Press up'
        ],
        aiFormTips: [
          'Slight forward lean for chest',
          'Dont go too deep',
          'Keep elbows tucked'
        ],
        estimatedCalories: 70,
        durationMinutes: 10),
    const Exercise(
        id: 'b7',
        name: 'Crunches',
        category: WorkoutCategory.bodyweight,
        muscleGroup: 'Core',
        difficulty: Difficulty.beginner,
        description: 'Basic abdominal crunch for core activation.',
        icon: Icons.accessibility_new,
        steps: [
          'Lie on back, knees bent',
          'Hands behind head',
          'Curl shoulders off ground',
          'Squeeze abs, lower slowly'
        ],
        aiFormTips: [
          'Dont pull on neck',
          'Exhale on crunch',
          'Focus on contraction'
        ],
        estimatedCalories: 30,
        durationMinutes: 8),

    // ─── HIIT ───────────────────────────────────────────────
    const Exercise(
        id: 'h1',
        name: 'Tabata Circuit',
        category: WorkoutCategory.hiit,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.advanced,
        description: '20s work / 10s rest × 8 rounds. Maximum intensity.',
        icon: Icons.flash_on,
        steps: [
          'Choose 4 exercises',
          '20s max effort each',
          '10s rest between',
          '2 rounds through all 4'
        ],
        aiFormTips: [
          'True max effort on work intervals',
          'Active rest not passive',
          'Scale movements if needed'
        ],
        estimatedCalories: 160,
        durationMinutes: 16),
    const Exercise(
        id: 'h2',
        name: 'EMOM Circuit',
        category: WorkoutCategory.hiit,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.intermediate,
        description: 'Every Minute On the Minute — complete reps then rest.',
        icon: Icons.flash_on,
        steps: [
          'Set timer for 10-20 min',
          'Complete prescribed reps at start of each minute',
          'Rest remainder',
          'Repeat'
        ],
        aiFormTips: [
          'Choose rep count you can finish in 40s',
          'Maintain form even when fatigued',
          'Scale down if needed'
        ],
        estimatedCalories: 130,
        durationMinutes: 20),
    const Exercise(
        id: 'h3',
        name: 'Sprint Intervals',
        category: WorkoutCategory.hiit,
        muscleGroup: 'Legs',
        difficulty: Difficulty.advanced,
        description: '30s sprint / 60s recovery intervals.',
        icon: Icons.flash_on,
        steps: [
          '5 min warmup jog',
          '30s all-out sprint',
          '60s recovery walk',
          'Repeat 8-10 times',
          '5 min cooldown'
        ],
        aiFormTips: [
          'True sprint effort',
          'Walk recovery dont stop',
          'Maintain arm drive'
        ],
        estimatedCalories: 140,
        durationMinutes: 20),
    const Exercise(
        id: 'h4',
        name: 'AMRAP Workout',
        category: WorkoutCategory.hiit,
        muscleGroup: 'Full Body',
        difficulty: Difficulty.intermediate,
        description: 'As Many Rounds As Possible in set time.',
        icon: Icons.flash_on,
        steps: [
          'Set 15-20 min timer',
          '10 pushups',
          '15 squats',
          '20 mountain climbers',
          'Count total rounds'
        ],
        aiFormTips: [
          'Pace yourself early',
          'Form over speed',
          'Track rounds for progress'
        ],
        estimatedCalories: 120,
        durationMinutes: 20),
  ];

  static List<Exercise> byCategory(WorkoutCategory cat) =>
      all.where((e) => e.category == cat).toList();
  static List<Exercise> byDifficulty(Difficulty d) =>
      all.where((e) => e.difficulty == d).toList();
  static List<Exercise> search(String q) => all
      .where((e) =>
          e.name.toLowerCase().contains(q.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(q.toLowerCase()))
      .toList();
  static Exercise? byId(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
