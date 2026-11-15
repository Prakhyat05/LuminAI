import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'firebase_service.dart';
import 'data_persistence_service.dart';

/// Service to track step count and sync with Firestore.
class StepCounterService extends ChangeNotifier {
  static final StepCounterService _instance = StepCounterService._internal();
  factory StepCounterService() => _instance;
  StepCounterService._internal();

  final DataPersistenceService _data = DataPersistenceService();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  int _todaySteps = 0;
  int _sessionSteps = 0;
  int _initialStepCount = 0;
  String _status = 'unknown';
  bool _isTracking = false;

  // Getters
  int get todaySteps => _todaySteps;
  int get sessionSteps => _sessionSteps;
  String get status => _status;
  bool get isTracking => _isTracking;

  /// Initialize step counter - starts listening for step counts.
  Future<bool> initialize() async {
    // Pedometer handles permissions automatically
    // Android needs ACTIVITY_RECOGNITION permission (declared in AndroidManifest.xml)
    // iOS needs NSMotionUsageDescription (declared in Info.plist)
    try {
      await _startListening();
    } catch (e) {
      debugPrint('Step counter listening not available: $e');
    }
    try {
      await _loadTodaySteps();
    } catch (e) {
      debugPrint('Step counter load error: $e');
    }
    return true;
  }

  Future<void> _loadTodaySteps() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _todaySteps = await _data.getStepCount(today);
    notifyListeners();
  }

  Future<void> _startListening() async {
    _isTracking = true;

    // Listen to step count stream
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );

    // Listen to pedestrian status (walking/stopped)
    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: _onPedestrianStatusError,
      cancelOnError: true,
    );
  }

  Future<void> _onStepCount(StepCount event) async {
    if (_initialStepCount == 0) {
      // First reading - use as baseline
      _initialStepCount = event.steps;
    }

    // Calculate session steps from initial reading
    _sessionSteps = event.steps - _initialStepCount;

    // Update today's total (session + previously saved)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final saved = await _data.getStepCount(today);
    final total = saved + _sessionSteps;
    _todaySteps = total;
    _saveStepCount(total);
    notifyListeners();
  }

  void _onStepCountError(error) {
    debugPrint('Step count error: $error');
    _status = 'error';
    notifyListeners();
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    _status = event.status;
    notifyListeners();
  }

  void _onPedestrianStatusError(error) {
    _status = 'unknown';
    notifyListeners();
  }

  Future<void> _saveStepCount(int steps) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _data.updateStepCount(today, steps);

    // Sync to Firestore
    await _syncToFirestore(steps);
  }

  /// Sync step count to Firestore realtime database.
  Future<void> _syncToFirestore(int steps) async {
    try {
      final currentStats = await FirebaseService.getTodayStats();
      await FirebaseService.saveDailyStats(
        steps: steps,
        caloriesBurned: currentStats?['caloriesBurned'] ?? 0,
        activeMinutes: currentStats?['activeMinutes'] ?? 0,
        workoutsCompleted: currentStats?['workoutsCompleted'] ?? 0,
      );
    } catch (e) {
      debugPrint('Failed to sync steps to Firestore: $e');
    }
  }

  /// Reset for new day (called at midnight or on new day detection)
  Future<void> resetDaily() async {
    _initialStepCount = 0;
    _sessionSteps = 0;
    await _loadTodaySteps();
  }

  /// Pause tracking (e.g., when app goes to background)
  void pause() {
    _stepCountSubscription?.pause();
    _pedestrianStatusSubscription?.pause();
  }

  /// Resume tracking
  void resume() {
    _stepCountSubscription?.resume();
    _pedestrianStatusSubscription?.resume();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    super.dispose();
  }
}