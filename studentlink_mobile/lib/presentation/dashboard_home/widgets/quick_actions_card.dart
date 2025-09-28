import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onSubmitConcern;

  const QuickActionsCard({
    Key? key,
    required this.onSubmitConcern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ModernCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: theme.colorScheme.primary,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ModernButtonWidget(
            text: 'Submit New Concern',
            type: ModernButtonType.primary,
            size: ModernButtonSize.large,
            isFullWidth: true,
            icon: Icons.add_circle_outline,
            onPressed: onSubmitConcern,
          ),
        ],
      ),
    );
  }
}
