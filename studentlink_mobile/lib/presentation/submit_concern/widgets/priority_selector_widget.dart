import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrioritySelectorWidget extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onChanged;

  const PrioritySelectorWidget({
    Key? key,
    required this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> priorities = [
      {
        'name': 'Low',
        'color': Colors.green,
        'description': 'Non-urgent matter',
        'icon': 'low_priority'
      },
      {
        'name': 'Medium',
        'color': Colors.orange,
        'description': 'Moderate importance',
        'icon': 'remove'
      },
      {
        'name': 'High',
        'color': Colors.red,
        'description': 'Important matter',
        'icon': 'priority_high'
      },
      {
        'name': 'Urgent',
        'color': Color(0xFFE22824),
        'description': 'Requires immediate attention',
        'icon': 'warning'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: priorities.map((priority) {
            final isSelected = selectedPriority == priority['name'];
            return GestureDetector(
              onTap: () => onChanged(priority['name']),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected ? priority['color'] : Colors.transparent,
                  border: Border.all(
                    color: priority['color'],
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: priority['icon'],
                      color: isSelected ? Colors.white : priority['color'],
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          priority['name'],
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color:
                                isSelected ? Colors.white : priority['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          priority['description'],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : (priority['color'] as Color)
                                    .withValues(alpha: 0.7),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
