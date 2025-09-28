import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../services/onboarding_service.dart';
import 'widgets/onboarding_page_widget.dart';
import 'widgets/onboarding_progress_indicator.dart';
import 'widgets/onboarding_background_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 5;

  // Modern onboarding content with vector illustration support
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Welcome to StudentLink",
      subtitle: "Your Academic Support Hub",
      description: "Connect with your institution, get instant help, and stay updated with all your academic needs in one place.",
      icon: Icons.school_rounded,
      primaryColor: AppTheme.primaryLight,
      secondaryColor: AppTheme.secondaryLight,
      illustrationPath: "assets/illustrations/welcome.svg", // Vector illustration support
    ),
    OnboardingPageData(
      title: "Submit Concerns",
      subtitle: "Get Help When You Need It",
      description: "Report academic issues, technical problems, or any concerns directly to your department with real-time tracking.",
      icon: Icons.support_agent_rounded,
      primaryColor: AppTheme.secondaryLight,
      secondaryColor: AppTheme.primaryLight,
      illustrationPath: "assets/illustrations/concerns.svg",
    ),
    OnboardingPageData(
      title: "AI Assistant",
      subtitle: "Instant Answers & Support",
      description: "Get immediate answers to your questions with our intelligent AI assistant available 24/7 for academic guidance.",
      icon: Icons.psychology_rounded,
      primaryColor: AppTheme.successLight,
      secondaryColor: AppTheme.warningLight,
      illustrationPath: "assets/illustrations/ai_assistant.svg",
    ),
    OnboardingPageData(
      title: "Emergency Help",
      subtitle: "Quick Access to Urgent Support",
      description: "One-tap access to emergency contacts and urgent support services. Your safety and well-being are our priority.",
      icon: Icons.emergency_rounded,
      primaryColor: AppTheme.emergencyLight,
      secondaryColor: AppTheme.primaryLight,
      illustrationPath: "assets/illustrations/emergency.svg",
    ),
    OnboardingPageData(
      title: "Stay Connected",
      subtitle: "Real-time Updates & Announcements",
      description: "Receive instant notifications about important announcements, concern updates, and institutional news.",
      icon: Icons.notifications_active_rounded,
      primaryColor: AppTheme.primaryLight,
      secondaryColor: AppTheme.secondaryLight,
      illustrationPath: "assets/illustrations/notifications.svg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    HapticFeedback.lightImpact();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.selectionClick();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    HapticFeedback.heavyImpact();
    _markOnboardingCompleted();
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _markOnboardingCompleted() {
    OnboardingService.markOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle background pattern
            const OnboardingBackgroundWidget(),
            
            // Main content with modern layout
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Compact header
                  _buildCompactHeader(),
                  
                  // Main content area with optimized spacing
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        children: [
                          // Compact progress indicator
                          const SizedBox(height: 16),
                          OnboardingProgressIndicator(
                            currentPage: _currentPage,
                            totalPages: _totalPages,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Page content with better space utilization
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemCount: _totalPages,
                              itemBuilder: (context, index) {
                                return OnboardingPageWidget(
                                  data: _pages[index],
                                  isActive: _currentPage == index,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Modern navigation section
                  _buildModernNavigationSection(),
                  
                  // Bottom spacing
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App logo/brand - more compact
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryLight, AppTheme.secondaryLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 3.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'StudentLink',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Compact skip button
          _buildCompactSkipButton(),
        ],
      ),
    );
  }

  Widget _buildCompactSkipButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _skipOnboarding,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.textSecondaryLight,
                  size: 3.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavigationSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Column(
        children: [
          // Modern navigation buttons with better proportions
          Row(
            children: [
              // Previous button - only show if not on first page
              if (_currentPage > 0) ...[
                Expanded(
                  child: _buildNavigationButton(
                    text: 'Previous',
                    icon: Icons.arrow_back_ios_rounded,
                    isPrimary: false,
                    onTap: _previousPage,
                  ),
                ),
                SizedBox(width: 3.w),
              ],
              
              // Next/Get Started button
              Expanded(
                flex: _currentPage > 0 ? 1 : 2,
                child: _buildNavigationButton(
                  text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                  icon: _currentPage == _totalPages - 1 
                      ? Icons.check_rounded 
                      : Icons.arrow_forward_ios_rounded,
                  isPrimary: true,
                  onTap: _nextPage,
                ),
              ),
            ],
          ),
          
          // Page counter - more subtle
          const SizedBox(height: 12),
          Text(
            '${_currentPage + 1} of $_totalPages',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        gradient: isPrimary 
            ? LinearGradient(
                colors: [AppTheme.primaryLight, AppTheme.secondaryLight],
              )
            : null,
        color: isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary 
            ? null 
            : Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
                ? AppTheme.primaryLight.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isPrimary ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPrimary) ...[
                Text(
                  text,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(
                  icon,
                  size: 3.5.w,
                  color: Colors.white,
                ),
              ] else ...[
                Icon(
                  icon,
                  size: 3.5.w,
                  color: AppTheme.primaryLight,
                ),
                SizedBox(width: 1.w),
                Text(
                  text,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced onboarding page data class with vector illustration support
class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String? illustrationPath; // Support for vector illustrations

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.illustrationPath,
  });
}