import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

/// Firebase initialization and configuration service
/// Supports: Email/Password, Google, Phone, Anonymous auth
class FirebaseService {
  FirebaseService._();

  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Initialize Firebase - call this before runApp()
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;

    // Enable Firestore persistence
    _firestore?.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get FirebaseAuth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  /// Get the current user (null if not logged in)
  static User? get currentUser => auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  // ═══════════════════════════════════════════════════════════════
  // EMAIL/PASSWORD AUTH
  // ═══════════════════════════════════════════════════════════════

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmail(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign up with email and password
  static Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName}) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name if provided
    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    return credential;
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  // ═══════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN
  // ═══════════════════════════════════════════════════════════════

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // First check if there are any accounts available
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
      }

      // Trigger the Google Sign-In flow with explicit scopes
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // User cancelled

      // Get the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google Sign-In: Missing tokens, requesting again...');
        // Request again with force
        await _googleSignIn.signOut();
        final retryUser = await _googleSignIn.signIn();
        if (retryUser == null) return null;
        final retryAuth = await retryUser.authentication;
        if (retryAuth.accessToken == null || retryAuth.idToken == null) {
          throw Exception('Failed to obtain Google auth tokens');
        }
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      return await auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow; // Re-throw to let the caller handle it
    }
  }

  /// Sign out from Google
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  // ═══════════════════════════════════════════════════════════════
  // PHONE AUTH
  // ═══════════════════════════════════════════════════════════════

  /// Verify phone number - sends code
  static Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required void Function(String) onCodeSent,
    required void Function(FirebaseAuthException) onError,
    required void Function(PhoneAuthCredential) onVerified,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Auto-sign in on Android devices
        await auth.signInWithCredential(credential);
        onVerified(credential);
      },
      verificationFailed: onError,
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  /// Sign in with phone verification code
  static Future<UserCredential> signInWithPhoneCredential(String verificationId, String code) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    return auth.signInWithCredential(credential);
  }

  // ═══════════════════════════════════════════════════════════════
  // ANONYMOUS AUTH
  // ═══════════════════════════════════════════════════════════════

  /// Sign in anonymously
  static Future<UserCredential> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  /// Convert anonymous user to permanent (needs to be done before Firestore write)
  static Future<void> convertAnonymousToPermanent() async {
    if (auth.currentUser != null && auth.currentUser!.isAnonymous) {
      // This requires previous anonymous sign-in to be linked
      // This is typically done during sign-up flow
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SIGN OUT
  // ═══════════════════════════════════════════════════════════════

  /// Sign out
  static Future<void> signOut() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  // ═══════════════════════════════════════════════════════════════
  // FIRESTORE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get user document reference
  static DocumentReference userDoc([String? uid]) {
    final userId = uid ?? currentUserId;
    if (userId == null) {
      throw Exception('No user logged in');
    }
    return firestore.collection('users').doc(userId);
  }

  /// Get sessions subcollection reference
  static CollectionReference sessionsCol([String? uid]) {
    return userDoc(uid).collection('sessions');
  }

  /// Save user profile data
  static Future<void> saveUserProfile(Map<String, dynamic> data, {String? uid}) async {
    await userDoc(uid).set(data, SetOptions(merge: true));
  }

  /// Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile({String? uid}) async {
    final doc = await userDoc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Save workout session
  static Future<DocumentReference> saveWorkoutSession(Map<String, dynamic> session, {String? uid}) async {
    return await sessionsCol(uid).add({
      ...session,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get workout sessions
  static Future<List<Map<String, dynamic>>> getWorkoutSessions({String? uid, int limit = 20}) async {
    final snapshot = await sessionsCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(data as Map);
    }).toList();
  }

  /// Get workout sessions stream (real-time)
  static Stream<QuerySnapshot> getWorkoutSessionsStream({String? uid}) {
    return sessionsCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Update user stats
  static Future<void> updateUserStats(Map<String, dynamic> stats, {String? uid}) async {
    await userDoc(uid).collection('stats').doc('current').set(stats, SetOptions(merge: true));
  }

  /// Get user stats
  static Future<Map<String, dynamic>?> getUserStats({String? uid}) async {
    final doc = await userDoc(uid).collection('stats').doc('current').get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Delete a workout session
  static Future<void> deleteWorkoutSession(String sessionId, {String? uid}) async {
    await sessionsCol(uid).doc(sessionId).delete();
  }

  /// Create initial user document on signup
  static Future<void> createUserDocument(User user, {String? name, String? phone}) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': name ?? user.displayName ?? '',
      'phone': phone ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'onboardingComplete': false,
      'profileComplete': false,
      'fitnessGoal': '',
      'dailyStepGoal': 10000,
      'workoutsPerWeek': 4,
      'totalWorkouts': 0,
      'totalMinutes': 0,
      'totalCalories': 0,
    };
    await userDoc(user.uid).set(userData, SetOptions(merge: true));
  }

  /// Update last login
  static Future<void> updateLastLogin() async {
    if (currentUserId != null) {
      await userDoc().update({'lastLoginAt': FieldValue.serverTimestamp()});
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // FIREBASE STORAGE - Profile Pictures
  // ═══════════════════════════════════════════════════════════════

  /// Get storage reference
  static Reference get _storageRef => _storage!.ref();

  /// Upload profile picture
  static Future<String?> uploadProfilePicture(String filePath, {String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return null;

    try {
      final ref = _storageRef.child('profiles').child('$uid.jpg');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  /// Get profile picture URL
  static Future<String?> getProfilePictureUrl({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return null;

    try {
      final ref = _storageRef.child('profiles').child('$uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Delete profile picture
  static Future<void> deleteProfilePicture({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return;

    try {
      final ref = _storageRef.child('profiles').child('$uid.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting profile picture: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // USER STATS - Steps, Calories, Active Time
  // ═══════════════════════════════════════════════════════════════

  /// Save daily stats
  static Future<void> saveDailyStats({
    int? steps,
    double? caloriesBurned,
    int? activeMinutes,
    int? workoutsCompleted,
    int? totalReps,
    double? formAccuracy,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await userDoc(uid).collection('daily_stats').doc(dateStr).set({
      if (steps != null) 'steps': steps,
      if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
      if (activeMinutes != null) 'activeMinutes': activeMinutes,
      if (workoutsCompleted != null) 'workoutsCompleted': workoutsCompleted,
      if (totalReps != null) 'totalReps': totalReps,
      if (formAccuracy != null) 'formAccuracy': formAccuracy,
      'date': dateStr,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update aggregated stats
    await _updateAggregatedStats(uid);
  }

  /// Update aggregated lifetime stats
  static Future<void> _updateAggregatedStats(String uid) async {
    final statsRef = userDoc(uid).collection('stats').doc('lifetime');

    // Get all daily stats
    final dailyStats = await userDoc(uid).collection('daily_stats').get();

    int totalSteps = 0;
    double totalCalories = 0;
    int totalActiveMinutes = 0;
    int totalWorkouts = 0;
    int totalReps = 0;
    double totalFormAccuracy = 0;

    for (final doc in dailyStats.docs) {
      final data = doc.data();
      totalSteps += (data['steps'] as int?) ?? 0;
      totalCalories += (data['caloriesBurned'] as num?)?.toDouble() ?? 0;
      totalActiveMinutes += (data['activeMinutes'] as int?) ?? 0;
      totalWorkouts += (data['workoutsCompleted'] as int?) ?? 0;
      totalReps += (data['totalReps'] as int?) ?? 0;
      totalFormAccuracy += (data['formAccuracy'] as num?)?.toDouble() ?? 0;
    }

    final count = dailyStats.docs.length;
    final avgFormAccuracy = count > 0 ? totalFormAccuracy / count : 0.0;

    await statsRef.set({
      'totalSteps': totalSteps,
      'totalCaloriesBurned': totalCalories,
      'totalActiveMinutes': totalActiveMinutes,
      'totalWorkouts': totalWorkouts,
      'totalReps': totalReps,
      'averageFormAccuracy': avgFormAccuracy,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get today's stats
  static Future<Map<String, dynamic>?> getTodayStats() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final doc = await userDoc(uid).collection('daily_stats').doc(dateStr).get();
    return doc.exists ? Map<String, dynamic>.from(doc.data() as Map) : null;
  }

  /// Get lifetime stats
  static Future<Map<String, dynamic>?> getLifetimeStats() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await userDoc(uid).collection('stats').doc('lifetime').get();
    if (!doc.exists) return null;
    return Map<String, dynamic>.from(doc.data() as Map);
  }

  /// Get weekly stats
  static Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final snapshot = await userDoc(uid)
        .collection('daily_stats')
        .where('date', isGreaterThanOrEqualTo: '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Map<String, dynamic>.from(doc.data())).toList();
  }

  /// Record workout session with full stats
  static Future<void> recordWorkout({
    required String exerciseName,
    required int leftReps,
    required int rightReps,
    required int totalReps,
    required double formAccuracy,
    required int durationSeconds,
    required double caloriesBurned,
    required int setsCompleted,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Save workout session
    await userDoc(uid).collection('sessions').add({
      'exerciseName': exerciseName,
      'leftReps': leftReps,
      'rightReps': rightReps,
      'totalReps': totalReps,
      'formAccuracy': formAccuracy,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'setsCompleted': setsCompleted,
      'date': dateStr,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update daily stats
    final existingStats = await getTodayStats();
    await saveDailyStats(
      steps: null,
      caloriesBurned: (existingStats?['caloriesBurned'] ?? 0) + caloriesBurned,
      activeMinutes: (existingStats?['activeMinutes'] ?? 0) + (durationSeconds ~/ 60),
      workoutsCompleted: (existingStats?['workoutsCompleted'] ?? 0) + 1,
      totalReps: (existingStats?['totalReps'] ?? 0) + totalReps,
      formAccuracy: formAccuracy,
    );
  }
}