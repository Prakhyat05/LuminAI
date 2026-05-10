import 'dart:async';
import 'dart:collection';

import 'package:flutter_tts/flutter_tts.dart';

/// Priority levels for voice coaching utterances
enum TTSPriority {
  low,       // ambient info ("Form looks good")
  normal,    // rep counts ("Rep 5")
  high,      // form corrections ("Tuck your elbow")
  critical,  // safety alerts, milestones ("Set complete!")
}

/// A queued utterance with priority and dedup key
class _TTSUtterance {
  final String text;
  final TTSPriority priority;
  final String? dedupKey;
  final DateTime queuedAt;

  _TTSUtterance({
    required this.text,
    required this.priority,
    this.dedupKey,
  }) : queuedAt = DateTime.now();
}

/// Asynchronous Text-to-Speech service for voice coaching.
///
/// Provides non-blocking voice feedback with:
/// - Priority queue (critical alerts preempt normal speech)
/// - Cooldown per priority level
/// - Deduplication (same alert not repeated within window)
/// - Milestone announcements (every 5 reps, set complete, etc.)
/// - Session lifecycle events (start, rest, finish)
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _enabled = true;

  /// Per-priority cooldowns
  final Map<TTSPriority, Duration> _cooldowns = {
    TTSPriority.low: const Duration(seconds: 8),
    TTSPriority.normal: const Duration(seconds: 2),
    TTSPriority.high: const Duration(seconds: 5),
    TTSPriority.critical: const Duration(seconds: 1),
  };

  final Map<TTSPriority, DateTime> _lastUtteranceByPriority = {};
  final Map<String, DateTime> _lastDedupUtterance = {};
  final Queue<_TTSUtterance> _queue = Queue();

  /// Dedup window: same message not repeated within this duration
  static const Duration _dedupWindow = Duration(seconds: 10);

  /// Current volume (0.0 to 1.0)
  double _volume = 0.85;
  double get volume => _volume;
  bool get enabled => _enabled;

  /// Initialize the TTS engine with optimal settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.52);
    await _tts.setVolume(_volume);
    await _tts.setPitch(1.05);

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _processQueue();
    });

    // Use a clear, authoritative voice
    final voices = await _tts.getVoices;
    if (voices is List && voices.isNotEmpty) {
      final preferred = voices.cast<Map>().where(
            (v) => v['locale']?.toString().startsWith('en') == true,
          );
      if (preferred.isNotEmpty) {
        await _tts.setVoice({
          'name': preferred.first['name'].toString(),
          'locale': preferred.first['locale'].toString(),
        });
      }
    }

    _isInitialized = true;
  }

  // ─── Public Coaching API ──────────────────────────────────

  /// Announce a rep count
  Future<void> announceRep(int repCount) async {
    // Milestone announcements at 5, 10, 15, 20, 25...
    if (repCount % 5 == 0 && repCount > 0) {
      _enqueue(
        '$repCount reps! Keep it up!',
        TTSPriority.critical,
        dedupKey: 'milestone_$repCount',
      );
    } else {
      _enqueue(
        'Rep $repCount',
        TTSPriority.normal,
        dedupKey: 'rep_$repCount',
      );
    }
  }

  /// Announce a form correction
  Future<void> announceFormCorrection(String correction) async {
    _enqueue(correction, TTSPriority.high, dedupKey: 'form_$correction');
  }

  /// Announce form is good (low priority, infrequent)
  Future<void> announceGoodForm() async {
    _enqueue('Great form, keep going!', TTSPriority.low, dedupKey: 'good_form');
  }

  /// Announce session start
  Future<void> announceSessionStart(String exerciseName) async {
    await speakImmediate('Starting $exerciseName. Get ready!');
  }

  /// Announce set complete
  Future<void> announceSetComplete(int setNumber, int totalSets) async {
    _enqueue(
      'Set $setNumber of $totalSets complete. Rest now.',
      TTSPriority.critical,
      dedupKey: 'set_$setNumber',
    );
  }

  /// Announce rest period start
  Future<void> announceRestStart(int restSeconds) async {
    _enqueue(
      'Rest for $restSeconds seconds.',
      TTSPriority.critical,
      dedupKey: 'rest_start',
    );
  }

  /// Announce rest period ending
  Future<void> announceRestEnding() async {
    _enqueue(
      'Get ready, rest period ending.',
      TTSPriority.critical,
      dedupKey: 'rest_ending',
    );
  }

  /// Announce workout complete
  Future<void> announceWorkoutComplete({
    required int totalReps,
    required double formAccuracy,
    required int durationSeconds,
  }) async {
    final minutes = durationSeconds ~/ 60;
    final accuracy = formAccuracy.round();
    await speakImmediate(
      'Workout complete! $totalReps reps in $minutes minutes '
      'with $accuracy percent form accuracy. Great job!',
    );
  }

  /// Announce countdown (3, 2, 1, Go!)
  Future<void> announceCountdown(int number) async {
    if (number > 0) {
      await speakImmediate('$number');
    } else {
      await speakImmediate('Go!');
    }
  }

  /// Announce timer alarm
  Future<void> announceAlarm(String message) async {
    _enqueue(message, TTSPriority.critical, dedupKey: 'alarm');
  }

  Future<void> announceTimerTick(int secondsRemaining) async {
    if (secondsRemaining <= 3 && secondsRemaining > 0) {
      await speakImmediate('$secondsRemaining');
    }
  }

  Future<void> announceIntervalComplete() async {
    _enqueue('Interval complete!', TTSPriority.critical, dedupKey: 'interval_complete');
  }

  Future<void> announceRepSpeed(bool tooFast) async {
    final msg = tooFast ? 'Slow down your reps' : 'A little faster';
    _enqueue(msg, TTSPriority.high, dedupKey: 'rep_speed');
  }

  Future<void> announceHoldMilestone(int seconds) async {
    if (seconds % 10 == 0 && seconds > 0) {
      _enqueue('$seconds seconds. Keep holding!', TTSPriority.normal, dedupKey: 'hold_$seconds');
    }
  }

  /// Announce hold status for timed exercises
  Future<void> announceHoldStatus(int seconds) async {
    if (seconds % 10 == 0 && seconds > 0) {
      _enqueue(
        '$seconds seconds. Hold it!',
        TTSPriority.normal,
        dedupKey: 'hold_$seconds',
      );
    }
  }

  /// Motivational cue based on rep count
  Future<void> announceMotivation(int repCount) async {
    final messages = [
      'You\'re doing amazing!',
      'Push through it!',
      'Stay strong!',
      'Almost there!',
      'Don\'t give up!',
      'Feel the burn!',
      'One more!',
    ];
    final msg = messages[repCount % messages.length];
    _enqueue(msg, TTSPriority.low, dedupKey: 'motivation');
  }

  // ─── Controls ─────────────────────────────────────────────

  /// Enable/disable voice coaching
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      stop();
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  /// Speak text immediately, bypassing queue and cooldown.
  Future<void> speakImmediate(String text) async {
    if (!_enabled) return;
    await initialize();
    await _tts.stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Stop any current speech and clear queue
  Future<void> stop() async {
    _queue.clear();
    _isSpeaking = false;
    await _tts.stop();
  }

  /// Dispose of the TTS engine
  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
  }

  // ─── Internal Queue Processing ────────────────────────────

  void _enqueue(String text, TTSPriority priority, {String? dedupKey}) {
    if (!_enabled) return;

    // Dedup check
    if (dedupKey != null) {
      final lastTime = _lastDedupUtterance[dedupKey];
      if (lastTime != null &&
          DateTime.now().difference(lastTime) < _dedupWindow) {
        return;
      }
    }

    // Priority cooldown check
    final lastPriority = _lastUtteranceByPriority[priority];
    if (lastPriority != null) {
      final cooldown = _cooldowns[priority] ?? const Duration(seconds: 3);
      if (DateTime.now().difference(lastPriority) < cooldown) {
        // Critical messages still get queued even during cooldown
        if (priority != TTSPriority.critical) return;
      }
    }

    _queue.addLast(_TTSUtterance(
      text: text,
      priority: priority,
      dedupKey: dedupKey,
    ));

    // Sort queue by priority (critical first)
    final sorted = _queue.toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
    _queue.clear();
    _queue.addAll(sorted);

    if (!_isSpeaking) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty || _isSpeaking || !_enabled) return;

    await initialize();

    final utterance = _queue.removeFirst();

    // Update tracking
    _lastUtteranceByPriority[utterance.priority] = DateTime.now();
    if (utterance.dedupKey != null) {
      _lastDedupUtterance[utterance.dedupKey!] = DateTime.now();
    }

    _isSpeaking = true;
    await _tts.speak(utterance.text);
  }
}
