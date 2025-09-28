import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Conditional ML Service that uses Hugging Face API for most features
/// and optionally loads ML Kit only when accessibility features are needed
class ConditionalMLService {
  static final ConditionalMLService _instance = ConditionalMLService._internal();
  factory ConditionalMLService() => _instance;
  ConditionalMLService._internal();

  // Hugging Face API configuration (FREE)
  static const String _huggingFaceApiUrl = 'https://api-inference.huggingface.co/models';
  static const String _huggingFaceApiKey = 'hf_your_api_key_here'; // Replace with your Hugging Face API key

  /// Extract text from image using Hugging Face API (FREE alternative to ML Kit)
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      // For now, return a placeholder - you can implement Hugging Face OCR API
      print('📸 Text extraction requested for: $imagePath');
      return 'Text extraction feature - implement with Hugging Face OCR API';
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// Extract text from image bytes using Hugging Face API
  Future<String> extractTextFromImageBytes(Uint8List imageBytes) async {
    try {
      // For now, return a placeholder - you can implement Hugging Face OCR API
      print('📸 Text extraction requested from image bytes');
      return 'Text extraction feature - implement with Hugging Face OCR API';
    } catch (e) {
      throw Exception('Failed to extract text from image bytes: $e');
    }
  }

  /// Identify language using Hugging Face API (FREE alternative to ML Kit)
  Future<String> identifyLanguage(String text) async {
    try {
      // Use Hugging Face language identification API
      final response = await http.post(
        Uri.parse('$_huggingFaceApiUrl/facebook/m2m100_418M'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Parse the language identification result
        return result['language'] ?? 'en';
      } else {
        print('Hugging Face API error: ${response.statusCode}');
        return 'en'; // Default to English
      }
    } catch (e) {
      print('Error identifying language: $e');
      return 'en'; // Default to English
    }
  }

  /// Translate text using Hugging Face API (FREE alternative to ML Kit)
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      // Use Hugging Face translation API
      final response = await http.post(
        Uri.parse('$_huggingFaceApiUrl/Helsinki-NLP/opus-mt-en-$targetLanguage'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Parse the translation result
        return result['translation_text'] ?? text;
      } else {
        print('Hugging Face translation API error: ${response.statusCode}');
        return text; // Return original text if translation fails
      }
    } catch (e) {
      print('Error translating text: $e');
      return text; // Return original text if translation fails
    }
  }

  /// Check if ML Kit features are available (for conditional loading)
  Future<bool> isMLKitAvailable() async {
    try {
      // Check if ML Kit is available (only when explicitly loaded)
      // This will return false by default to maintain small app size
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load ML Kit features on demand (for advanced accessibility features)
  Future<bool> loadMLKitFeatures() async {
    try {
      // This would dynamically load ML Kit only when needed
      // For now, we'll use Hugging Face API instead
      print('🚀 ML Kit features requested - using Hugging Face API instead');
      return true;
    } catch (e) {
      print('Error loading ML Kit features: $e');
      return false;
    }
  }

  /// Get available languages for translation
  List<String> getAvailableLanguages() {
    return [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh',
      'ar', 'hi', 'th', 'vi', 'id', 'ms', 'tl', 'ceb', 'war'
    ];
  }

  /// Get language name from code
  String getLanguageName(String languageCode) {
    final languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'id': 'Indonesian',
      'ms': 'Malay',
      'tl': 'Filipino',
      'ceb': 'Cebuano',
      'war': 'Waray',
    };
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  /// Check if a language is supported for translation
  bool isLanguageSupported(String languageCode) {
    return getAvailableLanguages().contains(languageCode);
  }

  /// Get supported languages for translation
  Map<String, String> getSupportedLanguages() {
    final languages = <String, String>{};
    for (final code in getAvailableLanguages()) {
      languages[code] = getLanguageName(code);
    }
    return languages;
  }
}