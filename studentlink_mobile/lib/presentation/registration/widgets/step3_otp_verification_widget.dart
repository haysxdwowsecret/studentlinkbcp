import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';

class Step3OtpVerificationWidget extends StatefulWidget {
  final String personalEmail;
  final String contactNumber;
  final Function(String emailOtp, String phoneOtp) onDataChanged;
  final Function(String error) onError;

  const Step3OtpVerificationWidget({
    Key? key,
    required this.personalEmail,
    required this.contactNumber,
    required this.onDataChanged,
    required this.onError,
  }) : super(key: key);

  @override
  State<Step3OtpVerificationWidget> createState() => _Step3OtpVerificationWidgetState();
}

class _Step3OtpVerificationWidgetState extends State<Step3OtpVerificationWidget> {
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
  Timer? _debounceTimer; // Add debounce timer for text changes

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
    _debounceTimer?.cancel(); // Cancel debounce timer
    super.dispose();
  }

  void _onDataChanged() {
    // Optimize: Debounce rapid text changes to reduce rebuilds
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
        
        // Show debug OTP if available (for development)
        String message = 'OTP sent to ${widget.personalEmail}';
        if (response['debug_otp'] != null) {
          message += '\nDebug OTP: ${response['debug_otp']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
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
        
        // Show debug OTP if available (for development)
        String message = 'OTP sent to ${widget.contactNumber}';
        if (response['debug_otp'] != null) {
          message += '\nDebug OTP: ${response['debug_otp']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
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
          // Header
          Text(
            'Verify Your Contact Information',
            style: TextStyle(
              fontSize: 5.5.w,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          
          SizedBox(height: 1.5.h),
          
          Text(
            'We\'ve sent verification codes to your email and phone number. Please enter them below to continue.',
            style: TextStyle(
              fontSize: 3.8.w,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 3.h),

          // Email OTP Section
          _buildOtpSection(
            title: 'Email Verification',
            subtitle: 'Enter the 6-digit code sent to',
            contact: widget.personalEmail,
            controller: _emailOtpController,
            isSent: _emailOtpSent,
            countdown: _emailCountdown,
            onSend: _sendEmailOtp,
            icon: Icons.email,
            color: Colors.blue,
          ),
          
          SizedBox(height: 3.h),

          // Phone OTP Section
          _buildOtpSection(
            title: 'Phone Verification',
            subtitle: 'Enter the 6-digit code sent to',
            contact: widget.contactNumber,
            controller: _phoneOtpController,
            isSent: _phoneOtpSent,
            countdown: _phoneCountdown,
            onSend: _sendPhoneOtp,
            icon: Icons.phone,
            color: Colors.green,
          ),
          
          SizedBox(height: 2.h),
          
          // Information note
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade600,
                  size: 3.5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Information',
                        style: TextStyle(
                          fontSize: 3.5.w,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '• Check your email inbox and SMS messages\n'
                        '• OTP codes expire in 10 minutes\n'
                        '• You can resend codes after 60 seconds\n'
                        '• Contact support if you don\'t receive the codes',
                        style: TextStyle(
                          fontSize: 3.2.w,
                          color: Colors.orange.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection({
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
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 4.w,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      '$subtitle $contact',
                      style: TextStyle(
                        fontSize: 3.2.w,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isSent ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isSent ? 'Sent' : 'Pending',
                  style: TextStyle(
                    fontSize: 2.8.w,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 2.h),
          
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
                Icons.security,
                color: color,
              ),
              suffixIcon: countdown > 0
                  ? Container(
                      padding: EdgeInsets.all(2.w),
                      child: Text(
                        '${countdown}s',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 3.w,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: color,
                      ),
                      onPressed: _isLoading ? null : onSend,
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 3.h,
              ),
            ),
            style: TextStyle(
              fontSize: 4.5.w,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.grey.shade800,
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
          
          SizedBox(height: 1.h),
          
          // Resend button
          if (countdown == 0 && isSent)
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : onSend,
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    color: color,
                    fontSize: 3.5.w,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
