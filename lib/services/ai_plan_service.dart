import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/exercise.dart';
import '../data/exercise_database.dart';

/// AI-powered fitness plan generator.
/// Uses rule-based logic to create personalized workout plans
/// based on user goals, fitness level, and preferences.
class AIPlanService {
  AIPlanService._();

  static Future<AIFitnessPlan> generatePlanAsync({
    required FitnessGoal goal,
    required String fitnessLevel,
    required int daysPerWeek,
    double weightKg = 70,
  }) async {
    final basePlan = _generateBasePlan(
      goal: goal,
      fitnessLevel: fitnessLevel,
      daysPerWeek: daysPerWeek,
      weightKg: weightKg,
    );

    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) {
      debugPrint('No GEMINI_API_KEY found. Using local AI plan generation.');
      return basePlan;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = '''
        I am a fitness trainer AI. The user is a $fitnessLevel looking for ${goal.label}. They weigh $weightKg kg.
        Provide a short, motivating summary (1 sentence), 3 personalized nutrition tips, and 3 recovery tips.
        Format strictly as JSON without markdown blocks:
        {
          "summary": "...",
          "nutritionTips": ["...", "...", "..."],
          "recoveryTips": ["...", "...", "..."]
        }
      ''';
      
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleanText);
      
      return AIFitnessPlan(
        goal: basePlan.goal,
        title: basePlan.title,
        summary: data['summary'] ?? basePlan.summary,
        days: basePlan.days,
        nutritionTips: List<String>.from(data['nutritionTips'] ?? basePlan.nutritionTips),
        recoveryTips: List<String>.from(data['recoveryTips'] ?? basePlan.recoveryTips),
        createdAt: basePlan.createdAt,
      );
    } catch (e) {
      debugPrint('Gemini AI enhancement failed: $e');
      return basePlan;
    }
  }

  static AIFitnessPlan _generateBasePlan({
    required FitnessGoal goal,
    required String fitnessLevel,
    required int daysPerWeek,
    double weightKg = 70,
  }) {
    final days = <DailyPlan>[];
    final exDb = ExerciseDatabase.all;

    switch (goal) {
      case FitnessGoal.weightLoss:
        days.addAll(_weightLossPlan(daysPerWeek, fitnessLevel, exDb));
        break;
      case FitnessGoal.muscleGain:
      case FitnessGoal.muscleBuilding:
        days.addAll(_musclePlan(daysPerWeek, fitnessLevel, exDb, goal));
        break;
      case FitnessGoal.endurance:
        days.addAll(_endurancePlan(daysPerWeek, fitnessLevel, exDb));
        break;
      case FitnessGoal.flexibility:
        days.addAll(_flexPlan(daysPerWeek, exDb));
        break;
      case FitnessGoal.generalFitness:
        days.addAll(_generalPlan(daysPerWeek, fitnessLevel, exDb));
        break;
    }

    return AIFitnessPlan(
      goal: goal,
      title: '${goal.label} Plan',
      summary: _summaryFor(goal, daysPerWeek),
      days: days,
      nutritionTips: _nutritionTips(goal),
      recoveryTips: _recoveryTips(),
      createdAt: DateTime.now(),
    );
  }

  static List<DailyPlan> _weightLossPlan(
      int d, String level, List<Exercise> db) {
    final cardio =
        db.where((e) => e.category == WorkoutCategory.cardio).toList();
    final hiit = db.where((e) => e.category == WorkoutCategory.hiit).toList();
    final body =
        db.where((e) => e.category == WorkoutCategory.bodyweight).toList();
    final plans = <DailyPlan>[];
    final labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    for (int i = 0; i < d && i < 7; i++) {
      final isCardioDay = i % 2 == 0;
      final exList = isCardioDay
          ? [
              if (hiit.isNotEmpty) hiit[i % hiit.length],
              if (cardio.isNotEmpty) cardio[i % cardio.length]
            ]
          : [
              if (body.isNotEmpty) body[0],
              if (body.length > 1) body[2],
              if (body.length > 4) body[4]
            ];
      plans.add(DailyPlan(
        dayLabel: labels[i],
        focus: isCardioDay ? 'HIIT + Cardio' : 'Bodyweight Strength',
        exercises: exList
            .map((e) => PlannedExercise(
                exercise: e,
                sets: isCardioDay ? 4 : 3,
                reps: isCardioDay ? 0 : 15,
                durationSeconds: isCardioDay ? 30 : 0,
                restSeconds: isCardioDay ? 15 : 45))
            .toList(),
        estimatedMinutes: isCardioDay ? 35 : 30,
        estimatedCalories: isCardioDay ? 350 : 250,
      ));
    }
    return plans;
  }

  static List<DailyPlan> _musclePlan(
      int d, String level, List<Exercise> db, FitnessGoal g) {
    final gym = db.where((e) => e.category == WorkoutCategory.gym).toList();
    final body =
        db.where((e) => e.category == WorkoutCategory.bodyweight).toList();
    final splits = [
      'Push Day',
      'Pull Day',
      'Leg Day',
      'Upper Body',
      'Lower Body',
      'Full Body',
      'Active Recovery'
    ];
    final plans = <DailyPlan>[];
    final labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final reps = g == FitnessGoal.muscleBuilding ? 10 : 8;
    final sets = g == FitnessGoal.muscleBuilding ? 4 : 5;
    for (int i = 0; i < d && i < 7; i++) {
      final focus = splits[i % splits.length];
      List<Exercise> chosen;
      if (focus.contains('Push')) {
        chosen = gym
            .where(
                (e) => ['Chest', 'Shoulders', 'Arms'].contains(e.muscleGroup))
            .take(3)
            .toList();
      } else if (focus.contains('Pull'))
        chosen = gym
            .where((e) => ['Back', 'Arms'].contains(e.muscleGroup))
            .take(3)
            .toList();
      else if (focus.contains('Leg'))
        chosen = gym.where((e) => e.muscleGroup == 'Legs').take(3).toList();
      else
        chosen = [...gym.take(2), ...body.take(1)];
      plans.add(DailyPlan(
        dayLabel: labels[i],
        focus: focus,
        exercises: chosen
            .map((e) => PlannedExercise(
                exercise: e, sets: sets, reps: reps, restSeconds: 90))
            .toList(),
        estimatedMinutes: 50,
        estimatedCalories: 400,
      ));
    }
    return plans;
  }

  static List<DailyPlan> _endurancePlan(
      int d, String level, List<Exercise> db) {
    final cardio =
        db.where((e) => e.category == WorkoutCategory.cardio).toList();
    final plans = <DailyPlan>[];
    final labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final focuses = [
      'Easy Run',
      'Interval Training',
      'Cross Training',
      'Tempo Run',
      'Long Run',
      'Active Recovery',
      'Rest'
    ];
    for (int i = 0; i < d && i < 7; i++) {
      plans.add(DailyPlan(
        dayLabel: labels[i],
        focus: focuses[i % focuses.length],
        exercises: [
          PlannedExercise(
              exercise: cardio[i % cardio.length],
              sets: 1,
              reps: 0,
              durationSeconds: 1800,
              restSeconds: 0)
        ],
        estimatedMinutes: 40,
        estimatedCalories: 300,
      ));
    }
    return plans;
  }

  static List<DailyPlan> _flexPlan(int d, List<Exercise> db) {
    final flex =
        db.where((e) => e.category == WorkoutCategory.flexibility).toList();
    final plans = <DailyPlan>[];
    final labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    for (int i = 0; i < d && i < 7; i++) {
      plans.add(DailyPlan(
        dayLabel: labels[i],
        focus: 'Flexibility & Mobility',
        exercises: flex
            .map((e) => PlannedExercise(
                exercise: e,
                sets: 1,
                reps: 0,
                durationSeconds: 300,
                restSeconds: 30))
            .toList(),
        estimatedMinutes: 30,
        estimatedCalories: 80,
      ));
    }
    return plans;
  }

  static List<DailyPlan> _generalPlan(int d, String level, List<Exercise> db) {
    final all = [
      ...db.where((e) => e.category == WorkoutCategory.bodyweight).take(3),
      ...db.where((e) => e.category == WorkoutCategory.cardio).take(2),
      ...db.where((e) => e.category == WorkoutCategory.flexibility).take(2)
    ];
    final plans = <DailyPlan>[];
    final labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    for (int i = 0; i < d && i < 7; i++) {
      final dayEx = [all[i % all.length], all[(i + 2) % all.length]];
      plans.add(DailyPlan(
        dayLabel: labels[i],
        focus: 'Mixed Training',
        exercises: dayEx
            .map((e) => PlannedExercise(
                exercise: e, sets: 3, reps: 12, restSeconds: 60))
            .toList(),
        estimatedMinutes: 35,
        estimatedCalories: 250,
      ));
    }
    return plans;
  }

  static String _summaryFor(FitnessGoal g, int d) => switch (g) {
        FitnessGoal.weightLoss =>
          '$d-day fat-burning plan with HIIT and cardio focus. Alternates high-intensity intervals with bodyweight circuits.',
        FitnessGoal.muscleGain =>
          '$d-day strength plan with progressive overload. Push/Pull/Legs split for maximum muscle recruitment.',
        FitnessGoal.muscleBuilding =>
          '$d-day hypertrophy plan. Higher volume with moderate weight for maximum muscle growth.',
        FitnessGoal.endurance =>
          '$d-day endurance plan mixing easy runs, intervals, and cross-training for cardiovascular improvement.',
        FitnessGoal.flexibility =>
          '$d-day mobility plan with yoga flows, stretching, and foam rolling for full-body flexibility.',
        FitnessGoal.generalFitness =>
          '$d-day balanced plan mixing strength, cardio, and flexibility for overall fitness.',
      };

  static List<String> _nutritionTips(FitnessGoal g) => switch (g) {
        FitnessGoal.weightLoss => [
            'Maintain 300-500 calorie deficit',
            'High protein: 1.6g per kg bodyweight',
            'Eat whole foods, avoid processed sugar',
            'Stay hydrated: 3L+ water daily',
            'Time largest meal post-workout'
          ],
        FitnessGoal.muscleGain || FitnessGoal.muscleBuilding => [
            'Caloric surplus: +300-500 above maintenance',
            'Protein: 2g per kg bodyweight',
            'Complex carbs for energy',
            'Pre-workout meal 2hrs before',
            'Post-workout shake within 30min'
          ],
        FitnessGoal.endurance => [
            'Carb-load before long sessions',
            'Electrolyte replacement during exercise',
            'Anti-inflammatory foods for recovery',
            'Iron-rich foods for oxygen transport',
            'Moderate protein: 1.4g per kg'
          ],
        _ => [
            'Balanced macros: 40% carb, 30% protein, 30% fat',
            'Eat 5-6 small meals throughout day',
            'Hydrate before, during, and after exercise',
            'Colorful vegetables at every meal',
            'Limit alcohol and processed foods'
          ],
      };

  static List<String> _recoveryTips() => [
        'Sleep 7-9 hours nightly',
        'Foam roll after every session',
        'Take 1-2 rest days per week',
        'Active recovery: walking, light yoga',
        'Cold showers reduce inflammation'
      ];

  /// Daily rotating tips.
  static String getDailyTip() {
    final tips = [
      'Drink water first thing in the morning',
      'Warm up 5 min before every workout',
      'Track your progress weekly',
      'Sleep is when muscles grow — prioritize 8hrs',
      'Progressive overload: increase weight or reps each week',
      'Foam rolling reduces soreness by 30%',
      'Post-workout protein within 30 min optimizes recovery',
      'Consistency beats intensity — show up every day',
      'Breathe out during exertion for more power',
      'Stretch after workouts when muscles are warm',
      'Compound movements burn more calories than isolation',
      'Take rest days seriously — recovery is training',
      'Eat protein with every meal for muscle synthesis',
      'Stay hydrated: aim for 3 liters daily'
    ];
    return tips[DateTime.now().day % tips.length];
  }
}
