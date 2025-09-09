import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnnouncementCardWidget extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final String searchQuery;

  const AnnouncementCardWidget({
    Key? key,
    required this.announcement,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority = announcement['priority'] == 'high';
    final bool isBookmarked = announcement['isBookmarked'] ?? false;
    final DateTime publishedAt = announcement['publishedAt'] ?? DateTime.now();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isHighPriority
            ? Border.all(color: AppTheme.emergencyLight, width: 2)
            : Border.all(color: AppTheme.lightTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isHighPriority
                      ? AppTheme.emergencyLight.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row with Priority and Bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isHighPriority) ...[
                          Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomIconWidget(
                              iconName: 'priority_high',
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],

                        Expanded(
                          child: _buildHighlightedText(
                            announcement['title'] ?? '',
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isHighPriority
                                  ? AppTheme.emergencyLight
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                        ),

                        // Bookmark Button
                        GestureDetector(
                          onTap: onBookmark,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            child: CustomIconWidget(
                              iconName:
                                  isBookmarked ? 'bookmark' : 'bookmark_border',
                              color: isBookmarked
                                  ? AppTheme.warningLight
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Department and Date Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getDepartmentColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            announcement['department'] ?? '',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: _getDepartmentColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            announcement['category'] ?? '',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: _getCategoryColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          _formatDate(publishedAt),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Section
              Container(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Preview
                    _buildHighlightedText(
                      _getContentPreview(),
                      AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Footer with Author and Actions
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          announcement['author'] ?? 'Unknown',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Spacer(),

                        // Share Button
                        GestureDetector(
                          onTap: onShare,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            child: CustomIconWidget(
                              iconName: 'share',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),

                        // Read More Indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Read More',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              CustomIconWidget(
                                iconName: 'arrow_forward_ios',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, TextStyle? style) {
    if (searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: style?.copyWith(
          backgroundColor: AppTheme.warningLight.withValues(alpha: 0.3),
          fontWeight: FontWeight.w700,
        ),
      ));

      start = index + searchQuery.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }

  String _getContentPreview() {
    final String content = announcement['content'] ?? '';
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}...';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getDepartmentColor() {
    final String department = announcement['department']?.toLowerCase() ?? '';

    if (department.contains('academic')) return AppTheme.primaryLight;
    if (department.contains('mis') || department.contains('it'))
      return Colors.blue;
    if (department.contains('student')) return AppTheme.successLight;
    if (department.contains('library')) return Colors.purple;
    if (department.contains('admin')) return Colors.orange;
    if (department.contains('criminology')) return Colors.red;

    return AppTheme.lightTheme.colorScheme.primary;
  }

  Color _getCategoryColor() {
    final String category = announcement['category']?.toLowerCase() ?? '';

    switch (category) {
      case 'academic':
        return AppTheme.primaryLight;
      case 'events':
        return AppTheme.successLight;
      case 'administrative':
        return Colors.orange;
      case 'emergency':
        return AppTheme.emergencyLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
