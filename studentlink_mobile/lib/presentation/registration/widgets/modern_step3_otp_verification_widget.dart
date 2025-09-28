import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Modern step 3 OTP verification widget
class ModernStep3OtpVerificationWidget extends StatelessWidget {
  final String personalEmail;
  final String contactNumber;
  final Function(String? emailOtp, String? phoneOtp) onDataChanged;
  final Function(String error) onError;

  const ModernStep3OtpVerificationWidget({
    Key? key,
    required this.personalEmail,
    required this.contactNumber,
    required this.onDataChanged,
    required this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OTP Verification',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This step will be implemented with modern UI design.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
