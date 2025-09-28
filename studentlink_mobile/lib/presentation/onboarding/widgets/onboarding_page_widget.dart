import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../onboarding_screen.dart';

class OnboardingPageWidget extends StatefulWidget {
  final OnboardingPageData data;
  final bool isActive;

  const OnboardingPageWidget({
    Key? key,
    required this.data,
    required this.isActive,
  }) : super(key: key);

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.elasticOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isActive) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(OnboardingPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _iconAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _textAnimationController.forward();
    });
  }

  void _stopAnimations() {
    _iconAnimationController.reset();
    _textAnimationController.reset();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Vector illustration area with optimized spacing
          Expanded(
            flex: 3,
            child: _buildIllustrationSection(),
          ),
          
          // Content section with better proportions
          Expanded(
            flex: 2,
            child: _buildContentSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decoration
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  widget.data.primaryColor.withValues(alpha: 0.1),
                  widget.data.secondaryColor.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 1.0],
              ),
              shape: BoxShape.circle,
            ),
          ),
          
          // Main illustration container
          ScaleTransition(
            scale: _iconScaleAnimation,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.data.primaryColor,
                    widget.data.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.data.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vector illustration placeholder (can be replaced with actual SVG)
                  if (widget.data.illustrationPath != null)
                    _buildVectorIllustration()
                  else
                    _buildIconIllustration(),
                  
                  // Subtle pattern overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorIllustration() {
    // Placeholder for vector illustration
    // In a real implementation, you would use flutter_svg or similar
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        widget.data.icon,
        size: 20.w,
        color: Colors.white,
      ),
    );
  }

  Widget _buildIconIllustration() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        widget.data.icon,
        size: 20.w,
        color: Colors.white,
      ),
    );
  }

  Widget _buildContentSection() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title with better typography
              Text(
                widget.data.title,
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle with modern styling
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: widget.data.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.data.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.data.subtitle,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: widget.data.primaryColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description with improved readability
              Text(
                widget.data.description,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 20),
              
              // Feature highlights with modern design
              _buildFeatureHighlights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = _getFeatureHighlights();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((feature) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.data.primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 3.5.w,
                color: widget.data.primaryColor,
              ),
              SizedBox(width: 1.5.w),
              Text(
                feature,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<String> _getFeatureHighlights() {
    switch (widget.data.title) {
      case "Welcome to StudentLink":
        return ["Academic Support", "Real-time Updates"];
      case "Submit Concerns":
        return ["Track Progress", "Quick Response"];
      case "AI Assistant":
        return ["24/7 Available", "Smart Guidance"];
      case "Emergency Help":
        return ["One-tap Access", "Urgent Support"];
      case "Stay Connected":
        return ["Real-time Alerts", "Important Updates"];
      default:
        return ["Feature 1", "Feature 2"];
    }
  }
}