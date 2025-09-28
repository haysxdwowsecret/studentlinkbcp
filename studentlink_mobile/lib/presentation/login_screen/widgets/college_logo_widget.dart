import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CollegeLogoWidget extends StatelessWidget {
  const CollegeLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: Column(
        children: [
          Image.asset(
            'assets/images/img_app_logo.png',
            width: 25.w,
            height: 25.w,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to BCP text if image fails to load
              return Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'BCP',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          Text(
            'Bestlink College',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'of the Philippines',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}