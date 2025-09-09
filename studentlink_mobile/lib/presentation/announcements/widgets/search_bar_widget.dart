import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          onChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
