import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Modern chat input widget with sleek, minimalistic design
class ModernChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSendMessage;
  final Function() onShowQuickSuggestions;
  final bool isEnabled;

  const ModernChatInputWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowQuickSuggestions,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<ModernChatInputWidget> createState() => _ModernChatInputWidgetState();
}

class _ModernChatInputWidgetState extends State<ModernChatInputWidget> {
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

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _hasText = hasText;
          });
        }
      });
    }
  }

  void _onFocusChanged() {
    final isKeyboardVisible = widget.focusNode.hasFocus;
    if (_isKeyboardVisible != isKeyboardVisible) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
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
    final bool shouldShowActive = _hasText && _isKeyboardVisible;
    
    return RepaintBoundary(
      child: Container(
        // 🚀 KEYBOARD FIX: Add bottom padding when keyboard is visible
        padding: EdgeInsets.only(
          bottom: _isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom : 0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: shouldShowActive 
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
            width: shouldShowActive ? 2 : 1,
          ),
          boxShadow: shouldShowActive ? [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Attachment button
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: IconButton(
                onPressed: widget.isEnabled ? widget.onShowQuickSuggestions : null,
                icon: Icon(
                  Icons.add_rounded,
                  color: shouldShowActive 
                      ? AppTheme.lightTheme.colorScheme.primary
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: shouldShowActive 
                      ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
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
                decoration: const InputDecoration(
                  hintText: 'Ask me anything about college...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: shouldShowActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                  boxShadow: shouldShowActive ? [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.isEnabled && _hasText ? () => _handleSend() : null,
                    child: Icon(
                      Icons.send_rounded,
                      color: shouldShowActive ? Colors.white : const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                  ),
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
