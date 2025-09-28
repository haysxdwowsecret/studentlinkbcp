import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive_design.dart';
import '../../../widgets/responsive_widgets.dart';

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
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🚀 PERFORMANCE: Debounced setState to reduce rebuilds
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _hasText = hasText;
          });
        }
      });
    }
  }

  // 🚀 PERFORMANCE: Debounced focus change to reduce rebuilds
  void _onFocusChanged() {
    final isKeyboardVisible = widget.focusNode.hasFocus;
    if (_isKeyboardVisible != isKeyboardVisible) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isKeyboardVisible = isKeyboardVisible;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowBlue = _hasText && _isKeyboardVisible;
    
    return RepaintBoundary(
      child: Container(
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
                width: ResponsiveDesign.getIconSize(40),
                height: ResponsiveDesign.getIconSize(40),
                margin: ResponsiveDesign.getMargin(left: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
                ),
                child: Icon(
                  Icons.add,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: ResponsiveDesign.getIconSize(20),
                ),
              ),
            ),
            
            ResponsiveSpacing(height: 0, width: 12),
            
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
                  hintStyle: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                    fontSize: ResponsiveDesign.getFontSize(14),
                  ),
                  border: InputBorder.none,
                  contentPadding: ResponsiveDesign.getPadding(horizontal: 12, vertical: 12),
                ),
                style: TextStyle(
                  fontSize: ResponsiveDesign.getFontSize(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            ResponsiveSpacing(height: 0, width: 8),
            
            // Send button
            GestureDetector(
              onTap: widget.isEnabled && _hasText ? () => _handleSend() : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: ResponsiveDesign.getIconSize(40),
                height: ResponsiveDesign.getIconSize(40),
                margin: ResponsiveDesign.getMargin(right: 12),
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
                  size: ResponsiveDesign.getIconSize(18),
                ),
              ),
            ),
          ],
        ),
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