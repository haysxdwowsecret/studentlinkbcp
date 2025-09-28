import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_theme.dart';

class NewAnnouncementDetailModal extends StatefulWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const NewAnnouncementDetailModal({
    Key? key,
    required this.announcement,
    required this.onBookmark,
    required this.onShare,
  }) : super(key: key);

  @override
  State<NewAnnouncementDetailModal> createState() => _NewAnnouncementDetailModalState();
}

class _NewAnnouncementDetailModalState extends State<NewAnnouncementDetailModal> {
  @override
  Widget build(BuildContext context) {
    final category = widget.announcement['category'] ?? 'General';
    final title = widget.announcement['title'] ?? 'Announcement';
    final description = widget.announcement['description'] ?? '';
    final timestamp = widget.announcement['announcement_timestamp'] ?? 
                     widget.announcement['created_at'] ?? 
                     widget.announcement['published_at'] ?? '';
    final imageUrl = widget.announcement['image_url'] ?? widget.announcement['image_path'];
    final actionButtonText = widget.announcement['action_button_text'];
    final actionButtonUrl = widget.announcement['action_button_url'];
    final isBookmarked = widget.announcement['is_bookmarked'] ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
              color: AppTheme.textSecondaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onBookmark();
                      },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppTheme.warningLight : AppTheme.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onShare();
                      },
                      icon: Icon(
                        Icons.share_rounded,
                        color: AppTheme.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppTheme.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    _formatTimestamp(timestamp),
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Image
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = _calculateOptimalHeight(constraints.maxWidth);
                        return Container(
                          width: double.infinity,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain, // Changed from cover to contain to show full image
                              width: double.infinity,
                              height: imageHeight,
                              placeholder: (context, url) => _buildImagePlaceholder(imageHeight),
                              errorWidget: (context, url, error) => _buildImagePlaceholder(imageHeight),
                              memCacheWidth: 1200, // Increased for better quality
                              memCacheHeight: 1200,
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  if (description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Action button (if present)
                  if (actionButtonText != null && actionButtonUrl != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleActionButtonTap(actionButtonUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              actionButtonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Additional info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Announcement Details',
                          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Category', category),
                        _buildDetailRow('Published', _formatTimestamp(timestamp)),
                        if (widget.announcement['author'] != null)
                          _buildDetailRow('Author', widget.announcement['author']['name'] ?? 'Unknown'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOptimalHeight(double availableWidth) {
    // Calculate height based on available width to maintain good proportions
    // This creates a flexible aspect ratio that works well for most images
    final baseHeight = availableWidth * 0.6; // 5:3 aspect ratio as base
    final minHeight = 200.0;
    final maxHeight = 350.0;
    
    return baseHeight.clamp(minHeight, maxHeight);
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 48,
                color: AppTheme.primaryLight.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Image not available',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleActionButtonTap(String url) async {
    try {
      print('🔗 Attempting to open URL: $url');
      
      // Validate URL format
      if (url.isEmpty) {
        _showErrorSnackBar('No URL provided');
        return;
      }
      
      // Ensure URL has proper scheme
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }
      
      final uri = Uri.parse(formattedUrl);
      print('🔗 Parsed URI: $uri');
      
      if (await canLaunchUrl(uri)) {
        print('✅ URL can be launched, opening...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        HapticFeedback.lightImpact();
      } else {
        print('❌ URL cannot be launched');
        _showErrorSnackBar('Could not open the link. Please check if the URL is valid.');
      }
    } catch (e) {
      print('❌ Error opening link: $e');
      _showErrorSnackBar('Error opening link: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: AppTheme.emergencyLight,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}




