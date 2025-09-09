import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Set<String> selectedDepartments;
  final Set<String> selectedCategories;
  final Set<String> selectedPriorities;
  final DateTimeRange? selectedDateRange;
  final Function(String type, String value) onRemoveFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.selectedDepartments,
    required this.selectedCategories,
    required this.selectedPriorities,
    required this.selectedDateRange,
    required this.onRemoveFilter,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    // Department chips
    for (final department in selectedDepartments) {
      chips.add(_buildFilterChip(
        department,
        'department',
        department,
        AppTheme.lightTheme.colorScheme.primary,
      ));
    }

    // Category chips
    for (final category in selectedCategories) {
      chips.add(_buildFilterChip(
        category,
        'category',
        category,
        _getCategoryColor(category),
      ));
    }

    // Priority chips
    for (final priority in selectedPriorities) {
      chips.add(_buildFilterChip(
        priority.toUpperCase(),
        'priority',
        priority,
        _getPriorityColor(priority),
      ));
    }

    // Date range chip
    if (selectedDateRange != null) {
      chips.add(_buildFilterChip(
        'Date: ${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}',
        'date',
        '',
        Colors.purple,
      ));
    }

    if (chips.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters:',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Clear All',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.emergencyLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 0.5.h,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      String label, String type, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.5.w,
            height: 1.5.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => onRemoveFilter(type, value),
            child: Container(
              padding: EdgeInsets.all(0.5.w),
              child: CustomIconWidget(
                iconName: 'close',
                color: color,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return AppTheme.primaryLight;
      case 'events':
        return AppTheme.successLight;
      case 'administrative':
        return Colors.orange;
      case 'emergency':
        return AppTheme.emergencyLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return AppTheme.emergencyLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      case 'normal':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
