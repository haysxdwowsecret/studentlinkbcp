import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Widget for chat input with send functionality
class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSendMessage;
  final Function() onShowQuickSuggestions;
  final bool isEnabled;

  const ChatInputWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowQuickSuggestions,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onFocusChanged() {
    final isKeyboardVisible = widget.focusNode.hasFocus;
    if (_isKeyboardVisible != isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowBlue = _hasText && _isKeyboardVisible;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: shouldShowBlue 
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: shouldShowBlue ? 1.5 : 1,
        ),
        boxShadow: shouldShowBlue ? [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // + Button for quick suggestions
          GestureDetector(
            onTap: widget.isEnabled ? widget.onShowQuickSuggestions : null,
            child: Container(
              width: 10.w,
              height: 10.w,
              margin: EdgeInsets.only(left: 1.5.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          
          SizedBox(width: 1.5.w),
          
          // Text input field
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.isEnabled,
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) => _handleSend(),
              decoration: InputDecoration(
                hintText: 'Ask me anything about college...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 2.5.h,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          
          SizedBox(width: 1.w),
          
          // Send button
          GestureDetector(
            onTap: widget.isEnabled && _hasText ? () => _handleSend() : null,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 10.w,
              height: 10.w,
              margin: EdgeInsets.only(right: 1.5.w),
              decoration: BoxDecoration(
                color: shouldShowBlue
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: shouldShowBlue ? [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 4.5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(text);
    }
  }
}

