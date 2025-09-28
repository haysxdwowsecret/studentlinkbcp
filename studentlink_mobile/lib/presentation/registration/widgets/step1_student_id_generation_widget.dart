import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/error_handler.dart';

class Step1StudentIdGenerationWidget extends StatefulWidget {
  final Function(String studentId, String schoolEmail) onStudentIdGenerated;
  final Function(String error) onError;

  const Step1StudentIdGenerationWidget({
    super.key,
    required this.onStudentIdGenerated,
    required this.onError,
  });

  @override
  State<Step1StudentIdGenerationWidget> createState() => _Step1StudentIdGenerationWidgetState();
}

class _Step1StudentIdGenerationWidgetState extends State<Step1StudentIdGenerationWidget> {
  bool _isGenerating = false;
  String? _generatedStudentId;
  String? _generatedSchoolEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Generate Student ID',
          style: TextStyle(
            fontSize: 5.5.w,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.5.h),
        
        Text(
          'Your unique student ID will be automatically generated. This ID will be used for your school email and throughout your academic journey.',
          style: TextStyle(
            fontSize: 3.8.w,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 3.h),
          
        // Generate button
        Center(
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateStudentId,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: _isGenerating
                ? SizedBox(
                    width: 3.5.w,
                    height: 3.5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 4.5.w,
                  ),
            label: Text(
              _isGenerating ? 'Generating...' : 'Generate Student ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 4.w,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 3.h),
          
        // Generated ID display
        if (_generatedStudentId != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 4.5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Student ID Generated Successfully!',
                        style: TextStyle(
                          fontSize: 4.w,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                  
                // Student ID
                _buildInfoRow(
                  'Student ID',
                  _generatedStudentId!,
                  Icons.badge,
                  Colors.blue,
                ),
                
                SizedBox(height: 1.5.h),
                
                // School Email
                _buildInfoRow(
                  'School Email',
                  _generatedSchoolEmail!,
                  Icons.email,
                  Colors.orange,
                ),
                
                SizedBox(height: 1.5.h),
                
                // Info note
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 3.5.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Please save this information. You will need your Student ID for login and your School Email for official communications.',
                          style: TextStyle(
                            fontSize: 3.2.w,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 2.h),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade600,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Important Information',
                      style: TextStyle(
                        fontSize: 4.5.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                _buildInstructionItem(
                  'Your Student ID is unique and cannot be changed',
                  Icons.fingerprint,
                ),
                
                _buildInstructionItem(
                  'The School Email will be used for official communications',
                  Icons.mail,
                ),
                
                _buildInstructionItem(
                  'Keep this information secure and confidential',
                  Icons.security,
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 4.5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 3.5.w,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 4.w,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(value),
            icon: Icon(
              Icons.copy,
              color: Colors.grey.shade600,
              size: 4.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 3.5.w,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateStudentId() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await apiService.generateStudentId();
      
      setState(() {
        _generatedStudentId = result['student_id'];
        _generatedSchoolEmail = result['school_email'];
      });

      widget.onStudentIdGenerated(_generatedStudentId!, _generatedSchoolEmail!);
    } catch (e) {
      final errorMessage = e is AppError ? e.message : 'Failed to generate student ID. Please try again.';
      widget.onError(errorMessage);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard(String text) async {
    try {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: text));
      
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
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Copied to clipboard: $text',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 3.5.w,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF22C55E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    } catch (e) {
      // Show error message if clipboard access fails
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Failed to copy to clipboard. Please try again.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 3.5.w,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC2626),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    }
  }
}
