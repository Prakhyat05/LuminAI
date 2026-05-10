import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 22: Performance Trends — Multi-axis line graphs (30-day)
class PerformanceTrendsScreen extends StatelessWidget {
  const PerformanceTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Performance Trends')),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('30-Day Trends', style: AppTypography.headlineLg),
              const SizedBox(height: 24),
              // Strength Volume
              Text('STRENGTH VOLUME', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                      height: 200,
                      child: LineChart(LineChartData(
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 50,
                            getDrawingHorizontalLine: (_) => const FlLine(
                                color: AppColors.outlineVariant,
                                strokeWidth: 0.5)),
                        titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (v, _) => Text(
                                        '${v.toInt()}',
                                        style: AppTypography.labelSm
                                            .copyWith(fontSize: 9)))),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) => Text(
                                        'W${v.toInt() + 1}',
                                        style: AppTypography.labelSm
                                            .copyWith(fontSize: 9)))),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles()),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                              spots: const [
                                FlSpot(0, 120),
                                FlSpot(1, 145),
                                FlSpot(2, 160),
                                FlSpot(3, 185)
                              ],
                              color: AppColors.deepNavy,
                              barWidth: 2,
                              dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, __, ___, ____) =>
                                      FlDotCirclePainter(
                                          radius: 3,
                                          color: AppColors.deepNavy,
                                          strokeWidth: 0)),
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.deepNavy.withOpacity(0.08)))
                        ],
                        minY: 50,
                        maxY: 250,
                      )))),
              const SizedBox(height: 24),
              // Rep Speed
              Text('REP SPEED (SEC/REP)', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              SolidGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                      height: 200,
                      child: LineChart(LineChartData(
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (_) => const FlLine(
                                color: AppColors.outlineVariant,
                                strokeWidth: 0.5)),
                        titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (v, _) => Text(
                                        v.toStringAsFixed(1),
                                        style: AppTypography.labelSm
                                            .copyWith(fontSize: 9)))),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) => Text(
                                        'W${v.toInt() + 1}',
                                        style: AppTypography.labelSm
                                            .copyWith(fontSize: 9)))),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles()),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                              spots: const [
                                FlSpot(0, 3.2),
                                FlSpot(1, 2.8),
                                FlSpot(2, 2.5),
                                FlSpot(3, 2.3)
                              ],
                              color: AppColors.slateGrey,
                              barWidth: 2,
                              dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, __, ___, ____) =>
                                      FlDotCirclePainter(
                                          radius: 3,
                                          color: AppColors.slateGrey,
                                          strokeWidth: 0)),
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.slateGrey.withOpacity(0.08)))
                        ],
                        minY: 1,
                        maxY: 5,
                      )))),
              const SizedBox(height: 24),
              // Summary stats
              Row(children: [
                Expanded(
                    child: SolidGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Text('+54%',
                              style: AppTypography.metricMd
                                  .copyWith(color: AppColors.successGreen)),
                          const SizedBox(height: 4),
                          Text('VOLUME GAIN',
                              style:
                                  AppTypography.labelCaps.copyWith(fontSize: 9))
                        ]))),
                const SizedBox(width: 12),
                Expanded(
                    child: SolidGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Text('-28%',
                              style: AppTypography.metricMd
                                  .copyWith(color: AppColors.deepNavy)),
                          const SizedBox(height: 4),
                          Text('FASTER REPS',
                              style:
                                  AppTypography.labelCaps.copyWith(fontSize: 9))
                        ]))),
              ]),
            ])),
      ),
    );
  }
}
