import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Screen 8: Community Setup (replaced Institutional Verification)
///
/// Generic social features setup — community challenges, leaderboards, goals sharing.
class CommunitySetupScreen extends StatefulWidget {
  const CommunitySetupScreen({super.key});

  @override
  State<CommunitySetupScreen> createState() => _CommunitySetupScreenState();
}

class _CommunitySetupScreenState extends State<CommunitySetupScreen> {
  final _usernameController = TextEditingController();
  bool _joinCommunity = true;
  bool _shareProgress = false;
  bool _joinChallenges = true;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Community Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STEP 3 OF 4', style: AppTypography.labelCaps),
              const SizedBox(height: 4),
              const LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: AlwaysStoppedAnimation(AppColors.deepNavy),
                  minHeight: 4),
              const SizedBox(height: 32),
              Text('Join the Community', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Connect with fitness enthusiasts, join challenges, and share your progress.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
              ),
              const SizedBox(height: 40),
  
              // Community card
              SolidGlassCard(
                padding: const EdgeInsets.all(24),
                backgroundColor: AppColors.deepNavy,
                borderColor: AppColors.deepNavy,
                child: Row(
                  children: [
                    Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: AppColors.pureWhite.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.people_outline,
                            color: AppColors.pureWhite, size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LuminAI Community',
                                style: AppTypography.headlineSm
                                    .copyWith(color: AppColors.pureWhite)),
                            const SizedBox(height: 4),
                            Text('Global fitness network',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.pureWhite.withOpacity(0.7))),
                          ]),
                    ),
                    const Icon(Icons.verified_outlined,
                        color: AppColors.successGreen, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 24),
  
              // Username
              Text('DISPLAY NAME', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Choose a display name',
                  prefixIcon: Icon(Icons.alternate_email, size: 20),
                ),
              ),
              const SizedBox(height: 24),
  
              // Toggles
              _toggleRow(
                  'Join Community',
                  'Get access to leaderboards & groups',
                  Icons.groups_outlined,
                  _joinCommunity,
                  (v) => setState(() => _joinCommunity = v)),
              const SizedBox(height: 8),
              _toggleRow(
                  'Share Progress',
                  'Let others see your workout stats',
                  Icons.share_outlined,
                  _shareProgress,
                  (v) => setState(() => _shareProgress = v)),
              const SizedBox(height: 8),
              _toggleRow(
                  'Weekly Challenges',
                  'Compete in community fitness goals',
                  Icons.emoji_events_outlined,
                  _joinChallenges,
                  (v) => setState(() => _joinChallenges = v)),
              const SizedBox(height: 32),
  
              // Benefits
              Text('COMMUNITY BENEFITS', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              _benefitRow(Icons.leaderboard_outlined, 'Leaderboards',
                  'Compete with fitness enthusiasts worldwide'),
              const SizedBox(height: 8),
              _benefitRow(Icons.trending_up, 'Progress Sharing',
                  'Share milestones with your network'),
              const SizedBox(height: 8),
              _benefitRow(Icons.people_outline, 'Group Challenges',
                  'Weekly community fitness goals'),
              const SizedBox(height: 40),
  
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/goal-architect'),
                      child: const Text('Continue'))),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/goal-architect'),
                    child: Text('Skip for now',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.textTertiary))),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(String title, String sub, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return SolidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, color: AppColors.deepNavy, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(sub, style: AppTypography.labelSm),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ]),
    );
  }

  Widget _benefitRow(IconData icon, String title, String sub) {
    return SolidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, color: AppColors.deepNavy, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(sub, style: AppTypography.labelSm),
            ],
          ),
        ),
      ]),
    );
  }
}
