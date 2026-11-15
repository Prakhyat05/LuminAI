import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 24: Progress Report (replaced Faculty Review)
///
/// Shareable progress summary with weekly breakdown.
class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Progress Report')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report header
              SolidGlassCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.deepNavy,
                borderColor: AppColors.deepNavy,
                child: Row(
                  children: [
                    Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.pureWhite.withOpacity(0.15)),
                        child: const Icon(Icons.assessment_outlined,
                            color: AppColors.pureWhite, size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Report',
                                style: AppTypography.headlineSm
                                    .copyWith(color: AppColors.pureWhite)),
                            Text('May 2026',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.pureWhite
                                        .withOpacity(0.7))),
                          ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Performance Summary', style: AppTypography.headlineMd),
              const SizedBox(height: 4),
              Text('Your training stats this month',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 24),

              // Summary
              Row(children: [
                Expanded(child: _summaryCard('Total Sessions', '28')),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Avg Form', '94%')),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Total Reps', '1,248')),
              ]),
              const SizedBox(height: 24),
              Text('WEEKLY PROGRESS', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              SolidGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _weekRow('Week 1', 120, 250, '88%'),
                  const Divider(height: 16, color: AppColors.outlineVariant),
                  _weekRow('Week 2', 145, 250, '91%'),
                  const Divider(height: 16, color: AppColors.outlineVariant),
                  _weekRow('Week 3', 160, 250, '93%'),
                  const Divider(height: 16, color: AppColors.outlineVariant),
                  _weekRow('Week 4', 185, 250, '96%'),
                ]),
              ),
              const SizedBox(height: 24),
              Text('AI INSIGHTS', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              SolidGlassCard(
                padding: const EdgeInsets.all(20),
                child: Text(
                    'Excellent progress trajectory. Consistent improvement in form accuracy (88% → 96%) over 4 weeks. Recommend advancing to compound movements and increasing training volume. AI-assisted form correction proving effective.',
                    style: AppTypography.bodyMd.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 24),

              // Share button
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      label: const Text('Share Report'),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(
                            text:
                                'LuminAI Monthly Progress Report:\n• Total Workouts: 16\n• Form Accuracy: 94.2%\n• Total Reps: 610\n• Active Training: 420 mins\nhttps://luminai-ai.web.app'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Report summary copied to clipboard! Ready to share.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      })),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_outlined, size: 20),
                      label: const Text('Export as PDF'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Export Report'),
                            content: const Text(
                                'Your comprehensive 4-week training evaluation report has been formatted and is ready for export.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close')),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Downloaded: LuminAI_Training_Report.pdf'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text('Download PDF')),
                            ],
                          ),
                        );
                      })),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value) => SolidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(value,
            style:
                AppTypography.metricMd.copyWith(color: AppColors.deepNavy)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSm),
      ]));

  Widget _weekRow(String week, int reps, int max, String form) =>
      Row(children: [
        SizedBox(width: 50, child: Text(week, style: AppTypography.bodySm)),
        Expanded(
            child: LinearProgressIndicator(
                value: reps / max,
                backgroundColor: AppColors.progressTrack,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.deepNavy),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Text('$reps reps',
            style: AppTypography.labelSm
                .copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(form,
            style: AppTypography.metricSm
                .copyWith(fontSize: 14, color: AppColors.successGreen)),
      ]);
}
