import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_engine.dart';
import '../services/tts_service.dart';
import '../services/exercise_tracking_config.dart';
import '../services/data_persistence_service.dart';
import '../widgets/skeleton_painter.dart';
import '../models/exercise.dart';
import '../data/exercise_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LiveAITrackingScreen extends StatefulWidget {
  const LiveAITrackingScreen({super.key});
  @override
  State<LiveAITrackingScreen> createState() => _LiveAITrackingScreenState();
}

class _LiveAITrackingScreenState extends State<LiveAITrackingScreen>
    with TickerProviderStateMixin {
  // ─── Core Services ─────────────────────────────────────────
  CameraController? _cam;
  final PoseDetector _detector = PoseDetector(options: PoseDetectorOptions());
  final PoseEngine _engine = PoseEngine();
  final TTSService _tts = TTSService();

  // ─── State ─────────────────────────────────────────────────
  bool _isBusy = false;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isResting = false;
  bool _sessionComplete = false;
  List<Point<double>> _landmarks = [];
  Size _imageSize = const Size(480, 640);

  Exercise? _exercise;
  TrackableExercise? _trackableType;
  int _targetSets = 3;
  int _targetReps = 24;
  int _restSeconds = 60;
  int _currentSet = 1;

  // ─── Cache & Timers ────────────────────────────────────────
  FrameResult? _lastFrameResult;
  int _lastRepTimeSeconds = 0;
  int _intervalSeconds = 30; // Custom interval timer

  // ─── Counters ──────────────────────────────────────────────
  int _totalReps = 0;
  int _leftReps = 0;
  int _rightReps = 0;
  double _formAccuracy = 100.0;
  String _alertMessage = 'Position yourself in frame';
  AlertSeverity _alertSeverity = AlertSeverity.low;
  double _caloriesBurned = 0.0;

  // ─── Timers ────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  int _restRemaining = 0;
  Timer? _workoutTimer;
  Timer? _restTimer;

  // ─── Animation ─────────────────────────────────────────────
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _tts.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exercise == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Exercise) {
        _exercise = args;
        _trackableType = ExerciseTrackingRegistry.mapExerciseId(args.id);
        if (_trackableType != null) {
          _engine.setExercise(_trackableType!);
        }
      } else if (args is Map) {
        final ex = args['exercise'] as Exercise?;
        _exercise = ex;
        _targetSets = (args['sets'] as int?) ?? 3;
        _targetReps = (args['reps'] as int?) ?? 12;
        _restSeconds = (args['rest'] as int?) ?? 60;
        if (ex != null) {
          _trackableType = ExerciseTrackingRegistry.mapExerciseId(ex.id);
          if (_trackableType != null) _engine.setExercise(_trackableType!);
        }
      }

      // Fallback default if launched directly without arguments
      if (_exercise == null && ExerciseDatabase.all.isNotEmpty) {
        _exercise = ExerciseDatabase.all.first;
        _trackableType = ExerciseTrackingRegistry.mapExerciseId(_exercise!.id);
        if (_trackableType != null) {
          _engine.setExercise(_trackableType!);
        }
      }

      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      debugPrint('🎥 Attempting to get available cameras...');
      final cameras = await availableCameras();
      debugPrint('🎥 Found ${cameras.length} camera(s)');
      if (cameras.isEmpty) {
        debugPrint('❌ No cameras found on device');
        return;
      }

      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      debugPrint(
          '🎥 Selected camera: ${cam.name}, orientation: ${cam.sensorOrientation}');

      // Use low resolution for better ML Kit compatibility
      _cam = CameraController(cam, ResolutionPreset.low,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);

      debugPrint('🎥 Initializing CameraController...');
      await _cam?.initialize();
      debugPrint('✅ Camera initialized successfully!');

      // Log camera properties
      final previewSize = _cam?.value.previewSize;
      debugPrint(
          '📷 Preview size: ${previewSize?.width}x${previewSize?.height}');
      debugPrint(
          '📷 Sensor orientation: ${_cam?.description.sensorOrientation}');

      if (!mounted) return;
      _cam?.startImageStream(_processFrame);
      setState(() {});
    } catch (e) {
      debugPrint('❌ Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera Error: $e')),
        );
      }
    }
  }

  void _startWorkout() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _tts.announceSessionStart(_exercise?.name ?? 'Exercise');
    _lastRepTimeSeconds = _elapsedSeconds;
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);

        // Interval alarm
        if (_elapsedSeconds > 0 && _elapsedSeconds % _intervalSeconds == 0) {
          _tts.announceIntervalComplete();
        }

        // Hold timer feedback
        if (_engine.activeProfile?.isTimedHold == true &&
            _engine.isInHoldPosition) {
          _tts.announceHoldMilestone(_engine.holdSeconds.toInt());
        }
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    _tts.speakImmediate(_isPaused ? 'Paused' : 'Resumed');
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restRemaining = _restSeconds;
    });
    _tts.announceRestStart(_restSeconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _restRemaining--);
      if (_restRemaining <= 3 && _restRemaining > 0) {
        _tts.announceCountdown(_restRemaining);
      }
      if (_restRemaining <= 0) {
        t.cancel();
        _endRest();
      }
    });
  }

  void _endRest() {
    _restTimer?.cancel();
    _engine.reset();
    setState(() {
      _isResting = false;
      _currentSet++;
      _totalReps = 0;
      _leftReps = 0;
      _rightReps = 0;
    });
    _tts.speakImmediate('Set $_currentSet. Go!');
  }

  void _completeWorkout() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _cam?.stopImageStream();
    setState(() {
      _sessionComplete = true;
      _isRunning = false;
    });
    _tts.announceWorkoutComplete(
      totalReps: _totalReps,
      formAccuracy: _formAccuracy,
      durationSeconds: _elapsedSeconds,
    );
    _saveSession();
  }

  Future<void> _saveSession() async {
    try {
      await DataPersistenceService().initialize();
      await DataPersistenceService().saveSession(
        exerciseName: _exercise?.name ?? 'Exercise',
        leftReps: _engine.leftRepCount,
        rightReps: _engine.rightRepCount,
        totalReps: _totalReps,
        perfectFormPct: _formAccuracy,
        durationSeconds: _elapsedSeconds,
        caloriesBurned: _caloriesBurned,
      );
    } catch (e) {
      debugPrint('Save session error: $e');
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isBusy || _isPaused || _isResting) return;
    _isBusy = true;
    try {
      // Check image properties
      debugPrint(
          '📷 Frame: ${image.width}x${image.height}, format: ${image.format.raw}, planes: ${image.planes.length}');

      final input = _toInputImage(image);
      if (input == null) {
        debugPrint('❌ _toInputImage returned null');
        _isBusy = false;
        return;
      }

      debugPrint('✅ InputImage created, processing...');
      final poses = await _detector.processImage(input);
      debugPrint('🔍 Detected ${poses.length} pose(s)');
      if (poses.isNotEmpty && mounted) {
        final pose = poses.first;
        final map = <int, Point<double>>{};
        for (final lm in pose.landmarks.values) {
          map[lm.type.index] = Point(lm.x, lm.y);
        }
        final pts = List.generate(33, (i) => map[i] ?? const Point(0, 0));

        final rotRaw = _cam?.description.sensorOrientation ?? 0;
        final isRotated = rotRaw == 90 || rotRaw == 270;
        final imgW = image.width.toDouble();
        final imgH = image.height.toDouble();
        _imageSize = Size(isRotated ? imgH : imgW, isRotated ? imgW : imgH);

        if (_trackableType != null) {
          final result = _engine.processFrame(pts);
          setState(() {
            _landmarks = pts;
            _lastFrameResult = result;

            if (_isRunning) {
              _formAccuracy = result.formAccuracy;
              _leftReps = result.leftReps;
              _rightReps = result.rightReps;
              if (result.repThisFrame) {
                _totalReps = result.totalReps;
                _caloriesBurned +=
                    (_engine.activeProfile?.caloriesPerRep ?? 1.0);
                _tts.announceRep(_totalReps);

                // Rep speed feedback
                final repDuration = _elapsedSeconds - _lastRepTimeSeconds;
                _lastRepTimeSeconds = _elapsedSeconds;
                if (repDuration < 2) {
                  _tts.announceRepSpeed(true);
                } else if (repDuration > 8) {
                  _tts.announceRepSpeed(false);
                }

                if (_totalReps % 10 == 0) _tts.announceMotivation(_totalReps);
                // Auto set-complete
                if (_targetReps > 0 && _totalReps >= _targetReps) {
                  if (_currentSet >= _targetSets) {
                    _completeWorkout();
                  } else {
                    _tts.announceSetComplete(_currentSet, _targetSets);
                    _startRest();
                  }
                }
              }
            }
            if (result.hasAlerts) {
              final a = result.alerts.first;
              if (_alertMessage != a.message) {
                if (_isRunning) _tts.announceFormCorrection(a.message);
              }
              _alertMessage = a.message;
              _alertSeverity = a.severity;
            } else {
              _alertMessage = 'Form looks great!';
              _alertSeverity = AlertSeverity.low;
            }
          });
        } else {
          setState(() => _landmarks = pts);
        }
      }
    } catch (e) {
      debugPrint('Process error: $e');
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _toInputImage(CameraImage img) {
    if (_cam == null) return null;

    try {
      final sensorOrientation = _cam!.description.sensorOrientation;
      final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);

      if (rotation == null) {
        debugPrint('❌ Could not determine rotation from: $sensorOrientation');
        return null;
      }

      // For YUV420, combine all planes into NV21 format
      if (img.format.group == ImageFormatGroup.yuv420 &&
          img.planes.length == 3) {
        final width = img.width;
        final height = img.height;

        // Calculate total size needed
        final yRowStride = img.planes[0].bytesPerRow;
        final ySize = yRowStride * height;
        final uvRowStride = img.planes[1].bytesPerRow;
        final uvHeight = (height / 2).ceil();
        final uvSize = uvRowStride * uvHeight * 2;

        // Create combined buffer
        final allBytes = Uint8List(ySize + uvSize);

        // Copy Y plane
        allBytes.setRange(0, ySize, img.planes[0].bytes);

        // Copy U and V planes - swap to NV21 format (VU instead of UV)
        final uvStart = ySize;
        final uPlane = img.planes[1].bytes;
        final vPlane = img.planes[2].bytes;

        for (int y = 0; y < uvHeight; y++) {
          for (int x = 0; x < width ~/ 2; x++) {
            final srcIdx = y * uvRowStride + x;
            final dstIdx = uvStart + y * width + x * 2;

            if (srcIdx < uPlane.length && srcIdx < vPlane.length) {
              allBytes[dstIdx] = vPlane[srcIdx]; // V first
              allBytes[dstIdx + 1] = uPlane[srcIdx]; // U second
            }
          }
        }

        debugPrint(
            '📸 NV21: ${allBytes.length} bytes, ${img.width}x${img.height}');

        return InputImage.fromBytes(
          bytes: allBytes,
          metadata: InputImageMetadata(
            size: Size(img.width.toDouble(), img.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: img.width,
          ),
        );
      }

      // Default handling for other formats
      final format = InputImageFormatValue.fromRawValue(img.format.raw) ??
          InputImageFormat.yuv_420_888;

      return InputImage.fromBytes(
        bytes: img.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(img.width.toDouble(), img.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: img.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('❌ _toInputImage error: $e');
      return null;
    }
  }

  /// Convert YUV420 (3 planes) to NV21 (Y + interleaved VU) format
  Uint8List? _convertYuv420ToNv21(CameraImage img) {
    try {
      final width = img.width;
      final height = img.height;

      // Y plane size + UV plane size (both halves combined)
      final ySize = width * height;
      final uvPlaneSize = (width ~/ 2) * (height ~/ 2);

      final nv21 = Uint8List(ySize + uvPlaneSize * 2);

      // Copy Y plane directly
      final yPlane = img.planes[0].bytes;
      nv21.setRange(0, ySize, yPlane);

      // Get U and V planes
      final uPlane = img.planes[1].bytes;
      final vPlane = img.planes[2].bytes;

      // NV21 format: Y plane followed by interleaved V, U
      final uvStart = ySize;

      // Simple copy - just put V first then U
      // YUV420sp is typically stored as UV interleaved
      // We need NV21 which is VU interleaved
      int uvIndex = 0;
      for (int i = 0; i < uvPlaneSize; i++) {
        if (i < vPlane.length && i < uPlane.length) {
          nv21[uvStart + uvIndex++] = vPlane[i]; // V first
          nv21[uvStart + uvIndex++] = uPlane[i]; // U second
        }
      }

      debugPrint(
          '✅ NV21: ${nv21.length} bytes (Y:$ySize, UV:${uvPlaneSize * 2})');
      return nv21;
    } catch (e) {
      debugPrint('❌ NV21 conversion error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _cam?.dispose();
    _detector.close();
    _pulseCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  // ─── UI ────────────────────────────────────────────────────

  Color _severityColor(AlertSeverity s) => switch (s) {
        AlertSeverity.high => const Color(0xFFFF5252),
        AlertSeverity.medium => const Color(0xFFFFAB00),
        AlertSeverity.low => const Color(0xFF00E676),
      };

  String _fmtTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_sessionComplete) return _buildRecap();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_cam != null && _cam!.value.isInitialized)
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: _togglePause,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cam!.value.previewSize?.height ?? 1000,
                        height: _cam!.value.previewSize?.width ?? 1000,
                        child: CameraPreview(_cam!),
                      ),
                    ),
                    if (_landmarks.isNotEmpty)
                      CustomPaint(
                        painter: SkeletonPainter(
                          landmarks: _landmarks,
                          imageSize: _imageSize,
                          alerts: _lastFrameResult?.alerts ?? [],
                          formAccuracy: _formAccuracy,
                          leftAngle: _lastFrameResult?.leftAngle ?? 0.0,
                          rightAngle: _lastFrameResult?.rightAngle ?? 0.0,
                          activeProfile: _engine.activeProfile,
                        ),
                      ),
                    // Scanline effect overlay
                    if (_isRunning)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScanlinePainter(),
                          size: Size.infinite,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 12,
            right: 12,
            child: Row(children: [
              _iconBtn(Icons.arrow_back, () => Navigator.pop(context)),
              const Spacer(),
              _pillChip(_fmtTime(_elapsedSeconds), Icons.timer, Colors.white),
              const SizedBox(width: 8),
              _pillChip(
                  'Set $_currentSet/$_targetSets', Icons.repeat, Colors.white),
              const Spacer(),
              _iconBtn(
                _tts.enabled ? Icons.volume_up : Icons.volume_off,
                () => setState(() => _tts.setEnabled(!_tts.enabled)),
              ),
            ]),
          ),

          // Total reps badge (center top)
          if (_totalReps > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'TOTAL $_totalReps REPS',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

          // Left arm panel (per-arm HUD)
          if (_landmarks.isNotEmpty)
            Positioned(
              left: 4,
              top: MediaQuery.of(context).size.height * 0.35,
              child: _buildArmPanel(
                label: 'LEFT',
                reps: _leftReps,
                angle: _lastFrameResult?.leftAngle ?? 0,
                isAlert: _alertSeverity != AlertSeverity.low,
              ),
            ),

          // Right arm panel (per-arm HUD)
          if (_landmarks.isNotEmpty)
            Positioned(
              right: 4,
              top: MediaQuery.of(context).size.height * 0.35,
              child: _buildArmPanel(
                label: 'RIGHT',
                reps: _rightReps,
                angle: _lastFrameResult?.rightAngle ?? 0,
                isAlert: _alertSeverity != AlertSeverity.low,
              ),
            ),

          // Rest overlay
          if (_isResting) _buildRestOverlay(),

          // Bottom HUD
          if (!_isResting)
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Form alert banner
                if (true) // Always show the alert banner so they can position themselves
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _severityColor(_alertSeverity).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              _severityColor(_alertSeverity).withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Icon(
                          _alertSeverity == AlertSeverity.low
                              ? Icons.check_circle
                              : Icons.warning_rounded,
                          color: _severityColor(_alertSeverity),
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_alertMessage,
                            style: TextStyle(
                                color: _severityColor(_alertSeverity),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ]),
                  ),

                // Main stats card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Exercise name
                    Text(
                      _exercise?.name ?? 'AI Trainer',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),

                    // Rep counter / Hold timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_engine.activeProfile?.isTimedHold == true)
                          Text('${_lastFrameResult?.holdSeconds.toInt() ?? 0}',
                              style: AppTypography.displayMetrics
                                  .copyWith(color: Colors.white, fontSize: 56))
                        else
                          Text('$_totalReps',
                              style: AppTypography.displayMetrics
                                  .copyWith(color: Colors.white, fontSize: 56)),
                        if (_targetReps > 0 &&
                            _engine.activeProfile?.isTimedHold != true)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(' / $_targetReps',
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300)),
                          ),
                        if (_engine.activeProfile?.isTimedHold == true)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(' SEC',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        _engine.activeProfile?.isTimedHold == true
                            ? 'HOLD TIME'
                            : 'REPS',
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Stats row
                    Row(children: [
                      _statCol(
                          'ACCURACY',
                          '${_formAccuracy.round()}%',
                          _formAccuracy >= 80
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFFAB00)),
                      _divider(),
                      _statCol('CALORIES', _caloriesBurned.toStringAsFixed(1),
                          const Color(0xFFFF6E40)),
                      _divider(),
                      _statCol('TIME', _fmtTime(_elapsedSeconds),
                          const Color(0xFF448AFF)),
                    ]),
                    const SizedBox(height: 16),

                    // Form accuracy bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _formAccuracy / 100,
                        minHeight: 4,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(_formAccuracy >= 80
                            ? const Color(0xFF00E676)
                            : _formAccuracy >= 50
                                ? const Color(0xFFFFAB00)
                                : const Color(0xFFFF5252)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Controls
                    if (!_isRunning)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text('START WORKOUT',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _startWorkout,
                        ),
                      )
                    else
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                size: 20),
                            label: Text(_isPaused ? 'RESUME' : 'PAUSE',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _togglePause,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.stop_rounded, size: 20),
                            label: const Text('FINISH',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFF5252).withOpacity(0.8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _completeWorkout,
                          ),
                        ),
                      ]), // Row
                  ]), // Column
                ), // Container
              ]), // Column
            ), // Positioned
        ], // Stack children
      ), // Stack body
    ); // Scaffold
  }

  Widget _buildRestOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('REST',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(_fmtTime(_restRemaining),
              style: AppTypography.displayMetrics
                  .copyWith(color: Colors.white, fontSize: 72)),
          const SizedBox(height: 8),
          Text('Next: Set ${_currentSet + 1} of $_targetSets',
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.skip_next, size: 20),
            label: const Text('SKIP REST'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _endRest,
          ),
        ]),
      ),
    );
  }

  Widget _buildRecap() {
    final mins = _elapsedSeconds ~/ 60;
    final secs = _elapsedSeconds % 60;
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Session Complete')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.emoji_events_rounded,
              size: 72, color: Color(0xFFFFD600)),
          const SizedBox(height: 16),
          Text('Great Workout!', style: AppTypography.headlineLg),
          const SizedBox(height: 8),
          Text(_exercise?.name ?? 'Exercise',
              style:
                  AppTypography.bodyMd.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 32),
          _recapCard('Total Reps', '$_totalReps', Icons.repeat,
              const Color(0xFF448AFF)),
          _recapCard('Sets Completed', '$_currentSet', Icons.layers,
              const Color(0xFF7C4DFF)),
          _recapCard('Duration', '${mins}m ${secs}s', Icons.timer,
              const Color(0xFF00BFA5)),
          _recapCard(
              'Form Accuracy',
              '${_formAccuracy.round()}%',
              Icons.check_circle,
              _formAccuracy >= 80
                  ? const Color(0xFF00C853)
                  : const Color(0xFFFF8C00)),
          _recapCard('Calories', '${_caloriesBurned.toStringAsFixed(1)} kcal',
              Icons.local_fire_department, const Color(0xFFFF6E40)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('BACK TO HOME'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _recapCard(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Text(label,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textSecondary))),
        Text(value, style: AppTypography.metricMd.copyWith(color: color)),
      ]),
    );
  }

  Widget _statCol(String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _divider() => Container(width: 1, height: 28, color: Colors.white12);

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black45, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _pillChip(String text, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.black45, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color.withOpacity(0.7), size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );

  /// Per-arm HUD panel (like the HTML version)
  Widget _buildArmPanel({
    required String label,
    required int reps,
    required double angle,
    required bool isAlert,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth < 380 ? 56.0 : 68.0;
    final fontSize = screenWidth < 380 ? 36.0 : 44.0;
    final progressHeight = screenWidth < 380 ? 80.0 : 120.0;

    final panelColor =
        isAlert ? const Color(0xFFFF5252) : const Color(0xFF00FF88);

    // Calculate progress based on angle (for bicep curl: 180° = 0%, 45° = 100%)
    double progress = 0;
    if (angle > 0) {
      progress = ((180 - angle) / 135 * 100).clamp(0, 100);
    }

    return Container(
      width: panelWidth,
      padding: EdgeInsets.symmetric(horizontal: screenWidth < 380 ? 4 : 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: label == 'LEFT'
            ? const BorderRadius.only(
                topRight: Radius.circular(12), bottomRight: Radius.circular(12))
            : const BorderRadius.only(
                topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
        border: Border.all(color: panelColor.withOpacity(0.25)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 8, letterSpacing: 3)),
        const SizedBox(height: 8),
        Text('$reps',
            style: TextStyle(
                color: panelColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: panelColor.withOpacity(0.4), blurRadius: 16)
                ])),
        const Text('REPS',
            style: TextStyle(
                color: Colors.white38, fontSize: 8, letterSpacing: 2)),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          width: 10,
          height: progressHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 10,
                height: progress * 1.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAlert
                        ? [const Color(0xFFFF2244), const Color(0xFFFF8800)]
                        : [const Color(0xFF00FF88), const Color(0xFF00CCFF)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('${angle.round()}°',
            style: const TextStyle(
                color: Colors.white38, fontSize: 10, letterSpacing: 1)),
      ]),
    );
  }
}

/// Scanline effect painter for the HUD aesthetic
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
