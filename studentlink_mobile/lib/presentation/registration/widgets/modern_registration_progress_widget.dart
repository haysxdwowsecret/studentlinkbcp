import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Modern registration progress widget with sleek design
class ModernRegistrationProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ModernRegistrationProgressWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress text
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Modern progress bar
          Stack(
            children: [
              // Connector lines
              Positioned(
                top: 16,
                left: 32,
                right: 32,
                child: Row(
                  children: List.generate(totalSteps - 1, (index) {
                    final stepNumber = index + 1;
                    final isCompleted = stepNumber < currentStep;
                    
                    return Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.lightTheme.colorScheme.primary
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Step circles and titles
              Row(
                children: List.generate(totalSteps, (index) {
                  final stepNumber = index + 1;
                  final isCompleted = stepNumber < currentStep;
                  final isCurrent = stepNumber == currentStep;
                  
                  return Expanded(
                    child: Column(
                      children: [
                        // Step circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isCurrent
                                ? AppTheme.lightTheme.colorScheme.primary
                                : const Color(0xFFE5E7EB),
                            boxShadow: isCompleted || isCurrent ? [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    stepNumber.toString(),
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : const Color(0xFF9CA3AF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Step title
                        _buildStepTitle(_getStepTitle(stepNumber), isActive: isCompleted || isCurrent),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'ID';
      case 2:
        return 'Personal';
      case 3:
        return 'Contact';
      case 4:
        return 'Verify';
      case 5:
        return 'Additional';
      case 6:
        return 'Account';
      default:
        return '';
    }
  }

  Widget _buildStepTitle(String title, {required bool isActive}) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive
            ? AppTheme.lightTheme.colorScheme.primary
            : const Color(0xFF9CA3AF),
      ) ?? const TextStyle(),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
