import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../models/exercise.dart';
import '../data/exercise_database.dart';

/// Screen 12: Exercise Library — Searchable grid with category tabs.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});
  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  WorkoutCategory? _selectedCategory;
  Difficulty? _selectedDifficulty;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Exercise> get _filteredExercises {
    return ExerciseDatabase.all.where((e) {
      if (_selectedCategory != null && e.category != _selectedCategory) {
        return false;
      }
      if (_selectedDifficulty != null && e.difficulty != _selectedDifficulty) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !e.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !e.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Category tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip(null, 'All',
                      Icons.grid_view_outlined),
                  ...WorkoutCategory.values.map(
                      (c) => _categoryChip(c, c.label, c.icon)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Difficulty filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _difficultyChip(null, 'Any Level'),
                  ...Difficulty.values
                      .map((d) => _difficultyChip(d, d.label)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Count
            Text('${exercises.length} exercises',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_outlined,
                              size: 48,
                              color:
                                  AppColors.textTertiary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No exercises found',
                              style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.textTertiary)),
                          const SizedBox(height: 8),
                          TextButton(
                              onPressed: () => setState(() {
                                    _selectedCategory = null;
                                    _selectedDifficulty = null;
                                    _searchQuery = '';
                                    _searchController.clear();
                                  }),
                              child: const Text('Clear filters')),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600
                                ? 3
                                : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: exercises.length,
                      itemBuilder: (ctx, i) {
                        final e = exercises[i];
                        return _exerciseCard(context, e);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, Exercise e) {
    return SolidGlassCard(
      onTap: () => Navigator.pushNamed(context, '/exercise-detail',
          arguments: e),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Icon(e.icon, color: AppColors.deepNavy, size: 24),
          ),
          const SizedBox(height: 10),
          Text(e.name,
              style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(e.muscleGroup, style: AppTypography.labelSm),
          const SizedBox(height: 6),
          // Difficulty + calorie badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: e.difficulty.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e.difficulty.label,
                    style: AppTypography.labelSm.copyWith(
                        fontSize: 9,
                        color: e.difficulty.color,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              Text('${e.estimatedCalories} kcal',
                  style: AppTypography.labelSm.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
      WorkoutCategory? category, String label, IconData icon) {
    final active = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.deepNavy : AppColors.pureWhite,
            border: Border.all(
                color: active
                    ? AppColors.deepNavy
                    : AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: active
                      ? AppColors.pureWhite
                      : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTypography.labelSm.copyWith(
                      color: active
                          ? AppColors.pureWhite
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyChip(Difficulty? diff, String label) {
    final active = _selectedDifficulty == diff;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = diff),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? (diff?.color ?? AppColors.deepNavy).withOpacity(0.12)
                : Colors.transparent,
            border: Border.all(
                color: active
                    ? (diff?.color ?? AppColors.deepNavy)
                    : AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              style: AppTypography.labelSm.copyWith(
                  color: active
                      ? (diff?.color ?? AppColors.deepNavy)
                      : AppColors.textTertiary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11)),
        ),
      ),
    );
  }
}
