import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/data_persistence_service.dart';

/// Screen 20: Form Accuracy Analytics — Perfect Form percentage
class FormAccuracyScreen extends StatefulWidget {
  const FormAccuracyScreen({super.key});

  @override
  State<FormAccuracyScreen> createState() => _FormAccuracyScreenState();
}

class _FormAccuracyScreenState extends State<FormAccuracyScreen> {
  bool _isLoading = true;
  double _overallAccuracy = 0.0; // 0.0 to 1.0
  Map<String, double> _exerciseAccuracyMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DataPersistenceService();
    final sessions = await db.getRecentSessions(limit: 100);

    if (sessions.isEmpty) {
      setState(() {
        _overallAccuracy = 0.0;
        _isLoading = false;
      });
      return;
    }

    double totalForm = 0;
    Map<String, List<double>> formByExercise = {};

    for (var s in sessions) {
      // perfect_form_pct is stored as 0.0 to 100.0, we convert to 0.0 to 1.0
      double formPct = (s['perfect_form_pct'] as num?)?.toDouble() ?? 0.0;
      double formFrac = formPct / 100.0;
      totalForm += formFrac;

      String name = s['exercise_name'] as String? ?? 'Unknown';
      formByExercise.putIfAbsent(name, () => []).add(formFrac);
    }

    double overall = totalForm / sessions.length;
    Map<String, double> exMap = {};
    formByExercise.forEach((key, values) {
      exMap[key] = values.reduce((a, b) => a + b) / values.length;
    });

    setState(() {
      _overallAccuracy = overall;
      _exerciseAccuracyMap = exMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Form Accuracy')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Form Analytics', style: AppTypography.headlineLg),
                        const SizedBox(height: 4),
                        Text('Recent performance (from recorded sessions)',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.textTertiary)),
                        const SizedBox(height: 24),
                        // Hero metric
                        Center(
                            child: SizedBox(
                                width: 180,
                                height: 180,
                                child:
                                    Stack(alignment: Alignment.center, children: [
                                  SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: CircularProgressIndicator(
                                          value: _overallAccuracy,
                                          strokeWidth: 12,
                                          backgroundColor: AppColors.progressTrack,
                                          valueColor: const AlwaysStoppedAnimation(
                                              AppColors.deepNavy))),
                                  Column(mainAxisSize: MainAxisSize.min, children: [
                                    Text(
                                        (_overallAccuracy * 100).toStringAsFixed(0),
                                        style: AppTypography.displayMetrics),
                                    Text('% PERFECT',
                                        style: AppTypography.metricUnit),
                                  ]),
                                ]))),
                        const SizedBox(height: 32),
                        // Breakdown
                        Text('BREAKDOWN BY EXERCISE',
                            style: AppTypography.labelCaps),
                        const SizedBox(height: 12),
                        if (_exerciseAccuracyMap.isEmpty)
                          const Text('No exercise data available yet.')
                        else
                          ..._exerciseAccuracyMap.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _exerciseAccuracyWidget(e.key, e.value,
                                  '${(e.value * 100).toStringAsFixed(0)}%'),
                            );
                          }),
                        const SizedBox(height: 32),
                        // Common issues (Static for now as issues aren't persisted in DB)
                        Text('COMMON FORM ISSUES', style: AppTypography.labelCaps),
                        const SizedBox(height: 12),
                        SolidGlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              _issueRow('Elbow Drift', 'Tracked live',
                                  AppColors.warningOrange),
                              const Divider(
                                  height: 20, color: AppColors.outlineVariant),
                              _issueRow('Incomplete ROM', 'Tracked live',
                                  AppColors.warningOrange.withOpacity(0.7)),
                              const Divider(
                                  height: 20, color: AppColors.outlineVariant),
                              _issueRow('Forward Lean', 'Tracked live',
                                  AppColors.textTertiary),
                            ])),
                      ])),
            ),
    );
  }

  Widget _exerciseAccuracyWidget(String name, double pct, String label) =>
      SolidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text(name, style: AppTypography.bodyMd)),
            SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.progressTrack,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.deepNavy),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 12),
            Text(label,
                style:
                    AppTypography.metricSm.copyWith(color: AppColors.deepNavy)),
          ]));

  Widget _issueRow(String issue, String count, Color color) => Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Text(issue, style: AppTypography.bodyMd)),
        Text(count,
            style:
                AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
      ]);
}
