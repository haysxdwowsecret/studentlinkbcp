import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/responsive_design.dart';

class BiometricAuthWidget extends StatefulWidget {
  final String biometricType;
  final String biometricIcon;
  final bool isAuthenticating;
  final VoidCallback onTap;

  const BiometricAuthWidget({
    Key? key,
    required this.biometricType,
    required this.biometricIcon,
    required this.isAuthenticating,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _rippleController.repeat();
  }

  @override
  void didUpdateWidget(BiometricAuthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAuthenticating && !oldWidget.isAuthenticating) {
      _rotationController.repeat();
    } else if (!widget.isAuthenticating && oldWidget.isAuthenticating) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isAuthenticating ? null : widget.onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect
            if (widget.isAuthenticating)
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 30.w * (1 + _rippleAnimation.value * 0.3),
                    height: 30.w * (1 + _rippleAnimation.value * 0.3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(
                          alpha: 0.3 * (1 - _rippleAnimation.value),
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            
            // Main biometric icon container
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: widget.isAuthenticating 
                      ? _rotationAnimation.value * 2 * 3.14159 
                      : 0.0,
                  child: Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isAuthenticating
                            ? [
                                AppTheme.secondaryLight,
                                AppTheme.primaryLight,
                              ]
                            : [
                                AppTheme.primaryLight,
                                AppTheme.secondaryLight,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveDesign.getBorderRadius(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLight.withValues(
                            alpha: widget.isAuthenticating ? 0.4 : 0.2,
                          ),
                          blurRadius: widget.isAuthenticating ? 25 : 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getBiometricIcon(),
                      size: ResponsiveDesign.getIconSize(40),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            // Loading indicator
            if (widget.isAuthenticating)
              Positioned(
                bottom: 2.h,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    switch (widget.biometricIcon) {
      case 'fingerprint':
        return Icons.fingerprint_rounded;
      case 'face':
        return Icons.face_rounded;
      case 'visibility':
        return Icons.visibility_rounded;
      case 'security':
      default:
        return Icons.security_rounded;
    }
  }
}
