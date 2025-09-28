import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/onboarding_service.dart';
import '../../services/biometric_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // 0.2 seconds as requested
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Start animation and navigate after completion
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
      
      if (!isOnboardingCompleted) {
        // User hasn't completed onboarding, show onboarding flow
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }

      // User has completed onboarding, check authentication status
      final biometricService = BiometricAuthService();
      
      // First, check if user is logged in (has valid auth token)
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      
      if (authToken == null || authToken.isEmpty) {
        // User is not logged in, go to login screen
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      
      // User is logged in, check biometric authentication options
      // Check device biometric authentication first (like GCash/PayMaya)
      final shouldUseDeviceBiometric = await biometricService.shouldUseDeviceBiometricAuth();
      if (shouldUseDeviceBiometric) {
        // User is logged in and device biometric is enabled, show biometric auth
        Navigator.pushReplacementNamed(context, AppRoutes.biometricAuth);
        return;
      }
      
      // Fallback to TypingDNA authentication
      final shouldUseTypingDna = await biometricService.shouldUseTypingDnaAuth();
      if (shouldUseTypingDna) {
        // User is logged in and TypingDNA is enabled, show TypingDNA auth
        Navigator.pushReplacementNamed(context, AppRoutes.typingDnaAuth);
        return;
      }
      
      // User is logged in but no biometric authentication is set up
      // Go directly to dashboard since they have a valid session
      Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
    } catch (e) {
      print('Error in navigation logic: $e');
      // If there's an error, default to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Plain white background as requested
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/img_app_logo.png',
            width: 80.w, // Responsive width
            height: 80.w, // Keep it square
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
