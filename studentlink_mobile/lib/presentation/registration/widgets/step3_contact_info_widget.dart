import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class Step3ContactInfoWidget extends StatefulWidget {
  final String? schoolEmail;
  final Function(String? personalEmail, String? contactNumber) onDataChanged;

  const Step3ContactInfoWidget({
    Key? key,
    required this.schoolEmail,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<Step3ContactInfoWidget> createState() => _Step3ContactInfoWidgetState();
}

class _Step3ContactInfoWidgetState extends State<Step3ContactInfoWidget> {
  final _personalEmailController = TextEditingController();
  final _contactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _personalEmailController.addListener(_onDataChanged);
    _contactNumberController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _personalEmailController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _personalEmailController.text.trim().isEmpty ? null : _personalEmailController.text.trim(),
      _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 5.5.w,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.5.h),
        
        Text(
          'Provide your contact details for communication and account recovery.',
          style: TextStyle(
            fontSize: 3.8.w,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 3.h),
          
          // School Email (read-only)
          if (widget.schoolEmail != null) ...[
            _buildReadOnlyField(
              label: 'School Email',
              value: widget.schoolEmail!,
              icon: Icons.school,
              color: Colors.green,
            ),
            
        SizedBox(height: 1.5.h),
        ],
        
        // Personal Email
        _buildTextField(
          controller: _personalEmailController,
          label: 'Personal Email',
          hint: 'Enter your personal email address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
        
        SizedBox(height: 1.5.h),
        
        // Contact Number
        _buildTextField(
          controller: _contactNumberController,
          label: 'Contact Number',
          hint: 'Enter your phone number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        
        SizedBox(height: 1.5.h),
          
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
                      'Email Information',
                      style: TextStyle(
                        fontSize: 3.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '• School Email: Used for official communications\n'
                      '• Personal Email: Used for account recovery\n'
                      '• Both emails will be verified during registration',
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
        
        SizedBox(height: 1.5.h),
        
        // Contact note
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.phone_android,
                color: Colors.blue.shade600,
                size: 3.5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 3.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '• Include country code (e.g., +63 for Philippines)\n'
                      '• Used for SMS notifications and account recovery\n'
                      '• Must be a valid, active phone number',
                      style: TextStyle(
                        fontSize: 3.2.w,
                        color: Colors.blue.shade700,
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
      );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Auto-generated',
                style: TextStyle(
                  fontSize: 3.w,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 3.5.w,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 3.w,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 3.5.w,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
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
            fontSize: 3.5.w,
            color: Colors.grey.shade800,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (keyboardType == TextInputType.emailAddress) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
