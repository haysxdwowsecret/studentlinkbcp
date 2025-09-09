import 'package:dio/dio.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');

  // Factory constructor to return the singleton instance
  factory OpenAIService() {
    return _instance;
  }

  // Private constructor for singleton pattern
  OpenAIService._internal() {
    _initializeService();
  }

  void _initializeService() {
    // Load API key from environment variables
    if (apiKey.isEmpty) {
      // For demo purposes, use a placeholder API key
      // In production, this should be provided via --dart-define
      print('Warning: OPENAI_API_KEY not provided. Using demo mode.');
    }

    // Configure Dio with base URL and headers
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.isEmpty ? 'demo-key' : apiKey}',
        },
      ),
    );
  }

  Dio get dio => _dio;
}
