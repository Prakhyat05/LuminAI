import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'data_persistence_service.dart';
import '../models/exercise.dart';
import 'ai_plan_service.dart';

/// App-wide user state manager.
/// Provides user profile, daily stats, auth state, and current plan.
class UserState extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final DataPersistenceService _data = DataPersistenceService();

  bool _initialized = false;
  bool _isAuthenticated = false;
  bool _onboardingComplete = false;

  // Profile
  String _userName = 'User';
  String _email = '';
  int _age = 25;
  String _fitnessLevel = 'Beginner';
  double _weightKg = 70.0;
  double _heightCm = 170.0;
  String _goalKey = 'generalFitness';

  // Today's stats
  int _todaySteps = 0;
  double _todayCalories = 0;
  double _todayProtein = 0;
  int _todayActiveMinutes = 0;
  int _stepGoal = 20000;

  // Current plan
  AIFitnessPlan? _currentPlan;

  // Recent sessions
  List<Map<String, dynamic>> _recentSessions = [];

  // Getters
  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get onboardingComplete => _onboardingComplete;
  String get userName => _userName;
  String get email => _email;
  int get age => _age;
  String get fitnessLevel => _fitnessLevel;
  double get weightKg => _weightKg;
  double get heightCm => _heightCm;
  String get goalKey => _goalKey;
  int get todaySteps => _todaySteps;
  double get todayCalories => _todayCalories;
  double get todayProtein => _todayProtein;
  int get todayActiveMinutes => _todayActiveMinutes;
  int get stepGoal => _stepGoal;
  AIFitnessPlan? get currentPlan => _currentPlan;
  List<Map<String, dynamic>> get recentSessions => _recentSessions;

  FitnessGoal get fitnessGoal {
    try {
      return FitnessGoal.values.firstWhere((g) => g.name == _goalKey);
    } catch (_) {
      return FitnessGoal.generalFitness;
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Initialize state from persisted data.
  Future<void> initialize() async {
    await _data.initialize();
    _isAuthenticated = await _auth.isAuthenticated;
    _onboardingComplete = await _auth.isOnboardingComplete;

    if (_isAuthenticated) {
      await _loadProfile();
      await _loadTodayStats();
      await _loadRecentSessions();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final profile = await _auth.getProfile();
    _userName = profile['name'] ?? 'User';
    _email = profile['email'] ?? '';
    _age = profile['age'] ?? 25;
    _fitnessLevel = profile['fitnessLevel'] ?? 'Beginner';
    _weightKg = profile['weightKg'] ?? 70.0;
    _heightCm = profile['heightCm'] ?? 170.0;
    _goalKey = profile['goal'] ?? 'generalFitness';
    _stepGoal = _data.getStepGoal();
  }

  Future<void> _loadTodayStats() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _todaySteps = await _data.getStepCount(today);
    _todayProtein = await _data.getTodayProtein();
    // Calculate from recent sessions today
    final sessions = await _data.getRecentSessions(limit: 50);
    double cals = 0;
    int mins = 0;
    for (final s in sessions) {
      final created = s['created_at'] as String? ?? '';
      if (created.startsWith(today)) {
        cals += (s['calories_burned'] as num?)?.toDouble() ?? 0;
        mins += ((s['duration_seconds'] as num?)?.toInt() ?? 0) ~/ 60;
      }
    }
    _todayCalories = cals;
    _todayActiveMinutes = mins;
  }

  Future<void> _loadRecentSessions() async {
    _recentSessions = await _data.getRecentSessions(limit: 10);
  }

  /// Update profile data.
  Future<void> updateProfile({
    String? name,
    int? age,
    String? fitnessLevel,
    double? weightKg,
    double? heightCm,
    String? goal,
  }) async {
    await _auth.updateProfile(
      name: name,
      age: age,
      fitnessLevel: fitnessLevel,
      weightKg: weightKg,
      heightCm: heightCm,
      goal: goal,
    );
    if (name != null) _userName = name;
    if (age != null) _age = age;
    if (fitnessLevel != null) _fitnessLevel = fitnessLevel;
    if (weightKg != null) _weightKg = weightKg;
    if (heightCm != null) _heightCm = heightCm;
    if (goal != null) _goalKey = goal;
    notifyListeners();
  }

  /// Generate and set AI plan.
  Future<void> generatePlan({required int daysPerWeek}) async {
    _currentPlan = await AIPlanService.generatePlanAsync(
      goal: fitnessGoal,
      fitnessLevel: _fitnessLevel,
      daysPerWeek: daysPerWeek,
      weightKg: _weightKg,
    );
    notifyListeners();
  }

  /// Save a completed session and refresh stats.
  Future<void> saveSession({
    required String exerciseName,
    required int leftReps,
    required int rightReps,
    required int totalReps,
    required double perfectFormPct,
    required int durationSeconds,
    required double caloriesBurned,
  }) async {
    await _data.saveSession(
      exerciseName: exerciseName,
      leftReps: leftReps,
      rightReps: rightReps,
      totalReps: totalReps,
      perfectFormPct: perfectFormPct,
      durationSeconds: durationSeconds,
      caloriesBurned: caloriesBurned,
    );
    // Update daily activity
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _data.updateDailyActivity(
      date: today,
      workoutCount: 1,
      totalDurationMin: durationSeconds ~/ 60,
      intensityLevel: 2,
    );
    await _loadTodayStats();
    await _loadRecentSessions();
    notifyListeners();
  }

  /// Mark onboarding complete.
  Future<void> completeOnboarding() async {
    await _auth.completeOnboarding();
    _onboardingComplete = true;
    notifyListeners();
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _userName = 'User';
    _email = '';
    _currentPlan = null;
    _recentSessions = [];
    notifyListeners();
  }

  /// Refresh after login.
  Future<void> onLoginSuccess() async {
    _isAuthenticated = true;
    await _loadProfile();
    await _loadTodayStats();
    await _loadRecentSessions();
    notifyListeners();
  }
}
