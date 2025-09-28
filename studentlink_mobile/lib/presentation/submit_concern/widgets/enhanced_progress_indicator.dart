import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// Enhanced progress indicator widget with step visualization
class EnhancedProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double completionPercentage;
  final VoidCallback? onStepTap;
  final bool showStepLabels;
  final bool showPercentage;

  const EnhancedProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.completionPercentage,
    this.onStepTap,
    this.showStepLabels = true,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar and percentage
          Row(
            children: [
              Expanded(
                child: _buildProgressBar(),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 12),
                _buildPercentageIndicator(),
              ],
            ],
          ),
          
          if (showStepLabels) ...[
            const SizedBox(height: 12),
            _buildStepLabels(),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: completionPercentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryLight,
                    AppTheme.primaryLight.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isCompleted = stepNumber < currentStep;
            final isCurrent = stepNumber == currentStep;
            
            return GestureDetector(
              onTap: onStepTap != null ? () {
                HapticFeedback.lightImpact();
                onStepTap!();
              } : null,
              child: _buildStepIndicator(stepNumber, isCompleted, isCurrent),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int stepNumber, bool isCompleted, bool isCurrent) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted || isCurrent
            ? AppTheme.primaryLight
            : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(
                color: AppTheme.primaryLight,
                width: 2,
              )
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              )
            : Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: isCurrent || isCompleted
                      ? Colors.white
                      : const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildPercentageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(completionPercentage * 100).round()}%',
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStepLabels() {
    final stepLabels = [
      'Subject',
      'Department',
      'Type',
      'Priority',
      'Options',
      'Description',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stepLabels.take(totalSteps).map((label) {
        final stepIndex = stepLabels.indexOf(label);
        final stepNumber = stepIndex + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;
        
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isCompleted || isCurrent
                    ? AppTheme.primaryLight
                    : const Color(0xFF9CA3AF),
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Compact progress indicator for smaller spaces
class CompactProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double completionPercentage;

  const CompactProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.completionPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress bar
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: completionPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Step counter
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
