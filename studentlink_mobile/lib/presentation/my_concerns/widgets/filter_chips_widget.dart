import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String) onFilterRemoved;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.onClearAll,
  }) : super(key: key);

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    // Status filter chip
    if (activeFilters['status'] != null && activeFilters['status'] != 'All') {
      chips.add(
        Chip(
          label: Text(
            'Status: ${activeFilters['status']}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          deleteIcon: CustomIconWidget(
            iconName: 'close',
            size: 16,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          onDeleted: () => onFilterRemoved('status'),
          backgroundColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
        ),
      );
    }

    // Department filter chip
    if (activeFilters['department'] != null &&
        activeFilters['department'] != 'All') {
      chips.add(
        Chip(
          label: Text(
            'Dept: ${_truncateDepartment(activeFilters['department'])}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          deleteIcon: CustomIconWidget(
            iconName: 'close',
            size: 16,
            color: AppTheme.lightTheme.colorScheme.secondary,
          ),
          onDeleted: () => onFilterRemoved('department'),
          backgroundColor:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.secondary,
            width: 1,
          ),
        ),
      );
    }

    // Date range filter chip
    if (activeFilters['dateRange'] != null) {
      final DateTimeRange dateRange =
          activeFilters['dateRange'] as DateTimeRange;
      chips.add(
        Chip(
          label: Text(
            'Date: ${dateRange.start.day}/${dateRange.start.month} - ${dateRange.end.day}/${dateRange.end.month}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),
          ),
          deleteIcon: CustomIconWidget(
            iconName: 'close',
            size: 16,
            color: AppTheme.lightTheme.colorScheme.tertiary,
          ),
          onDeleted: () => onFilterRemoved('dateRange'),
          backgroundColor:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.tertiary,
            width: 1,
          ),
        ),
      );
    }

    return chips;
  }

  String _truncateDepartment(String department) {
    if (department.length <= 20) return department;
    return '${department.substring(0, 17)}...';
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (activeFilters['status'] != null && activeFilters['status'] != 'All')
      count++;
    if (activeFilters['department'] != null &&
        activeFilters['department'] != 'All') count++;
    if (activeFilters['dateRange'] != null) count++;
    return count;
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
