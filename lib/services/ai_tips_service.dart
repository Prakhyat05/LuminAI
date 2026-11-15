import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_config.dart';
import '../models/exercise.dart';

/// AI-powered fitness tip generator using Gemini API.
class AITipsService {
  AITipsService._();

  static Future<String> generateFormTip(String exerciseName, String? issue) async {
    if (!AIConfig.useGeminiApi) {
      return _localTip(exerciseName, issue);
    }

    try {
      final model = GenerativeModel(
        model: AIConfig.defaultModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final prompt = '''
You are an elite fitness AI coach. For the exercise "$exerciseName"${issue != null ? ' where the user has the following issue: "$issue"' : ''}, provide one specific, actionable tip to improve form and prevent injury.

Respond with ONLY the tip text (max 100 characters), no markdown or explanation.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? _localTip(exerciseName, issue);
      return text.length > 100 ? text.substring(0, 100) : text;
    } catch (e) {
      debugPrint('Gemini tip generation failed: $e');
      return _localTip(exerciseName, issue);
    }
  }

  static Future<List<String>> generateNutritionTips(FitnessGoal goal) async {
    if (!AIConfig.useGeminiApi) {
      return _localNutritionTips(goal);
    }

    try {
      final model = GenerativeModel(
        model: AIConfig.defaultModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final prompt = '''
As a nutrition AI for fitness goal "${goal.label}", provide 3 personalized nutrition tips.
Respond as JSON array only: ["tip1", "tip2", "tip3"]
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '[]';
      final data = jsonDecode(text);
      return List<String>.from(data);
    } catch (e) {
      debugPrint('Gemini nutrition tips failed: $e');
      return _localNutritionTips(goal);
    }
  }

  static Future<List<String>> generateRecoveryTips() async {
    if (!AIConfig.useGeminiApi) {
      return _localRecoveryTips();
    }

    try {
      final model = GenerativeModel(
        model: AIConfig.defaultModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final prompt = '''
As a recovery AI coach, provide 3 quick recovery tips for athletes.
Respond as JSON array only: ["tip1", "tip2", "tip3"]
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '[]';
      final data = jsonDecode(text);
      return List<String>.from(data);
    } catch (e) {
      debugPrint('Gemini recovery tips failed: $e');
      return _localRecoveryTips();
    }
  }

  static Future<String> generateMotivation() async {
    if (!AIConfig.useGeminiApi) {
      return _localMotivation();
    }

    try {
      final model = GenerativeModel(
        model: AIConfig.defaultModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final prompt = '''
Generate one short, motivating fitness message (max 60 characters). No markdown.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? _localMotivation();
      return text.length > 60 ? text.substring(0, 60) : text;
    } catch (e) {
      debugPrint('Gemini motivation failed: $e');
      return _localMotivation();
    }
  }

  // ─── Fallback local generation ───────────────────────────────

  static String _localTip(String exercise, String? issue) {
    final tips = {
      'Bicep Curls': 'Keep elbows pinned to torso and avoid swinging.',
      'Squats': 'Push knees out over toes and keep chest up.',
      'Pushups': 'Engage core and maintain a straight body line.',
      'Deadlifts': 'Maintain neutral spine and keep bar close to body.',
    };
    if (issue != null) {
      return 'Focus on controlled movement and proper breathing.';
    }
    return tips[exercise] ?? 'Maintain proper form throughout the movement.';
  }

  static List<String> _localNutritionTips(FitnessGoal goal) => switch (goal) {
        FitnessGoal.weightLoss => [
            'Maintain 300-500 calorie deficit',
            'High protein: 1.6g per kg bodyweight',
            'Stay hydrated: 3L+ water daily',
          ],
        FitnessGoal.muscleGain || FitnessGoal.muscleBuilding => [
            'Caloric surplus: +300-500 above maintenance',
            'Protein: 2g per kg bodyweight',
            'Post-workout shake within 30min',
          ],
        _ => [
            'Balanced macros: 40% carb, 30% protein, 30% fat',
            'Hydrate before, during, and after exercise',
            'Eat 5-6 small meals throughout day',
          ],
      };

  static List<String> _localRecoveryTips() => [
        'Sleep 7-9 hours nightly for optimal recovery',
        'Foam roll after every session',
        'Take 1-2 rest days per week',
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
      'Stay hydrated: aim for 3 liters daily',
    ];
    return tips[DateTime.now().day % tips.length];
  }

  static String _localMotivation() {
    final messages = [
      'You got this! Keep pushing.',
      'Every rep counts toward your goal.',
      'Form first, power second.',
      'Stay consistent, stay strong.',
      'Push through the discomfort.',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}