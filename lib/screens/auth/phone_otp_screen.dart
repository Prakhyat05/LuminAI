import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/auth_service.dart';

/// Phone OTP verification screen.
/// Two-step flow: phone input → 6-digit OTP entry with auto-focus.
class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});
  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocuses = List.generate(6, (_) => FocusNode());
  final _auth = AuthService();

  bool _otpSent = false;
  bool _verifying = false;
  String? _error;
  String? _otpHint;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocuses) {
      f.dispose();
    }
    _resendTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }
    setState(() {
      _error = null;
      _verifying = true;
    });
    final result = await _auth.sendPhoneOTP(phone);
    setState(() {
      _verifying = false;
      if (result.isSuccess) {
        _otpSent = true;
        _otpHint = result.message; // Shows mock OTP for testing
        _startResendTimer();
        _animController.forward(from: 0);
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    setState(() {
      _error = null;
      _verifying = true;
    });
    final result =
        await _auth.verifyPhoneOTP(code, _phoneController.text.trim());
    if (result.isSuccess) {
      if (mounted) Navigator.pushReplacementNamed(context, '/identity-setup');
    } else {
      setState(() {
        _verifying = false;
        _error = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_otpSent) {
              setState(() => _otpSent = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(_otpSent ? 'Verify OTP' : 'Phone Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: _otpSent ? _buildOtpEntry() : _buildPhoneInput(),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.deepNavy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.phone_android_outlined,
              color: AppColors.deepNavy, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Enter your phone number', style: AppTypography.headlineLg),
        const SizedBox(height: 8),
        Text(
          'We\'ll send you a 6-digit verification code',
          style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
        ),
        const SizedBox(height: 40),
        Text('PHONE NUMBER', style: AppTypography.labelCaps),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('+91',
                  style: AppTypography.bodyMd
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: const InputDecoration(
                  hintText: '9876543210',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.errorRed)),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifying ? null : _sendOtp,
            child: _verifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.pureWhite))
                : const Text('Send OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpEntry() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.sms_outlined,
                color: AppColors.successGreen, size: 32),
          ),
          const SizedBox(height: 24),
          Text('Verification Code', style: AppTypography.headlineLg),
          const SizedBox(height: 8),
          Text(
            'Sent to ${_phoneController.text}',
            style: AppTypography.bodyMd.copyWith(color: AppColors.slateGrey),
          ),
          if (_otpHint != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_otpHint!,
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.infoBlue)),
            ),
          ],
          const SizedBox(height: 40),
          // OTP digit boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                width: 48,
                height: 56,
                margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocuses[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1)
                  ],
                  style: AppTypography.metricMd,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.deepNavy, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _otpFocuses[i + 1].requestFocus();
                    }
                    if (val.isEmpty && i > 0) {
                      _otpFocuses[i - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.errorRed)),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifying ? null : _verifyOtp,
              child: _verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.pureWhite))
                  : const Text('Verify & Continue'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _resendCountdown > 0 ? null : _sendOtp,
            child: Text(
              _resendCountdown > 0
                  ? 'Resend in ${_resendCountdown}s'
                  : 'Resend OTP',
              style: AppTypography.bodySm.copyWith(
                color: _resendCountdown > 0
                    ? AppColors.textTertiary
                    : AppColors.deepNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
