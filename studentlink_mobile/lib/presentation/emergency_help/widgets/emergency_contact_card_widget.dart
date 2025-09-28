import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './service_status_widget.dart';

class EmergencyContactCardWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onCallTap;
  final VoidCallback onLocationTap;

  const EmergencyContactCardWidget({
    Key? key,
    required this.service,
    required this.onCallTap,
    required this.onLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color serviceColor =
        service['color'] as Color? ?? AppTheme.primaryLight;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              serviceColor.withValues(alpha: 0.05),
              serviceColor.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: serviceColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: serviceColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: service['icon'] ?? 'help',
                      color: serviceColor,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? 'Service',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: serviceColor,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        ServiceStatusWidget(
                          status: service['status'] ?? 'Unknown',
                          nextAvailable: service['nextAvailable'],
                        ),
                      ],
                    ),
                  ),
                  // Emergency Call Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.emergencyLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.emergencyLight.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onCallTap();
                        },
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'call',
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    service['description'] ?? '',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Contact Info Grid
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: serviceColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: serviceColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Phone',
                          'call',
                          service['contact'] ?? '',
                          serviceColor,
                          () => _copyToClipboard(
                              context, service['contact'] ?? ''),
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Hours',
                          'schedule',
                          service['hours'] ?? '',
                          serviceColor,
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          'Location',
                          'location_on',
                          '${service['location'] ?? ''}\n${service['room'] ?? ''}',
                          serviceColor,
                          onLocationTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String iconName,
    String value,
    Color color, [
    VoidCallback? onTap,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'touch_app',
                color: color.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied to clipboard'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
