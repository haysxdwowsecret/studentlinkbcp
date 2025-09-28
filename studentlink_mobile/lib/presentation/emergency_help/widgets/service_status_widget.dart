import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ServiceStatusWidget extends StatelessWidget {
  final String status;
  final DateTime? nextAvailable;

  const ServiceStatusWidget({
    Key? key,
    required this.status,
    this.nextAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'available':
        statusColor = AppTheme.successLight;
        statusIcon = Icons.check_circle;
        break;
      case 'busy':
        statusColor = AppTheme.warningLight;
        statusIcon = Icons.schedule;
        break;
      case 'closed':
        statusColor = AppTheme.emergencyLight;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            status,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (nextAvailable != null) ...[
            SizedBox(width: 2.w),
            Text(
              _getNextAvailableText(),
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getNextAvailableText() {
    if (nextAvailable == null) return '';

    final duration = nextAvailable!.difference(DateTime.now());
    if (duration.inMinutes <= 0) {
      return 'Available now';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return 'in ${duration.inMinutes}m';
    }
  }
}
