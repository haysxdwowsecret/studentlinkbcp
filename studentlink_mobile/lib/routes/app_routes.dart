import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/forgot_password/forgot_password_screen.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/my_concerns/my_concerns.dart';
import '../presentation/concern_details/concern_details.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/submit_concern/enhanced_submit_concern.dart';
import '../presentation/ai_chat_assistant/ai_chat_assistant.dart';
import '../presentation/emergency_help/emergency_help.dart';
import '../presentation/announcements/new_announcements_screen.dart';
import '../presentation/registration/registration_screen.dart';
import '../presentation/profile_settings/enhanced_profile_screen.dart';
import '../presentation/profile_settings/change_password_screen.dart';
import '../presentation/accessibility_tools/accessibility_tools_screen.dart';
import '../presentation/firebase_test/firebase_test_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/biometric_auth/biometric_auth_screen.dart';
import '../presentation/biometric_auth/typingdna_auth_screen.dart';

class AppRoutes {
  // Core navigation routes
  static const String splashScreen = '/splash-screen';
  static const String login = '/login-screen';
  static const String dashboardHome = '/dashboard-home';
  
  // Main feature routes
  static const String myConcerns = '/my-concerns';
  static const String announcements = '/announcements';
  static const String profileSettings = '/profile-settings';
  static const String submitConcern = '/submit-concern';
  static const String concernDetails = '/concern-details';
  
  // Authentication routes
  static const String forgotPassword = '/forgot-password';
  static const String registration = '/registration';
  
  // Profile management routes
  static const String enhancedProfile = '/enhanced-profile';
  static const String changePassword = '/change-password';
  
  // AI and assistance routes
  static const String aiChatAssistant = '/ai-chat-assistant';
  static const String emergencyHelp = '/emergency-help';
  static const String accessibilityTools = '/accessibility-tools';
  
  // Development/Testing routes
  static const String firebaseTest = '/firebase-test';
  
  // Onboarding route
  static const String onboarding = '/onboarding';
  
  // Biometric authentication routes
  static const String biometricAuth = '/biometric-auth';
  static const String typingDnaAuth = '/typingdna-auth';

  static Map<String, WidgetBuilder> routes = {
    // Core navigation
    splashScreen: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    dashboardHome: (context) => const DashboardHome(),
    
    // Main features
    myConcerns: (context) => const MyConcerns(),
    announcements: (context) => const NewAnnouncementsScreen(),
    profileSettings: (context) => const ProfileSettings(),
    submitConcern: (context) => const EnhancedSubmitConcern(),
    concernDetails: (context) => const ConcernDetails(),
    
    // Authentication
    forgotPassword: (context) => const ForgotPasswordScreen(),
    registration: (context) => const RegistrationScreen(),
    
    // Profile management
    enhancedProfile: (context) => const EnhancedProfileScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    
    // AI and assistance
    aiChatAssistant: (context) => const AiChatAssistant(),
    emergencyHelp: (context) => const EmergencyHelp(),
    accessibilityTools: (context) => const AccessibilityToolsScreen(),
    
    // Development/Testing
    firebaseTest: (context) => const FirebaseTestScreen(),
    
    // Onboarding
    onboarding: (context) => const OnboardingScreen(),
    
    // Biometric authentication
    biometricAuth: (context) => const BiometricAuthScreen(),
    typingDnaAuth: (context) => const TypingDnaAuthScreen(),
  };
}