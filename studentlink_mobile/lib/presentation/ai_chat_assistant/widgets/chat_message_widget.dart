import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../ai_chat_assistant.dart';

/// Widget to display individual chat messages
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(ChatMessage)? onMessageLongPress;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    this.onMessageLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.3.h, horizontal: 3.w),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(),
            SizedBox(width: 1.5.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => onMessageLongPress?.call(message),
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 3.5.w,
                  vertical: 1.8.h,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: message.isUser
                          ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: message.isUser
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        height: 1.4,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: message.isUser
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                        if (message.isUser) ...[
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.done_all,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 3.5.w,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 2.w),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryLight,
            AppTheme.lightTheme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryLight.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 3.5.w,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 3.5.w,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
