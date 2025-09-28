import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config/firebase_config.dart';
import '../models/user.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final Dio _dio = Dio();
  String? _fcmToken;
  User? _currentUser;

  // Initialize Firebase service
  Future<void> initialize() async {
    try {
      // Configure FCM
      FirebaseConfig.configureForegroundMessages();
      FirebaseConfig.configureBackgroundMessages();
      FirebaseConfig.configureMessageOpenedApp();

      // Request permissions
      await FirebaseConfig.requestPermissions();

      // Get FCM token
      await _getAndStoreFCMToken();

      print('Firebase service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase service: $e');
    }
  }

  // Get and store FCM token
  Future<String?> _getAndStoreFCMToken() async {
    try {
      _fcmToken = await FirebaseConfig.getFCMToken();
      
      if (_fcmToken != null) {
        // Store token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
        
        // Send token to backend if user is logged in
        if (_currentUser != null) {
          await _sendTokenToBackend(_fcmToken!);
        }
        
        print('FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
      }
      
      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Send FCM token to backend
  Future<bool> _sendTokenToBackend(String token) async {
    try {
      if (_currentUser == null) return false;

      final response = await _dio.post(
        'http://192.168.100.145:8000/api/fcm-tokens',
        data: {
          'token': token,
          'device_type': 'mobile',
          'device_id': await _getDeviceId(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM token sent to backend successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error sending FCM token to backend: $e');
      return false;
    }
  }

  // Get device ID
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }

  // Set current user and send token
  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    
    // Send FCM token if available
    if (_fcmToken != null) {
      await _sendTokenToBackend(_fcmToken!);
    } else {
      // Get token if not available
      await _getAndStoreFCMToken();
    }
  }

  // Clear user data
  Future<void> clearUser() async {
    _currentUser = null;
    
    // Remove FCM token from backend
    if (_fcmToken != null) {
      await _removeTokenFromBackend(_fcmToken!);
    }
    
    // Clear local token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
    _fcmToken = null;
  }

  // Remove FCM token from backend
  Future<bool> _removeTokenFromBackend(String token) async {
    try {
      if (_currentUser == null) return false;

      final response = await _dio.delete(
        'http://192.168.100.145:8000/api/fcm-tokens/$token',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing FCM token from backend: $e');
      return false;
    }
  }

  // Get current FCM token
  String? get currentToken => _fcmToken;

  // Refresh FCM token
  Future<String?> refreshToken() async {
    try {
      // Delete old token
      await FirebaseMessaging.instance.deleteToken();
      
      // Get new token
      return await _getAndStoreFCMToken();
    } catch (e) {
      print('Error refreshing FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Subscribe to user-specific topics
  Future<void> subscribeToUserTopics() async {
    if (_currentUser == null) return;

    try {
      // Subscribe to general notifications
      await subscribeToTopic('all_users');
      
      // Subscribe to role-specific notifications
      await subscribeToTopic('role_${_currentUser!.role}');
      
      // Subscribe to department-specific notifications
      await subscribeToTopic('department_${_currentUser!.departmentId}');
      
      print('Subscribed to user-specific topics');
    } catch (e) {
      print('Error subscribing to user topics: $e');
    }
  }

  // Unsubscribe from user-specific topics
  Future<void> unsubscribeFromUserTopics() async {
    if (_currentUser == null) return;

    try {
      // Unsubscribe from general notifications
      await unsubscribeFromTopic('all_users');
      
      // Unsubscribe from role-specific notifications
      await unsubscribeFromTopic('role_${_currentUser!.role}');
      
      // Unsubscribe from department-specific notifications
      await unsubscribeFromTopic('department_${_currentUser!.departmentId}');
      
      print('Unsubscribed from user-specific topics');
    } catch (e) {
      print('Error unsubscribing from user topics: $e');
    }
  }

  // Handle notification tap
  void handleNotificationTap(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? concernId = data['concern_id'];
    final String? announcementId = data['announcement_id'];

    switch (type) {
      case 'concern_update':
        if (concernId != null) {
          // Navigate to concern details
          print('Navigate to concern: $concernId');
          // TODO: Implement navigation
        }
        break;
      case 'announcement':
        if (announcementId != null) {
          // Navigate to announcement details
          print('Navigate to announcement: $announcementId');
          // TODO: Implement navigation
        }
        break;
      case 'concern_assignment':
        if (concernId != null) {
          // Navigate to assigned concern
          print('Navigate to assigned concern: $concernId');
          // TODO: Implement navigation
        }
        break;
      case 'emergency':
        // Navigate to emergency help
        print('Navigate to emergency help');
        // TODO: Implement navigation
        break;
      default:
        // Navigate to home or notifications
        print('Navigate to home');
        // TODO: Implement navigation
        break;
    }
  }
}
