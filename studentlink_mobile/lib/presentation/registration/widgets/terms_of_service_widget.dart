import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class TermsOfServiceWidget extends StatelessWidget {
  const TermsOfServiceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 8.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'StudentLink Terms of Service',
                      style: TextStyle(
                        fontSize: 5.w,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Last Updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 3.5.w,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Terms Content
              _buildSection(
                '1. Acceptance of Terms',
                'By accessing and using the StudentLink application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),
              
              _buildSection(
                '2. Description of Service',
                'StudentLink is a comprehensive concern management system designed for Bestlink College of the Philippines. The service allows students to submit concerns, track their status, and communicate with department heads.',
              ),
              
              _buildSection(
                '3. User Accounts',
                'To use StudentLink, you must create an account with accurate and complete information. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
              ),
              
              _buildSection(
                '4. Acceptable Use',
                'You agree to use StudentLink only for lawful purposes and in accordance with these Terms. You may not:\n\n• Submit false, misleading, or fraudulent information\n• Use the service to harass, abuse, or harm others\n• Attempt to gain unauthorized access to the system\n• Use the service for commercial purposes without permission\n• Violate any applicable laws or regulations',
              ),
              
              _buildSection(
                '5. Privacy and Data Protection',
                'Your privacy is important to us. We collect, use, and protect your personal information in accordance with our Privacy Policy and applicable data protection laws, including the Data Privacy Act of 2012 (Republic Act No. 10173).',
              ),
              
              _buildSection(
                '6. Intellectual Property',
                'The StudentLink application, including its design, functionality, and content, is protected by intellectual property laws. You may not copy, modify, distribute, or create derivative works without explicit permission.',
              ),
              
              _buildSection(
                '7. Limitation of Liability',
                'StudentLink is provided "as is" without warranties of any kind. We shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the service.',
              ),
              
              _buildSection(
                '8. Termination',
                'We reserve the right to terminate or suspend your account at any time for violations of these Terms or for any other reason at our sole discretion.',
              ),
              
              _buildSection(
                '9. Changes to Terms',
                'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting. Your continued use of the service constitutes acceptance of the modified Terms.',
              ),
              
              _buildSection(
                '10. Governing Law',
                'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines. Any disputes shall be resolved in the courts of the Philippines.',
              ),
              
              _buildSection(
                '11. Contact Information',
                'For questions about these Terms of Service, please contact:\n\nBestlink College of the Philippines\nStudentLink Support Team\nEmail: support@bcp.edu.ph\nPhone: (02) 8XXX-XXXX',
              ),
              
              SizedBox(height: 3.h),
              
              // Footer
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'By using StudentLink, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                  style: TextStyle(
                    fontSize: 3.5.w,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 4.5.w,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 3.8.w,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
