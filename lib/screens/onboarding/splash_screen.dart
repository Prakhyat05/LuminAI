import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../services/step_counter_service.dart';

/// Screen 1: Splash Screen
///
/// Minimalist brand reveal featuring the LuminAI logo on a pure white field.
/// Deep Navy wordmark centered with ultra-thin line iconography.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleUp = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();

    // Initialize services and navigate based on auth state
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Initialize step counter
    final stepService = StepCounterService();
    await stepService.initialize();

    // Wait for animation then navigate
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      _navigateBasedOnState();
    });
  }

  Future<void> _navigateBasedOnState() async {
    final auth = AuthService();
    final isAuth = await auth.isAuthenticated;
    final onboardingComplete = await auth.isOnboardingComplete;

    if (!mounted) return;

    if (isAuth && onboardingComplete) {
      // User is logged in and completed onboarding - go to dashboard
      Navigator.pushReplacementNamed(context, '/home');
    } else if (isAuth && !onboardingComplete) {
      // User logged in but needs to complete profile setup
      Navigator.pushReplacementNamed(context, '/identity-setup');
    } else {
      // New user - show onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Center(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleUp.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Image
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
                        child: Image.asset(
                          'assets/LuminAI.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Optional tagline or just logo
                      Text(
                        'ELITE PERFORMANCE TRAINER',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.slateGrey,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
