import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationInfoWidget extends StatelessWidget {
  final Map<String, dynamic> service;

  const LocationInfoWidget({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color serviceColor =
        service['color'] as Color? ?? AppTheme.primaryLight;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 3.h),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: serviceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'location_on',
                  color: serviceColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Details',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: serviceColor,
                      ),
                    ),
                    Text(
                      service['name'] ?? '',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Location Details Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: serviceColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: serviceColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    'Building', service['location'] ?? '', serviceColor),
                SizedBox(height: 2.h),
                _buildDetailRow('Room', service['room'] ?? '', serviceColor),
                SizedBox(height: 2.h),
                _buildDetailRow('Landmark', _getLandmark(), serviceColor),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Navigation Instructions
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'directions_walk',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'How to get there',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  _getDirections(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  label: Text('Close'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // In a real app, this would open maps
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening campus map...'),
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                      ),
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'map',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text('Open Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: serviceColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _getLandmark() {
    final String serviceName = service['name'] ?? '';
    if (serviceName.contains('Medical') || serviceName.contains('Clinic')) {
      return 'Near the main lobby entrance';
    } else if (serviceName.contains('Security')) {
      return 'At the main campus entrance';
    } else if (serviceName.contains('Guidance')) {
      return 'Next to the Registrar\'s Office';
    }
    return 'On-campus location';
  }

  String _getDirections() {
    final String serviceName = service['name'] ?? '';
    if (serviceName.contains('Medical') || serviceName.contains('Clinic')) {
      return 'Enter through the main lobby of the Administration Building. The Medical Clinic is located on the ground floor, immediately to your right after entering.';
    } else if (serviceName.contains('Security')) {
      return 'The Security Office is located at the main campus entrance (Gate 1). Look for the security booth next to the vehicle checkpoint.';
    } else if (serviceName.contains('Guidance')) {
      return 'Go to the Student Affairs Building, take the stairs or elevator to the 2nd floor. The Guidance Office is in Room 201, next to the Registrar\'s Office.';
    }
    return 'Follow campus signage to locate this service.';
  }
}
