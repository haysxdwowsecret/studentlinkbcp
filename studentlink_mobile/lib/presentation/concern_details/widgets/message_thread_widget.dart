import 'package:flutter/material.dart';
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'chat',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Conversation Thread',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${messages.length} messages',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 50.h),
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: messages.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isStudent = message["senderType"] == "student";

    return Row(
      mainAxisAlignment:
          isStudent ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isStudent) ...[
          CircleAvatar(
            radius: 4.w,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            child: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
          ),
          SizedBox(width: 2.w),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: 70.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isStudent
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isStudent ? 4 : 12),
                topRight: Radius.circular(isStudent ? 12 : 4),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message["senderName"] ?? "Unknown",
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isStudent
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (message["isRead"] == true)
                      CustomIconWidget(
                        iconName: 'done_all',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 3.w,
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  message["content"] ?? "",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  message["timestamp"] ?? "",
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isStudent) ...[
          SizedBox(width: 2.w),
          CircleAvatar(
            radius: 4.w,
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.1),
            child: CustomIconWidget(
              iconName: 'support_agent',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 4.w,
            ),
          ),
        ],
      ],
    );
  }
}
