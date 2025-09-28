import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ModernBackgroundWidget extends StatelessWidget {
  const ModernBackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ModernBackgroundPainter(),
      ),
    );
  }
}

class _ModernBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.primaryLight.withValues(alpha: 0.05),
        AppTheme.secondaryLight.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw subtle geometric patterns
    _drawGeometricPattern(canvas, size);
  }

  void _drawGeometricPattern(Canvas canvas, Size size) {
    // Draw subtle lines only (no circles)
    final linePaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (double y = 0; y < size.height; y += size.height * 0.2) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += size.width * 0.25) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
