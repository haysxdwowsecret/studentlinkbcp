import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class SimpleProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String studentId;
  final String course;
  final String yearLevel;
  final String? avatar;

  const SimpleProfileHeaderWidget({
    Key? key,
    required this.name,
    required this.studentId,
    required this.course,
    required this.yearLevel,
    this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 8.w,
            backgroundColor: Colors.white,
            backgroundImage: avatar != null && avatar!.isNotEmpty
                ? NetworkImage(avatar!)
                : null,
            child: avatar == null || avatar!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 10.w,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  )
                : null,
          ),
          
          SizedBox(height: 3.h),
          
          // Name
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 5.w,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 1.h),
          
          // Student ID
          Text(
            'ID: $studentId',
            style: GoogleFonts.inter(
              fontSize: 4.w,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 1.h),
          
          // Course and Year Level
          Text(
            '$course - $yearLevel',
            style: GoogleFonts.inter(
              fontSize: 3.5.w,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
