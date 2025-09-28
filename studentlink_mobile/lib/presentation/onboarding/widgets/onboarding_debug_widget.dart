import 'package:flutter/material.dart';
import '../../../services/onboarding_service.dart';
import '../../../theme/app_theme.dart';

/// Debug widget for testing onboarding flow
/// This widget can be temporarily added to any screen for testing purposes
class OnboardingDebugWidget extends StatelessWidget {
  const OnboardingDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtleLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Onboarding Debug',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _resetOnboarding(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningLight,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset Onboarding'),
              ),
              ElevatedButton(
                onPressed: () => _checkOnboardingStatus(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryLight,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetOnboarding(BuildContext context) {
    OnboardingService.resetOnboarding();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding reset! Restart the app to see onboarding again.'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _checkOnboardingStatus(BuildContext context) async {
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted 
            ? 'Onboarding is completed' 
            : 'Onboarding is not completed',
        ),
        backgroundColor: isCompleted ? AppTheme.successLight : AppTheme.warningLight,
      ),
    );
  }
}
