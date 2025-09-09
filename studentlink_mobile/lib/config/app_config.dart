class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bcpstudentlink.online/api',
  );

  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // App Configuration
  static const String appName = 'StudentLink';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // College Information
  static const String collegeName = 'Bestlink College of the Philippines';
  static const String collegeCode = 'BCP';
  static const String collegeEmail = 'info@bestlink.edu.ph';
  static const String collegePhone = '+63-2-8123-4567';
  static const String collegeAddress = '123 Education Street, Quezon City, Philippines';

  // Emergency Contact Numbers
  static const String emergencyMedical = '911';
  static const String emergencySecurity = '117';
  static const String emergencyFire = '116';

  // Feature Flags
  static const bool enableAiFeatures = bool.fromEnvironment(
    'ENABLE_AI_FEATURES',
    defaultValue: true,
  );

  static const bool enableVoiceInput = bool.fromEnvironment(
    'ENABLE_VOICE_INPUT',
    defaultValue: true,
  );

  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: true,
  );

  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: false,
  );

  // Debug Configuration
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );

  static const bool enableApiLogging = bool.fromEnvironment(
    'ENABLE_API_LOGGING',
    defaultValue: false,
  );

  // File Upload Configuration
  static const int maxFileSize = 25 * 1024 * 1024; // 25MB
  static const List<String> allowedFileTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 
    'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip'
  ];

  // Audio Recording Configuration
  static const int maxRecordingDuration = 300; // 5 minutes in seconds
  static const String audioFormat = 'm4a';

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);

  // Timeout Configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // UI Configuration
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;

  // Theme Configuration
  static const String defaultTheme = 'light';
  static const String defaultLanguage = 'en';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxSubjectLength = 255;
  static const int maxDescriptionLength = 5000;
  static const int maxMessageLength = 2000;

  // Helper methods
  static String get baseApiUrl {
    // Remove trailing slash if present
    return apiBaseUrl.endsWith('/') 
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
  }

  static bool get isDemoMode {
    return openAiApiKey.isEmpty || apiBaseUrl.contains('localhost');
  }

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': appVersion,
      'X-Platform': 'mobile',
    };
  }

  static Map<String, dynamic> get appInfo {
    return {
      'name': appName,
      'version': appVersion,
      'build': buildNumber,
      'platform': 'flutter',
      'college': collegeName,
    };
  }
}
