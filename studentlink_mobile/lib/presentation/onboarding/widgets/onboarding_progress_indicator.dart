import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class OnboardingProgressIndicator extends StatefulWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingProgressIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  State<OnboardingProgressIndicator> createState() => _OnboardingProgressIndicatorState();
}

class _OnboardingProgressIndicatorState extends State<OnboardingProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    _progressAnimationController.forward();
  }

  @override
  void didUpdateWidget(OnboardingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      _progressAnimationController.reset();
      _progressAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Modern progress bar
          _buildProgressBar(),
          
          const SizedBox(height: 12),
          
          // Compact page indicators
          _buildPageIndicators(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (widget.currentPage + 1) / widget.totalPages * _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryLight, AppTheme.secondaryLight],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalPages, (index) {
        final isActive = index == widget.currentPage;
        final isCompleted = index < widget.currentPage;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          child: _buildPageIndicator(
            index: index,
            isActive: isActive,
            isCompleted: isCompleted,
          ),
        );
      }),
    );
  }

  Widget _buildPageIndicator({
    required int index,
    required bool isActive,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 4.w,
        ),
      );
    } else if (isActive) {
      return Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryLight, AppTheme.secondaryLight],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
      );
    }
  }
}