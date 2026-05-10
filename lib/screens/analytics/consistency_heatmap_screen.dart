import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 21: Consistency Heatmap — Monthly workout frequency grid
class ConsistencyHeatmapScreen extends StatelessWidget {
  const ConsistencyHeatmapScreen({super.key});
  static const _days = ['M','T','W','T','F','S','S'];

  @override
  Widget build(BuildContext context) {
    // Sample data: 0=none, 1=low, 2=medium, 3=high
    final data = [0,2,3,1,3,0,0, 1,3,2,3,2,1,0, 0,3,3,2,3,0,1, 2,1,3,3,2,0,0, 0,2,0,0,0,0,0];
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Consistency')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout Heatmap', style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text('May 2026', style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
              const SizedBox(height: 24),
              // Day headers
              Row(children: _days.map((d) => Expanded(child: Center(child: Text(d, style: AppTypography.labelCaps.copyWith(fontSize: 10))))).toList()),
              const SizedBox(height: 8),
              // Heatmap grid
              ...List.generate(5, (week) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: List.generate(7, (day) {
                final idx = week * 7 + day;
                final intensity = idx < data.length ? data[idx] : 0;
                return Expanded(child: Container(margin: const EdgeInsets.all(2), height: 36, decoration: BoxDecoration(
                  color: intensity == 0 ? AppColors.surfaceLow : AppColors.deepNavy.withOpacity(0.2 + intensity * 0.25),
                  borderRadius: BorderRadius.circular(6))));
              })))),
              const SizedBox(height: 16),
              // Legend
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legendItem(AppColors.surfaceLow, 'None'),
                const SizedBox(width: 12),
                _legendItem(AppColors.deepNavy.withOpacity(0.45), 'Low'),
                const SizedBox(width: 12),
                _legendItem(AppColors.deepNavy.withOpacity(0.7), 'Med'),
                const SizedBox(width: 12),
                _legendItem(AppColors.deepNavy.withOpacity(0.95), 'High'),
              ]),
              const SizedBox(height: 32),
              // Stats
              Row(children: [
                Expanded(child: SolidGlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                  Text('18', style: AppTypography.metricMd), Text('ACTIVE DAYS', style: AppTypography.labelCaps.copyWith(fontSize: 10))]))),
                const SizedBox(width: 12),
                Expanded(child: SolidGlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                  Text('7', style: AppTypography.metricMd), Text('DAY STREAK', style: AppTypography.labelCaps.copyWith(fontSize: 10))]))),
                const SizedBox(width: 12),
                Expanded(child: SolidGlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
                  Text('64%', style: AppTypography.metricMd), Text('CONSISTENCY', style: AppTypography.labelCaps.copyWith(fontSize: 10))]))),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: AppTypography.labelSm),
  ]);
}
