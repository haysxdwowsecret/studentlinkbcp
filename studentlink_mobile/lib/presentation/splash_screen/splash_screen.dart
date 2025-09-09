import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/college_logo_widget.dart';
import './widgets/loading_indicator_widget.dart';

/// Splash Screen serves as the application's entry point, displaying Bestlink College
/// branding while initializing services and checking authentication status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for loading indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization process
      await _performInitializationSteps();

      // Navigate to appropriate screen based on authentication status
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      _handleInitializationError(e);
    }
  }

  Future<void> _performInitializationSteps() async {
    final steps = [
      {'message': 'Loading app configuration...', 'duration': 500},
      {'message': 'Initializing services...', 'duration': 800},
      {'message': 'Checking authentication...', 'duration': 600},
      {'message': 'Loading user preferences...', 'duration': 400},
      {'message': 'Almost ready...', 'duration': 300},
    ];

    for (final step in steps) {
      if (mounted) {
        setState(() {
          _statusMessage = step['message'] as String;
        });
      }

      await Future.delayed(Duration(milliseconds: step['duration'] as int));
    }

    // Minimum splash screen display time
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _statusMessage = 'Welcome to StudentLink!';
    });

    // Brief welcome message display
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // For now, simulate checking authentication
    // In a real app, this would check actual authentication status
    final bool isAuthenticated = await _checkAuthenticationStatus();

    if (isAuthenticated) {
      // User is authenticated, go to dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
    } else {
      // User needs to login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    try {
      // Check if user has valid authentication token
      if (apiService.isAuthenticated) {
        // Verify token is still valid by making a test API call
        await apiService.getCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      // Token is invalid or expired
      return false;
    }
  }

  void _handleInitializationError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _statusMessage = 'Initialization failed. Redirecting...';
    });

    // Show error briefly then redirect to login
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: _buildGradientBackground(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildLogoSection(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildLoadingSection(),
                ),
                _buildVersionInfo(),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryLight,
          AppTheme.primaryVariantLight,
          AppTheme.primaryVariantLight.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.7, 1.0],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CollegeLogoWidget(
                  size: 25.w,
                  showShadow: true,
                ),
                SizedBox(height: 3.h),
                Text(
                  'StudentLink',
                  style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Bestlink College of the Philippines',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: LoadingIndicatorWidget(
                color: Colors.white,
                size: 6.w,
              ),
            );
          },
        ),
        SizedBox(height: 3.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _statusMessage,
            key: ValueKey(_statusMessage),
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (_isInitializing) ...[
          SizedBox(height: 2.h),
          Container(
            width: 60.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7, // Simulated progress
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Student Concern Management System',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
