import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_config.dart';

/// Test service to verify Gemini API key is working
class GeminiTestService {
  GeminiTestService._();

  /// Test the Gemini API key by making a simple request
  static Future<GeminiTestResult> testApiKey() async {
    if (!AIConfig.useGeminiApi) {
      return GeminiTestResult(
        success: false,
        message: 'No API key configured',
      );
    }

    try {
      final model = GenerativeModel(
        model: AIConfig.defaultModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final response = await model.generateContent([
        Content.text('Reply with exactly: "API_KEY_WORKING" if you receive this message.')
      ]);

      final text = response.text?.trim() ?? '';

      if (text.contains('API_KEY_WORKING')) {
        return GeminiTestResult(
          success: true,
          message: 'API key is working correctly!',
          response: text,
        );
      } else {
        return GeminiTestResult(
          success: false,
          message: 'Unexpected response from API',
          response: text,
        );
      }
    } on GenerativeAIException catch (e) {
      return GeminiTestResult(
        success: false,
        message: _getErrorMessage(e),
        error: e.toString(),
      );
    } catch (e) {
      return GeminiTestResult(
        success: false,
        message: 'API request failed',
        error: e.toString(),
      );
    }
  }

  static String _getErrorMessage(GenerativeAIException e) {
    if (e.toString().contains('API_KEY_INVALID')) {
      return 'API Key is invalid. Please check your Gemini API key.';
    } else if (e.toString().contains('QUOTA_EXCEEDED')) {
      return 'API quota exceeded. Check your Google Cloud quota.';
    } else if (e.toString().contains('timeout')) {
      return 'Request timed out. Check your internet connection.';
    } else if (e.toString().contains('permission')) {
      return 'API key does not have permission. Enable Gemini API in Google Cloud Console.';
    }
    return e.toString();
  }
}

class GeminiTestResult {
  final bool success;
  final String message;
  final String? response;
  final String? error;

  GeminiTestResult({
    required this.success,
    required this.message,
    this.response,
    this.error,
  });
}