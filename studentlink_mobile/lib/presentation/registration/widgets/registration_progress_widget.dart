import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class RegistrationProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RegistrationProgressWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Progress text
          Text(
            'Step $currentStep of $totalSteps',
            style: TextStyle(
              fontSize: 4.w,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Progress bar
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.grey.shade300,
                        border: Border.all(
                          color: isCompleted || isCurrent
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 4.w,
                              )
                            : Text(
                                stepNumber.toString(),
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : Colors.grey.shade600,
                                  fontSize: 3.5.w,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    // Connector line
                    if (index < totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          SizedBox(height: 2.h),
          
          // Step titles
          Row(
            children: [
              Expanded(
                child: _buildStepTitle('ID', currentStep >= 1),
              ),
              Expanded(
                child: _buildStepTitle('Personal', currentStep >= 2),
              ),
              Expanded(
                child: _buildStepTitle('Contact', currentStep >= 3),
              ),
              Expanded(
                child: _buildStepTitle('Verify', currentStep >= 4),
              ),
              Expanded(
                child: _buildStepTitle('Additional', currentStep >= 5),
              ),
              Expanded(
                child: _buildStepTitle('Account', currentStep >= 6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, bool isActive) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 3.w,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive
            ? AppTheme.lightTheme.colorScheme.primary
            : Colors.grey.shade600,
      ),
    );
  }
}
