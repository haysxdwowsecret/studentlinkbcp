/// Performance configuration for the StudentLink app
class PerformanceConfig {
  /// Enable performance monitoring (set to false for production)
  static const bool enablePerformanceMonitoring = false;
  
  /// Enable performance overlay (set to false for production)
  static const bool enablePerformanceOverlay = false;
  
  /// Enable memory monitoring (set to false for production)
  static const bool enableMemoryMonitoring = false;
  
  /// Target frame rate for the app
  static const double targetFPS = 60.0;
  
  /// Minimum acceptable frame rate
  static const double minimumFPS = 55.0;
  
  /// Maximum image cache size (in bytes)
  static const int maxImageCacheSize = 100 * 1024 * 1024; // 100MB
  
  /// Maximum number of images to keep in cache
  static const int maxImageCacheCount = 1000;
  
  /// Debounce delay for user input (in milliseconds)
  static const int debounceDelayMs = 300;
  
  /// Animation duration for smooth transitions (in milliseconds)
  static const int animationDurationMs = 300;
  
  /// Enable RepaintBoundary optimization
  static const bool enableRepaintBoundary = true;
  
  /// Enable const constructor optimization
  static const bool enableConstConstructors = true;
  
  /// Enable scroll physics optimization
  static const bool enableScrollPhysicsOptimization = true;
  
  /// Enable text rendering optimization
  static const bool enableTextRenderingOptimization = true;
  
  /// Enable image loading optimization
  static const bool enableImageLoadingOptimization = true;
  
  /// Enable list rendering optimization
  static const bool enableListRenderingOptimization = true;
  
  /// Performance monitoring settings
  static const PerformanceMonitoringSettings monitoring = PerformanceMonitoringSettings();
}

/// Performance monitoring configuration
class PerformanceMonitoringSettings {
  const PerformanceMonitoringSettings();
  
  /// Enable FPS monitoring
  bool get enableFPSMonitoring => PerformanceConfig.enablePerformanceMonitoring;
  
  /// Enable memory monitoring
  bool get enableMemoryMonitoring => PerformanceConfig.enableMemoryMonitoring;
  
  /// Enable frame time monitoring
  bool get enableFrameTimeMonitoring => PerformanceConfig.enablePerformanceMonitoring;
  
  /// Enable widget rebuild monitoring
  bool get enableRebuildMonitoring => PerformanceConfig.enablePerformanceMonitoring;
  
  /// Sample rate for monitoring (1.0 = every frame, 0.1 = every 10th frame)
  double get sampleRate => 0.1;
  
  /// Maximum number of samples to keep in memory
  int get maxSamples => 1000;
}

/// Performance optimization flags
class PerformanceFlags {
  /// Enable all optimizations
  static const bool enableAllOptimizations = true;
  
  /// Enable widget optimization
  static const bool enableWidgetOptimization = true;
  
  /// Enable rendering optimization
  static const bool enableRenderingOptimization = true;
  
  /// Enable memory optimization
  static const bool enableMemoryOptimization = true;
  
  /// Enable network optimization
  static const bool enableNetworkOptimization = true;
  
  /// Enable animation optimization
  static const bool enableAnimationOptimization = true;
  
  /// Enable scroll optimization
  static const bool enableScrollOptimization = true;
  
  /// Enable image optimization
  static const bool enableImageOptimization = true;
  
  /// Enable text optimization
  static const bool enableTextOptimization = true;
  
  /// Enable list optimization
  static const bool enableListOptimization = true;
}

/// Performance metrics thresholds
class PerformanceThresholds {
  /// FPS thresholds
  static const double excellentFPS = 58.0;
  static const double goodFPS = 55.0;
  static const double acceptableFPS = 50.0;
  static const double poorFPS = 45.0;
  
  /// Memory thresholds (in MB)
  static const double lowMemoryUsage = 50.0;
  static const double mediumMemoryUsage = 100.0;
  static const double highMemoryUsage = 200.0;
  static const double criticalMemoryUsage = 300.0;
  
  /// Frame time thresholds (in milliseconds)
  static const double excellentFrameTime = 16.67; // 60 FPS
  static const double goodFrameTime = 18.52; // 54 FPS
  static const double acceptableFrameTime = 20.0; // 50 FPS
  static const double poorFrameTime = 22.22; // 45 FPS
}

/// Performance optimization recommendations
class PerformanceRecommendations {
  /// Get FPS-based recommendations
  static String getFPSRecommendation(double fps) {
    if (fps >= PerformanceThresholds.excellentFPS) {
      return 'Excellent performance!';
    } else if (fps >= PerformanceThresholds.goodFPS) {
      return 'Good performance. Consider minor optimizations.';
    } else if (fps >= PerformanceThresholds.acceptableFPS) {
      return 'Acceptable performance. Some optimizations recommended.';
    } else if (fps >= PerformanceThresholds.poorFPS) {
      return 'Poor performance. Significant optimizations needed.';
    } else {
      return 'Critical performance issues. Immediate optimization required.';
    }
  }
  
  /// Get memory-based recommendations
  static String getMemoryRecommendation(double memoryMB) {
    if (memoryMB <= PerformanceThresholds.lowMemoryUsage) {
      return 'Low memory usage. Good performance.';
    } else if (memoryMB <= PerformanceThresholds.mediumMemoryUsage) {
      return 'Medium memory usage. Monitor for leaks.';
    } else if (memoryMB <= PerformanceThresholds.highMemoryUsage) {
      return 'High memory usage. Consider optimization.';
    } else {
      return 'Critical memory usage. Immediate action required.';
    }
  }
}
