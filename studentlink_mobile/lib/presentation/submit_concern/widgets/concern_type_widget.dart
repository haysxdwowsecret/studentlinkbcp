import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConcernTypeWidget extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onChanged;
  final String? errorText;

  const ConcernTypeWidget({
    Key? key,
    required this.selectedType,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> concernTypes = [
      {'name': 'Academic Issue', 'icon': 'school', 'color': Colors.blue},
      {
        'name': 'Financial Concern',
        'icon': 'account_balance_wallet',
        'color': Colors.green
      },
      {'name': 'Facility Problem', 'icon': 'build', 'color': Colors.orange},
      {
        'name': 'Student Services',
        'icon': 'support_agent',
        'color': Colors.purple
      },
      {'name': 'Technical Support', 'icon': 'computer', 'color': Colors.teal},
      {'name': 'Disciplinary Matter', 'icon': 'gavel', 'color': Colors.red},
      {'name': 'Other', 'icon': 'help_outline', 'color': Colors.grey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Concern Type *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              ...concernTypes.map((type) {
                final isSelected = selectedType == type['name'];
                return InkWell(
                  onTap: () => onChanged(type['name']),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? type['color']
                                : (type['color'] as Color)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: CustomIconWidget(
                            iconName: type['icon'],
                            color: isSelected ? Colors.white : type['color'],
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            type['name'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 1.h, left: 3.w),
            child: Text(
              errorText!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
