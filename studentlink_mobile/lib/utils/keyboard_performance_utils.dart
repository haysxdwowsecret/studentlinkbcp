import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🚀 PERFORMANCE: Utility class for keyboard performance optimizations
class KeyboardPerformanceUtils {
  static Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 50);
  
  /// Debounced setState to prevent excessive rebuilds
  static void debouncedSetState(VoidCallback setStateCallback, {Duration? delay}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay ?? _debounceDelay, setStateCallback);
  }
  
  /// Optimized keyboard handling configuration
  static void configureKeyboardOptimizations() {
    // Disable haptic feedback during typing to reduce system load
    SystemChannels.platform.invokeMethod('HapticFeedback.disable');
  }
  
  /// Restore default keyboard behavior
  static void restoreKeyboardBehavior() {
    SystemChannels.platform.invokeMethod('HapticFeedback.enable');
  }
  
  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  /// Optimized scroll to bottom with keyboard awareness
  static void scrollToBottomOptimized(ScrollController controller, {Duration? duration}) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: duration ?? Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

/// 🚀 PERFORMANCE: Mixin for keyboard-aware widgets
mixin KeyboardAwareMixin<T extends StatefulWidget> on State<T> {
  Timer? _keyboardTimer;
  bool _isKeyboardVisible = false;
  
  @override
  void initState() {
    super.initState();
    _setupKeyboardListener();
  }
  
  @override
  void dispose() {
    _keyboardTimer?.cancel();
    super.dispose();
  }
  
  void _setupKeyboardListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardState();
    });
  }
  
  void _checkKeyboardState() {
    if (mounted) {
      final isVisible = KeyboardPerformanceUtils.isKeyboardVisible(context);
      if (_isKeyboardVisible != isVisible) {
        _isKeyboardVisible = isVisible;
        onKeyboardVisibilityChanged(_isKeyboardVisible);
      }
    }
  }
  
  /// Override this method to handle keyboard visibility changes
  void onKeyboardVisibilityChanged(bool isVisible) {}
  
  /// Get current keyboard state
  bool get isKeyboardVisible => _isKeyboardVisible;
}

/// 🚀 PERFORMANCE: Optimized text input controller
class OptimizedTextController extends TextEditingController {
  Timer? _debounceTimer;
  final Duration _debounceDelay = Duration(milliseconds: 50);
  final List<VoidCallback> _listeners = [];
  
  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }
  
  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    super.removeListener(listener);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  /// Debounced text change notification
  void notifyListenersDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}

/// 🚀 PERFORMANCE: Optimized focus node
class OptimizedFocusNode extends FocusNode {
  Timer? _debounceTimer;
  final Duration _debounceDelay = Duration(milliseconds: 100);
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  /// Debounced focus change notification
  void notifyListenersDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}

/// 🚀 PERFORMANCE: Performance monitoring utilities
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};
  
  /// Start timing a performance operation
  static void startTiming(String operation) {
    _startTimes[operation] = DateTime.now();
  }
  
  /// End timing and record the measurement
  static Duration endTiming(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _measurements.putIfAbsent(operation, () => []).add(duration);
      return duration;
    }
    return Duration.zero;
  }
  
  /// Get average time for an operation
  static Duration getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }
    
    final totalMicroseconds = measurements
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }
  
  /// Clear all measurements
  static void clearMeasurements() {
    _startTimes.clear();
    _measurements.clear();
  }
  
  /// Print performance report
  static void printReport() {
    print('🚀 PERFORMANCE REPORT:');
    _measurements.forEach((operation, measurements) {
      final average = getAverageTime(operation);
      print('$operation: ${average.inMilliseconds}ms (${measurements.length} samples)');
    });
  }
}
