import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ModernLogoWidget extends StatelessWidget {
  const ModernLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo container with gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryLight,
                AppTheme.secondaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/img_app_logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to BCP text if image fails to load
                return Text(
                  'BCP',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // College name
        Text(
          'Bestlink College',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          'of the Philippines',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
