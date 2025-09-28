import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseConfig {
  // Firebase project configuration for StudentLink BCP
  static const String projectId = 'studentlinkbcp0';
  static const String apiKey = 'AIzaSyD67rYi1UhLY2oEYvkF9g0zGAAwFpTkxB8'; // Real API key from google-services.json
  static const String appId = '1:760317150683:android:bb2a282c5b068de6ded3fe'; // Real app ID from google-services.json
  static const String messagingSenderId = '760317150683'; // Real project number
  static const String storageBucket = 'studentlinkbcp0.firebasestorage.app'; // Real storage bucket

  // Firebase options for different platforms
  static FirebaseOptions get androidOptions => const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      );

  static FirebaseOptions get iosOptions => const FirebaseOptions(
        apiKey: apiKey,
        appId: '1:760317150683:ios:your_ios_app_id', // Replace with actual iOS app ID
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      );

  static FirebaseOptions get webOptions => const FirebaseOptions(
        apiKey: apiKey,
        appId: '1:760317150683:web:your_web_app_id', // Replace with actual web app ID
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      );

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: androidOptions, // Default to Android, platform-specific initialization handled in main.dart
    );
    
    // Initialize Analytics
    await _initializeAnalytics();
  }

  // Initialize Firebase Analytics
  static Future<void> _initializeAnalytics() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      print('Firebase Analytics initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Analytics: $e');
    }
  }


  // FCM token management
  static Future<String?> getFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Request notification permissions
  static Future<NotificationSettings> requestPermissions() async {
    return await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Background message handler
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }

  // Configure FCM for foreground messages
  static void configureForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // Configure FCM for background messages
  static void configureBackgroundMessages() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Configure FCM for when app is opened from terminated state
  static void configureMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      
      // Handle navigation based on message data
      _handleMessageNavigation(message.data);
    });
  }

  // Handle navigation based on message data
  static void _handleMessageNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? concernId = data['concern_id'];
    final String? announcementId = data['announcement_id'];

    switch (type) {
      case 'concern_update':
        if (concernId != null) {
          // Navigate to concern details
          print('Navigate to concern: $concernId');
        }
        break;
      case 'announcement':
        if (announcementId != null) {
          // Navigate to announcement details
          print('Navigate to announcement: $announcementId');
        }
        break;
      case 'concern_assignment':
        if (concernId != null) {
          // Navigate to assigned concern
          print('Navigate to assigned concern: $concernId');
        }
        break;
      case 'emergency':
        // Navigate to emergency help
        print('Navigate to emergency help');
        break;
      default:
        // Navigate to home or notifications
        print('Navigate to home');
        break;
    }
  }

  // Analytics methods
  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
      print('Analytics event logged: $name');
    } catch (e) {
      print('Error logging analytics event: $e');
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    try {
      await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
      print('User property set: $name = $value');
    } catch (e) {
      print('Error setting user property: $e');
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      await FirebaseAnalytics.instance.setUserId(id: userId);
      print('User ID set: $userId');
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  // Storage methods will be implemented later when Firebase Storage is properly configured
}
