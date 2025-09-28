import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  
  /// Check if user has completed onboarding
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      // If there's an error, assume onboarding is not completed
      return false;
    }
  }
  
  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      // Handle error silently
      print('Error marking onboarding as completed: $e');
    }
  }
  
  /// Reset onboarding status (useful for testing or if user wants to see onboarding again)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
    } catch (e) {
      // Handle error silently
      print('Error resetting onboarding: $e');
    }
  }
}
