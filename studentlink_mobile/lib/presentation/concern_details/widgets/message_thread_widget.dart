import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageThreadWidget extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const MessageThreadWidget({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modern chat header
          _buildModernChatHeader(),
          
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isLastMessage = index == messages.length - 1;
                      return _buildModernMessageItem(message, isLastMessage);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChatHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chat icon with gradient
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryLight,
                  AppTheme.primaryLight.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 5.w,
            ),
          ),
          
          SizedBox(width: 3.w),
          
          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${messages.length} messages',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // More options button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Add more options functionality
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: const Color(0xFF6B7280),
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppTheme.primaryLight,
              size: 10.w,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            'No messages yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          
          SizedBox(height: 1.h),
          
          Text(
            'Start the conversation by sending a message',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernMessageItem(Map<String, dynamic> message, bool isLastMessage) {
    // Extract author information safely
    final author = message["author"] as Map<String, dynamic>?;
    final authorRole = author?["role"] ?? "student";
    final isStudent = authorRole == "student";
    
    // Extract message content and timestamp
    final messageContent = message["message"] ?? "";
    final timestamp = message["created_at"] ?? "";
    final isRead = message["read_at"] != null;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLastMessage ? 2.h : 1.h,
        left: isStudent ? 0 : 15.w,
        right: isStudent ? 15.w : 0,
      ),
      child: Row(
        mainAxisAlignment: isStudent ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isStudent) ...[
            // Avatar for student messages
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryLight,
                    AppTheme.primaryLight.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 4.w,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 75.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
              decoration: BoxDecoration(
                color: isStudent ? Colors.white : AppTheme.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(isStudent ? 4 : 18),
                  bottomRight: Radius.circular(isStudent ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    messageContent,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isStudent ? const Color(0xFF1A1A1A) : Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // Timestamp and read status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isStudent 
                              ? const Color(0xFF6B7280) 
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                      if (!isStudent && isRead) ...[
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.done_all_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 3.w,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (!isStudent) ...[
            SizedBox(width: 2.w),
            // Avatar for staff messages
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryLight,
                    AppTheme.secondaryLight.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 4.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return "";
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return "Just now";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays}d ago";
      } else {
        return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      }
    } catch (e) {
      return timestamp;
    }
  }
}
