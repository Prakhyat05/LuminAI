import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:io' as io;

/// Local Data Persistence Service
///
/// Handles all local data storage using:
/// - SharedPreferences: user profile, settings, quick key-value data & Web fallback
/// - SQLite: session logs, protein logs, step counts (on mobile & desktop)
class DataPersistenceService {
  static final DataPersistenceService _instance =
      DataPersistenceService._internal();
  factory DataPersistenceService() => _instance;
  DataPersistenceService._internal();

  Database? _db;
  SharedPreferences? _prefs;

  // ─── Initialization ────────────────────────────────────────

  static void _ensureFactory() {
    if (kIsWeb) return;
    try {
      if (io.Platform.isWindows ||
          io.Platform.isLinux ||
          io.Platform.isMacOS ||
          io.Platform.environment.containsKey('FLUTTER_TEST')) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (_) {}
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> initialize() async {
    await _ensurePrefs();
    if (!kIsWeb) {
      _ensureFactory();
      _db = await _openDatabase();
    }
    await _seedInitialDataIfNeeded();
  }

  Future<void> _seedInitialDataIfNeeded() async {
    await _ensurePrefs();
    if (_prefs?.getBool('luminai_seed_complete') == true) return;

    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);

    // Seed baseline step count for today
    await updateStepCount(todayStr, 8420);

    // Seed past sessions
    final sampleSessions = [
      {
        'exercise_name': 'Bicep Curls',
        'left_reps': 12,
        'right_reps': 12,
        'total_reps': 24,
        'perfect_form_pct': 95.0,
        'duration_seconds': 180,
        'calories_burned': 42.0,
      },
      {
        'exercise_name': 'Barbell Squats',
        'left_reps': 10,
        'right_reps': 10,
        'total_reps': 20,
        'perfect_form_pct': 91.0,
        'duration_seconds': 210,
        'calories_burned': 65.0,
      },
      {
        'exercise_name': 'Push-ups',
        'left_reps': 15,
        'right_reps': 15,
        'total_reps': 30,
        'perfect_form_pct': 93.0,
        'duration_seconds': 150,
        'calories_burned': 38.0,
      },
      {
        'exercise_name': 'Shoulder Press',
        'left_reps': 9,
        'right_reps': 9,
        'total_reps': 18,
        'perfect_form_pct': 89.0,
        'duration_seconds': 160,
        'calories_burned': 35.0,
      },
    ];

    for (final s in sampleSessions) {
      await saveSession(
        exerciseName: s['exercise_name'] as String,
        leftReps: s['left_reps'] as int,
        rightReps: s['right_reps'] as int,
        totalReps: s['total_reps'] as int,
        perfectFormPct: s['perfect_form_pct'] as double,
        durationSeconds: s['duration_seconds'] as int,
        caloriesBurned: s['calories_burned'] as double,
      );
    }

    // Seed daily activity for consistency heatmap
    for (int day = 1; day <= now.day; day++) {
      if (day % 7 != 0) {
        final dStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final intensity = (day % 3) + 1;
        await updateDailyActivity(
          date: dStr,
          workoutCount: intensity > 1 ? 2 : 1,
          totalDurationMin: intensity * 20,
          intensityLevel: intensity,
        );
      }
    }

    // Seed initial protein logs for today
    await logProtein(
        foodName: 'Oatmeal & Whey Shake',
        proteinGrams: 36.0,
        calories: 420.0,
        mealType: 'Breakfast');
    await logProtein(
        foodName: 'Grilled Chicken & Rice',
        proteinGrams: 45.0,
        calories: 520.0,
        mealType: 'Lunch');
    await logProtein(
        foodName: 'Greek Yogurt Bowl',
        proteinGrams: 20.0,
        calories: 210.0,
        mealType: 'Snack');

    await _prefs?.setBool('luminai_seed_complete', true);
  }

  Future<Database?> _openDatabase() async {
    if (kIsWeb) return null;
    _ensureFactory();
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'luminai.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Workout sessions
          await db.execute('''
            CREATE TABLE sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              exercise_name TEXT NOT NULL,
              left_reps INTEGER DEFAULT 0,
              right_reps INTEGER DEFAULT 0,
              total_reps INTEGER DEFAULT 0,
              perfect_form_pct REAL DEFAULT 0.0,
              duration_seconds INTEGER DEFAULT 0,
              calories_burned REAL DEFAULT 0.0,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');

          // Daily step counts
          await db.execute('''
            CREATE TABLE step_counts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL UNIQUE,
              steps INTEGER DEFAULT 0,
              goal INTEGER DEFAULT 20000,
              updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');

          // Protein intake logs
          await db.execute('''
            CREATE TABLE protein_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              food_name TEXT NOT NULL,
              protein_grams REAL NOT NULL,
              calories REAL DEFAULT 0.0,
              meal_type TEXT,
              logged_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');

          // Daily activity heatmap data
          await db.execute('''
            CREATE TABLE daily_activity (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL UNIQUE,
              workout_count INTEGER DEFAULT 0,
              total_duration_min INTEGER DEFAULT 0,
              intensity_level INTEGER DEFAULT 0,
              updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('SQLite database unavailable (using SharedPreferences fallback): $e');
      return null;
    }
  }

  // ─── User Profile (SharedPreferences) ──────────────────────

  Future<void> saveUserProfile({
    required String name,
    required int age,
    required String fitnessLevel,
    required double weightKg,
    required double heightCm,
    String? institution,
  }) async {
    await _ensurePrefs();
    await _prefs!.setString('user_name', name);
    await _prefs!.setInt('user_age', age);
    await _prefs!.setString('user_fitness_level', fitnessLevel);
    await _prefs!.setDouble('user_weight_kg', weightKg);
    await _prefs!.setDouble('user_height_cm', heightCm);
    if (institution != null) {
      await _prefs!.setString('user_institution', institution);
    }
    await _prefs!.setBool('profile_completed', true);
  }

  Map<String, dynamic> getUserProfile() {
    final prefs = _prefs;
    if (prefs == null) return {};
    return {
      'name': prefs.getString('user_name') ?? 'User',
      'age': prefs.getInt('user_age') ?? 25,
      'fitnessLevel': prefs.getString('user_fitness_level') ?? 'Beginner',
      'weightKg': prefs.getDouble('user_weight_kg') ?? 70.0,
      'heightCm': prefs.getDouble('user_height_cm') ?? 170.0,
      'institution': prefs.getString('user_institution') ?? '',
      'profileCompleted': prefs.getBool('profile_completed') ?? false,
    };
  }

  // ─── Goals (SharedPreferences) ─────────────────────────────

  Future<void> saveStepGoal(int goal) async {
    await _ensurePrefs();
    await _prefs!.setInt('step_goal', goal);
  }

  int getStepGoal() => _prefs?.getInt('step_goal') ?? 20000;

  Future<void> saveProteinGoal(double grams) async {
    await _ensurePrefs();
    await _prefs!.setDouble('protein_goal', grams);
  }

  double getProteinGoal() => _prefs?.getDouble('protein_goal') ?? 150.0;

  // ─── Session Data (SQLite with Web SharedPreferences Fallback) ──

  Future<int> saveSession({
    required String exerciseName,
    required int leftReps,
    required int rightReps,
    required int totalReps,
    required double perfectFormPct,
    required int durationSeconds,
    required double caloriesBurned,
  }) async {
    await _ensurePrefs();
    final sessionMap = <String, dynamic>{
      'exercise_name': exerciseName,
      'left_reps': leftReps,
      'right_reps': rightReps,
      'total_reps': totalReps,
      'perfect_form_pct': perfectFormPct,
      'duration_seconds': durationSeconds,
      'calories_burned': caloriesBurned,
      'created_at': DateTime.now().toIso8601String(),
    };

    if (kIsWeb || _db == null) {
      final list = _prefs?.getStringList('local_sessions') ?? [];
      list.insert(0, jsonEncode(sessionMap));
      if (list.length > 100) list.removeLast();
      await _prefs?.setStringList('local_sessions', list);
      return 1;
    }

    try {
      final db = _db ?? await _openDatabase();
      if (db == null) {
        final list = _prefs?.getStringList('local_sessions') ?? [];
        list.insert(0, jsonEncode(sessionMap));
        await _prefs?.setStringList('local_sessions', list);
        return 1;
      }
      return await db.insert('sessions', sessionMap);
    } catch (_) {
      final list = _prefs?.getStringList('local_sessions') ?? [];
      list.insert(0, jsonEncode(sessionMap));
      await _prefs?.setStringList('local_sessions', list);
      return 1;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 30}) async {
    await _ensurePrefs();
    if (kIsWeb || _db == null) {
      final list = _prefs?.getStringList('local_sessions') ?? [];
      return list.take(limit).map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();
    }
    try {
      final db = _db ?? await _openDatabase();
      if (db == null) {
        final list = _prefs?.getStringList('local_sessions') ?? [];
        return list.take(limit).map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();
      }
      return await db.query(
        'sessions',
        orderBy: 'created_at DESC',
        limit: limit,
      );
    } catch (_) {
      final list = _prefs?.getStringList('local_sessions') ?? [];
      return list.take(limit).map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();
    }
  }

  // ─── Step Counts ───────────────────────────────────────────

  Future<void> updateStepCount(String date, int steps) async {
    await _ensurePrefs();
    await _prefs?.setInt('steps_$date', steps);
    if (!kIsWeb && _db != null) {
      try {
        await _db!.insert(
          'step_counts',
          {
            'date': date,
            'steps': steps,
            'goal': getStepGoal(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
  }

  Future<int> getStepCount(String date) async {
    await _ensurePrefs();
    if (kIsWeb || _db == null) {
      return _prefs?.getInt('steps_$date') ?? 0;
    }
    try {
      final result = await _db!.query(
        'step_counts',
        where: 'date = ?',
        whereArgs: [date],
      );
      if (result.isEmpty) return _prefs?.getInt('steps_$date') ?? 0;
      return result.first['steps'] as int;
    } catch (_) {
      return _prefs?.getInt('steps_$date') ?? 0;
    }
  }

  // ─── Protein Logs ──────────────────────────────────────────

  Future<int> logProtein({
    required String foodName,
    required double proteinGrams,
    double calories = 0.0,
    String? mealType,
  }) async {
    await _ensurePrefs();
    if (!kIsWeb && _db != null) {
      try {
        return await _db!.insert('protein_logs', {
          'food_name': foodName,
          'protein_grams': proteinGrams,
          'calories': calories,
          'meal_type': mealType,
          'logged_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
    return 1;
  }

  Future<double> getTodayProtein() async {
    await _ensurePrefs();
    if (!kIsWeb && _db != null) {
      try {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final result = await _db!.rawQuery(
          "SELECT SUM(protein_grams) as total FROM protein_logs WHERE logged_at LIKE '$today%'",
        );
        return (result.first['total'] as num?)?.toDouble() ?? 0.0;
      } catch (_) {}
    }
    return 0.0;
  }

  // ─── Activity Heatmap ──────────────────────────────────────

  Future<void> updateDailyActivity({
    required String date,
    required int workoutCount,
    required int totalDurationMin,
    required int intensityLevel,
  }) async {
    await _ensurePrefs();
    final actMap = <String, dynamic>{
      'date': date,
      'workout_count': workoutCount,
      'total_duration_min': totalDurationMin,
      'intensity_level': intensityLevel,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final list = _prefs?.getStringList('local_daily_activity') ?? [];
    list.removeWhere((item) {
      final d = jsonDecode(item) as Map<String, dynamic>;
      return d['date'] == date;
    });
    list.add(jsonEncode(actMap));
    await _prefs?.setStringList('local_daily_activity', list);

    if (!kIsWeb && _db != null) {
      try {
        await _db!.insert(
          'daily_activity',
          actMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyActivity(
      int year, int month) async {
    await _ensurePrefs();
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month == 12
        ? '${year + 1}-01-01'
        : '$year-${(month + 1).toString().padLeft(2, '0')}-01';

    if (!kIsWeb && _db != null) {
      try {
        return await _db!.query(
          'daily_activity',
          where: 'date >= ? AND date < ?',
          whereArgs: [startDate, endDate],
          orderBy: 'date ASC',
        );
      } catch (_) {}
    }

    final list = _prefs?.getStringList('local_daily_activity') ?? [];
    return list
        .map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map))
        .where((row) {
          final d = row['date'] as String? ?? '';
          return d.compareTo(startDate) >= 0 && d.compareTo(endDate) < 0;
        })
        .toList();
  }

  // ─── Settings (SharedPreferences) ──────────────────────────

  Future<void> setDarkMode(bool enabled) async {
    await _ensurePrefs();
    await _prefs!.setBool('dark_mode', enabled);
  }

  bool isDarkMode() => _prefs?.getBool('dark_mode') ?? false;

  Future<void> setOnboardingComplete(bool complete) async {
    await _ensurePrefs();
    await _prefs!.setBool('onboarding_complete', complete);
  }

  bool isOnboardingComplete() =>
      _prefs?.getBool('onboarding_complete') ?? false;

  // ─── Cleanup ───────────────────────────────────────────────

  Future<void> dispose() async {
    await _db?.close();
  }
}
