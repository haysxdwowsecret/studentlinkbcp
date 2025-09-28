import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../services/biometric_auth_service.dart';
import '../../theme/app_theme.dart';
import './widgets/modern_background_widget.dart';
import './widgets/modern_logo_widget.dart';
import './widgets/modern_login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Authenticate with the backend API
      await apiService.login(email, password);
      
      // Login successful if we get here without exception
      // Success haptic feedback
      HapticFeedback.mediumImpact();

      // Show success message
      if (mounted) {
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
                const Text('Login successful!'),
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

        // Check if biometric authentication should be enabled
        await _handlePostLoginBiometric(email, password);
        
        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard-home');
      }
    } catch (e) {
      // Network or other errors
      setState(() {
        _errorMessage =
            'Unable to connect to the server. Please check your internet connection and try again.';
      });

      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Modern background
            const ModernBackgroundWidget(),

            // Main content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Modern logo and branding
                    const ModernLogoWidget(),

                    const SizedBox(height: 32),

                    // Welcome section
                    _buildWelcomeSection(),

                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null) _buildErrorMessage(),

                    // Modern login form
                    ModernLoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Registration option
                    _buildRegistrationOption(),

                    const SizedBox(height: 32),

                    // App version and support info
                    _buildFooterInfo(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to access StudentLink',
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.emergencyLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.emergencyLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.emergencyLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.emergencyLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationOption() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: const Color(0xFFE5E7EB),
                thickness: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: const Color(0xFFE5E7EB),
                thickness: 1,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Registration button
        OutlinedButton(
          onPressed: _isLoading ? null : _navigateToRegistration,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: const BorderSide(
              color: AppTheme.primaryLight,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Create New Account',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        Text(
          'StudentLink v1.0.0',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For technical support, contact MIS Office',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _navigateToRegistration() {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Navigate to registration screen
    Navigator.of(context).pushNamed('/registration');
  }

  Future<void> _handlePostLoginBiometric(String email, String password) async {
    try {
      final biometricService = BiometricAuthService();
      
      // Check what biometric options are available
      final availability = await biometricService.checkBiometricAvailability();
      
      if (availability == BiometricAvailability.deviceBiometric) {
        // Device biometric is available (like GCash/PayMaya)
        final enabled = await biometricService.enableDeviceBiometricAuth();
        if (enabled) {
          _showDeviceBiometricEnabledMessage();
        } else {
          _showBiometricEnableFailedMessage();
        }
      } else if (availability == BiometricAvailability.typingPattern) {
        // Only TypingDNA is available
        final enabled = await biometricService.enableTypingDnaAuth(email);
        if (enabled) {
          _showTypingDnaEnabledMessage();
        } else {
          _showTypingDnaEnableFailedMessage();
        }
      } else {
        // No biometric authentication available
        _showBiometricNotAvailableMessage();
      }
    } catch (e) {
      print('Error handling post-login biometric: $e');
    }
  }



  void _showBiometricEnableFailedMessage() {
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
            const Text('Failed to enable biometric authentication'),
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

  void _showDeviceBiometricEnabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Device biometric authentication enabled!'),
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

  void _showTypingDnaEnabledMessage() {
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
            const Text('Typing pattern authentication enabled!'),
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

  void _showTypingDnaEnableFailedMessage() {
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
            const Text('Failed to enable typing pattern authentication'),
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

  void _showBiometricNotAvailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Biometric authentication not available on this device'),
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
}