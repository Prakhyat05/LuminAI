import 'package:flutter/material.dart';
import '../../services/gemini_test_service.dart';
import '../../services/ai_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Debug screen to test Gemini API key
class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});
  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  bool _loading = false;
  GeminiTestResult? _result;

  Future<void> _testApi() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    final result = await GeminiTestService.testApiKey();

    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('Test Gemini API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SolidGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key, color: AppColors.deepNavy),
                      const SizedBox(width: 8),
                      Text('API Key Status', style: AppTypography.headlineSm),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AIConfig.useGeminiApi
                        ? '${AIConfig.geminiApiKey.substring(0, 6)}...${AIConfig.geminiApiKey.substring(AIConfig.geminiApiKey.length - 4)} (Active)'
                        : 'No API key set (--dart-define=GEMINI_API_KEY=...)',
                    style: AppTypography.bodySm.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _testApi,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_loading ? 'Testing...' : 'Test API Key'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              SolidGlassCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: _result!.success
                    ? AppColors.successGreen.withOpacity(0.1)
                    : AppColors.errorRed.withOpacity(0.1),
                borderColor: _result!.success
                    ? AppColors.successGreen
                    : AppColors.errorRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.success
                              ? Icons.check_circle
                              : Icons.error,
                          color: _result!.success
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _result!.success ? 'SUCCESS' : 'FAILED',
                          style: AppTypography.labelCaps.copyWith(
                            color: _result!.success
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result!.message,
                      style: AppTypography.bodyMd,
                    ),
                    if (_result!.response != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Response: ${_result!.response}',
                        style: AppTypography.bodySm.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (_result!.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${_result!.error}',
                        style: AppTypography.bodySm.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}