import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String categoryFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.categoryFilter,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryFilter == 'All') {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters (1)',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'Clear All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 0.5.h,
            children: [
              Chip(
                label: Text(
                  'Category: $categoryFilter',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                backgroundColor:
                    AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
