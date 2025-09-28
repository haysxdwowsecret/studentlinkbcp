import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernQuickActionsCard extends StatelessWidget {
  final VoidCallback onSubmitConcern;

  const ModernQuickActionsCard({
    Key? key,
    required this.onSubmitConcern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AppTheme.primaryLight,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons grid
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_rounded,
                  title: 'Submit Concern',
                  subtitle: 'Report an issue',
                  color: AppTheme.primaryLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSubmitConcern();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_rounded,
                  title: 'AI Assistant',
                  subtitle: 'Get help instantly',
                  color: AppTheme.secondaryLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/ai-chat-assistant');
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.assignment_rounded,
                  title: 'My Concerns',
                  subtitle: 'View all issues',
                  color: AppTheme.successLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/my-concerns');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.campaign_rounded,
                  title: 'Announcements',
                  subtitle: 'Latest updates',
                  color: AppTheme.warningLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/announcements');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
