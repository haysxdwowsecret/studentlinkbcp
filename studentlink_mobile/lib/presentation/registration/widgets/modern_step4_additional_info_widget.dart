import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Modern step 4 widget for additional information
class ModernStep4AdditionalInfoWidget extends StatelessWidget {
  final Function(DateTime? birthday, String? civilStatus, String? password, String? passwordConfirmation) onDataChanged;

  const ModernStep4AdditionalInfoWidget({
    Key? key,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This step will be implemented with modern UI design.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
