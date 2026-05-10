import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';

/// Screen 5: Authentication Gateway
///
/// Multi-auth: Email/Password sign in/up, Phone OTP, Google Sign-In.
class AuthGatewayScreen extends StatefulWidget {
  const AuthGatewayScreen({super.key});

  @override
  State<AuthGatewayScreen> createState() => _AuthGatewayScreenState();
}

class _AuthGatewayScreenState extends State<AuthGatewayScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    AuthResult result;
    if (_isLogin) {
      result = await _auth.signInWithEmail(
          _emailController.text.trim(), _passwordController.text);
    } else {
      result = await _auth.signUpWithEmail(_emailController.text.trim(),
          _passwordController.text, _nameController.text.trim());
    }
    if (result.isSuccess) {
      if (mounted) Navigator.pushReplacementNamed(context, '/identity-setup');
    } else {
      setState(() {
        _loading = false;
        _error = result.error;
      });
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _auth.signInWithGoogle();
    if (result.isSuccess) {
      if (mounted) Navigator.pushReplacementNamed(context, '/identity-setup');
    } else {
      setState(() {
        _loading = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ─── Logo ──────────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.deepNavy, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bolt_outlined,
                    color: AppColors.deepNavy, size: 28),
              ),
              const SizedBox(height: 32),

              // ─── Header ────────────────────────────────────
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to continue your training journey'
                    : 'Join the LuminAI elite training ecosystem',
                style:
                    AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
              ),
              const SizedBox(height: 40),

              // ─── Toggle ────────────────────────────────────
              SolidGlassCard(
                padding: const EdgeInsets.all(4),
                borderColor: AppColors.outlineVariant,
                child: Row(
                  children: [
                    Expanded(
                        child: _tabButton('Sign In', _isLogin, () {
                      setState(() => _isLogin = true);
                    })),
                    Expanded(
                        child: _tabButton('Sign Up', !_isLogin, () {
                      setState(() => _isLogin = false);
                    })),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ─── Name Field (Sign Up only) ──────────────────
              if (!_isLogin) ...[
                Text('FULL NAME', style: AppTypography.labelCaps),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Your full name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ─── Email Field ───────────────────────────────
              Text('EMAIL', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'your@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Password Field ────────────────────────────
              Text('PASSWORD', style: AppTypography.labelCaps),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ],

              // ─── Error ──────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // ─── Submit Button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitEmail,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.pureWhite))
                      : Text(_isLogin ? 'Sign In' : 'Create Account'),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Divider ───────────────────────────────────
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: AppTypography.labelCaps),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Phone OTP Login ────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/phone-otp'),
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  label: const Text('Continue with Phone'),
                ),
              ),
              const SizedBox(height: 12),

              // ─── Google Login ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _googleSignIn,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.deepNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.button.copyWith(
              color: active ? AppColors.pureWhite : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
