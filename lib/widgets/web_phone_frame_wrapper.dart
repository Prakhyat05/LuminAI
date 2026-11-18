import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps the application inside a luxury iPhone 15 Pro mockup frame when running
/// on desktop/web browser viewports (> 600px).
///
/// On mobile devices (<= 600px width), it automatically passes through the native UI
/// to provide a true full-screen mobile experience.
class WebPhoneFrameWrapper extends StatefulWidget {
  final Widget child;

  const WebPhoneFrameWrapper({
    super.key,
    required this.child,
  });

  @override
  State<WebPhoneFrameWrapper> createState() => _WebPhoneFrameWrapperState();
}

class _WebPhoneFrameWrapperState extends State<WebPhoneFrameWrapper> {
  bool _usePhoneFrame = true;

  @override
  Widget build(BuildContext context) {
    // Only apply on Web when viewport is desktop/tablet width (> 600px)
    if (!kIsWeb) {
      return widget.child;
    }

    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width <= 600 || !_usePhoneFrame) {
      // Normal mobile view (or toggled to full width)
      return Stack(
        children: [
          widget.child,
          if (kIsWeb && screenSize.width > 600)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: const Color(0xFF00E5FF),
                elevation: 6,
                onPressed: () => setState(() => _usePhoneFrame = true),
                icon: const Icon(Icons.phone_iphone_rounded, size: 20),
                label: const Text(
                  'Switch to Phone Frame',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      );
    }

    // iPhone 15 Pro Logical Dimensions
    const double screenW = 393.0;
    const double screenH = 852.0;
    const double bezelThickness = 12.0;
    const double frameW = screenW + (bezelThickness * 2);
    const double frameH = screenH + (bezelThickness * 2);
    const double cornerRadius = 50.0;
    const double screenRadius = 42.0;

    // Available height inside viewport (leaving room for header & margins)
    final double maxAvailableH = (screenSize.height - 110.0).clamp(480.0, 920.0);

    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF070A13),
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.3,
            colors: [
              Color(0xFF0F172A), // Deep Cyber Navy
              Color(0xFF060911), // Obsidian Black
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glowing background orbs
            Positioned(
              left: -100,
              top: screenSize.height * 0.2,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F2FE).withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              right: -100,
              bottom: screenSize.height * 0.15,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withOpacity(0.04),
                ),
              ),
            ),

            // Main Layout
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation & Control Header
                  _buildStudioHeader(context),

                  // Center Workspace
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Feature Sidebar (visible on wider screens)
                          if (screenSize.width >= 1150)
                            Expanded(
                              flex: 3,
                              child: _buildLeftInfoCard(),
                            ),

                          // Center: iPhone 15 Pro Mockup
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              height: maxAvailableH,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: _buildIPhoneChassis(
                                  frameW: frameW,
                                  frameH: frameH,
                                  screenW: screenW,
                                  screenH: screenH,
                                  bezelThickness: bezelThickness,
                                  cornerRadius: cornerRadius,
                                  screenRadius: screenRadius,
                                ),
                              ),
                            ),
                          ),

                          // Right Quick Actions Sidebar (visible on wider screens)
                          if (screenSize.width >= 1150)
                            Expanded(
                              flex: 3,
                              child: _buildRightActionCard(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Studio Top Header Bar
  Widget _buildStudioHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C101B).withOpacity(0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Brand Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  'LUMINAI',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'LIVE MOBILE DEMO',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Device Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Apple iPhone 15 Pro • iOS 18',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Spacer(),

          // Quick Route Buttons
          _navChip('Dashboard', '/home'),
          const SizedBox(width: 8),
          _navChip('Live AI', '/live-ai', isPrimary: true),
          const SizedBox(width: 8),
          _navChip('Gemini Plan', '/ai-plan'),
          const SizedBox(width: 8),
          _navChip('Nutrition', '/nutrition'),
          const SizedBox(width: 8),
          _navChip('Analytics', '/progress-report'),
          const SizedBox(width: 16),

          // Viewport Toggle Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Color(0xFF334155)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => setState(() => _usePhoneFrame = false),
            icon: const Icon(Icons.fullscreen_rounded, size: 18),
            label: const Text('Full View', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _navChip(String label, String route, {bool isPrimary = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final nav = Navigator.of(context);
        nav.pushNamed(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF00E5FF).withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF00E5FF).withOpacity(0.4)
                : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? const Color(0xFF00E5FF) : const Color(0xFFE2E8F0),
            fontSize: 12,
            fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Authentic iPhone 15 Pro Chassis with Buttons, Dynamic Island & Status Bar
  Widget _buildIPhoneChassis({
    required double frameW,
    required double frameH,
    required double screenW,
    required double screenH,
    required double bezelThickness,
    required double cornerRadius,
    required double screenRadius,
  }) {
    return Container(
      width: frameW,
      height: frameH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius),
        // Titanium Chassis Gradient
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A4E5C), // Outer titanium edge highlight
            Color(0xFF282B34),
            Color(0xFF1E2028),
            Color(0xFF363A46),
          ],
        ),
        boxShadow: [
          // Heavy diffuse ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.65),
            blurRadius: 50,
            spreadRadius: 8,
            offset: const Offset(0, 22),
          ),
          // Subtle neon backlight glow
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.12),
            blurRadius: 35,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(bezelThickness),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(screenRadius),
            border: Border.all(color: const Color(0xFF0D0F16), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenRadius - 2),
            child: Stack(
              children: [
                // 1. The Real Live Flutter App (with iPhone 15 Pro MediaQuery override)
                Positioned.fill(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(screenW, screenH),
                      padding: const EdgeInsets.only(top: 48, bottom: 28),
                      viewInsets: EdgeInsets.zero,
                      devicePixelRatio: 3.0,
                    ),
                    child: widget.child,
                  ),
                ),

                // 2. Dynamic Island Capsule at Top
                Positioned(
                  top: 11,
                  left: (screenW - 116) / 2,
                  child: Container(
                    width: 116,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Camera lens dot with subtle blue reflection
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E284A),
                            border: Border.all(color: const Color(0xFF2A3968), width: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. iOS Status Bar (Clock & Icons)
                Positioned(
                  top: 14,
                  left: 24,
                  child: Text(
                    _getFormattedTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 22,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Signal bars
                      const Icon(Icons.signal_cellular_alt_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      // 5G
                      const Text(
                        '5G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Battery icon
                      Container(
                        width: 22,
                        height: 11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.5),
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. iOS Home Indicator Bar at Bottom
                Positioned(
                  bottom: 8,
                  left: (screenW - 134) / 2,
                  child: Container(
                    width: 134,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Left Sidebar: Features & Engineering Architecture
  Widget _buildLeftInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LUMINAI ARCHITECTURE',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Precision Biomechanical AI Vision',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Experience real-time computer vision pose tracking, automated rep counting, and personalized generative AI coaching right inside the iPhone simulation.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          _featureRow(Icons.remove_red_eye_rounded, '33 3D Skeletal Keypoints', 'Google ML Kit BlazePose at 30+ FPS'),
          const SizedBox(height: 14),
          _featureRow(Icons.calculate_rounded, 'Sub-50ms Kinematics', 'Quadrant-aware joint trigonometry'),
          const SizedBox(height: 14),
          _featureRow(Icons.auto_awesome_rounded, 'Gemini 1.5 Flash Architect', 'Context-aware dynamic workout routines'),
          const SizedBox(height: 14),
          _featureRow(Icons.lock_rounded, '100% On-Device Privacy', 'Zero raw camera frames streamed to servers'),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF00E5FF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Right Sidebar: Recruiter Quick Actions & Binary Downloads
  Widget _buildRightActionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'RECRUITER DEMO GUIDE',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Instant Evaluation Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '1. Tap "Continue as Guest" on the Auth gateway for instant access.\n2. In Live Tracking, switch to "Studio Mode" to simulate real-time pose estimation.\n3. Log meals in Nutrition Command to test live macro balancing.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),
          const Text(
            'PRODUCTION RELEASES',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _downloadBadge(
            icon: Icons.android_rounded,
            title: 'Android APK (v1.0.0)',
            size: '53.7 MB (arm64)',
            url: 'https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-arm64-v1.0.0.apk',
          ),
          const SizedBox(height: 10),
          _downloadBadge(
            icon: Icons.video_library_rounded,
            title: '1080p Walkthrough Video',
            size: '4.55 MB (MP4)',
            url: 'https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-App-Walkthrough-16x9.mp4',
          ),
          const SizedBox(height: 10),
          _downloadBadge(
            icon: Icons.code_rounded,
            title: 'GitHub Source & Releases',
            size: 'MIT Licensed',
            url: 'https://github.com/Prakhyat05/LuminAI',
          ),
        ],
      ),
    );
  }

  Widget _downloadBadge({
    required IconData icon,
    required String title,
    required String size,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  size,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white38),
        ],
      ),
    );
  }
}
