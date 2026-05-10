import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Local authentication service using SharedPreferences.
/// Simulates Email/Password, Phone OTP, and Google sign-in.
/// Ready to swap with Firebase Auth or Supabase when backend is configured.
class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  SharedPreferences? _prefs;
  String? _pendingOTP;

  Future<void> _ensurePrefs() async => _prefs ??= await SharedPreferences.getInstance();

  // ─── Auth State ─────────────────────────────────────────
  Future<bool> get isAuthenticated async {
    await _ensurePrefs();
    return _prefs!.getBool('auth_logged_in') ?? false;
  }

  Future<String> get currentUserName async {
    await _ensurePrefs();
    return _prefs!.getString('user_name') ?? 'User';
  }

  Future<String> get currentUserEmail async {
    await _ensurePrefs();
    return _prefs!.getString('user_email') ?? '';
  }

  Future<bool> get isOnboardingComplete async {
    await _ensurePrefs();
    return _prefs!.getBool('onboarding_complete') ?? false;
  }

  // ─── Email Auth ─────────────────────────────────────────
  Future<AuthResult> signUpWithEmail(String email, String password, String name) async {
    await _ensurePrefs();
    if (email.isEmpty || !email.contains('@')) return AuthResult.fail('Invalid email address');
    if (password.length < 6) return AuthResult.fail('Password must be at least 6 characters');
    if (name.trim().isEmpty) return AuthResult.fail('Name is required');
    await _prefs!.setString('user_email', email);
    await _prefs!.setString('user_name', name);
    await _prefs!.setString('auth_method', 'email');
    await _prefs!.setBool('auth_logged_in', true);
    return AuthResult.success();
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    await _ensurePrefs();
    if (email.isEmpty || !email.contains('@')) return AuthResult.fail('Invalid email address');
    if (password.length < 6) return AuthResult.fail('Invalid password');
    final stored = _prefs!.getString('user_email') ?? '';
    if (stored.isNotEmpty && stored != email) return AuthResult.fail('Account not found');
    await _prefs!.setString('user_email', email);
    await _prefs!.setString('auth_method', 'email');
    await _prefs!.setBool('auth_logged_in', true);
    return AuthResult.success();
  }

  // ─── Phone OTP ──────────────────────────────────────────
  Future<AuthResult> sendPhoneOTP(String phone) async {
    if (phone.length < 10) return AuthResult.fail('Invalid phone number');
    _pendingOTP = (100000 + Random().nextInt(900000)).toString();
    // In production, send via SMS gateway. For now, return the code.
    return AuthResult.success(message: 'OTP sent: $_pendingOTP');
  }

  Future<AuthResult> verifyPhoneOTP(String code, String phone) async {
    await _ensurePrefs();
    if (_pendingOTP == null) return AuthResult.fail('No OTP was sent');
    if (code != _pendingOTP) return AuthResult.fail('Invalid OTP code');
    await _prefs!.setString('user_phone', phone);
    await _prefs!.setString('auth_method', 'phone');
    await _prefs!.setBool('auth_logged_in', true);
    _pendingOTP = null;
    return AuthResult.success();
  }

  // ─── Google Sign-In (Simulated) ─────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    await _ensurePrefs();
    // Simulated — in production, integrate google_sign_in package
    await _prefs!.setString('auth_method', 'google');
    await _prefs!.setBool('auth_logged_in', true);
    if ((_prefs!.getString('user_name') ?? '').isEmpty) {
      await _prefs!.setString('user_name', 'User');
    }
    return AuthResult.success();
  }

  // ─── Sign Out ───────────────────────────────────────────
  Future<void> signOut() async {
    await _ensurePrefs();
    await _prefs!.setBool('auth_logged_in', false);
  }

  // ─── Profile Update ─────────────────────────────────────
  Future<void> updateProfile({String? name, int? age, String? fitnessLevel,
    double? weightKg, double? heightCm, String? goal}) async {
    await _ensurePrefs();
    if (name != null) await _prefs!.setString('user_name', name);
    if (age != null) await _prefs!.setInt('user_age', age);
    if (fitnessLevel != null) await _prefs!.setString('user_fitness_level', fitnessLevel);
    if (weightKg != null) await _prefs!.setDouble('user_weight_kg', weightKg);
    if (heightCm != null) await _prefs!.setDouble('user_height_cm', heightCm);
    if (goal != null) await _prefs!.setString('user_goal', goal);
  }

  Future<void> completeOnboarding() async {
    await _ensurePrefs();
    await _prefs!.setBool('onboarding_complete', true);
  }

  Future<Map<String, dynamic>> getProfile() async {
    await _ensurePrefs();
    return {
      'name': _prefs!.getString('user_name') ?? 'User',
      'email': _prefs!.getString('user_email') ?? '',
      'age': _prefs!.getInt('user_age') ?? 25,
      'fitnessLevel': _prefs!.getString('user_fitness_level') ?? 'Beginner',
      'weightKg': _prefs!.getDouble('user_weight_kg') ?? 70.0,
      'heightCm': _prefs!.getDouble('user_height_cm') ?? 170.0,
      'goal': _prefs!.getString('user_goal') ?? 'generalFitness',
    };
  }
}

class AuthResult {
  final bool isSuccess;
  final String? error;
  final String? message;
  AuthResult.success({this.message}) : isSuccess = true, error = null;
  AuthResult.fail(this.error) : isSuccess = false, message = null;
}
