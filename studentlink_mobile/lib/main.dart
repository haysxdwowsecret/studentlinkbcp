import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/app_export.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/chat_service.dart';
import '../services/settings_service.dart';
import '../widgets/custom_error_widget.dart';
import '../utils/performance_optimizer.dart';
import '../utils/keyboard_performance_utils.dart';
import '../theme/responsive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize Firebase service
  await FirebaseService().initialize();
  
  // Initialize Notification service
  await NotificationService().initialize();
  
  // Initialize Chat service
  await ChatService().initialize();
  
  // Initialize Settings service
  await SettingsService().initialize();
  
  // Performance optimizations
  PerformanceOptimizer.startFrameRateMonitoring();
  KeyboardPerformanceUtils.configureKeyboardOptimizations();
  
  // Initialize API service
  await apiService.initialize();

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Log the error details for debugging
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
    print('Library: ${details.library}');
    
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'studentlink',
          theme: ResponsiveTheme.lightTheme, // 🎯 RESPONSIVE: Use responsive theme
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          // 🎯 RESPONSIVE DESIGN: Smart scaling for all devices
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                // Disable system text scaling to use our responsive system
                textScaler: TextScaler.linear(1.0),
                // Ensure consistent scaling across devices
                devicePixelRatio: MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0),
              ),
              child: RepaintBoundary(
                child: child!,
              ),
            );
          },
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.splashScreen,
        );
      },
    );
  }
}
