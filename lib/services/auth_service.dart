import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication service using Firebase Auth.
/// Supports Email/Password, Google, Phone OTP, and Anonymous auth.
class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async => _prefs ??= await SharedPreferences.getInstance();

  // ─── Auth State ─────────────────────────────────────────
  Future<bool> get isAuthenticated async {
    await _ensurePrefs();
    return FirebaseService.isLoggedIn || (_prefs!.getBool('auth_logged_in') ?? false);
  }

  Future<String> get currentUserName async {
    await _ensurePrefs();
    if (FirebaseService.currentUser != null) {
      return FirebaseService.currentUser!.displayName ?? _prefs!.getString('user_name') ?? 'User';
    }
    return _prefs!.getString('user_name') ?? 'User';
  }

  Future<String> get currentUserEmail async {
    await _ensurePrefs();
    if (FirebaseService.currentUser != null) {
      return FirebaseService.currentUser!.email ?? _prefs!.getString('user_email') ?? '';
    }
    return _prefs!.getString('user_email') ?? '';
  }

  Future<String?> get currentUserId async {
    return FirebaseService.currentUserId ?? _prefs!.getString('user_id');
  }

  Future<bool> get isOnboardingComplete async {
    await _ensurePrefs();
    return _prefs!.getBool('onboarding_complete') ?? false;
  }

  // ─── Email/Password Auth ────────────────────────────────
  Future<AuthResult> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await FirebaseService.signUpWithEmail(email, password, displayName: name);

      // Create Firestore user document
      await FirebaseService.createUserDocument(credential.user!, name: name);

      // Store locally
      await _ensurePrefs();
      await _prefs!.setString('user_id', credential.user!.uid);
      await _prefs!.setString('user_email', email);
      await _prefs!.setString('user_name', name);
      await _prefs!.setString('auth_method', 'email');
      await _prefs!.setBool('auth_logged_in', true);

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.fail('Sign up failed: $e');
    }
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseService.signInWithEmail(email, password);

      await _ensurePrefs();
      await _prefs!.setString('user_id', credential.user!.uid);
      await _prefs!.setString('user_email', email);
      await _prefs!.setString('auth_method', 'email');
      await _prefs!.setBool('auth_logged_in', true);

      // Update last login
      await FirebaseService.updateLastLogin();

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.fail('Sign in failed: $e');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseService.sendPasswordResetEmail(email);
      return AuthResult.success(message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.fail('Failed to send reset email: $e');
    }
  }

  // ─── Phone OTP Auth ─────────────────────────────────────
  String? _pendingVerificationId;

  Future<AuthResult> sendPhoneOTP(String phone) async {
    try {
      await FirebaseService.verifyPhoneNumber(
        phone,
        onCodeSent: (verificationId) {
          _pendingVerificationId = verificationId;
        },
        onError: (e) {
          throw e;
        },
        onVerified: (credential) {},
      );
      return AuthResult.success(message: 'OTP sent to $phone');
    } catch (e) {
      return AuthResult.fail('Failed to send OTP: $e');
    }
  }

  Future<AuthResult> verifyPhoneOTP(String code) async {
    if (_pendingVerificationId == null) {
      return AuthResult.fail('No OTP sent. Please request a new code.');
    }

    try {
      final credential = await FirebaseService.signInWithPhoneCredential(
        _pendingVerificationId!,
        code,
      );

      // Create user document if new user
      if (credential.user != null) {
        await FirebaseService.createUserDocument(
          credential.user!,
          phone: credential.user!.phoneNumber,
        );
      }

      await _ensurePrefs();
      await _prefs!.setString('user_id', credential.user!.uid);
      await _prefs!.setString('user_phone', credential.user!.phoneNumber ?? '');
      await _prefs!.setString('auth_method', 'phone');
      await _prefs!.setBool('auth_logged_in', true);

      _pendingVerificationId = null;
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.fail('Invalid OTP code');
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      final credential = await FirebaseService.signInWithGoogle();

      if (credential == null) {
        return AuthResult.fail('Google sign-in was cancelled. Please try again.');
      }

      // Create user document if new user
      await FirebaseService.createUserDocument(
        credential.user!,
        name: credential.user!.displayName,
      );

      await _ensurePrefs();
      await _prefs!.setString('user_id', credential.user!.uid);
      await _prefs!.setString('user_name', credential.user!.displayName ?? 'User');
      await _prefs!.setString('user_email', credential.user!.email ?? '');
      await _prefs!.setString('auth_method', 'google');
      await _prefs!.setBool('auth_logged_in', true);

      await FirebaseService.updateLastLogin();

      return AuthResult.success();
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Sign in canceled') || errorMsg.contains('cancelled')) {
        return AuthResult.fail('Google sign-in was cancelled. Please try again.');
      } else if (errorMsg.contains('network_error') || errorMsg.contains('NETWORK_ERROR')) {
        return AuthResult.fail('Network error. Please check your internet connection.');
      } else if (errorMsg.contains('timeout')) {
        return AuthResult.fail('Request timed out. Please try again.');
      }
      return AuthResult.fail('Google sign-in failed. Please try again or use email sign-in.');
    }
  }

  // ─── Anonymous Auth ─────────────────────────────────────
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await FirebaseService.signInAnonymously();

      await _ensurePrefs();
      await _prefs!.setString('user_id', credential.user!.uid);
      await _prefs!.setString('user_name', 'Guest');
      await _prefs!.setString('auth_method', 'anonymous');
      await _prefs!.setBool('auth_logged_in', true);

      return AuthResult.success();
    } catch (e) {
      return AuthResult.fail('Anonymous sign-in failed: $e');
    }
  }

  // ─── Sign Out ───────────────────────────────────────────
  Future<void> signOut() async {
    await FirebaseService.signOut();
    await _ensurePrefs();
    await _prefs!.setBool('auth_logged_in', false);
  }

  // ─── Profile Update ─────────────────────────────────────
  Future<void> updateProfile({
    String? name,
    int? age,
    String? fitnessLevel,
    double? weightKg,
    double? heightCm,
    String? goal
  }) async {
    await _ensurePrefs();

    final updates = <String, dynamic>{};
    if (name != null) {
      updates['displayName'] = name;
      await _prefs!.setString('user_name', name);
    }
    if (age != null) updates['age'] = age;
    if (fitnessLevel != null) updates['fitnessLevel'] = fitnessLevel;
    if (weightKg != null) updates['weightKg'] = weightKg;
    if (heightCm != null) updates['heightCm'] = heightCm;
    if (goal != null) updates['fitnessGoal'] = goal;

    // Update Firebase user
    if (FirebaseService.currentUser != null && name != null) {
      await FirebaseService.currentUser!.updateDisplayName(name);
    }

    // Save to Firestore
    final uid = await currentUserId;
    if (uid != null && updates.isNotEmpty) {
      await FirebaseService.saveUserProfile(updates, uid: uid);
    }
  }

  Future<void> completeOnboarding() async {
    await _ensurePrefs();
    await _prefs!.setBool('onboarding_complete', true);

    final uid = await currentUserId;
    if (uid != null) {
      await FirebaseService.saveUserProfile({'onboardingComplete': true}, uid: uid);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    await _ensurePrefs();

    // Try to get from Firebase first
    final uid = await currentUserId;
    if (uid != null) {
      final firebaseProfile = await FirebaseService.getUserProfile(uid: uid);
      if (firebaseProfile != null) {
        return firebaseProfile;
      }
    }

    // Fall back to local storage
    return {
      'name': _prefs!.getString('user_name') ?? 'User',
      'email': _prefs!.getString('user_email') ?? '',
      'phone': _prefs!.getString('user_phone') ?? '',
      'age': _prefs!.getInt('user_age') ?? 25,
      'fitnessLevel': _prefs!.getString('user_fitness_level') ?? 'Beginner',
      'weightKg': _prefs!.getDouble('user_weight_kg') ?? 70.0,
      'heightCm': _prefs!.getDouble('user_height_cm') ?? 170.0,
      'goal': _prefs!.getString('user_goal') ?? 'generalFitness',
    };
  }

  // Helper to convert Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String code) => switch (code) {
    'user-not-found' => 'No account found with this email',
    'wrong-password' => 'Incorrect password',
    'email-already-in-use' => 'An account with this email already exists',
    'invalid-email' => 'Invalid email address',
    'weak-password' => 'Password should be at least 6 characters',
    'operation-not-allowed' => 'This sign-in method is not enabled',
    'too-many-requests' => 'Too many attempts. Please try again later',
    'account-exists-with-different-credential' => 'An account exists with a different sign-in method',
    'invalid-credential' => 'Invalid credentials',
    'user-disabled' => 'This account has been disabled',
    _ => 'An error occurred. Please try again',
  };
}

/// Auth result wrapper
class AuthResult {
  final bool isSuccess;
  final String? error;
  final String? message;

  AuthResult.success({this.message}) : isSuccess = true, error = null;
  AuthResult.fail(this.error) : isSuccess = false, message = null;
}