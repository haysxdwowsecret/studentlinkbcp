import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_theme.dart';

class NewAnnouncementCardWidget extends StatefulWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const NewAnnouncementCardWidget({
    Key? key,
    required this.announcement,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
  }) : super(key: key);

  @override
  State<NewAnnouncementCardWidget> createState() => _NewAnnouncementCardWidgetState();
}

class _NewAnnouncementCardWidgetState extends State<NewAnnouncementCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.announcement['category'] ?? 'General';
    final title = widget.announcement['title'] ?? 'Announcement';
    final timestamp = widget.announcement['announcement_timestamp'] ?? 
                     widget.announcement['created_at'] ?? 
                     widget.announcement['published_at'] ?? '';
    final imageUrl = widget.announcement['image_url'] ?? widget.announcement['image_path'];
    final actionButtonText = widget.announcement['action_button_text'];
    final actionButtonUrl = widget.announcement['action_button_url'];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag and timestamp row
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                        // Timestamp
                        Text(
                          _formatTimestamp(timestamp),
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Image placeholder
                  GestureDetector(
                    onTap: widget.onTap,
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = _calculateOptimalHeight(constraints.maxWidth - 32); // Account for margins
                        return Container(
                          height: imageHeight,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryLight.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: imageHeight,
                                    placeholder: (context, url) => _buildImagePlaceholder(imageHeight),
                                    errorWidget: (context, url, error) => _buildImagePlaceholder(imageHeight),
                                    memCacheWidth: 800,
                                    memCacheHeight: 600,
                                  ),
                                )
                              : _buildImagePlaceholder(imageHeight),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action button (if present)
                  if (actionButtonText != null && actionButtonUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleActionButtonTap(actionButtonUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryLight,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                                Icons.bookmark_border_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateOptimalHeight(double availableWidth) {
    // Calculate height based on available width to maintain good proportions
    // This creates a flexible aspect ratio that works well for most images
    final baseHeight = availableWidth * 0.6; // 5:3 aspect ratio as base
    final minHeight = 150.0;
    final maxHeight = 300.0;
    
    return baseHeight.clamp(minHeight, maxHeight);
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
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
