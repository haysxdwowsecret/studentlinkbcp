import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernAnnouncementDetailModal extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const ModernAnnouncementDetailModal({
    Key? key,
    required this.announcement,
    required this.onBookmark,
    required this.onShare,
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
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(category),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (isImportant) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.emergencyLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'IMPORTANT',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(createdAt),
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onBookmark();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isBookmarked ? AppTheme.primaryLight : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: isBookmarked ? AppTheme.primaryLight : const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    label: Text(
                      isBookmarked ? 'Bookmarked' : 'Bookmark',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: isBookmarked ? AppTheme.primaryLight : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onShare();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Share',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
