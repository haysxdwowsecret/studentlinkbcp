import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_auth/local_auth.dart';

/// Comprehensive settings service for managing all app preferences
/// Provides persistent storage and system integration for all toggle settings
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Keys for SharedPreferences
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _appSettingsKey = 'app_settings';
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _languageKey = 'app_language';
  static const String _wifiOnlyKey = 'wifi_only_data';
  static const String _biometricAuthKey = 'biometric_auth_enabled';

  // Default settings
  static const Map<String, dynamic> _defaultNotificationSettings = {
    'concernUpdates': true,
    'announcementAlerts': true,
    'emergencyNotifications': true,
    'aiAssistantMessages': false,
  };

  static const Map<String, dynamic> _defaultAppSettings = {
    'isFilipino': false,
    'wifiOnlyData': false,
    'biometricAuth': false,
  };

  static const Map<String, dynamic> _defaultPrivacySettings = {
    'anonymousDefault': false,
    'dataSharing': true,
  };

  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Local Auth instance
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Initialize settings service
  Future<void> initialize() async {
    try {
      // Load all settings from storage
      await _loadAllSettings();
      
      // Initialize Firebase messaging with current notification settings
      await _initializeFirebaseMessaging();
      
      // Check biometric availability
      await _checkBiometricAvailability();
      
      debugPrint('✅ SettingsService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing SettingsService: $e');
    }
  }

  /// Load all settings from SharedPreferences
  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load notification settings
    final notificationJson = prefs.getString(_notificationSettingsKey);
    if (notificationJson == null) {
      await _saveNotificationSettings(_defaultNotificationSettings);
    }
    
    // Load app settings
    final appJson = prefs.getString(_appSettingsKey);
    if (appJson == null) {
      await _saveAppSettings(_defaultAppSettings);
    }
    
    // Load privacy settings
    final privacyJson = prefs.getString(_privacySettingsKey);
    if (privacyJson == null) {
      await _savePrivacySettings(_defaultPrivacySettings);
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  /// Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_notificationSettingsKey);
      if (json != null) {
        final Map<String, dynamic> data = jsonDecode(json);
        return {
          'concernUpdates': data['concernUpdates'] ?? true,
          'announcementAlerts': data['announcementAlerts'] ?? true,
          'emergencyNotifications': data['emergencyNotifications'] ?? true,
          'aiAssistantMessages': data['aiAssistantMessages'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
    return Map.from(_defaultNotificationSettings);
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      await _saveNotificationSettings(settings);
      await _updateFirebaseMessagingTopics(settings);
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return false;
    }
  }

  /// Save notification settings to storage
  Future<void> _saveNotificationSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
  }

  /// Update Firebase messaging topics based on notification settings
  Future<void> _updateFirebaseMessagingTopics(Map<String, bool> settings) async {
    try {
      if (settings['concernUpdates'] == true) {
        await _firebaseMessaging.subscribeToTopic('concern_updates');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('concern_updates');
      }

      if (settings['announcementAlerts'] == true) {
        await _firebaseMessaging.subscribeToTopic('announcements');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('announcements');
      }

      if (settings['emergencyNotifications'] == true) {
        await _firebaseMessaging.subscribeToTopic('emergency_alerts');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('emergency_alerts');
      }

      if (settings['aiAssistantMessages'] == true) {
        await _firebaseMessaging.subscribeToTopic('ai_assistant_tips');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('ai_assistant_tips');
      }

      debugPrint('✅ Firebase messaging topics updated');
    } catch (e) {
      debugPrint('❌ Error updating Firebase topics: $e');
    }
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Request permission for notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Firebase messaging permission granted');
        
        // Subscribe to topics based on current settings
        final notificationSettings = await getNotificationSettings();
        await _updateFirebaseMessagingTopics(notificationSettings);
      } else {
        debugPrint('❌ Firebase messaging permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing Firebase messaging: $e');
    }
  }

  // ==================== APP SETTINGS ====================

  /// Get app settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_appSettingsKey);
      if (json != null) {
        final Map<String, dynamic> data = jsonDecode(json);
        return {
          'isFilipino': data['isFilipino'] ?? false,
          'wifiOnlyData': data['wifiOnlyData'] ?? false,
          'biometricAuth': data['biometricAuth'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
    return Map.from(_defaultAppSettings);
  }

  /// Update app settings
  Future<bool> updateAppSettings(Map<String, dynamic> settings) async {
    try {
      await _saveAppSettings(settings);
      
      // Handle specific setting changes
      if (settings.containsKey('biometricAuth')) {
        await _handleBiometricAuthChange(settings['biometricAuth']);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating app settings: $e');
      return false;
    }
  }

  /// Save app settings to storage
  Future<void> _saveAppSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appSettingsKey, jsonEncode(settings));
  }

  /// Handle biometric authentication setting change
  Future<void> _handleBiometricAuthChange(bool enabled) async {
    try {
      if (enabled) {
        // Check if biometric authentication is available
        final isAvailable = await _localAuth.canCheckBiometrics;
        if (!isAvailable) {
          throw Exception('Biometric authentication not available on this device');
        }

        // Authenticate to enable biometric auth
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication for StudentLink',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!authenticated) {
          throw Exception('Biometric authentication failed');
        }
      }
      
      debugPrint('✅ Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Error handling biometric auth change: $e');
      rethrow;
    }
  }

  /// Check biometric availability
  Future<bool> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        // Disable biometric auth if not available
        final settings = await getAppSettings();
        settings['biometricAuth'] = false;
        await _saveAppSettings(settings);
      }
      return isAvailable;
    } catch (e) {
      debugPrint('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  // ==================== PRIVACY SETTINGS ====================

  /// Get privacy settings
  Future<Map<String, bool>> getPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_privacySettingsKey);
      if (json != null) {
        final Map<String, dynamic> data = jsonDecode(json);
        return {
          'anonymousDefault': data['anonymousDefault'] ?? false,
          'dataSharing': data['dataSharing'] ?? true,
        };
      }
    } catch (e) {
      debugPrint('Error loading privacy settings: $e');
    }
    return Map.from(_defaultPrivacySettings);
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(Map<String, bool> settings) async {
    try {
      await _savePrivacySettings(settings);
      
      // Handle data sharing setting
      if (settings.containsKey('dataSharing')) {
        await _handleDataSharingChange(settings['dataSharing']!);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      return false;
    }
  }

  /// Save privacy settings to storage
  Future<void> _savePrivacySettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privacySettingsKey, jsonEncode(settings));
  }

  /// Handle data sharing setting change
  Future<void> _handleDataSharingChange(bool enabled) async {
    try {
      // Here you would typically integrate with analytics services
      // For now, we'll just log the change
      debugPrint('Data sharing ${enabled ? 'enabled' : 'disabled'}');
      
      // You could integrate with Firebase Analytics here:
      // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('❌ Error handling data sharing change: $e');
    }
  }

  // ==================== LANGUAGE SETTINGS ====================

  /// Get current language setting
  Future<bool> getLanguageSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_languageKey) ?? false; // false = English, true = Filipino
    } catch (e) {
      debugPrint('Error loading language setting: $e');
      return false;
    }
  }

  /// Update language setting
  Future<bool> updateLanguageSetting(bool isFilipino) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_languageKey, isFilipino);
      
      // Update app settings as well
      final appSettings = await getAppSettings();
      appSettings['isFilipino'] = isFilipino;
      await _saveAppSettings(appSettings);
      
      debugPrint('✅ Language changed to ${isFilipino ? 'Filipino' : 'English'}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating language setting: $e');
      return false;
    }
  }

  // ==================== WI-FI ONLY SETTINGS ====================

  /// Get Wi-Fi only setting
  Future<bool> getWifiOnlySetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_wifiOnlyKey) ?? false;
    } catch (e) {
      debugPrint('Error loading Wi-Fi only setting: $e');
      return false;
    }
  }

  /// Update Wi-Fi only setting
  Future<bool> updateWifiOnlySetting(bool wifiOnly) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_wifiOnlyKey, wifiOnly);
      
      // Update app settings as well
      final appSettings = await getAppSettings();
      appSettings['wifiOnlyData'] = wifiOnly;
      await _saveAppSettings(appSettings);
      
      debugPrint('✅ Wi-Fi only data ${wifiOnly ? 'enabled' : 'disabled'}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating Wi-Fi only setting: $e');
      return false;
    }
  }

  // ==================== BIOMETRIC AUTH SETTINGS ====================

  /// Get biometric auth setting
  Future<bool> getBiometricAuthSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricAuthKey) ?? false;
    } catch (e) {
      debugPrint('Error loading biometric auth setting: $e');
      return false;
    }
  }

  /// Update biometric auth setting
  Future<bool> updateBiometricAuthSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricAuthKey, enabled);
      
      // Update app settings as well
      final appSettings = await getAppSettings();
      appSettings['biometricAuth'] = enabled;
      await _saveAppSettings(appSettings);
      
      // Handle biometric auth change
      await _handleBiometricAuthChange(enabled);
      
      debugPrint('✅ Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating biometric auth setting: $e');
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Reset all settings to defaults
  Future<void> resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all settings
      await prefs.remove(_notificationSettingsKey);
      await prefs.remove(_appSettingsKey);
      await prefs.remove(_privacySettingsKey);
      await prefs.remove(_languageKey);
      await prefs.remove(_wifiOnlyKey);
      await prefs.remove(_biometricAuthKey);
      
      // Reload defaults
      await _loadAllSettings();
      
      debugPrint('✅ All settings reset to defaults');
    } catch (e) {
      debugPrint('❌ Error resetting settings: $e');
    }
  }

  /// Get all settings as a single map
  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      final notificationSettings = await getNotificationSettings();
      final appSettings = await getAppSettings();
      final privacySettings = await getPrivacySettings();
      
      return {
        'notifications': notificationSettings,
        'app': appSettings,
        'privacy': privacySettings,
      };
    } catch (e) {
      debugPrint('❌ Error getting all settings: $e');
      return {};
    }
  }

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometricTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('❌ Error getting biometric types: $e');
      return [];
    }
  }
}
