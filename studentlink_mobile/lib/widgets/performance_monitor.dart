import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring widget for debugging frame rates
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.enabled = false, // Disabled by default for production
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  double _currentFPS = 60.0;
  final List<double> _fpsHistory = [];
  final int _maxHistoryLength = 60; // Keep last 60 frames

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (!mounted) return;
      
      final frameRate = 1.0 / (timeStamp.inMicroseconds / 1000000.0);
      _fpsHistory.add(frameRate);
      
      if (_fpsHistory.length > _maxHistoryLength) {
        _fpsHistory.removeAt(0);
      }
      
      final averageFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
      
      if (mounted) {
        setState(() {
          _currentFPS = averageFPS;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFPSColor().withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'FPS: ${_currentFPS.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getFPSColor() {
    if (_currentFPS >= 55) return Colors.green;
    if (_currentFPS >= 45) return Colors.orange;
    return Colors.red;
  }
}

/// Performance overlay for debugging
class PerformanceOverlay extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 30,
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Text(
                'Performance Overlay Enabled',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Memory usage monitor
class MemoryMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const MemoryMonitor({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<MemoryMonitor> createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  String _memoryUsage = '0 MB';

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMemoryMonitoring();
    }
  }

  void _startMemoryMonitoring() {
    // This would require platform-specific implementation
    // For now, we'll just show a placeholder
    setState(() {
      _memoryUsage = 'Monitoring...';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 100,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Memory: $_memoryUsage',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
