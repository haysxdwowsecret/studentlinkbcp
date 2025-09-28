import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String statusFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.statusFilter,
    required this.onClearAll,
  }) : super(key: key);

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    // Status filter chip
    if (statusFilter != 'All') {
      chips.add(
        Chip(
          label: Text(
            'Status: $statusFilter',
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
      );
    }

    return chips;
  }

  int _getActiveFilterCount() {
    return statusFilter != 'All' ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final chips = _buildFilterChips();
    final filterCount = _getActiveFilterCount();

    if (chips.isEmpty) {
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
                'Active Filters ($filterCount)',
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
            children: chips,
          ),
        ],
      ),
    );
  }
}
