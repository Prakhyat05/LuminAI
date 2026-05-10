import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';

/// Screen 6: Identity Setup
///
/// Personal profile — name, age, fitness level.
class IdentitySetupScreen extends StatefulWidget {
  const IdentitySetupScreen({super.key});

  @override
  State<IdentitySetupScreen> createState() => _IdentitySetupScreenState();
}

class _IdentitySetupScreenState extends State<IdentitySetupScreen> {
  final _nameController = TextEditingController();
  int _age = 25;
  String _fitnessLevel = 'Beginner';
  final _fitnessLevels = ['Beginner', 'Intermediate', 'Advanced', 'Elite'];
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final name = await _auth.currentUserName;
    if (name != 'User' && name.isNotEmpty) {
      _nameController.text = name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await _auth.updateProfile(
          name: name, age: _age, fitnessLevel: _fitnessLevel);
    }
    if (mounted) Navigator.pushNamed(context, '/biodata-calibration');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Identity Setup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Step indicator ───────────────────────────────
              Text('STEP 1 OF 4', style: AppTypography.labelCaps),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.25,
                backgroundColor: AppColors.progressTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.deepNavy),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 32),

              // ─── Header ──────────────────────────────────────
              Text('Tell us about yourself', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                'We\'ll personalize your training experience based on your profile.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
              ),
              const SizedBox(height: 40),

              // ─── Avatar ──────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepNavy.withOpacity(0.08),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(Icons.person_outline,
                          size: 40, color: AppColors.deepNavy),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.deepNavy),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 16, color: AppColors.pureWhite),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ─── Full Name ───────────────────────────────────
              Text('FULL NAME', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Age ─────────────────────────────────────────
              Text('AGE', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              SolidGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_age > 13) setState(() => _age--);
                      },
                    ),
                    Text('$_age', style: AppTypography.metricMd),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (_age < 99) setState(() => _age++);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Fitness Level ───────────────────────────────
              Text('FITNESS LEVEL', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fitnessLevels.map((level) {
                  final selected = level == _fitnessLevel;
                  return GestureDetector(
                    onTap: () => setState(() => _fitnessLevel = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.deepNavy
                            : AppColors.pureWhite,
                        border: Border.all(
                            color: selected
                                ? AppColors.deepNavy
                                : AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(level,
                          style: AppTypography.button.copyWith(
                              color: selected
                                  ? AppColors.pureWhite
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),

              // ─── Continue ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
