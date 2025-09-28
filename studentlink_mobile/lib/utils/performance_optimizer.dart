import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Performance optimization utilities for the StudentLink app
class PerformanceOptimizer {
  static Timer? _frameRateTimer;
  static int _frameCount = 0;
  static double _currentFPS = 0.0;
  
  /// Start monitoring frame rate for performance debugging
  static void startFrameRateMonitoring() {
    if (kDebugMode) {
      _frameRateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _currentFPS = _frameCount.toDouble();
        _frameCount = 0;
        
        // Log performance warnings
        if (_currentFPS < 30) {
          debugPrint('⚠️ Performance Warning: Low FPS detected: $_currentFPS');
        }
      });
      
      SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
        _frameCount++;
      });
    }
  }
  
  /// Stop frame rate monitoring
  static void stopFrameRateMonitoring() {
    _frameRateTimer?.cancel();
    _frameRateTimer = null;
  }

  /// Debounce function calls to prevent excessive rebuilds
  static Timer? debounce(
    Duration delay,
    VoidCallback callback, {
    Timer? existingTimer,
  }) {
    existingTimer?.cancel();
    return Timer(delay, callback);
  }
  
  /// Throttle function calls to limit execution frequency
  static Timer? throttle(
    Duration delay,
    VoidCallback callback, {
    Timer? existingTimer,
  }) {
    if (existingTimer?.isActive == true) return existingTimer;
    return Timer(delay, callback);
  }
  
  /// Optimize widget rebuilds by batching state updates
  static void batchStateUpdate(VoidCallback stateUpdate) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stateUpdate();
    });
  }
  
  /// Get current FPS for debugging
  static double get currentFPS => _currentFPS;
  
  /// Check if app is running smoothly
  static bool get isRunningSmoothly => _currentFPS >= 50;
}

/// Mixin for performance-optimized widgets
mixin PerformanceOptimizedMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  
  /// Debounced setState to prevent excessive rebuilds
  void debouncedSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (mounted) setState(fn);
    });
  }
  
  /// Throttled setState to limit rebuild frequency
  void throttledSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 100)}) {
    if (_throttleTimer?.isActive == true) return;
    _throttleTimer = Timer(delay, () {
      if (mounted) setState(fn);
    });
  }
  
  void disposeOptimized() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
  }
}

/// Performance-optimized text controller
class OptimizedTextController extends TextEditingController {
  Timer? _debounceTimer;
  final Duration _debounceDelay;
  final ValueChanged<String>? _onTextChanged;
  
  OptimizedTextController({
    String? text,
    Duration debounceDelay = const Duration(milliseconds: 300),
    ValueChanged<String>? onTextChanged,
  }) : _debounceDelay = debounceDelay,
       _onTextChanged = onTextChanged,
       super(text: text) {
    addListener(_handleTextChange);
  }
  
  void _handleTextChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _onTextChanged?.call(this.text);
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    removeListener(_handleTextChange);
    super.dispose();
  }
}