import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Set<String> selectedDepartments;
  final Set<String> selectedCategories;
  final Set<String> selectedPriorities;
  final DateTimeRange? selectedDateRange;
  final Function(Set<String>, Set<String>, Set<String>, DateTimeRange?)
      onApplyFilters;

  const FilterBottomSheetWidget({
    Key? key,
    required this.selectedDepartments,
    required this.selectedCategories,
    required this.selectedPriorities,
    required this.selectedDateRange,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Set<String> _departments;
  late Set<String> _categories;
  late Set<String> _priorities;
  late DateTimeRange? _dateRange;

  final List<String> _availableDepartments = [
    'Academic Affairs',
    'MIS',
    'Student Affairs',
    'Library',
    'Administration',
    'Criminology Department',
  ];

  final List<String> _availableCategories = [
    'Academic',
    'Events',
    'Administrative',
    'Emergency',
  ];

  final List<String> _availablePriorities = [
    'high',
    'medium',
    'low',
    'normal',
  ];

  @override
  void initState() {
    super.initState();
    _departments = Set.from(widget.selectedDepartments);
    _categories = Set.from(widget.selectedCategories);
    _priorities = Set.from(widget.selectedPriorities);
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Filter Announcements',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppTheme.emergencyLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Date Range Filter
                  _buildFilterSection(
                    'Date Range',
                    'date_range',
                    _buildDateRangeSelector(),
                  ),

                  SizedBox(height: 3.h),

                  // Department Filter
                  _buildFilterSection(
                    'Department',
                    'business',
                    _buildChipSelector(_availableDepartments, _departments),
                  ),

                  SizedBox(height: 3.h),

                  // Category Filter
                  _buildFilterSection(
                    'Category',
                    'category',
                    _buildChipSelector(_availableCategories, _categories),
                  ),

                  SizedBox(height: 3.h),

                  // Priority Filter
                  _buildFilterSection(
                    'Priority',
                    'flag',
                    _buildPrioritySelector(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, String iconName, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              _dateRange == null
                  ? 'Select date range'
                  : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: _dateRange == null
                    ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Spacer(),
            if (_dateRange != null) ...[
              GestureDetector(
                onTap: () => setState(() => _dateRange = null),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelector(List<String> options, Set<String> selected) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool value) {
            setState(() {
              if (value) {
                selected.add(option);
              } else {
                selected.remove(option);
              }
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
          labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.dividerColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _availablePriorities.map((priority) {
        final isSelected = _priorities.contains(priority);
        final Color priorityColor = _getPriorityColor(priority);

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.w),
              Text(priority.toUpperCase()),
            ],
          ),
          selected: isSelected,
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _priorities.add(priority);
              } else {
                _priorities.remove(priority);
              }
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor: priorityColor.withValues(alpha: 0.1),
          checkmarkColor: priorityColor,
          labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? priorityColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color:
                isSelected ? priorityColor : AppTheme.lightTheme.dividerColor,
          ),
        );
      }).toList(),
    );
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

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _departments.clear();
      _categories.clear();
      _priorities.clear();
      _dateRange = null;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_departments, _categories, _priorities, _dateRange);
    Navigator.pop(context);
  }
}
