import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget to display the Bestlink College logo with shadow effects
class CollegeLogoWidget extends StatelessWidget {
  final double size;
  final bool showShadow;
  final Color? shadowColor;

  const CollegeLogoWidget({
    Key? key,
    required this.size,
    this.showShadow = false,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: shadowColor ?? Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(1.w),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Picsart_25-09-06_16-04-40-076.jpg',
                width: size * 0.9,
                height: size * 0.9,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to original logo if image fails to load
                  return CustomImageWidget(
                    imageUrl: 'assets/images/img_app_logo.svg',
                    width: size * 0.7,
                    height: size * 0.7,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}