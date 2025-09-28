import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';

class ModernStep4OtpVerificationWidget extends StatefulWidget {
  final String personalEmail;
  final String contactNumber;
  final Function(String emailOtp, String phoneOtp) onDataChanged;
  final Function(String error) onError;

  const ModernStep4OtpVerificationWidget({
    Key? key,
    required this.personalEmail,
    required this.contactNumber,
    required this.onDataChanged,
    required this.onError,
  }) : super(key: key);

  @override
  State<ModernStep4OtpVerificationWidget> createState() => _ModernStep4OtpVerificationWidgetState();
}

class _ModernStep4OtpVerificationWidgetState extends State<ModernStep4OtpVerificationWidget> {
  final _emailOtpController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _emailOtpSent = false;
  bool _phoneOtpSent = false;
  int _emailCountdown = 0;
  int _phoneCountdown = 0;
  Timer? _emailTimer;
  Timer? _phoneTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _emailOtpController.addListener(_onDataChanged);
    _phoneOtpController.addListener(_onDataChanged);
    
    // Auto-send OTPs when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendEmailOtp();
      _sendPhoneOtp();
    });
  }

  @override
  void dispose() {
    _emailOtpController.dispose();
    _phoneOtpController.dispose();
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onDataChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onDataChanged(
        _emailOtpController.text.trim(),
        _phoneOtpController.text.trim(),
      );
    });
  }

  void _startCountdown(bool isEmail) {
    setState(() {
      if (isEmail) {
        _emailCountdown = 60;
      } else {
        _phoneCountdown = 60;
      }
    });

    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (isEmail) {
          _emailCountdown--;
          if (_emailCountdown <= 0) {
            _emailTimer?.cancel();
            _emailTimer = null;
          }
        } else {
          _phoneCountdown--;
          if (_phoneCountdown <= 0) {
            _phoneTimer?.cancel();
            _phoneTimer = null;
          }
        }
      });
    });

    if (isEmail) {
      _emailTimer = timer;
    } else {
      _phoneTimer = timer;
    }
  }

  Future<void> _sendEmailOtp() async {
    if (_emailCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().sendEmailOtp(widget.personalEmail);
      
      if (response['success']) {
        setState(() => _emailOtpSent = true);
        _startCountdown(true);
        
        HapticFeedback.lightImpact();
        
        String message = 'OTP sent to ${widget.personalEmail}';
        if (response['debug_otp'] != null) {
          message += '\nDebug OTP: ${response['debug_otp']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        widget.onError(response['message'] ?? 'Failed to send email OTP');
      }
    } catch (e) {
      widget.onError('Failed to send email OTP: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneOtp() async {
    if (_phoneCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().sendPhoneOtp(widget.contactNumber);
      
      if (response['success']) {
        setState(() => _phoneOtpSent = true);
        _startCountdown(false);
        
        HapticFeedback.lightImpact();
        
        String message = 'OTP sent to ${widget.contactNumber}';
        if (response['debug_otp'] != null) {
          message += '\nDebug OTP: ${response['debug_otp']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        widget.onError(response['message'] ?? 'Failed to send phone OTP');
      }
    } catch (e) {
      widget.onError('Failed to send phone OTP: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern header with gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  AppTheme.secondaryLight.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary,
                            AppTheme.secondaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify Your Contact Information',
                            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We\'ve sent verification codes to your email and phone number. Please enter them below to continue.',
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Email OTP Section
          _buildModernOtpSection(
            title: 'Email Verification',
            subtitle: 'Enter the 6-digit code sent to',
            contact: widget.personalEmail,
            controller: _emailOtpController,
            isSent: _emailOtpSent,
            countdown: _emailCountdown,
            onSend: _sendEmailOtp,
            icon: Icons.email_rounded,
            color: const Color(0xFF3B82F6),
          ),
          
          const SizedBox(height: 20),

          // Phone OTP Section
          _buildModernOtpSection(
            title: 'Phone Verification',
            subtitle: 'Enter the 6-digit code sent to',
            contact: widget.contactNumber,
            controller: _phoneOtpController,
            isSent: _phoneOtpSent,
            countdown: _phoneCountdown,
            onSend: _sendPhoneOtp,
            icon: Icons.phone_rounded,
            color: const Color(0xFF10B981),
          ),
          
          const SizedBox(height: 24),
          
          // Modern Information Card
          _buildModernInfoCard(),
        ],
      ),
    );
  }


  Widget _buildModernOtpSection({
    required String title,
    required String subtitle,
    required String contact,
    required TextEditingController controller,
    required bool isSent,
    required int countdown,
    required VoidCallback onSend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$subtitle $contact',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSent ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSent ? 'Sent' : 'Pending',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // OTP Input Field
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !_isLoading,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Enter 6-digit code',
              hintText: '000000',
              counterText: '',
              prefixIcon: Icon(
                Icons.security_rounded,
                color: color,
              ),
              suffixIcon: countdown > 0
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${countdown}s',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: color,
                      ),
                      onPressed: _isLoading ? null : onSend,
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: color,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length != 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Resend button
          if (countdown == 0 && isSent)
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : onSend,
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Resend Code',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Information',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Check your email inbox and SMS messages\n'
                  '• OTP codes expire in 10 minutes\n'
                  '• You can resend codes after 60 seconds\n'
                  '• Contact support if you don\'t receive the codes',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
