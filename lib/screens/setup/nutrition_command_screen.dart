import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/data_persistence_service.dart';

/// Screen 10: Nutrition Command — High-protein tracking dashboard
class NutritionCommandScreen extends StatefulWidget {
  const NutritionCommandScreen({super.key});

  @override
  State<NutritionCommandScreen> createState() => _NutritionCommandScreenState();
}

class _NutritionCommandScreenState extends State<NutritionCommandScreen> {
  int _protein = 128;
  final int _proteinGoal = 180;
  int _calories = 1840;
  final int _caloriesGoal = 2800;
  int _carbs = 220;
  final int _carbsGoal = 300;

  final List<Map<String, dynamic>> _meals = [
    {
      'name': 'Breakfast',
      'time': '8:30 AM',
      'items': [
        {'name': 'Egg Whites (6)', 'protein': '36g'},
        {'name': 'Oatmeal', 'protein': '12g'},
        {'name': 'Whey Shake', 'protein': '25g'},
      ],
    },
    {
      'name': 'Lunch',
      'time': '1:00 PM',
      'items': [
        {'name': 'Grilled Chicken Breast', 'protein': '42g'},
        {'name': 'Brown Rice', 'protein': '5g'},
        {'name': 'Greek Yogurt', 'protein': '18g'},
      ],
    },
    {
      'name': 'Pre-Workout Snack',
      'time': '5:30 PM',
      'items': [
        {'name': 'Protein Bar', 'protein': '20g'},
        {'name': 'Banana', 'protein': '1g'},
      ],
    },
  ];

  void _showLogMealDialog() {
    final nameCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final calCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Log Meal & Protein', style: AppTypography.headlineSm),
                const SizedBox(height: 6),
                Text(
                  'Quickly log your intake to hit daily muscle recovery targets.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Text('QUICK PRESETS', style: AppTypography.labelCaps),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _presetChip(ctx, 'Whey Shake (25g)', 25, 130),
                    _presetChip(ctx, 'Chicken Breast (42g)', 42, 380),
                    _presetChip(ctx, 'Greek Yogurt (18g)', 18, 170),
                    _presetChip(ctx, 'Salmon & Rice (35g)', 35, 480),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Meal / Item Name',
                    hintText: 'e.g. Post-Workout Shake',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: proteinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          suffixText: 'g',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories (kcal)',
                          suffixText: 'kcal',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim().isNotEmpty
                          ? nameCtrl.text.trim()
                          : 'Custom Snack';
                      final p = int.tryParse(proteinCtrl.text.trim()) ?? 25;
                      final c = int.tryParse(calCtrl.text.trim()) ?? 220;
                      Navigator.pop(ctx);
                      _addMeal(name, p, c);
                    },
                    child: const Text('Add to Meal Log'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _presetChip(BuildContext ctx, String label, int protein, int cals) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.deepNavy.withOpacity(0.06),
      onPressed: () {
        Navigator.pop(ctx);
        _addMeal(label, protein, cals);
      },
    );
  }

  void _addMeal(String name, int proteinGrams, int cals) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    setState(() {
      _protein += proteinGrams;
      _calories += cals;
      _meals.insert(0, {
        'name': name,
        'time': timeStr,
        'items': [
          {'name': name, 'protein': '${proteinGrams}g'},
        ],
      });
    });

    DataPersistenceService().logProtein(
      foodName: name,
      proteinGrams: proteinGrams.toDouble(),
      calories: cals.toDouble(),
      mealType: 'Snack',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $name (+$proteinGrams g protein)!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('Nutrition Command'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Log Meal',
            onPressed: _showLogMealDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today\'s Nutrition', style: AppTypography.headlineLg),
          const SizedBox(height: 4),
          Text(
            'Track high-protein intake for muscle recovery and hypertrophy',
            style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: 24),
          // Macro rings
          SolidGlassCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _macroRing('Protein', _protein, _proteinGoal, 'g', AppColors.deepNavy),
                _macroRing('Calories', _calories, _caloriesGoal, 'kcal', AppColors.slateGrey),
                _macroRing('Carbs', _carbs, _carbsGoal, 'g', AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MEAL LOG', style: AppTypography.labelCaps),
              Text(
                '${_meals.length} meals logged',
                style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._meals.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _mealCard(
                  m['name'] as String,
                  m['time'] as String,
                  (m['items'] as List)
                      .map((item) => _food(
                            item['name'] as String,
                            item['protein'] as String,
                          ))
                      .toList(),
                ),
              )),
          const SizedBox(height: 16),
          // Quick add
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Log Meal'),
              onPressed: _showLogMealDialog,
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  static Widget _macroRing(
      String label, int current, int goal, String unit, Color color) {
    final pct = (current / goal).clamp(0.0, 1.0);
    return Column(children: [
      SizedBox(
        width: 76,
        height: 76,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 6,
            backgroundColor: AppColors.progressTrack,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$current',
                style: AppTypography.metricSm.copyWith(color: color, fontSize: 13)),
            Text(unit, style: AppTypography.labelSm.copyWith(fontSize: 9)),
          ]),
        ]),
      ),
      const SizedBox(height: 8),
      Text(label, style: AppTypography.labelSm),
      Text('/ $goal',
          style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary)),
    ]);
  }

  static Widget _mealCard(String meal, String time, List<Widget> foods) {
    return SolidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(meal, style: AppTypography.headlineSm.copyWith(fontSize: 16)),
          Text(time, style: AppTypography.labelSm),
        ]),
        const SizedBox(height: 12),
        ...foods,
      ]),
    );
  }

  static Widget _food(String name, String protein) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: AppTypography.bodySm),
        Text(protein,
            style: AppTypography.metricSm
                .copyWith(fontSize: 14, color: AppColors.deepNavy)),
      ]),
    );
  }
}
