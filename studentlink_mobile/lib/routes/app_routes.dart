import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/forgot_password/forgot_password_screen.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/my_concerns/my_concerns.dart';
import '../presentation/concern_details/concern_details.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/submit_concern/submit_concern.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/ai_chat_assistant/ai_chat_assistant.dart';
import '../presentation/emergency_help/emergency_help.dart';
import '../presentation/announcements/announcements.dart';

class AppRoutes {
  static const String splashScreen = '/';
  static const String login = '/login-screen';
  static const String forgotPassword = '/forgot-password';
  static const String profileSettings = '/profile-settings';
  static const String myConcerns = '/my-concerns';
  static const String concernDetails = '/concern-details';
  static const String dashboardHome = '/dashboard-home';
  static const String submitConcern = '/submit-concern';
  static const String aiChatAssistant = '/ai-chat-assistant';
  static const String emergencyHelp = '/emergency-help';
  static const String announcements = '/announcements';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    profileSettings: (context) => const ProfileSettings(),
    myConcerns: (context) => const MyConcerns(),
    concernDetails: (context) => const ConcernDetails(),
    dashboardHome: (context) => const DashboardHome(),
    submitConcern: (context) => const SubmitConcern(),
    aiChatAssistant: (context) => const AiChatAssistant(),
    emergencyHelp: (context) => const EmergencyHelp(),
    announcements: (context) => const Announcements(),
  };
}