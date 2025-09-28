import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernFilterChipsWidget extends StatelessWidget {
  final String statusFilter;
  final VoidCallback onClearAll;

  const ModernFilterChipsWidget({
    Key? key,
    required this.statusFilter,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter label
          Icon(
            Icons.filter_list_rounded,
            color: AppTheme.primaryLight,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtered by:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          
          // Active filter chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusLabel(statusFilter),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Clear all button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onClearAll();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_rounded,
                      color: const Color(0xFF6B7280),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'in_progress':
        return 'In Progress';
      case 'staff_resolved':
        return 'Staff Resolved';
      case 'student_confirmed':
        return 'Student Confirmed';
      case 'disputed':
        return 'Disputed';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      case 'all':
        return 'All';
      default:
        return status;
    }
  }
}
