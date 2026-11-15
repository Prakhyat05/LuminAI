import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../services/auth_service.dart';
import '../services/tts_service.dart';

/// Screen 25: System Settings — Dynamic profile, dark mode, sign out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false, _voiceCoach = true, _healthSync = true, _autoSync = true;
  String _userName = 'User';
  String _userInfo = 'LuminAI Member';
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _voiceCoach = TTSService().enabled;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _auth.getProfile();
    if (mounted) {
      setState(() {
        _userName = profile['name'] ?? 'User';
        final level = profile['fitnessLevel'] ?? 'Beginner';
        final email = profile['email'] ?? '';
        _userInfo = email.isNotEmpty ? '$email • $level' : level;
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        // Profile
        SolidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepNavy.withOpacity(0.08)),
                child: const Icon(Icons.person_outline,
                    color: AppColors.deepNavy, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: AppTypography.headlineSm),
                    Text(_userInfo,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.textTertiary)),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ]),
        ),
        const SizedBox(height: 24),
        Text('APPEARANCE', style: AppTypography.labelCaps),
        const SizedBox(height: 12),
        _toggleRow(Icons.dark_mode_outlined, 'Dark Mode',
            'Switch to dark theme', _darkMode,
            (v) => setState(() => _darkMode = v)),
        const SizedBox(height: 24),
        Text('TRAINING', style: AppTypography.labelCaps),
        const SizedBox(height: 12),
        _toggleRow(Icons.mic_outlined, 'Voice Coach',
            'TTS rep counting & form alerts', _voiceCoach, (v) {
          setState(() => _voiceCoach = v);
          TTSService().setEnabled(v);
        }),
        const SizedBox(height: 24),
        Text('DATA & SYNC', style: AppTypography.labelCaps),
        const SizedBox(height: 12),
        _toggleRow(Icons.favorite_border, 'Health Sync',
            'Sync with health platform', _healthSync,
            (v) => setState(() => _healthSync = v)),
        const SizedBox(height: 8),
        _toggleRow(Icons.sync_outlined, 'Auto-Sync',
            'Persist data to local database', _autoSync,
            (v) => setState(() => _autoSync = v)),
        const SizedBox(height: 24),
        Text('ABOUT', style: AppTypography.labelCaps),
        const SizedBox(height: 12),
        _navRow(Icons.info_outline, 'About LuminAI', 'v1.0.0 (Production)', () {
          showAboutDialog(
            context: context,
            applicationName: 'LuminAI',
            applicationVersion: '1.0.0',
            applicationIcon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/LuminAI.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            children: const [
              Text(
                'LuminAI is an elite AI personal trainer featuring on-device real-time pose tracking with Google ML Kit, biomechanical joint angle analysis, Google Gemini generative AI workout planning, and priority-queued audio coaching.',
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        _navRow(Icons.privacy_tip_outlined, 'Privacy Policy', '', () {}),
        const SizedBox(height: 8),
        _navRow(Icons.description_outlined, 'Terms of Service', '', () {}),
        const SizedBox(height: 32),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed)),
                child: const Text('Sign Out'))),
      ]),
    );
  }

  Widget _toggleRow(IconData icon, String title, String sub, bool value,
          ValueChanged<bool> onChanged) =>
      SolidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, color: AppColors.deepNavy, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: AppTypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
                if (sub.isNotEmpty) Text(sub, style: AppTypography.labelSm),
              ])),
          Switch(value: value, onChanged: onChanged),
        ]),
      );

  Widget _navRow(IconData icon, String title, String sub,
          VoidCallback onTap) =>
      SolidGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, color: AppColors.deepNavy, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: AppTypography.bodyMd),
                if (sub.isNotEmpty) Text(sub, style: AppTypography.labelSm),
              ])),
          const Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: 20),
        ]),
      );
}
