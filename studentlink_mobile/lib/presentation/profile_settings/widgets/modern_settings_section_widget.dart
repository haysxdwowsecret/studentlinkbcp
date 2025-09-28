import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ModernSettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ModernSettingsSectionWidget({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          
          // Section content
          ...children.map((child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          )).toList(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
