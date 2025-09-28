import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> statusHistory;

  const StatusTimelineWidget({
    Key? key,
    required this.statusHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'timeline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Status Timeline',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: statusHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final status = entry.value;
                final isLast = index == statusHistory.length - 1;
                return _buildTimelineItem(status, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> status, bool isLast) {
    final statusName = status["status"] ?? "";
    final isCompleted = status["isCompleted"] ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? _getStatusColor(statusName)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? _getStatusColor(statusName)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 3.w,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 8.h,
                color: isCompleted
                    ? _getStatusColor(statusName).withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusName,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                if (status["timestamp"] != null)
                  Text(
                    status["timestamp"],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (status["handledBy"] != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Handled by ${status["handledBy"]}',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                if (status["note"] != null) ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      status["note"],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'in process':
        return const Color(0xFFFFC107);
      case 'resolved':
        return const Color(0xFF28A745);
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
