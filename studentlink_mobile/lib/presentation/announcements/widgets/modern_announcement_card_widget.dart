import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernAnnouncementCardWidget extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final String searchQuery;

  const ModernAnnouncementCardWidget({
    Key? key,
    required this.announcement,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = announcement['title'] ?? 'Untitled Announcement';
    final content = announcement['content'] ?? '';
    final createdAt = announcement['created_at'] ?? '';
    final isImportant = announcement['is_important'] ?? false;
    final isBookmarked = announcement['isBookmarked'] ?? false;
    final category = announcement['category'] ?? 'General';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isImportant 
                  ? AppTheme.emergencyLight.withValues(alpha: 0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isImportant
                    ? AppTheme.emergencyLight.withValues(alpha: 0.15)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced header with category and actions
                Row(
                  children: [
                    _buildEnhancedCategoryChip(category),
                    const Spacer(),
                    if (isImportant) _buildImportantBadge(),
                    const SizedBox(width: 8),
                    _buildActionButtons(isBookmarked),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Enhanced title
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Enhanced content preview
                if (content.isNotEmpty) ...[
                  Text(
                    content,
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
                
                // Enhanced footer with date and read more
                Row(
                  children: [
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Read More',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryLight,
                            size: 14,
                          ),
                        ],
                      ),
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

  Widget _buildEnhancedCategoryChip(String category) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    
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
            category,
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

  Widget _buildImportantBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.emergencyLight, AppTheme.emergencyLight.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emergencyLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'IMPORTANT',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isBookmarked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bookmark button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onBookmark();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBookmarked 
                    ? AppTheme.warningLight.withValues(alpha: 0.1)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isBookmarked 
                      ? AppTheme.warningLight.withValues(alpha: 0.3)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isBookmarked ? AppTheme.warningLight : const Color(0xFF9CA3AF),
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Share button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onShare();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.share_rounded,
                color: const Color(0xFF9CA3AF),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return AppTheme.primaryLight;
      case 'events':
        return AppTheme.secondaryLight;
      case 'administrative':
        return AppTheme.warningLight;
      case 'emergency':
        return AppTheme.emergencyLight;
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Icons.school_rounded;
      case 'events':
        return Icons.event_rounded;
      case 'administrative':
        return Icons.admin_panel_settings_rounded;
      case 'emergency':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}