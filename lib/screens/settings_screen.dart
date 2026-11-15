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
        _navRow(Icons.info_outline, 'About LuminAI', 'v1.0.0 (Production Build)', _showAboutSheet),
        const SizedBox(height: 8),
        _navRow(Icons.privacy_tip_outlined, 'Privacy Policy', 'On-device vision & data security', _showPrivacyPolicy),
        const SizedBox(height: 8),
        _navRow(Icons.description_outlined, 'Terms & Health Disclaimer', 'Fitness advisory & safety', _showTermsOfService),
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

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage('assets/LuminAI.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LuminAI', style: AppTypography.headlineSm),
                        Text(
                          'v1.0.0 (Production Release)',
                          style: AppTypography.labelSm.copyWith(color: AppColors.infoBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'LuminAI is an elite, cross-platform personal fitness trainer powered by on-device computer vision and generative AI. It tracks body biomechanics in real-time, counts reps with hysteresis filtering, provides priority voice coaching, and generates customized workout plans.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 24),
              Text('CORE ARCHITECTURE & TECH STACK', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              _techItem('Computer Vision', 'Google ML Kit Pose Detection (33 3D landmarks @ 30 FPS on-device)'),
              _techItem('Kinematics Engine', 'Quadrant-aware joint trigonometry (atan2), moving-average smoothing, and hysteresis state machine'),
              _techItem('Generative AI', 'Google Gemini 1.5 Flash (dynamic plan synthesis with offline heuristic fallback)'),
              _techItem('Voice Coaching', 'Asynchronous TTS with priority queues, message deduplication, and cooldown ducking'),
              _techItem('Hybrid Persistence', 'High-throughput local SQLite database + Firebase Cloud Firestore sync'),
              _techItem('Cross-Platform', 'Flutter 3.x supporting Android, Web, iOS, macOS, Windows, Linux'),
              const SizedBox(height: 20),
              Text('DEVELOPER & LICENSE', style: AppTypography.labelCaps),
              const SizedBox(height: 12),
              _techItem('Author', 'Prakhyat (Lead Architect & Developer)'),
              _techItem('License', 'MIT Open-Source License'),
              _techItem('Live Web Demo', 'https://truckload-optimizer-eztke.web.app'),
              _techItem('GitHub Repository', 'https://github.com/Prakhyat05/LuminAI'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '100% On-Device Computer Vision Processing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'LuminAI executes all skeletal pose detection, landmark inference, and angle calculations strictly on your local device hardware. Camera video frames and images are NEVER uploaded to any cloud server, stored externally, or shared with third parties.',
              ),
              SizedBox(height: 12),
              Text(
                'Data Collection & Telemetry',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Telemetry such as rep counts, workout duration, and step counts are stored locally in your device SQLite database. Cloud synchronization via Firebase Firestore occurs only for authenticated user profiles with encryption in transit and at rest.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms & Health Advisory'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fitness & Health Advisory Disclaimer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'LuminAI is an athletic conditioning tool designed to provide biomechanical form feedback and rep tracking. It does NOT provide medical advice, diagnosis, or treatment. Consult a physician before beginning any physical exercise regimen.',
              ),
              SizedBox(height: 12),
              Text(
                'User Responsibility',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Users are solely responsible for ensuring adequate workout space, appropriate warmup, and safe execution within personal physical capabilities.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  Widget _techItem(String title, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
            const SizedBox(height: 2),
            Text(desc, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );

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
