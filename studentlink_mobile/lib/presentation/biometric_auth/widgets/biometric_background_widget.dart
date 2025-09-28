import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class BiometricBackgroundWidget extends StatelessWidget {
  const BiometricBackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BiometricBackgroundPainter(),
      ),
    );
  }
}

class _BiometricBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.backgroundLight,
        AppTheme.primaryLight.withValues(alpha: 0.03),
        AppTheme.secondaryLight.withValues(alpha: 0.02),
        AppTheme.backgroundLight,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw subtle geometric patterns
    _drawGeometricPattern(canvas, size);
    _drawFloatingElements(canvas, size);
  }

  void _drawGeometricPattern(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (double y = 0; y < size.height; y += size.height * 0.12) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += size.width * 0.15) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }
  }

  void _drawFloatingElements(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Draw floating circles with biometric theme
    final circles = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.9, size.height * 0.25),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.8, size.height * 0.85),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.9),
    ];

    for (final circle in circles) {
      canvas.drawCircle(
        circle,
        size.width * 0.015,
        circlePaint,
      );
    }

    // Draw subtle dots in a pattern
    final dotPaint = Paint()
      ..color = AppTheme.secondaryLight.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 71.0) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        1.0,
        dotPaint,
      );
    }

    // Draw security-themed patterns
    _drawSecurityPatterns(canvas, size);
  }

  void _drawSecurityPatterns(Canvas canvas, Size size) {
    final securityPaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw shield-like patterns
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    
    // Top shield
    final topShieldPath = Path();
    topShieldPath.moveTo(centerX, centerY - size.height * 0.2);
    topShieldPath.quadraticBezierTo(
      centerX - size.width * 0.1,
      centerY - size.height * 0.1,
      centerX - size.width * 0.05,
      centerY,
    );
    topShieldPath.quadraticBezierTo(
      centerX,
      centerY + size.height * 0.05,
      centerX + size.width * 0.05,
      centerY,
    );
    topShieldPath.quadraticBezierTo(
      centerX + size.width * 0.1,
      centerY - size.height * 0.1,
      centerX,
      centerY - size.height * 0.2,
    );
    canvas.drawPath(topShieldPath, securityPaint);

    // Bottom shield
    final bottomShieldPath = Path();
    bottomShieldPath.moveTo(centerX, centerY + size.height * 0.2);
    bottomShieldPath.quadraticBezierTo(
      centerX - size.width * 0.1,
      centerY + size.height * 0.1,
      centerX - size.width * 0.05,
      centerY,
    );
    bottomShieldPath.quadraticBezierTo(
      centerX,
      centerY - size.height * 0.05,
      centerX + size.width * 0.05,
      centerY,
    );
    bottomShieldPath.quadraticBezierTo(
      centerX + size.width * 0.1,
      centerY + size.height * 0.1,
      centerX,
      centerY + size.height * 0.2,
    );
    canvas.drawPath(bottomShieldPath, securityPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
