import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import 'resolution_confirmation_widget.dart';
import 'enhanced_concern_chat_screen.dart';

class EnhancedConcernDetailsModal extends StatefulWidget {
  final Map<String, dynamic> concern;
  final VoidCallback? onResolutionUpdated;

  const EnhancedConcernDetailsModal({
    Key? key,
    required this.concern,
    this.onResolutionUpdated,
  }) : super(key: key);

  @override
  State<EnhancedConcernDetailsModal> createState() => _EnhancedConcernDetailsModalState();
}

class _EnhancedConcernDetailsModalState extends State<EnhancedConcernDetailsModal> {

  void _openChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedConcernChatScreen(
          concern: widget.concern,
          onResolutionUpdated: () {
            widget.onResolutionUpdated?.call();
            setState(() {}); // Refresh the modal
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final concern = widget.concern;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Enhanced handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Enhanced header with gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryLight.withValues(alpha: 0.05),
                  AppTheme.secondaryLight.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Concern Details',
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View detailed information about this concern',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Enhanced content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced status and priority section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status & Priority',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildEnhancedStatusChip(concern['status'] ?? 'pending'),
                            const SizedBox(width: 12),
                            _buildEnhancedPriorityChip(concern['priority'] ?? 'medium'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Enhanced title section
                  _buildDetailSection(
                    title: 'Title',
                    content: concern['title'] ?? 'Untitled Concern',
                    icon: Icons.title_rounded,
                    isTitle: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Enhanced description section
                  _buildDetailSection(
                    title: 'Description',
                    content: concern['description'] ?? 'No description provided',
                    icon: Icons.description_rounded,
                    isDescription: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Enhanced metadata section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Additional Information',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Created date
                        _buildMetadataRow(
                          icon: Icons.access_time_rounded,
                          label: 'Created',
                          value: _formatDate(concern['created_at'] ?? ''),
                        ),
                        
                        if (concern['reference_number'] != null) ...[
                          const SizedBox(height: 12),
                          _buildMetadataRow(
                            icon: Icons.tag_rounded,
                            label: 'Reference Number',
                            value: concern['reference_number'],
                            isMonospace: true,
                          ),
                        ],
                        
                        if (concern['replies_count'] != null && concern['replies_count'] > 0) ...[
                          const SizedBox(height: 12),
                          _buildMetadataRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Replies',
                            value: '${concern['replies_count']} ${concern['replies_count'] == 1 ? 'reply' : 'replies'}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Chat access button
                  if (widget.concern['status'] != 'pending' && widget.concern['status'] != 'cancelled') ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openChatScreen(),
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text('View Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Resolution confirmation widget (only show for staff_resolved status)
                  if (widget.concern['status'] == 'staff_resolved') ...[
                    const SizedBox(height: 24),
                    ResolutionConfirmationWidget(
                      concern: widget.concern,
                      onResolutionUpdated: () {
                        widget.onResolutionUpdated?.call();
                        setState(() {}); // Refresh the modal
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
    bool isTitle = false,
    bool isDescription = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: isTitle 
                ? AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  )
                : isDescription
                    ? AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4B5563),
                        height: 1.6,
                        fontSize: 15,
                      )
                    : AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF9CA3AF),
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
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
    if (dateString.isEmpty) return 'Unknown';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
