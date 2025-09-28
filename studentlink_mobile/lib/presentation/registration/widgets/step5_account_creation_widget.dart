import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import 'terms_of_service_widget.dart';
import 'privacy_policy_widget.dart';

class Step5AccountCreationWidget extends StatefulWidget {
  final Function(String? password, String? passwordConfirmation) onDataChanged;

  const Step5AccountCreationWidget({
    Key? key,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<Step5AccountCreationWidget> createState() => _Step5AccountCreationWidgetState();
}

class _Step5AccountCreationWidgetState extends State<Step5AccountCreationWidget> {
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 5.5.w,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.5.h),
        
        Text(
          'Review your information and agree to the terms to complete your registration.',
          style: TextStyle(
            fontSize: 3.8.w,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 3.h),
          
        // Account summary
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: Colors.blue.shade600,
                    size: 3.5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Account Summary',
                    style: TextStyle(
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 1.5.h),
              
              Text(
                'Your account will be created with the following information:',
                style: TextStyle(
                  fontSize: 3.2.w,
                  color: Colors.blue.shade700,
                ),
              ),
              
              SizedBox(height: 1.5.h),
                
              _buildSummaryItem('Student ID', 'Auto-generated unique ID'),
              _buildSummaryItem('School Email', 'Auto-generated school email'),
              _buildSummaryItem('Personal Information', 'Name, birthday, civil status'),
              _buildSummaryItem('Contact Information', 'Personal email and phone number'),
              _buildSummaryItem('Account Security', 'Secure password protection'),
            ],
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Terms and conditions
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 3.5.w,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              
              SizedBox(height: 1.5.h),
                
              // Terms agreement
              CheckboxListTile(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'I agree to the ',
                        style: TextStyle(
                          fontSize: 3.2.w,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfServiceWidget(),
                          ),
                        );
                      },
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 3.2.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              
              // Privacy agreement
              CheckboxListTile(
                value: _agreeToPrivacy,
                onChanged: (value) {
                  setState(() {
                    _agreeToPrivacy = value ?? false;
                  });
                },
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'I agree to the ',
                        style: TextStyle(
                          fontSize: 3.2.w,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyWidget(),
                          ),
                        );
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 3.2.w,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 2.h),
          
        // Information note
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade600,
                size: 3.5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to Create Account',
                      style: TextStyle(
                        fontSize: 3.5.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Once you create your account, you will be automatically logged in and can start using the StudentLink app immediately.',
                      style: TextStyle(
                        fontSize: 3.2.w,
                        color: Colors.green.shade700,
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
        
        // Validation message
        if (!_agreeToTerms || !_agreeToPrivacy)
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange.shade600,
                  size: 3.5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Please agree to the Terms of Service and Privacy Policy to continue.',
                    style: TextStyle(
                      fontSize: 3.2.w,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildSummaryItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 3.5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 3.2.w,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 2.8.w,
                    color: Colors.blue.shade600,
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
