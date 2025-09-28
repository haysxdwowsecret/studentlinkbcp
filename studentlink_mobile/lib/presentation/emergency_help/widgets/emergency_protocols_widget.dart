import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyProtocolsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> protocols;

  const EmergencyProtocolsWidget({
    Key? key,
    required this.protocols,
  }) : super(key: key);

  @override
  State<EmergencyProtocolsWidget> createState() =>
      _EmergencyProtocolsWidgetState();
}

class _EmergencyProtocolsWidgetState extends State<EmergencyProtocolsWidget> {
  final Set<int> _expandedProtocols = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: widget.protocols.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> protocol = entry.value;
          final bool isExpanded = _expandedProtocols.contains(index);

          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedProtocols.remove(index);
                        } else {
                          _expandedProtocols.add(index);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: _getProtocolColor(protocol['title'])
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: protocol['icon'] ?? 'warning',
                              color: _getProtocolColor(protocol['title']),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  protocol['title'] ?? 'Protocol',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  '${(protocol['steps'] as List<String>?)?.length ?? 0} steps',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: Duration(milliseconds: 200),
                            child: CustomIconWidget(
                              iconName: 'expand_more',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Expandable Content
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isExpanded ? null : 0,
                  child: isExpanded
                      ? Container(
                          decoration: BoxDecoration(
                            color: _getProtocolColor(protocol['title'])
                                .withValues(alpha: 0.02),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Divider
                              Container(
                                height: 1,
                                color: AppTheme.lightTheme.dividerColor,
                              ),

                              // Steps
                              Container(
                                padding: EdgeInsets.all(4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Follow these steps:',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _getProtocolColor(
                                            protocol['title']),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    ...((protocol['steps'] as List<String>?)
                                            ?.asMap()
                                            .entries
                                            .map((stepEntry) {
                                          final int stepIndex = stepEntry.key;
                                          final String step = stepEntry.value;
                                          return _buildStepItem(stepIndex + 1,
                                              step, protocol['title']);
                                        }) ??
                                        []),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String stepText, String protocolTitle) {
    final Color protocolColor = _getProtocolColor(protocolTitle);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: protocolColor,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0.5.h),
              child: Text(
                stepText,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProtocolColor(String? title) {
    if (title == null) return AppTheme.primaryLight;

    switch (title.toLowerCase()) {
      case 'medical emergency':
        return AppTheme.emergencyLight;
      case 'fire emergency':
        return Colors.deepOrange;
      case 'security incident':
        return AppTheme.primaryLight;
      case 'natural disaster':
        return AppTheme.warningLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
