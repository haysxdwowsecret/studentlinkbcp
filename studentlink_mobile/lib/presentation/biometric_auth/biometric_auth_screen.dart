import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive_design.dart';
import '../../services/biometric_auth_service.dart';
import '../../routes/app_routes.dart';
import 'widgets/biometric_auth_widget.dart';
import 'widgets/biometric_background_widget.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({Key? key}) : super(key: key);

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String _biometricType = 'Biometric';
  String _biometricIcon = 'security';
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBiometricInfo();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadBiometricInfo() async {
    try {
      final biometricType = await _biometricService.getBiometricTypeString();
      final biometricIcon = await _biometricService.getBiometricIcon();
      
      setState(() {
        _biometricType = biometricType;
        _biometricIcon = biometricIcon;
      });
    } catch (e) {
      print('Error loading biometric info: $e');
      // Fallback to default values
      setState(() {
        _biometricType = 'Biometric';
        _biometricIcon = 'security';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Try device biometric authentication first
      final deviceEnabled = await _biometricService.isDeviceBiometricEnabled();
      BiometricAuthResult result;
      
      if (deviceEnabled) {
        result = await _biometricService.authenticateWithDeviceBiometric();
      } else {
        // Fallback to general biometric authentication
        result = await _biometricService.authenticateWithBiometric();
      }
      
      switch (result) {
        case BiometricAuthResult.success:
          // Success haptic feedback
          HapticFeedback.heavyImpact();
          
          // Show success message
          _showSuccessMessage();
          
          // Navigate to dashboard after a short delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
            }
          });
          break;
          
        case BiometricAuthResult.failed:
          _failedAttempts++;
          HapticFeedback.lightImpact();
          
          if (_failedAttempts >= _maxFailedAttempts) {
            _showMaxAttemptsReached();
          } else {
            _showFailedMessage();
          }
          break;
          
        case BiometricAuthResult.userCancel:
        case BiometricAuthResult.systemCancel:
          // User cancelled, don't count as failed attempt
          break;
          
        case BiometricAuthResult.notAvailable:
        case BiometricAuthResult.notEnabled:
        case BiometricAuthResult.error:
        case BiometricAuthResult.deviceNotSupported:
          _navigateToLogin();
          break;
      }
    } catch (e) {
      print('Error during biometric authentication: $e');
      _navigateToLogin();
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('$_biometricType authentication successful!'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showFailedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('$_biometricType authentication failed. Try again.'),
          ],
        ),
        backgroundColor: AppTheme.warningLight,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMaxAttemptsReached() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.block_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Too many failed attempts. Please login manually.'),
          ],
        ),
        backgroundColor: AppTheme.emergencyLight,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Navigate to login after showing message
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            const BiometricBackgroundWidget(),
            
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      _buildAppLogo(),
                      
                      SizedBox(height: 8.h),
                      
                      // Biometric authentication widget
                      _buildBiometricWidget(),
                      
                      SizedBox(height: 6.h),
                      
                      // Title and description
                      _buildTitleAndDescription(),
                      
                      SizedBox(height: 8.h),
                      
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight,
            AppTheme.secondaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveDesign.getBorderRadius(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.school_rounded,
        size: ResponsiveDesign.getIconSize(32),
        color: Colors.white,
      ),
    );
  }

  Widget _buildBiometricWidget() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
          child: BiometricAuthWidget(
            biometricType: _biometricType,
            biometricIcon: _biometricIcon,
            isAuthenticating: _isAuthenticating,
            onTap: _authenticateWithBiometric,
          ),
        );
      },
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 2.h),
        
        Text(
          'Use your $_biometricType to quickly access your account',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryLight,
            height: 1.5,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (_failedAttempts > 0) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveDesign.getBorderRadius(8),
              ),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Failed attempts: $_failedAttempts/$_maxFailedAttempts',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.warningLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Use Password button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _navigateToLogin,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveDesign.getButtonHeight() * 0.6,
              ),
              side: BorderSide(
                color: AppTheme.primaryLight,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveDesign.getBorderRadius(12),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: ResponsiveDesign.getIconSize(20),
                  color: AppTheme.primaryLight,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Use Password Instead',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Help text
        Text(
          'Tap the $_biometricType icon above to authenticate',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
