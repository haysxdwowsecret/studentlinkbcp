import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      await apiService.requestPasswordReset(_emailController.text.trim());
      
      // Success haptic feedback
      HapticFeedback.mediumImpact();

      setState(() {
        _isSuccess = true;
        _message = 'Password reset instructions have been sent to your email address.';
      });

    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();
      
      setState(() {
        _isSuccess = false;
        _message = e.toString().contains('Exception:') 
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to send password reset email. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // Modern Header
                _buildModernHeader(),

                const SizedBox(height: 32),

                // Email Field
                _buildModernEmailField(),

                const SizedBox(height: 24),

                // Message Display
                if (_message != null) _buildModernMessageDisplay(),

                const SizedBox(height: 32),

                // Reset Password Button
                _buildModernResetButton(),

                const SizedBox(height: 16),

                // Back to Login Button
                _buildModernBackButton(),

                const SizedBox(height: 32),

                // Help Text
                _buildModernHelpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'Reset Password',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: const Color(0xFF1A1A1A),
          size: 20,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // College Logo
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/img_app_logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'Forgot Your Password?',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Description
        Text(
          'Enter your email address and we\'ll send you instructions to reset your password.',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModernEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        enabled: !_isLoading,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email address',
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
          labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B7280),
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppTheme.primaryLight,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildModernMessageDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSuccess 
            ? AppTheme.successLight.withValues(alpha: 0.1)
            : AppTheme.emergencyLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSuccess 
              ? AppTheme.successLight.withValues(alpha: 0.3)
              : AppTheme.emergencyLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: _isSuccess ? AppTheme.successLight : AppTheme.emergencyLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: _isSuccess ? AppTheme.successLight : AppTheme.emergencyLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || _isSuccess ? null : _handlePasswordReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isSuccess ? 'Email Sent' : 'Send Reset Instructions',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildModernBackButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryLight,
          side: BorderSide(color: AppTheme.primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Back to Login',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModernHelpText() {
    return Center(
      child: Text(
        'Still having trouble? Contact support at\nsupport@bestlink.edu.ph',
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF9CA3AF),
          height: 1.5,
        ),
      ),
    );
  }
}
