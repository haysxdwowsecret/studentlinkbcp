import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../theme/app_theme.dart';

class OnboardingBackgroundWidget extends StatefulWidget {
  const OnboardingBackgroundWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingBackgroundWidget> createState() => _OnboardingBackgroundWidgetState();
}

class _OnboardingBackgroundWidgetState extends State<OnboardingBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _OnboardingBackgroundPainter(_animation.value),
        );
      },
    );
  }
}

class _OnboardingBackgroundPainter extends CustomPainter {
  final double animationValue;

  _OnboardingBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw subtle grid pattern
    _drawSubtleGrid(canvas, size, paint);
    
    // Draw floating elements
    _drawFloatingElements(canvas, size, paint);
    
    // Draw geometric patterns
    _drawGeometricPatterns(canvas, size, paint);
  }

  void _drawSubtleGrid(Canvas canvas, Size size, Paint paint) {
    paint.color = AppTheme.primaryLight.withValues(alpha: 0.02);
    paint.strokeWidth = 0.5;

    const gridSize = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawFloatingElements(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    for (int i = 0; i < 8; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 2 + random.nextDouble() * 4;
      final alpha = 0.03 + random.nextDouble() * 0.02;
      
      paint.color = AppTheme.primaryLight.withValues(alpha: alpha);
      
      // Animate the circles
      final animatedY = y + math.sin(animationValue + i) * 10;
      
      canvas.drawCircle(
        Offset(x, animatedY),
        radius,
        paint,
      );
    }
  }

  void _drawGeometricPatterns(Canvas canvas, Size size, Paint paint) {
    paint.color = AppTheme.primaryLight.withValues(alpha: 0.01);
    paint.strokeWidth = 1;

    // Draw subtle diagonal lines
    for (int i = 0; i < 3; i++) {
      final startX = -size.width * 0.5 + i * size.width * 0.3;
      final startY = size.height * 0.2;
      final endX = size.width * 0.5 + i * size.width * 0.3;
      final endY = size.height * 0.8;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw subtle curves
    paint.color = AppTheme.secondaryLight.withValues(alpha: 0.008);
    paint.strokeWidth = 0.8;
    
    for (int i = 0; i < 2; i++) {
      final path = Path();
      final startX = size.width * 0.1 + i * size.width * 0.4;
      final startY = size.height * 0.3;
      
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + size.width * 0.2,
        startY + size.height * 0.2,
        startX + size.width * 0.1,
        startY + size.height * 0.4,
      );
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}