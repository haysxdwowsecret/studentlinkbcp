import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundPatternWidget extends StatelessWidget {
  const BackgroundPatternWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.primaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Create subtle geometric pattern
    final double patternSize = size.width * 0.15;

    for (double x = -patternSize;
        x < size.width + patternSize;
        x += patternSize * 1.5) {
      for (double y = -patternSize;
          y < size.height + patternSize;
          y += patternSize * 1.5) {
        // Offset alternate rows
        final double offsetX =
            (y / (patternSize * 1.5)).floor() % 2 == 0 ? 0 : patternSize * 0.75;

        // Draw hexagonal pattern
        final Path hexPath = Path();
        final double centerX = x + offsetX;
        final double centerY = y;
        final double radius = patternSize * 0.3;

        for (int i = 0; i < 6; i++) {
          final double angle = (i * 60) * (3.14159 / 180);
          final double pointX = centerX + radius * cos(angle);
          final double pointY = centerY + radius * sin(angle);

          if (i == 0) {
            hexPath.moveTo(pointX, pointY);
          } else {
            hexPath.lineTo(pointX, pointY);
          }
        }
        hexPath.close();

        canvas.drawPath(hexPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function for cos calculation
double cos(double radians) {
  return (radians == 0)
      ? 1.0
      : (radians == 1.5708)
          ? 0.0
          : // π/2
          (radians == 3.14159)
              ? -1.0
              : // π
              (radians == 4.71239)
                  ? 0.0
                  : // 3π/2
                  _cosApproximation(radians);
}

// Helper function for sin calculation
double sin(double radians) {
  return (radians == 0)
      ? 0.0
      : (radians == 1.5708)
          ? 1.0
          : // π/2
          (radians == 3.14159)
              ? 0.0
              : // π
              (radians == 4.71239)
                  ? -1.0
                  : // 3π/2
                  _sinApproximation(radians);
}

// Simple cosine approximation for pattern drawing
double _cosApproximation(double x) {
  // Taylor series approximation for cosine
  x = x % (2 * 3.14159);
  if (x > 3.14159) x = x - 2 * 3.14159;

  double result = 1.0;
  double term = 1.0;

  for (int i = 1; i <= 4; i++) {
    term *= -x * x / ((2 * i - 1) * (2 * i));
    result += term;
  }

  return result;
}

// Simple sine approximation for pattern drawing
double _sinApproximation(double x) {
  // Taylor series approximation for sine
  x = x % (2 * 3.14159);
  if (x > 3.14159) x = x - 2 * 3.14159;

  double result = x;
  double term = x;

  for (int i = 1; i <= 4; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }

  return result;
}