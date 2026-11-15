import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  if (apiKey.isEmpty) {
    print('❌ Error: GEMINI_API_KEY is not set.');
    print('Run with: dart --define=GEMINI_API_KEY="your_api_key" test_gemini.dart');
    return;
  }

  print('Testing Gemini API Key...\n');

  // Try different model names
  final modelNames = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-1.0-pro',
    'gemini-pro',
  ];

  for (final modelName in modelNames) {
    print('Testing model: $modelName');
    try {
      final model = GenerativeModel(model: modelName, apiKey: apiKey);

      final response = await model.generateContent([
        Content.text('Say "OK" if you receive this.')
      ]);

      final text = response.text?.trim() ?? '';
      if (text.isNotEmpty) {
        print('✅ SUCCESS with model: $modelName');
        print('Response: $text');
        return;
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('not supported')) {
        print('  ❌ Model not supported');
      } else if (errorMsg.contains('not found')) {
        print('  ❌ Model not found');
      } else {
        print('  ❌ Error: ${errorMsg.split('\n').first}');
      }
    }
  }

  print('\n❌ No working model found. The API key may not have access to Gemini.');
  print('Possible causes:');
  print('1. API key is from wrong project');
  print('2. Gemini API not enabled in Google Cloud Console');
  print('3. API key has restrictions (e.g., API key restrictions, quota)');
}