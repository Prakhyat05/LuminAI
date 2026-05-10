import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 23: Team Leaderboard — LuminAI Community rankings
class TeamLeaderboardScreen extends StatelessWidget {
  const TeamLeaderboardScreen({super.key});
  static const _members = [
    {'name': 'Alex Rivera', 'reps': 1248, 'streak': 12, 'rank': 1},
    {'name': 'Jordan Lee', 'reps': 1102, 'streak': 9, 'rank': 2},
    {'name': 'Sam Chen', 'reps': 987, 'streak': 7, 'rank': 3},
    {'name': 'Taylor Kim', 'reps': 856, 'streak': 5, 'rank': 4},
    {'name': 'Morgan Patel', 'reps': 742, 'streak': 4, 'rank': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LuminAI Community', style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text('Monthly rankings by total validated reps',
                  style:
                      AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 24),
              // Podium
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: _podium(_members[1], 100, AppColors.slateGrey)),
                const SizedBox(width: 8),
                Expanded(child: _podium(_members[0], 130, AppColors.deepNavy)),
                const SizedBox(width: 8),
                Expanded(child: _podium(_members[2], 80, AppColors.textTertiary)),
              ]),
              const SizedBox(height: 32),
              Text('FULL RANKINGS', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              ..._members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SolidGlassCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: m['rank'] == 1
                        ? AppColors.deepNavy.withOpacity(0.04)
                        : null,
                    child: Row(children: [
                      Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: m['rank'] == 1
                                  ? AppColors.deepNavy
                                  : AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Text('#${m['rank']}',
                                  style: AppTypography.labelSm.copyWith(
                                      color: m['rank'] == 1
                                          ? AppColors.pureWhite
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700)))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['name'] as String,
                                  style: AppTypography.bodyMd
                                      .copyWith(fontWeight: FontWeight.w600)),
                              Text('${m['streak']}-day streak',
                                  style: AppTypography.labelSm),
                            ]),
                      ),
                      Text('${m['reps']}',
                          style: AppTypography.metricSm
                              .copyWith(color: AppColors.deepNavy)),
                      const SizedBox(width: 4),
                      Text('reps', style: AppTypography.labelSm),
                    ]),
                  ))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _podium(Map<String, dynamic> m, double height, Color color) {
    return Column(children: [
      Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color.withOpacity(0.1)),
          child: Center(
              child: Text(m['name'].toString().substring(0, 1),
                  style: AppTypography.button.copyWith(color: color)))),
      const SizedBox(height: 8),
      Text(m['name'].toString().split(' ')[0],
          style:
              AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8))),
          child: Center(
              child: Text('#${m['rank']}',
                  style: AppTypography.metricSm
                      .copyWith(color: AppColors.pureWhite)))),
    ]);
  }
}
