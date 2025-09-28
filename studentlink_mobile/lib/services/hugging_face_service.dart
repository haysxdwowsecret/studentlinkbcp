import 'dart:convert';
import 'package:http/http.dart' as http;

/// Hugging Face API Service for AI features
/// FREE alternative to expensive AI services
class HuggingFaceService {
  static final HuggingFaceService _instance = HuggingFaceService._internal();
  factory HuggingFaceService() => _instance;
  HuggingFaceService._internal();

  // Hugging Face API configuration (FREE)
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _apiKey = 'hf_your_api_key_here'; // Replace with your Hugging Face API key

  /// Get AI response for chat using Hugging Face's conversational model
  Future<String> getChatResponse(String userMessage, {String? context}) async {
    try {
      // Use Hugging Face's conversational AI model
      final response = await http.post(
        Uri.parse('$_baseUrl/microsoft/DialoGPT-medium'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': userMessage,
          'parameters': {
            'max_length': 150,
            'temperature': 0.7,
            'do_sample': true,
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is List && result.isNotEmpty) {
          return result[0]['generated_text'] ?? 'I apologize, but I cannot process that request right now.';
        }
        return 'I apologize, but I cannot process that request right now.';
      } else {
        print('Hugging Face API error: ${response.statusCode}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('Error getting AI response: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  /// Get fallback response when API is unavailable
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('concern') || message.contains('submit')) {
      return 'To submit a concern, go to the dashboard and tap "Submit Concern". You can choose the department and describe your issue.';
    } else if (message.contains('calendar') || message.contains('schedule')) {
      return 'You can find the academic calendar in the announcements section or contact the registrar\'s office for specific dates.';
    } else if (message.contains('contact') || message.contains('phone')) {
      return 'You can find contact information in the announcements section or visit the main office for assistance.';
    } else if (message.contains('library') || message.contains('hours')) {
      return 'Library hours are typically 8:00 AM to 8:00 PM on weekdays. Check the announcements for any schedule changes.';
    } else if (message.contains('enrollment') || message.contains('register')) {
      return 'For enrollment information, please visit the registrar\'s office or check the announcements for enrollment periods.';
    } else if (message.contains('grade') || message.contains('score')) {
      return 'You can check your grades through the student portal or contact your instructor for grade inquiries.';
    } else if (message.contains('uniform') || message.contains('dress')) {
      return 'Uniform policy information is available in the announcements section or student handbook.';
    } else if (message.contains('scholarship') || message.contains('financial')) {
      return 'For scholarship information, please visit the financial aid office or check the announcements for available scholarships.';
    } else {
      return 'I\'m here to help! You can ask me about submitting concerns, academic calendar, contact information, library hours, enrollment, grades, uniform policy, or scholarships.';
    }
  }

  /// Translate text using Hugging Face translation models
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final model = _getTranslationModel(targetLanguage);
      final response = await http.post(
        Uri.parse('$_baseUrl/$model'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is List && result.isNotEmpty) {
          return result[0]['translation_text'] ?? text;
        }
        return text;
      } else {
        print('Translation API error: ${response.statusCode}');
        return text;
      }
    } catch (e) {
      print('Error translating text: $e');
      return text;
    }
  }

  /// Get appropriate translation model for target language
  String _getTranslationModel(String targetLanguage) {
    final models = {
      'es': 'Helsinki-NLP/opus-mt-en-es',
      'fr': 'Helsinki-NLP/opus-mt-en-fr',
      'de': 'Helsinki-NLP/opus-mt-en-de',
      'it': 'Helsinki-NLP/opus-mt-en-it',
      'pt': 'Helsinki-NLP/opus-mt-en-pt',
      'ru': 'Helsinki-NLP/opus-mt-en-ru',
      'ja': 'Helsinki-NLP/opus-mt-en-jap',
      'ko': 'Helsinki-NLP/opus-mt-en-ko',
      'zh': 'Helsinki-NLP/opus-mt-en-zh',
      'ar': 'Helsinki-NLP/opus-mt-en-ar',
      'hi': 'Helsinki-NLP/opus-mt-en-hi',
      'th': 'Helsinki-NLP/opus-mt-en-th',
      'vi': 'Helsinki-NLP/opus-mt-en-vi',
      'id': 'Helsinki-NLP/opus-mt-en-id',
      'ms': 'Helsinki-NLP/opus-mt-en-ms',
      'tl': 'Helsinki-NLP/opus-mt-en-tl',
    };
    return models[targetLanguage] ?? 'Helsinki-NLP/opus-mt-en-es';
  }

  /// Identify language of text
  Future<String> identifyLanguage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/facebook/m2m100_418M'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Parse language identification result
        return result['language'] ?? 'en';
      } else {
        return 'en';
      }
    } catch (e) {
      print('Error identifying language: $e');
      return 'en';
    }
  }

  /// Get supported languages
  List<String> getSupportedLanguages() {
    return [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh',
      'ar', 'hi', 'th', 'vi', 'id', 'ms', 'tl'
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
    };
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }
}
