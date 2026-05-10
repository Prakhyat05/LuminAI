import 'package:flutter/material.dart';

enum WorkoutCategory {
  gym('Gym', Icons.fitness_center),
  cardio('Cardio', Icons.directions_run),
  flexibility('Flexibility', Icons.self_improvement),
  bodyweight('Bodyweight', Icons.accessibility_new),
  hiit('HIIT', Icons.flash_on);
  final String label;
  final IconData icon;
  const WorkoutCategory(this.label, this.icon);
}

enum Difficulty {
  beginner('Beginner', Color(0xFF00C853)),
  intermediate('Intermediate', Color(0xFFFF8C00)),
  advanced('Advanced', Color(0xFFBA1A1A));
  final String label;
  final Color color;
  const Difficulty(this.label, this.color);
}

enum FitnessGoal {
  weightLoss('Weight Loss', Icons.trending_down, 'Burn fat and get lean'),
  muscleGain('Muscle Gain', Icons.fitness_center, 'Build strength and size'),
  muscleBuilding('Muscle Building', Icons.sports_gymnastics, 'Hypertrophy training'),
  endurance('Endurance', Icons.directions_run, 'Improve stamina and cardio'),
  flexibility('Flexibility', Icons.self_improvement, 'Increase range of motion'),
  generalFitness('General Fitness', Icons.favorite, 'Overall health and wellness');
  final String label;
  final IconData icon;
  final String description;
  const FitnessGoal(this.label, this.icon, this.description);
}

class Exercise {
  final String id, name, muscleGroup, description;
  final WorkoutCategory category;
  final Difficulty difficulty;
  final List<String> steps, aiFormTips;
  final int estimatedCalories, durationMinutes;
  final IconData icon;
  final bool requiresEquipment;
  const Exercise({required this.id, required this.name, required this.category,
    required this.muscleGroup, required this.difficulty, required this.description,
    required this.steps, required this.aiFormTips, required this.estimatedCalories,
    required this.durationMinutes, required this.icon, this.requiresEquipment = false});
}

class PlannedExercise {
  final Exercise exercise;
  final int sets, reps, durationSeconds, restSeconds;
  const PlannedExercise({required this.exercise, this.sets = 3, this.reps = 12,
    this.durationSeconds = 0, this.restSeconds = 60});
  String get workDescription => reps > 0 ? '$sets × $reps reps' : '$sets × ${durationSeconds}s';
}

class DailyPlan {
  final String dayLabel, focus;
  final List<PlannedExercise> exercises;
  final int estimatedMinutes, estimatedCalories;
  const DailyPlan({required this.dayLabel, required this.focus, required this.exercises,
    required this.estimatedMinutes, required this.estimatedCalories});
}

class AIFitnessPlan {
  final FitnessGoal goal;
  final String title, summary;
  final List<DailyPlan> days;
  final List<String> nutritionTips, recoveryTips;
  final DateTime createdAt;
  const AIFitnessPlan({required this.goal, required this.title, required this.summary,
    required this.days, required this.nutritionTips, required this.recoveryTips, required this.createdAt});
  int get totalMinutes => days.fold(0, (s, d) => s + d.estimatedMinutes);
}
