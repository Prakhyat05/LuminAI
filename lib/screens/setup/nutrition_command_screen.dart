import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 10: Nutrition Command — High-protein tracking dashboard
class NutritionCommandScreen extends StatelessWidget {
  const NutritionCommandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Nutrition Command'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today\'s Nutrition', style: AppTypography.headlineLg),
          const SizedBox(height: 4),
          Text('Track high-protein intake for muscle growth', style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey)),
          const SizedBox(height: 24),
          // Macro rings
          SolidGlassCard(padding: const EdgeInsets.all(24), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _macroRing('Protein', 128, 180, 'g', AppColors.deepNavy),
              _macroRing('Calories', 1840, 2800, 'kcal', AppColors.slateGrey),
              _macroRing('Carbs', 220, 300, 'g', AppColors.textTertiary),
            ]),
          ])),
          const SizedBox(height: 24),
          Text('MEAL LOG', style: AppTypography.labelCaps),
          const SizedBox(height: 12),
          _mealCard('Breakfast', '8:30 AM', [_food('Egg Whites (6)', '36g'), _food('Oatmeal', '12g'), _food('Whey Shake', '25g')]),
          const SizedBox(height: 12),
          _mealCard('Lunch', '1:00 PM', [_food('Grilled Chicken Breast', '42g'), _food('Brown Rice', '5g'), _food('Greek Yogurt', '18g')]),
          const SizedBox(height: 12),
          _mealCard('Pre-Workout', '5:30 PM', [_food('Protein Bar', '20g'), _food('Banana', '1g')]),
          const SizedBox(height: 24),
          // Quick add
          SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: const Icon(Icons.add_circle_outline, size: 20), label: const Text('Log Meal'), onPressed: () {})),
        ]),
      ),
    );
  }

  static Widget _macroRing(String label, int current, int goal, String unit, Color color) {
    final pct = (current / goal).clamp(0.0, 1.0);
    return Column(children: [
      SizedBox(width: 72, height: 72, child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(value: pct, strokeWidth: 6, backgroundColor: AppColors.progressTrack, valueColor: AlwaysStoppedAnimation(color)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$current', style: AppTypography.metricSm.copyWith(color: color)),
          Text(unit, style: AppTypography.labelSm.copyWith(fontSize: 9)),
        ]),
      ])),
      const SizedBox(height: 8),
      Text(label, style: AppTypography.labelSm),
      Text('/ $goal', style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary)),
    ]);
  }

  static Widget _mealCard(String meal, String time, List<Widget> foods) {
    return SolidGlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(meal, style: AppTypography.headlineSm.copyWith(fontSize: 16)),
        Text(time, style: AppTypography.labelSm),
      ]),
      const SizedBox(height: 12),
      ...foods,
    ]));
  }

  static Widget _food(String name, String protein) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(name, style: AppTypography.bodySm),
      Text(protein, style: AppTypography.metricSm.copyWith(fontSize: 14, color: AppColors.deepNavy)),
    ]));
  }
}
