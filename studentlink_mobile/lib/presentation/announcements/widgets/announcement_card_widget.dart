import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../core/app_export.dart';

class AnnouncementCardWidget extends StatefulWidget {
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
  State<AnnouncementCardWidget> createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
    });

    try {
      final imageUrl = widget.announcement['image_url'];
      if (imageUrl == null) {
        _showSnackBar('No image available for download', isError: true);
        return;
      }

      // Get the downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'announcement_${widget.announcement['id']}.jpg';
      final filePath = '${directory.path}/$fileName';

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        _showSnackBar('Image saved to Downloads');
        
        // Provide haptic feedback
        HapticFeedback.lightImpact();
      } else {
        _showSnackBar('Failed to download image', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error downloading image: $e', isError: true);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority = widget.announcement['priority'] == 'high';
    final bool isBookmarked = widget.announcement['isBookmarked'] ?? false;
    final DateTime publishedAt = widget.announcement['publishedAt'] ?? DateTime.now();
    final bool isImageAnnouncement = widget.announcement['announcement_type'] == 'image';

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
          onTap: widget.onTap,
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
                            widget.announcement['title'] ?? '',
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
                          onTap: widget.onBookmark,
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
                            widget.announcement['department'] ?? '',
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
                            widget.announcement['category'] ?? '',
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
                    // Content Preview or Image
                    if (isImageAnnouncement) ...[
                      _buildImageContent(),
                    ] else ...[
                      _buildHighlightedText(
                        _getContentPreview(),
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],

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
                          widget.announcement['department'] ?? 'General',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Spacer(),

                        // Share Button
                        GestureDetector(
                          onTap: widget.onShare,
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
    if (widget.searchQuery.isEmpty) {
      return Text(text, style: style);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = widget.searchQuery.toLowerCase();
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
        text: text.substring(index, index + widget.searchQuery.length),
        style: style?.copyWith(
          backgroundColor: AppTheme.warningLight.withValues(alpha: 0.3),
          fontWeight: FontWeight.w700,
        ),
      ));

      start = index + widget.searchQuery.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }

  String _getContentPreview() {
    final String content = widget.announcement['content'] ?? '';
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
    final String department = widget.announcement['department']?.toLowerCase() ?? '';

    if (department.contains('academic')) return AppTheme.primaryLight;
    if (department.contains('mis') || department.contains('it')) {
      return Colors.blue;
    }
    if (department.contains('student')) return AppTheme.successLight;
    if (department.contains('library')) return Colors.purple;
    if (department.contains('admin')) return Colors.orange;
    if (department.contains('criminology')) return Colors.red;

    return AppTheme.lightTheme.colorScheme.primary;
  }

  Color _getCategoryColor() {
    final String category = widget.announcement['category']?.toLowerCase() ?? '';

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

  Widget _buildImageContent() {
    final String? imageUrl = widget.announcement['image_url'];
    
    if (imageUrl == null) {
      return Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'image_not_supported',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 32,
              ),
              SizedBox(height: 1.h),
              Text(
                'Image not available',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: _downloadImage,
      child: Container(
        height: 25.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 25.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 32,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Failed to load image',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Download indicator
            if (_isDownloading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // Long press hint
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'download',
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Long press to download',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
