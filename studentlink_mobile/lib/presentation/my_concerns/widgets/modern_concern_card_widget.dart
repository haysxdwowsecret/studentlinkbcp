import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernConcernCardWidget extends StatelessWidget {
  final Map<String, dynamic> concern;
  final VoidCallback onViewDetails;
  final VoidCallback onAddReply;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  const ModernConcernCardWidget({
    Key? key,
    required this.concern,
    required this.onViewDetails,
    required this.onAddReply,
    required this.onDelete,
    required this.onLongPress,
  }) : super(key: key);

  bool get _isApproved => concern['status'] == 'approved';

  @override
  Widget build(BuildContext context) {
    final status = concern['status'] ?? 'pending';
    final priority = concern['priority'] ?? 'medium';
    final title = concern['title'] ?? 'Untitled Concern';
    final description = concern['description'] ?? '';
    final createdAt = concern['created_at'] ?? '';
    final replyCount = concern['replies_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and priority
                Row(
                  children: [
                    _buildEnhancedStatusChip(status),
                    const SizedBox(width: 12),
                    _buildEnhancedPriorityChip(priority),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(createdAt),
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Title with enhanced typography
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Description with better spacing
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                      fontSize: 15,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Enhanced footer with actions
                Row(
                  children: [
                    // Reply count with better styling
                    if (replyCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppTheme.primaryLight,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    const Spacer(),
                    
                    // Enhanced action buttons
                    if (_isApproved) ...[
                      _buildEnhancedActionButton(
                        icon: Icons.reply_rounded,
                        label: 'Reply',
                        onTap: onAddReply,
                        color: AppTheme.primaryLight,
                        isPrimary: true,
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      _buildEnhancedActionButton(
                        icon: Icons.visibility_rounded,
                        label: 'View',
                        onTap: onViewDetails,
                        color: AppTheme.primaryLight,
                        isPrimary: true,
                      ),
                      const SizedBox(width: 12),
                    ],
                    _buildEnhancedActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      onTap: onDelete,
                      color: AppTheme.emergencyLight,
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusChip(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);
    final icon = _getStatusIcon(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPriorityChip(String priority) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority);
    final icon = _getPriorityIcon(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.primaryLight;
      case 'approved':
        return AppTheme.successLight;
      case 'in_progress':
        return AppTheme.warningLight;
      case 'staff_resolved':
        return const Color(0xFF3B82F6); // Blue for staff resolved
      case 'student_confirmed':
        return AppTheme.successLight;
      case 'disputed':
        return AppTheme.emergencyLight;
      case 'closed':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF9CA3AF);
    }
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
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.verified_rounded;
      case 'in_progress':
        return Icons.hourglass_empty_rounded;
      case 'staff_resolved':
        return Icons.engineering_rounded;
      case 'student_confirmed':
        return Icons.check_circle_rounded;
      case 'disputed':
        return Icons.report_problem_rounded;
      case 'closed':
        return Icons.lock_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.emergencyLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'Normal';
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'low':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
