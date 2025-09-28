import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';

/// Modern card widget with enhanced styling and animations
/// Provides consistent card design across the app with modern UI principles
class ModernCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool isInteractive;

  const ModernCardWidget({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      child: Material(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20.0),
        elevation: showShadow ? (elevation ?? 0.0) : 0.0,
        shadowColor: theme.brightness == Brightness.light 
            ? AppTheme.shadowLight 
            : AppTheme.shadowDark,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(20.0),
          child: Container(
            padding: padding ?? EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(20.0),
              border: isInteractive 
                  ? Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      width: 1.0,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Modern card with gradient background
class ModernGradientCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ModernGradientCardWidget({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.gradientColors,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    final defaultGradient = isLight
        ? [
            AppTheme.primaryLight.withValues(alpha: 0.05),
            AppTheme.secondaryLight.withValues(alpha: 0.05),
          ]
        : [
            AppTheme.primaryDark.withValues(alpha: 0.1),
            AppTheme.secondaryDark.withValues(alpha: 0.1),
          ];

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(20.0),
        elevation: 0.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(20.0),
          child: Container(
            padding: padding ?? EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? defaultGradient,
              ),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Modern card with icon and title
class ModernIconCardWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModernIconCardWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ModernCardWidget(
      onTap: onTap,
      isInteractive: onTap != null,
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 2.w),
            trailing!,
          ] else if (onTap != null) ...[
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern status card with colored indicator
class ModernStatusCardWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModernStatusCardWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.status,
    required this.statusColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ModernCardWidget(
      onTap: onTap,
      isInteractive: onTap != null,
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 2.w),
            trailing!,
          ] else if (onTap != null) ...[
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          ],
        ],
      ),
    );
  }
}
