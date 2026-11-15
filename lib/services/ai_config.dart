/// Centralized AI configuration for LuminAI.
/// Holds API keys and model settings for all AI operations.
class AIConfig {
  AIConfig._();

  /// Gemini API Key for generative AI features.
  /// Provide via: `flutter run --dart-define=GEMINI_API_KEY=your_key`
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Default Gemini model
  static const String defaultModel = 'gemini-1.5-flash';

  /// Whether to use the real Gemini API or fallback to local generation
  static bool get useGeminiApi => geminiApiKey.isNotEmpty;
}
