import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernDepartmentSelectionWidget extends StatelessWidget {
  final String? selectedDepartment;
  final Function(String?) onChanged;
  final String? errorText;

  const ModernDepartmentSelectionWidget({
    Key? key,
    required this.selectedDepartment,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.business_rounded,
              color: AppTheme.primaryLight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Department *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? AppTheme.emergencyLight 
                  : const Color(0xFFE5E7EB),
              width: errorText != null ? 2 : 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedDepartment,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onChanged(value);
            },
            decoration: InputDecoration(
              hintText: 'Select your department',
              hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(
                Icons.business_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
            ),
            items: [
              'BS in Accounting Information System',
              'BSBA major in Financial Management',
              'BSBA major in Human Resource Management',
              'BSBA major in Marketing Management',
              'BS in Computer Engineering',
              'BS in Information Technology',
              'BS in Criminology',
              'BS in Psychology',
              'BS in Entrepreneurship',
              'BS in Office Administration',
              'BS in Hospitality Management',
              'BS in Tourism Management',
              'Bachelor of Library and Information Science',
              'Bachelor of Physical Education',
              'Bachelor of Elementary Education',
              'Bachelor of Secondary Education - English',
              'Bachelor of Secondary Education - Filipino',
              'Bachelor of Secondary Education - Mathematics',
              'Bachelor of Secondary Education - Science',
              'Bachelor of Secondary Education - Social Studies',
              'Bachelor of Secondary Education - Values Education',
              'Bachelor of Technology and Livelihood Education',
            ].map((String department) {
              return DropdownMenuItem<String>(
                value: department,
                child: Text(
                  department,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.emergencyLight,
            ),
          ),
        ],
      ],
    );
  }
}
