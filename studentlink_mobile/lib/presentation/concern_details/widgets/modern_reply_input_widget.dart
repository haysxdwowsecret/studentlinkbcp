import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModernReplyInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onAttachFile;
  final VoidCallback onAIAssist;
  final Function(bool)? onTypingChanged;

  const ModernReplyInputWidget({
    Key? key,
    required this.onSendMessage,
    required this.onAttachFile,
    required this.onAIAssist,
    this.onTypingChanged,
  }) : super(key: key);

  @override
  State<ModernReplyInputWidget> createState() => _ModernReplyInputWidgetState();
}

class _ModernReplyInputWidgetState extends State<ModernReplyInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🚀 PERFORMANCE: Debounced setState to reduce rebuilds
  void _onTextChanged() {
    final isTyping = _messageController.text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() => _isTyping = isTyping);
          // Notify parent about typing status
          widget.onTypingChanged?.call(isTyping);
        }
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern input row
                Row(
                  children: [
                    // Attachment button
                    _buildActionButton(
                      icon: Icons.attach_file_rounded,
                      onTap: widget.onAttachFile,
                      color: const Color(0xFF6B7280),
                    ),
                    
                    SizedBox(width: 2.w),
                    
                    // AI Assist button
                    _buildActionButton(
                      icon: Icons.auto_awesome_rounded,
                      onTap: widget.onAIAssist,
                      color: AppTheme.secondaryLight,
                    ),
                    
                    SizedBox(width: 2.w),
                    
                    // Message input
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _isTyping 
                                ? AppTheme.primaryLight 
                                : const Color(0xFFE5E7EB),
                            width: _isTyping ? 2 : 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 3.h,
                            ),
                          ),
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 2.w),
                    
                    // Send button
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          gradient: _isTyping
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.primaryLight,
                                    AppTheme.primaryLight.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _isTyping ? null : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _isTyping ? [
                            BoxShadow(
                              color: AppTheme.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: _isTyping ? Colors.white : const Color(0xFF9CA3AF),
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Translation hint
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        color: AppTheme.primaryLight,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Translation available: EN → FIL',
                        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: color,
          size: 4.w,
        ),
      ),
    );
  }
}
