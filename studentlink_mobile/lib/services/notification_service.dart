import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      print('🔔 Initializing notification service...');

      // Request permission for notifications
      await _requestPermission();

      // Get FCM token
      await _getFcmToken();

      // Set up message handlers
      _setupMessageHandlers();

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize notification service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Provisional notification permission granted');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Get FCM token and register with backend
  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      
      if (_fcmToken != null) {
        print('🔑 FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
        
        // Register token with backend
        await _registerTokenWithBackend();
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend() async {
    if (_fcmToken == null) return;

    try {
      String deviceType = 'unknown';
      String? deviceId;

      if (Platform.isAndroid) {
        deviceType = 'android';
        deviceId = 'android_device_id'; // Simplified for now
      } else if (Platform.isIOS) {
        deviceType = 'ios';
        deviceId = 'ios_device_id'; // Simplified for now
      }

      await _apiService.storeFcmToken(_fcmToken!, deviceType, deviceId: deviceId);
      print('✅ FCM token registered with backend');
    } catch (e) {
      print('❌ Failed to register FCM token with backend: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification tap when app is terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleTerminatedMessage(message);
      }
    });

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      _registerTokenWithBackend();
      print('🔄 FCM token refreshed');
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Received foreground message: ${message.notification?.title}');
    
    // Show in-app notification
    _showInAppNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  /// Handle background messages (app opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    print('📱 App opened from background notification: ${message.notification?.title}');
    _navigateFromNotification(message.data);
  }

  /// Handle terminated app messages
  void _handleTerminatedMessage(RemoteMessage message) {
    print('📱 App opened from terminated state: ${message.notification?.title}');
    _navigateFromNotification(message.data);
  }

  /// Show in-app notification
  void _showInAppNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    // This will be handled by the UI layer
    // For now, just print the notification
    print('🔔 In-app notification: $title - $body');
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? concernId = data['concern_id'];
    final String? announcementId = data['announcement_id'];
    final String? chatRoomId = data['chat_room_id'];

    print('🧭 Navigating from notification - Type: $type');

    switch (type) {
      case 'concern_update':
        if (concernId != null) {
          // Navigate to concern details
          print('🧭 Navigating to concern details: $concernId');
        }
        break;
      case 'concern_message':
        if (concernId != null) {
          // Navigate to concern details with chat open
          print('🧭 Navigating to concern chat: $concernId');
        }
        break;
      case 'chat_message':
        if (chatRoomId != null) {
          // Navigate to chat room
          print('🧭 Navigating to chat room: $chatRoomId');
        } else if (concernId != null) {
          // Fallback to concern details
          print('🧭 Navigating to concern details: $concernId');
        }
        break;
      case 'announcement':
        if (announcementId != null) {
          // Navigate to announcement details
          print('🧭 Navigating to announcement details: $announcementId');
        }
        break;
      case 'emergency':
        // Navigate to emergency help
        print('🧭 Navigating to emergency help');
        break;
      default:
        // Navigate to dashboard
        print('🧭 Navigating to dashboard');
        break;
    }
  }

  /// Subscribe to topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Failed to delete FCM token: $e');
    }
  }
}

/// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.notification?.title}');
  // Handle background message here if needed
}
