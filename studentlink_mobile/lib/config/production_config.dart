// StudentLink Mobile - Production Configuration
// This file contains production-specific configurations

class ProductionConfig {
  // Production API Configuration
  static const String productionApiBaseUrl = 'https://api.bcpstudentlink.online/api';
  
  // Production Firebase Configuration
  static const String productionFirebaseProjectId = 'studentlinkbcp0';
  static const String productionFirebaseApiKey = 'AIzaSyD67rYi1UhLY2oEYvkF9g0zGAAwFpTkxB8';
  static const String productionFirebaseAppId = '1:760317150683:android:bb2a282c5b068de6ded3fe';
  static const String productionFirebaseMessagingSenderId = '760317150683';
  static const String productionFirebaseStorageBucket = 'studentlinkbcp0.firebasestorage.app';
  
  // Production Pusher Configuration
  static const String productionPusherAppId = '2050137';
  static const String productionPusherAppKey = '2667598035fbcc608dbd';
  static const String productionPusherAppSecret = '323be112148207484d7f';
  static const String productionPusherCluster = 'ap1';
  
  // Production Feature Flags
  static const bool productionEnableAiFeatures = true;
  static const bool productionEnablePushNotifications = true;
  static const bool productionEnableRealTimeUpdates = true;
  static const bool productionEnableAnalytics = true;
  static const bool productionEnableFileUploads = true;
  
  // Production Debug Settings
  static const bool productionDebugMode = false;
  static const bool productionEnableApiLogging = false;
  static const bool productionEnableMockData = false;
  
  // Production Performance Settings
  static const int productionMaxFileSize = 25 * 1024 * 1024; // 25MB
  static const Duration productionNetworkTimeout = Duration(seconds: 30);
  static const Duration productionCacheExpiration = Duration(hours: 24);
  
  // Production Security Settings
  static const bool productionEnableSsl = true;
  static const bool productionEnableCertificatePinning = true;
  
  // Production Analytics Settings
  static const bool productionEnableCrashReporting = true;
  static const bool productionEnablePerformanceMonitoring = true;
  
  // Production College Information
  static const String productionCollegeName = 'Bestlink College of the Philippines';
  static const String productionCollegeCode = 'BCP';
  static const String productionCollegeEmail = 'info@bestlink.edu.ph';
  static const String productionCollegePhone = '+63-2-8123-4567';
  static const String productionCollegeAddress = '123 Education Street, Quezon City, Philippines';
  
  // Production Emergency Contacts
  static const String productionEmergencyMedical = '911';
  static const String productionEmergencySecurity = '117';
  static const String productionEmergencyFire = '116';
  
  // Production App Information
  static const String productionAppName = 'StudentLink';
  static const String productionAppVersion = '1.0.0';
  static const String productionBuildNumber = '1';
  
  // Production Environment Detection
  static bool get isProduction {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'production';
  }
  
  // Production Configuration Getters
  static String get apiBaseUrl {
    return isProduction ? productionApiBaseUrl : 'http://192.168.100.145:8000/api';
  }
  
  static String get firebaseProjectId {
    return isProduction ? productionFirebaseProjectId : 'studentlinkbcp0';
  }
  
  static String get firebaseApiKey {
    return isProduction ? productionFirebaseApiKey : 'AIzaSyD67rYi1UhLY2oEYvkF9g0zGAAwFpTkxB8';
  }
  
  static String get firebaseAppId {
    return isProduction ? productionFirebaseAppId : '1:760317150683:android:bb2a282c5b068de6ded3fe';
  }
  
  static String get firebaseMessagingSenderId {
    return isProduction ? productionFirebaseMessagingSenderId : '760317150683';
  }
  
  static String get firebaseStorageBucket {
    return isProduction ? productionFirebaseStorageBucket : 'studentlinkbcp0.firebasestorage.app';
  }
  
  static String get pusherAppId {
    return isProduction ? productionPusherAppId : '2050137';
  }
  
  static String get pusherAppKey {
    return isProduction ? productionPusherAppKey : '2667598035fbcc608dbd';
  }
  
  static String get pusherAppSecret {
    return isProduction ? productionPusherAppSecret : '323be112148207484d7f';
  }
  
  static String get pusherCluster {
    return isProduction ? productionPusherCluster : 'ap1';
  }
  
  static bool get enableAiFeatures {
    return isProduction ? productionEnableAiFeatures : true;
  }
  
  static bool get enablePushNotifications {
    return isProduction ? productionEnablePushNotifications : true;
  }
  
  static bool get enableRealTimeUpdates {
    return isProduction ? productionEnableRealTimeUpdates : true;
  }
  
  static bool get enableAnalytics {
    return isProduction ? productionEnableAnalytics : true;
  }
  
  static bool get enableFileUploads {
    return isProduction ? productionEnableFileUploads : true;
  }
  
  static bool get debugMode {
    return isProduction ? productionDebugMode : true;
  }
  
  static bool get enableApiLogging {
    return isProduction ? productionEnableApiLogging : true;
  }
  
  static bool get enableMockData {
    return isProduction ? productionEnableMockData : false;
  }
  
  static int get maxFileSize {
    return isProduction ? productionMaxFileSize : 25 * 1024 * 1024;
  }
  
  static Duration get networkTimeout {
    return isProduction ? productionNetworkTimeout : Duration(seconds: 30);
  }
  
  static Duration get cacheExpiration {
    return isProduction ? productionCacheExpiration : Duration(hours: 24);
  }
  
  static bool get enableSsl {
    return isProduction ? productionEnableSsl : false;
  }
  
  static bool get enableCertificatePinning {
    return isProduction ? productionEnableCertificatePinning : false;
  }
  
  static bool get enableCrashReporting {
    return isProduction ? productionEnableCrashReporting : false;
  }
  
  static bool get enablePerformanceMonitoring {
    return isProduction ? productionEnablePerformanceMonitoring : false;
  }
  
  static String get collegeName {
    return isProduction ? productionCollegeName : 'Bestlink College of the Philippines';
  }
  
  static String get collegeCode {
    return isProduction ? productionCollegeCode : 'BCP';
  }
  
  static String get collegeEmail {
    return isProduction ? productionCollegeEmail : 'info@bestlink.edu.ph';
  }
  
  static String get collegePhone {
    return isProduction ? productionCollegePhone : '+63-2-8123-4567';
  }
  
  static String get collegeAddress {
    return isProduction ? productionCollegeAddress : '123 Education Street, Quezon City, Philippines';
  }
  
  static String get emergencyMedical {
    return isProduction ? productionEmergencyMedical : '911';
  }
  
  static String get emergencySecurity {
    return isProduction ? productionEmergencySecurity : '117';
  }
  
  static String get emergencyFire {
    return isProduction ? productionEmergencyFire : '116';
  }
  
  static String get appName {
    return isProduction ? productionAppName : 'StudentLink';
  }
  
  static String get appVersion {
    return isProduction ? productionAppVersion : '1.0.0';
  }
  
  static String get buildNumber {
    return isProduction ? productionBuildNumber : '1';
  }
}
