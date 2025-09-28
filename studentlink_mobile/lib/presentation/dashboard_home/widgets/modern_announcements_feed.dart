import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernAnnouncementsFeed extends StatelessWidget {
  final List<Map<String, dynamic>> announcements;

  const ModernAnnouncementsFeed({
    Key? key,
    required this.announcements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Latest Announcements',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              if (announcements.isNotEmpty)
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/announcements');
                  },
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (announcements.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: announcements.take(3).map((announcement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnnouncementItem(context, announcement),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Compact icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Compact text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No announcements',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Check back later for updates',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(BuildContext context, Map<String, dynamic> announcement) {
    final internalTitle = announcement['internal_title'] ?? 'Image Announcement #${announcement['id'] ?? ''}';
    final imageUrl = announcement['image_url'];
    final createdAt = announcement['created_at'] ?? '';
    final isImportant = announcement['is_important'] ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showAnnouncementDetails(context, announcement);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isImportant 
                ? AppTheme.primaryLight.withValues(alpha: 0.05)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isImportant 
                  ? AppTheme.primaryLight.withValues(alpha: 0.2)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Image preview or icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_rounded,
                              color: AppTheme.primaryLight,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image_rounded,
                        color: AppTheme.primaryLight,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Announcement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            internalTitle,
                            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isImportant)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyLight,
                              borderRadius: BorderRadius.circular(4),
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Image Announcement',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(createdAt),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetails(BuildContext context, Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        announcement['internal_title'] ?? 'Image Announcement #${announcement['id'] ?? ''}',
                        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Meta info
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(announcement['created_at'] ?? ''),
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const Spacer(),
                          if (announcement['is_important'] == true)
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
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Image
                      if (announcement['image_url'] != null && announcement['image_url'].isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final imageHeight = _calculateOptimalHeight(constraints.maxWidth);
                            return Container(
                              width: double.infinity,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF9FAFB),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  announcement['image_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFF9FAFB),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_rounded,
                                            color: const Color(0xFF9CA3AF),
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image not available',
                                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final imageHeight = _calculateOptimalHeight(constraints.maxWidth);
                            return Container(
                              width: double.infinity,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF9FAFB),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_rounded,
                                    color: const Color(0xFF9CA3AF),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No image available',
                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateOptimalHeight(double availableWidth) {
    // Calculate height based on available width to maintain good proportions
    // This creates a flexible aspect ratio that works well for most images
    final baseHeight = availableWidth * 0.6; // 5:3 aspect ratio as base
    final minHeight = 150.0;
    final maxHeight = 250.0;
    
    return baseHeight.clamp(minHeight, maxHeight);
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}