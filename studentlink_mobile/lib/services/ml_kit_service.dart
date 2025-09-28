import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class MLKitService {
  static final MLKitService _instance = MLKitService._internal();
  factory MLKitService() => _instance;
  MLKitService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  /// Extract text from image using ML Kit Text Recognition
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// Extract text from image bytes
  Future<String> extractTextFromImageBytes(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(1000, 1000), // Default size, will be adjusted
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1000,
        ),
      );
      
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text from image bytes: $e');
    }
  }

  /// Identify the language of the given text
  Future<String> identifyLanguage(String text) async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(text);
      
      if (languageCode != _languageIdentifier.undeterminedLanguageCode) {
        return languageCode;
      }
      return 'en'; // Default to English
    } catch (e) {
      throw Exception('Failed to identify language: $e');
    }
  }

  /// Convert language code to TranslateLanguage enum
  TranslateLanguage _getTranslateLanguage(String languageCode) {
    switch (languageCode) {
      case 'af': return TranslateLanguage.afrikaans;
      case 'sq': return TranslateLanguage.albanian;
      case 'ar': return TranslateLanguage.arabic;
      case 'be': return TranslateLanguage.belarusian;
      case 'bn': return TranslateLanguage.bengali;
      case 'bg': return TranslateLanguage.bulgarian;
      case 'ca': return TranslateLanguage.catalan;
      case 'zh': return TranslateLanguage.chinese;
      case 'hr': return TranslateLanguage.croatian;
      case 'cs': return TranslateLanguage.czech;
      case 'da': return TranslateLanguage.danish;
      case 'nl': return TranslateLanguage.dutch;
      case 'en': return TranslateLanguage.english;
      case 'eo': return TranslateLanguage.esperanto;
      case 'et': return TranslateLanguage.estonian;
      case 'fi': return TranslateLanguage.finnish;
      case 'fr': return TranslateLanguage.french;
      case 'gl': return TranslateLanguage.galician;
      case 'ka': return TranslateLanguage.georgian;
      case 'de': return TranslateLanguage.german;
      case 'el': return TranslateLanguage.greek;
      case 'gu': return TranslateLanguage.gujarati;
      case 'ht': return TranslateLanguage.haitian;
      case 'he': return TranslateLanguage.hebrew;
      case 'hi': return TranslateLanguage.hindi;
      case 'hu': return TranslateLanguage.hungarian;
      case 'is': return TranslateLanguage.icelandic;
      case 'id': return TranslateLanguage.indonesian;
      case 'ga': return TranslateLanguage.irish;
      case 'it': return TranslateLanguage.italian;
      case 'ja': return TranslateLanguage.japanese;
      case 'kn': return TranslateLanguage.kannada;
      case 'ko': return TranslateLanguage.korean;
      case 'lv': return TranslateLanguage.latvian;
      case 'lt': return TranslateLanguage.lithuanian;
      case 'mk': return TranslateLanguage.macedonian;
      case 'ms': return TranslateLanguage.malay;
      case 'ml': return TranslateLanguage.english; // Malayalam not supported, fallback to English
      case 'mt': return TranslateLanguage.maltese;
      case 'mr': return TranslateLanguage.english; // Marathi not supported, fallback to English
      case 'mn': return TranslateLanguage.english; // Mongolian not supported, fallback to English
      case 'ne': return TranslateLanguage.english; // Nepali not supported, fallback to English
      case 'no': return TranslateLanguage.norwegian;
      case 'fa': return TranslateLanguage.persian;
      case 'pl': return TranslateLanguage.polish;
      case 'pt': return TranslateLanguage.portuguese;
      case 'pa': return TranslateLanguage.english; // Punjabi not supported, fallback to English
      case 'ro': return TranslateLanguage.romanian;
      case 'ru': return TranslateLanguage.russian;
      case 'sk': return TranslateLanguage.slovak;
      case 'sl': return TranslateLanguage.slovenian;
      case 'es': return TranslateLanguage.spanish;
      case 'sw': return TranslateLanguage.swahili;
      case 'sv': return TranslateLanguage.swedish;
      case 'tl': return TranslateLanguage.tagalog;
      case 'ta': return TranslateLanguage.tamil;
      case 'te': return TranslateLanguage.telugu;
      case 'th': return TranslateLanguage.thai;
      case 'tr': return TranslateLanguage.turkish;
      case 'uk': return TranslateLanguage.ukrainian;
      case 'ur': return TranslateLanguage.urdu;
      case 'vi': return TranslateLanguage.vietnamese;
      case 'cy': return TranslateLanguage.welsh;
      default: return TranslateLanguage.english;
    }
  }

  /// Translate text from source language to target language
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      // First identify the source language
      final sourceLanguage = await identifyLanguage(text);
      
      // Create translator for the language pair
      final translator = OnDeviceTranslator(
        sourceLanguage: _getTranslateLanguage(sourceLanguage),
        targetLanguage: _getTranslateLanguage(targetLanguage),
      );
      
      final translatedText = await translator.translateText(text);
      await translator.close();
      
      return translatedText;
    } catch (e) {
      throw Exception('Failed to translate text: $e');
    }
  }

  /// Get supported languages for translation
  List<String> getSupportedLanguages() {
    return [
      'af', 'ar', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'ceb', 'co', 'cs', 'cy', 'da', 'de', 'el', 'en', 'eo', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'fy', 'ga', 'gd', 'gl', 'gu', 'ha', 'haw', 'he', 'hi', 'hmn', 'hr', 'ht', 'hu', 'hy', 'id', 'ig', 'is', 'it', 'ja', 'jw', 'ka', 'kk', 'km', 'kn', 'ko', 'ku', 'ky', 'la', 'lb', 'lo', 'lt', 'lv', 'mg', 'mi', 'mk', 'ml', 'mn', 'mr', 'ms', 'mt', 'my', 'ne', 'nl', 'no', 'ny', 'pa', 'pl', 'ps', 'pt', 'ro', 'ru', 'rw', 'sd', 'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sq', 'sr', 'st', 'su', 'sv', 'sw', 'ta', 'te', 'tg', 'th', 'tl', 'tr', 'tt', 'ug', 'uk', 'ur', 'uz', 'vi', 'xh', 'yi', 'yo', 'zh', 'zu'
    ];
  }

  /// Get language name from language code
  String getLanguageName(String languageCode) {
    const languageNames = {
      'af': 'Afrikaans',
      'ar': 'Arabic',
      'az': 'Azerbaijani',
      'be': 'Belarusian',
      'bg': 'Bulgarian',
      'bn': 'Bengali',
      'bs': 'Bosnian',
      'ca': 'Catalan',
      'ceb': 'Cebuano',
      'co': 'Corsican',
      'cs': 'Czech',
      'cy': 'Welsh',
      'da': 'Danish',
      'de': 'German',
      'el': 'Greek',
      'en': 'English',
      'eo': 'Esperanto',
      'es': 'Spanish',
      'et': 'Estonian',
      'eu': 'Basque',
      'fa': 'Persian',
      'fi': 'Finnish',
      'fr': 'French',
      'fy': 'Frisian',
      'ga': 'Irish',
      'gd': 'Scots Gaelic',
      'gl': 'Galician',
      'gu': 'Gujarati',
      'ha': 'Hausa',
      'haw': 'Hawaiian',
      'he': 'Hebrew',
      'hi': 'Hindi',
      'hmn': 'Hmong',
      'hr': 'Croatian',
      'ht': 'Haitian Creole',
      'hu': 'Hungarian',
      'hy': 'Armenian',
      'id': 'Indonesian',
      'ig': 'Igbo',
      'is': 'Icelandic',
      'it': 'Italian',
      'ja': 'Japanese',
      'jw': 'Javanese',
      'ka': 'Georgian',
      'kk': 'Kazakh',
      'km': 'Khmer',
      'kn': 'Kannada',
      'ko': 'Korean',
      'ku': 'Kurdish',
      'ky': 'Kyrgyz',
      'la': 'Latin',
      'lb': 'Luxembourgish',
      'lo': 'Lao',
      'lt': 'Lithuanian',
      'lv': 'Latvian',
      'mg': 'Malagasy',
      'mi': 'Maori',
      'mk': 'Macedonian',
      'ml': 'Malayalam',
      'mn': 'Mongolian',
      'mr': 'Marathi',
      'ms': 'Malay',
      'mt': 'Maltese',
      'my': 'Myanmar (Burmese)',
      'ne': 'Nepali',
      'nl': 'Dutch',
      'no': 'Norwegian',
      'ny': 'Chichewa',
      'pa': 'Punjabi',
      'pl': 'Polish',
      'ps': 'Pashto',
      'pt': 'Portuguese',
      'ro': 'Romanian',
      'ru': 'Russian',
      'rw': 'Kinyarwanda',
      'sd': 'Sindhi',
      'si': 'Sinhala',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'sm': 'Samoan',
      'sn': 'Shona',
      'so': 'Somali',
      'sq': 'Albanian',
      'sr': 'Serbian',
      'st': 'Sesotho',
      'su': 'Sundanese',
      'sv': 'Swedish',
      'sw': 'Swahili',
      'ta': 'Tamil',
      'te': 'Telugu',
      'tg': 'Tajik',
      'th': 'Thai',
      'tl': 'Filipino',
      'tr': 'Turkish',
      'tt': 'Tatar',
      'ug': 'Uyghur',
      'uk': 'Ukrainian',
      'ur': 'Urdu',
      'uz': 'Uzbek',
      'vi': 'Vietnamese',
      'xh': 'Xhosa',
      'yi': 'Yiddish',
      'yo': 'Yoruba',
      'zh': 'Chinese',
      'zu': 'Zulu',
    };
    
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  /// Process image and extract text with language detection and translation
  Future<Map<String, dynamic>> processImageWithTranslation(
    String imagePath, 
    String targetLanguage
  ) async {
    try {
      // Extract text from image
      final extractedText = await extractTextFromImage(imagePath);
      
      if (extractedText.isEmpty) {
        return {
          'success': false,
          'message': 'No text found in the image',
          'extractedText': '',
          'sourceLanguage': '',
          'translatedText': '',
        };
      }

      // Identify source language
      final sourceLanguage = await identifyLanguage(extractedText);
      
      // Translate if source and target languages are different
      String translatedText = extractedText;
      if (sourceLanguage != targetLanguage) {
        translatedText = await translateText(extractedText, targetLanguage);
      }

      return {
        'success': true,
        'extractedText': extractedText,
        'sourceLanguage': sourceLanguage,
        'sourceLanguageName': getLanguageName(sourceLanguage),
        'translatedText': translatedText,
        'targetLanguage': targetLanguage,
        'targetLanguageName': getLanguageName(targetLanguage),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process image: $e',
        'extractedText': '',
        'sourceLanguage': '',
        'translatedText': '',
      };
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _textRecognizer.close();
    await _languageIdentifier.close();
  }
}
