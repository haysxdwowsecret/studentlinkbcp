import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive_design.dart';
import '../../services/biometric_auth_service.dart';
import '../../routes/app_routes.dart';
import 'widgets/typing_pattern_widget.dart';
import 'widgets/biometric_background_widget.dart';

class TypingDnaAuthScreen extends StatefulWidget {
  const TypingDnaAuthScreen({Key? key}) : super(key: key);

  @override
  State<TypingDnaAuthScreen> createState() => _TypingDnaAuthScreenState();
}

class _TypingDnaAuthScreenState extends State<TypingDnaAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String? _userId;
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;
  
  // Typing patterns for authentication
  final List<String> _authTexts = [
    'Welcome to StudentLink',
    'Secure authentication system',
    'Type this text to verify your identity',
  ];
  
  int _currentTextIndex = 0;
  List<String> _collectedPatterns = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await _biometricService.getTypingDnaUserId();
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      print('Error loading user data: $e');
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithTypingPattern(String pattern) async {
    if (_isAuthenticating || _userId == null) return;

    setState(() {
      _isAuthenticating = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      final currentText = _authTexts[_currentTextIndex];
      final result = await _biometricService.authenticateWithTypingDna(
        _userId!,
        currentText,
        pattern,
      );
      
      switch (result) {
        case TypingDnaResult.success:
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
          
        case TypingDnaResult.failed:
          _failedAttempts++;
          HapticFeedback.lightImpact();
          
          if (_failedAttempts >= _maxFailedAttempts) {
            _showMaxAttemptsReached();
          } else {
            _showFailedMessage();
          }
          break;
          
        case TypingDnaResult.setupComplete:
          // First time setup completed
          _showSetupCompleteMessage();
          break;
          
        case TypingDnaResult.notEnabled:
        case TypingDnaResult.error:
          _navigateToLogin();
          break;
      }
    } catch (e) {
      print('Error during TypingDNA authentication: $e');
      _navigateToLogin();
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _onPatternCollected(String pattern) {
    _collectedPatterns.add(pattern);
    
    if (_collectedPatterns.length >= 2) {
      // We have enough patterns, authenticate
      _authenticateWithTypingPattern(pattern);
    } else {
      // Move to next text
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % _authTexts.length;
      });
    }
  }

  void _onPatternCollectionComplete() {
    // All patterns collected, authenticate with the last pattern
    if (_collectedPatterns.isNotEmpty) {
      _authenticateWithTypingPattern(_collectedPatterns.last);
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
            const Text('Typing pattern authentication successful!'),
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
            const Text('Typing pattern authentication failed. Try again.'),
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

  void _showSetupCompleteMessage() {
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
            const Text('Typing pattern setup completed!'),
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

    // Navigate to dashboard after setup
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
      }
    });
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
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      _buildAppLogo(),
                      
                      SizedBox(height: 4.h),
                      
                      // Title and description
                      _buildTitleAndDescription(),
                      
                      SizedBox(height: 4.h),
                      
                      // Typing pattern widget
                      _buildTypingPatternWidget(),
                      
                      SizedBox(height: 4.h),
                      
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
        Icons.keyboard_rounded,
        size: ResponsiveDesign.getIconSize(32),
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      children: [
        Text(
          'Typing Pattern Authentication',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 2.h),
        
        Text(
          'Type the text below to authenticate using your unique typing pattern',
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

  Widget _buildTypingPatternWidget() {
    return TypingPatternWidget(
      text: _authTexts[_currentTextIndex],
      onPatternCollected: _onPatternCollected,
      onComplete: _onPatternCollectionComplete,
      isEnabled: !_isAuthenticating,
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
          'Type the text above to authenticate with your unique typing pattern',
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
