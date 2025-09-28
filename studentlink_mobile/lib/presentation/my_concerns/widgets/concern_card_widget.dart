import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConcernCardWidget extends StatelessWidget {
  final Map<String, dynamic> concern;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAddReply;
  final VoidCallback? onArchive;
  final VoidCallback? onLongPress;

  const ConcernCardWidget({
    Key? key,
    required this.concern,
    this.onViewDetails,
    this.onAddReply,
    this.onArchive,
    this.onLongPress,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'resolved':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'closed':
        return Colors.grey;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getDepartmentName(Map<String, dynamic> concern) {
    // Try to get department name from assigned_to object
    if (concern['assigned_to'] != null && concern['assigned_to'] is Map) {
      final assignedTo = concern['assigned_to'] as Map<String, dynamic>;
      if (assignedTo['name'] != null) {
        return assignedTo['name'] as String;
      }
    }
    
    // Try to get department name from department object
    if (concern['department'] != null) {
      if (concern['department'] is String) {
        return concern['department'] as String;
      } else if (concern['department'] is Map) {
        final dept = concern['department'] as Map<String, dynamic>;
        return dept['name'] ?? dept['code'] ?? 'Unknown Department';
      }
    }
    
    return 'Unknown Department';
  }

  DateTime _getSubmissionDate(Map<String, dynamic> concern) {
    try {
      if (concern['created_at'] != null) {
        return DateTime.parse(concern['created_at'] as String);
      }
      if (concern['submissionDate'] != null) {
        if (concern['submissionDate'] is DateTime) {
          return concern['submissionDate'] as DateTime;
        } else if (concern['submissionDate'] is String) {
          return DateTime.parse(concern['submissionDate'] as String);
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final String title = concern['subject'] ?? concern['title'] ?? 'No Title';
    final String department = _getDepartmentName(concern);
    final String status = concern['status'] ?? 'Unknown';
    final DateTime submissionDate = _getSubmissionDate(concern);
    final String latestReply = concern['latestReply'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(concern['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onViewDetails?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.visibility,
              label: 'View Details',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => onAddReply?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.reply,
              label: 'Add Reply',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: status.toLowerCase() == 'resolved'
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => onArchive?.call(),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Archive',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              )
            : null,
        child: GestureDetector(
          onLongPress: onLongPress,
          onLongPressStart: (details) {
            // Provide haptic feedback for better UX
            HapticFeedback.mediumImpact();
          },
          onLongPressCancel: () {
            // Reset any visual feedback if long press is cancelled
          },
          behavior: HitTestBehavior.opaque,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          department,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${submissionDate.day}/${submissionDate.month}/${submissionDate.year}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (latestReply.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'chat_bubble_outline',
                            size: 16,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              latestReply,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Show rejection reason if concern is rejected
                  if (status.toLowerCase() == 'rejected' && concern['rejection_reason'] != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rejection Reason:',
                                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  concern['rejection_reason'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
