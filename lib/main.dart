import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'services/firebase_service.dart';

// Onboarding
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_skeletal.dart';
import 'screens/onboarding/onboarding_voice_coach.dart';
import 'screens/onboarding/onboarding_reports.dart';

// Auth
import 'screens/auth/auth_gateway_screen.dart';
import 'screens/auth/identity_setup_screen.dart';
import 'screens/auth/biodata_calibration_screen.dart';
import 'screens/auth/institutional_verification_screen.dart';
import 'screens/auth/phone_otp_screen.dart';

// Setup
import 'screens/setup/goal_architect_screen.dart';
import 'screens/setup/nutrition_command_screen.dart';

// Core
import 'screens/exercise_library_screen.dart';
import 'screens/instructional_detail_screen.dart';
import 'screens/live_ai_tracking_screen.dart';

// AI
import 'screens/ai/ai_plan_screen.dart';
import 'screens/ai/ai_tips_screen.dart';

// Session
import 'screens/session/environment_calibration_screen.dart';
import 'screens/session/active_ai_hud_screen.dart';
import 'screens/session/skeletal_trace_screen.dart';
import 'screens/session/form_alert_screen.dart';
import 'screens/session/mid_session_controls_screen.dart';
import 'screens/session/session_recap_screen.dart';

// Analytics
import 'screens/analytics/form_accuracy_screen.dart';
import 'screens/analytics/consistency_heatmap_screen.dart';
import 'screens/analytics/performance_trends_screen.dart';

// Social
import 'screens/social/team_leaderboard_screen.dart';
import 'screens/social/faculty_review_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Firebase startup notice: $e');
  }
  runApp(const LuminAIApp());
}

class LuminAIApp extends StatelessWidget {
  const LuminAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuminAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const _OnboardingFlow(),
        '/auth': (_) => const AuthGatewayScreen(),
        '/phone-otp': (_) => const PhoneOtpScreen(),
        '/identity-setup': (_) => const IdentitySetupScreen(),
        '/biodata-calibration': (_) => const BiodataCalibrationScreen(),
        '/community-setup': (_) => const CommunitySetupScreen(),
        '/goal-architect': (_) => const GoalArchitectScreen(),
        '/nutrition': (_) => const NutritionCommandScreen(),
        '/home': (_) => const MainNavigation(),
        '/exercise-library': (_) => const ExerciseLibraryScreen(),
        '/exercise-detail': (_) => const InstructionalDetailScreen(),
        '/ai-plan': (_) => const AIPlanScreen(),
        '/ai-tips': (_) => const AITipsScreen(),
        '/environment-calibration': (_) => const EnvironmentCalibrationScreen(),
        '/active-hud': (_) => const ActiveAiHudScreen(),
        '/skeletal-trace': (_) => const SkeletalTraceScreen(),
        '/form-alerts': (_) => const FormAlertScreen(),
        '/mid-session': (_) => const MidSessionControlsScreen(),
        '/session-recap': (_) => const SessionRecapScreen(),
        '/form-accuracy': (_) => const FormAccuracyScreen(),
        '/consistency-heatmap': (_) => const ConsistencyHeatmapScreen(),
        '/performance-trends': (_) => const PerformanceTrendsScreen(),
        '/team-leaderboard': (_) => const TeamLeaderboardScreen(),
        '/progress-report': (_) => const ProgressReportScreen(),
        '/live-ai': (_) => const LiveAITrackingScreen(),
      },
    );
  }
}

/// Wraps the 3 onboarding screens in a PageView
class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow();
  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_controller.page!.toInt() < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        OnboardingSkeletalScreen(onNext: _next),
        OnboardingVoiceCoachScreen(onNext: _next),
        OnboardingReportsScreen(onNext: _next),
      ],
    );
  }
}
