import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// 🚀 PERFORMANCE: Optimized keyboard-aware widget that handles keyboard animations smoothly
/// without causing FPS drops or excessive rebuilds
class KeyboardAwareWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableKeyboardPadding;

  const KeyboardAwareWidget({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.enableKeyboardPadding = true,
  }) : super(key: key);

  @override
  State<KeyboardAwareWidget> createState() => _KeyboardAwareWidgetState();
}

class _KeyboardAwareWidgetState extends State<KeyboardAwareWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _keyboardAnimation;
  double _keyboardHeight = 0;
  bool _isKeyboardVisible = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _keyboardAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    // Start listening to keyboard changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListener();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Setup keyboard listener to detect keyboard changes
  void _setupKeyboardListener() {
    // Check keyboard state periodically
    _debounceTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _checkKeyboardState();
      } else {
        timer.cancel();
      }
    });
  }

  /// Check current keyboard state
  void _checkKeyboardState() {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    _updateKeyboardState(keyboardHeight, isKeyboardVisible);
  }

  /// Update keyboard state and trigger animations
  void _updateKeyboardState(double keyboardHeight, bool isKeyboardVisible) {
    if (_keyboardHeight != keyboardHeight || _isKeyboardVisible != isKeyboardVisible) {
      setState(() {
        _keyboardHeight = keyboardHeight;
        _isKeyboardVisible = isKeyboardVisible;
      });

      // Update animation
      _keyboardAnimation = Tween<double>(
        begin: _keyboardAnimation.value,
        end: widget.enableKeyboardPadding ? keyboardHeight : 0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));

      if (isKeyboardVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.zero, // Prevent default keyboard handling
      ),
      child: AnimatedBuilder(
        animation: _keyboardAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_keyboardAnimation.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 🚀 PERFORMANCE: Optimized scroll controller that handles keyboard-aware scrolling
class KeyboardAwareScrollController extends ScrollController {
  final BuildContext context;
  Timer? _scrollTimer;

  KeyboardAwareScrollController({required this.context});

  /// Smoothly scroll to bottom when keyboard appears
  void scrollToBottomOnKeyboard() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(Duration(milliseconds: 300), () {
      if (hasClients && context.mounted) {
        animateTo(
          position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }
}

/// 🚀 PERFORMANCE: Optimized text input wrapper that reduces rebuilds
class OptimizedTextInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLines;
  final int minLines;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const OptimizedTextInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.maxLines = 1,
    this.minLines = 1,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<OptimizedTextInput> createState() => _OptimizedTextInputState();
}

class _OptimizedTextInputState extends State<OptimizedTextInput> {
  Timer? _debounceTimer;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    final hasFocus = widget.focusNode.hasFocus;
    if (_hasFocus != hasFocus) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 100), () {
        if (context.mounted) {
          setState(() {
            _hasFocus = hasFocus;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasFocus
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: _hasFocus ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
          ),
        ),
      ),
    );
  }
}
