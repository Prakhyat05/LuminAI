import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/data_persistence_service.dart';

/// Screen 19: Session Recap — Celebration + validated rep tally
class SessionRecapScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const SessionRecapScreen({super.key, this.initialData});

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  String _exerciseName = 'Bicep Curls';
  int _sets = 3;
  int _leftReps = 12;
  int _rightReps = 12;
  int _totalReps = 24;
  double _perfectFormPct = 94.0;
  int _durationSeconds = 180;
  double _caloriesBurned = 65.0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (widget.initialData != null) {
      _applyData(widget.initialData!);
    } else if (routeArgs is Map<String, dynamic>) {
      _applyData(routeArgs);
    } else {
      // Load most recent session from database
      final sessions = await DataPersistenceService().getRecentSessions(limit: 1);
      if (sessions.isNotEmpty && mounted) {
        final last = sessions.first;
        setState(() {
          _exerciseName = (last['exercise_name'] as String?) ?? 'Exercise';
          _leftReps = (last['left_reps'] as int?) ?? 12;
          _rightReps = (last['right_reps'] as int?) ?? 12;
          _totalReps = (last['total_reps'] as int?) ?? (_leftReps + _rightReps);
          _perfectFormPct = (last['perfect_form_pct'] as num?)?.toDouble() ?? 94.0;
          _durationSeconds = (last['duration_seconds'] as int?) ?? 180;
          _caloriesBurned = (last['calories_burned'] as num?)?.toDouble() ?? 65.0;
          _loaded = true;
        });
        return;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  void _applyData(Map<String, dynamic> data) {
    setState(() {
      _exerciseName = data['exerciseName'] ?? _exerciseName;
      _sets = data['sets'] ?? _sets;
      _leftReps = data['leftReps'] ?? _leftReps;
      _rightReps = data['rightReps'] ?? _rightReps;
      _totalReps = data['totalReps'] ?? (_leftReps + _rightReps);
      _perfectFormPct = (data['perfectFormPct'] as num?)?.toDouble() ?? _perfectFormPct;
      _durationSeconds = data['durationSeconds'] ?? _durationSeconds;
      _caloriesBurned = (data['caloriesBurned'] as num?)?.toDouble() ?? _caloriesBurned;
      _loaded = true;
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Celebration icon
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successGreen.withOpacity(0.1)),
                    child: const Icon(Icons.emoji_events_outlined,
                        size: 40, color: AppColors.successGreen)),
                const SizedBox(height: 24),
                Text('Session Complete!', style: AppTypography.headlineLg),
                const SizedBox(height: 8),
                Text('$_exerciseName — $_sets Sets',
                    style:
                        AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
                const SizedBox(height: 40),
                // Rep tally
                Row(children: [
                  Expanded(
                      child: SolidGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Text('LEFT ARM', style: AppTypography.labelCaps),
                            const SizedBox(height: 12),
                            Text('$_leftReps',
                                style: AppTypography.displayMetrics
                                    .copyWith(color: AppColors.deepNavy)),
                            Text('REPS', style: AppTypography.metricUnit),
                          ]))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SolidGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            Text('RIGHT ARM', style: AppTypography.labelCaps),
                            const SizedBox(height: 12),
                            Text('$_rightReps',
                                style: AppTypography.displayMetrics
                                    .copyWith(color: AppColors.deepNavy)),
                            Text('REPS', style: AppTypography.metricUnit),
                          ]))),
                ]),
                const SizedBox(height: 16),
                // Stats
                SolidGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _statRow('Total Validated Reps', '$_totalReps'),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Perfect Form', '${_perfectFormPct.round()}%'),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Duration', _formatDuration(_durationSeconds)),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _statRow('Calories Burned', '${_caloriesBurned.toStringAsFixed(1)} kcal'),
                    ])),
                const SizedBox(height: 48),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to Dashboard'))),
                const SizedBox(height: 12),
                TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/form-accuracy'),
                    child: Text('View Detailed Analytics',
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTypography.metricSm.copyWith(color: AppColors.deepNavy)),
      ]);
}
