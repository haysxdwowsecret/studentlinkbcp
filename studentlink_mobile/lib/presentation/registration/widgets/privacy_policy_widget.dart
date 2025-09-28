import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      color: Colors.blue.shade600,
                      size: 8.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'StudentLink Privacy Policy',
                      style: TextStyle(
                        fontSize: 5.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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
              
              // Privacy Content
              _buildSection(
                '1. Information We Collect',
                'We collect the following types of information:\n\n• Personal Information: Name, student ID, email addresses, phone number, birthday, civil status\n• Academic Information: Course, year level, department\n• Usage Data: How you interact with the application\n• Communication Data: Messages and concerns you submit\n• Device Information: Device type, operating system, app version',
              ),
              
              _buildSection(
                '2. How We Use Your Information',
                'We use your information to:\n\n• Provide and maintain the StudentLink service\n• Process and respond to your concerns\n• Communicate with you about your account and concerns\n• Improve our services and user experience\n• Ensure security and prevent fraud\n• Comply with legal obligations',
              ),
              
              _buildSection(
                '3. Information Sharing',
                'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With department heads to address your concerns\n• With school administrators for academic and administrative purposes\n• When required by law or legal process\n• To protect our rights, property, or safety, or that of our users',
              ),
              
              _buildSection(
                '4. Data Security',
                'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n• Encryption of sensitive data\n• Secure servers and databases\n• Regular security audits\n• Access controls and authentication\n• User training on data protection',
              ),
              
              _buildSection(
                '5. Data Retention',
                'We retain your personal information only as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law. Academic records may be retained for the duration of your enrollment and as required by educational regulations.',
              ),
              
              _buildSection(
                '6. Your Rights',
                'Under the Data Privacy Act of 2012 (Republic Act No. 10173), you have the right to:\n\n• Access your personal information\n• Correct inaccurate or incomplete data\n• Request deletion of your data (subject to legal requirements)\n• Object to processing of your data\n• Data portability\n• Withdraw consent where applicable',
              ),
              
              _buildSection(
                '7. Cookies and Tracking',
                'StudentLink may use cookies and similar technologies to enhance your experience, remember your preferences, and analyze usage patterns. You can control cookie settings through your device or browser preferences.',
              ),
              
              _buildSection(
                '8. Third-Party Services',
                'Our application may integrate with third-party services for functionality such as notifications, analytics, or cloud storage. These services have their own privacy policies, and we encourage you to review them.',
              ),
              
              _buildSection(
                '9. Children\'s Privacy',
                'StudentLink is designed for students of Bestlink College of the Philippines. We do not knowingly collect personal information from children under 13 years of age. If you are under 13, please do not use this service.',
              ),
              
              _buildSection(
                '10. International Transfers',
                'Your personal information is primarily processed within the Philippines. If we need to transfer your data internationally, we will ensure appropriate safeguards are in place to protect your privacy rights.',
              ),
              
              _buildSection(
                '11. Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy in the application and updating the "Last Updated" date.',
              ),
              
              _buildSection(
                '12. Contact Us',
                'If you have any questions about this Privacy Policy or our data practices, please contact us:\n\nBestlink College of the Philippines\nData Protection Officer\nEmail: privacy@bcp.edu.ph\nPhone: (02) 8XXX-XXXX\n\nFor data privacy concerns, you may also contact the National Privacy Commission at privacy.gov.ph',
              ),
              
              SizedBox(height: 3.h),
              
              // Footer
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.green.shade600,
                      size: 6.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Your privacy and data security are our top priorities. We are committed to protecting your personal information in accordance with the highest standards and applicable laws.',
                      style: TextStyle(
                        fontSize: 3.5.w,
                        color: Colors.green.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
              color: Colors.blue.shade700,
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
