import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickSuggestionsModal extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const QuickSuggestionsModal({
    Key? key,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.4.h,
            margin: EdgeInsets.only(top: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Title
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Quick action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    onSuggestionTap('Take a photo of my concern');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'Photos',
                  onTap: () {
                    Navigator.pop(context);
                    onSuggestionTap('Upload a photo from gallery');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.attach_file,
                  label: 'Files',
                  onTap: () {
                    Navigator.pop(context);
                    onSuggestionTap('Attach a document');
                  },
                ),
              ],
            ),
          ),
          
          SizedBox(height: 2.5.h),
          
          // Quick suggestions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Suggestions',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Wrap(
                  spacing: 1.5.w,
                  runSpacing: 1.5.h,
                  children: [
                    'How to submit a concern?',
                    'Academic calendar',
                    'Contact information',
                    'Library hours',
                    'Enrollment process',
                    'Grade inquiry',
                    'Uniform policy',
                    'Scholarship information',
                  ].map((suggestion) => _buildSuggestionChip(
                    context: context,
                    text: suggestion,
                    onTap: () {
                      Navigator.pop(context);
                      onSuggestionTap(suggestion);
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 2.5.h),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(height: 0.8.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}
