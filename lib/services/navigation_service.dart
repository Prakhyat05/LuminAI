import 'package:flutter/material.dart';

/// Centralized navigation service for consistent app navigation.
/// Use these methods instead of raw Navigator calls for cleaner navigation flow.
class AppNavigator {
  AppNavigator._();

  /// Replace entire stack with home (after onboarding/auth complete)
  static void goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  /// Go back one screen
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Replace current screen (auth/login flows)
  static void replace(BuildContext context, String route, {Object? args}) {
    Navigator.pushReplacementNamed(context, route, arguments: args);
  }

  /// Push new screen on top
  static void push(BuildContext context, String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  /// Replace with auth screen (sign out)
  static void goToAuth(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/auth');
  }

  /// Navigate to live tracking with exercise
  static void startWorkout(BuildContext context, dynamic exercise,
      {int sets = 3, int reps = 12, int rest = 60}) {
    Navigator.pushNamed(context, '/live-ai', arguments: {
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'rest': rest,
    });
  }

  /// Navigate to exercise detail
  static void viewExerciseDetail(BuildContext context, dynamic exercise) {
    Navigator.pushNamed(context, '/exercise-detail', arguments: exercise);
  }

  /// Go to onboarding flow
  static void goToOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }
}

/// Extension to add navigator methods to BuildContext
extension NavigatorExtension on BuildContext {
  void goHome() => AppNavigator.goHome(this);
  void goBack() => AppNavigator.goBack(this);
  void replace(String route, {Object? args}) =>
      AppNavigator.replace(this, route, args: args);
  void push(String route, {Object? args}) =>
      AppNavigator.push(this, route, args: args);
  void goToAuth() => AppNavigator.goToAuth(this);
  void startWorkout(dynamic exercise, {int sets = 3, int reps = 12, int rest = 60}) =>
      AppNavigator.startWorkout(this, exercise, sets: sets, reps: reps, rest: rest);
  void viewExerciseDetail(dynamic exercise) =>
      AppNavigator.viewExerciseDetail(this, exercise);
}