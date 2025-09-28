import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernPrioritySelectorWidget extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onChanged;

  const ModernPrioritySelectorWidget({
    Key? key,
    required this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priorities = [
      {'label': 'Low', 'value': 'Low', 'color': AppTheme.successLight},
      {'label': 'Medium', 'value': 'Medium', 'color': AppTheme.warningLight},
      {'label': 'High', 'value': 'High', 'color': AppTheme.emergencyLight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.priority_high_rounded,
              color: AppTheme.primaryLight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Priority Level',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: priorities.map((priority) {
            final isSelected = selectedPriority == priority['value'];
            final color = priority['color'] as Color;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(priority['value'] as String);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? color 
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(priority['value'] as String),
                        color: isSelected ? Colors.white : color,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priority['label'] as String,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : color,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the urgency level of your concern',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Icons.keyboard_arrow_down_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'high':
        return Icons.keyboard_arrow_up_rounded;
      default:
        return Icons.priority_high_rounded;
    }
  }
}
