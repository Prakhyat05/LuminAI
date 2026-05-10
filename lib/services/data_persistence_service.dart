import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

/// Local Data Persistence Service
///
/// Handles all local data storage using:
/// - SharedPreferences: user profile, settings, quick key-value data
/// - SQLite: session logs, protein logs, step counts (structured data)
///
/// All session data, protein logs, and step counts are persisted locally.
class DataPersistenceService {
  static final DataPersistenceService _instance =
      DataPersistenceService._internal();
  factory DataPersistenceService() => _instance;
  DataPersistenceService._internal();

  Database? _db;
  SharedPreferences? _prefs;

  // ─── Initialization ────────────────────────────────────────

  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _prefs = await SharedPreferences.getInstance();
    _db = await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'luminai.db');

    return openDatabase(
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

        // Protein logs
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
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setString('user_fitness_level', fitnessLevel);
    await prefs.setDouble('user_weight_kg', weightKg);
    await prefs.setDouble('user_height_cm', heightCm);
    if (institution != null) {
      await prefs.setString('user_institution', institution);
    }
    await prefs.setBool('profile_completed', true);
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
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt('step_goal', goal);
  }

  int getStepGoal() => _prefs?.getInt('step_goal') ?? 20000;

  Future<void> saveProteinGoal(double grams) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setDouble('protein_goal', grams);
  }

  double getProteinGoal() => _prefs?.getDouble('protein_goal') ?? 150.0;

  // ─── Session Data (SQLite) ─────────────────────────────────

  Future<int> saveSession({
    required String exerciseName,
    required int leftReps,
    required int rightReps,
    required int totalReps,
    required double perfectFormPct,
    required int durationSeconds,
    required double caloriesBurned,
  }) async {
    final db = _db ?? await _openDatabase();
    return db.insert('sessions', {
      'exercise_name': exerciseName,
      'left_reps': leftReps,
      'right_reps': rightReps,
      'total_reps': totalReps,
      'perfect_form_pct': perfectFormPct,
      'duration_seconds': durationSeconds,
      'calories_burned': caloriesBurned,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentSessions({int limit = 30}) async {
    final db = _db ?? await _openDatabase();
    return db.query(
      'sessions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // ─── Step Counts (SQLite) ──────────────────────────────────

  Future<void> updateStepCount(String date, int steps) async {
    final db = _db ?? await _openDatabase();
    await db.insert(
      'step_counts',
      {
        'date': date,
        'steps': steps,
        'goal': getStepGoal(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getStepCount(String date) async {
    final db = _db ?? await _openDatabase();
    final result = await db.query(
      'step_counts',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (result.isEmpty) return 0;
    return result.first['steps'] as int;
  }

  // ─── Protein Logs (SQLite) ─────────────────────────────────

  Future<int> logProtein({
    required String foodName,
    required double proteinGrams,
    double calories = 0.0,
    String? mealType,
  }) async {
    final db = _db ?? await _openDatabase();
    return db.insert('protein_logs', {
      'food_name': foodName,
      'protein_grams': proteinGrams,
      'calories': calories,
      'meal_type': mealType,
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  Future<double> getTodayProtein() async {
    final db = _db ?? await _openDatabase();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      "SELECT SUM(protein_grams) as total FROM protein_logs WHERE logged_at LIKE '$today%'",
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ─── Activity Heatmap (SQLite) ─────────────────────────────

  Future<void> updateDailyActivity({
    required String date,
    required int workoutCount,
    required int totalDurationMin,
    required int intensityLevel,
  }) async {
    final db = _db ?? await _openDatabase();
    await db.insert(
      'daily_activity',
      {
        'date': date,
        'workout_count': workoutCount,
        'total_duration_min': totalDurationMin,
        'intensity_level': intensityLevel,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyActivity(
      int year, int month) async {
    final db = _db ?? await _openDatabase();
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month == 12
        ? '${year + 1}-01-01'
        : '$year-${(month + 1).toString().padLeft(2, '0')}-01';
    return db.query(
      'daily_activity',
      where: 'date >= ? AND date < ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
  }

  // ─── Settings (SharedPreferences) ──────────────────────────

  Future<void> setDarkMode(bool enabled) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
  }

  bool isDarkMode() => _prefs?.getBool('dark_mode') ?? false;

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', complete);
  }

  bool isOnboardingComplete() =>
      _prefs?.getBool('onboarding_complete') ?? false;

  // ─── Cleanup ───────────────────────────────────────────────

  Future<void> dispose() async {
    await _db?.close();
  }
}
