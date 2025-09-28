import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Modern button widget with enhanced styling and animations
class ModernButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final ModernButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const ModernButtonWidget({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    Widget button;
    
    switch (type) {
      case ModernButtonType.primary:
        button = _buildElevatedButton(context, theme, isLight);
        break;
      case ModernButtonType.secondary:
        button = _buildOutlinedButton(context, theme, isLight);
        break;
      case ModernButtonType.text:
        button = _buildTextButton(context, theme, isLight);
        break;
      case ModernButtonType.ghost:
        button = _buildGhostButton(context, theme, isLight);
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildElevatedButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final textColor = this.textColor ?? Colors.white;
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        elevation: 0.0,
        shadowColor: buttonColor.withValues(alpha: 0.3),
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: _getTextStyle(theme),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0.0;
          if (states.contains(WidgetState.hovered)) return 4.0;
          return 2.0;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.8);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.9);
          }
          return buttonColor;
        }),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final textColor = this.textColor ?? buttonColor;
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        padding: padding ?? _getPadding(),
        side: BorderSide(color: buttonColor, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: _getTextStyle(theme),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(color: buttonColor.withValues(alpha: 0.8), width: 2.0);
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(color: buttonColor.withValues(alpha: 0.8), width: 2.0);
          }
          return BorderSide(color: buttonColor, width: 2.0);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  Widget _buildTextButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final textColor = this.textColor ?? buttonColor;
    
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: _getTextStyle(theme),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: _buildButtonContent(textColor),
    );
  }

  Widget _buildGhostButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final textColor = this.textColor ?? buttonColor;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: buttonColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: padding ?? _getPadding(),
            child: _buildButtonContent(textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 5.w,
        height: 5.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 5.w),
          SizedBox(width: 2.w),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ModernButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h);
      case ModernButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h);
      case ModernButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.4.h);
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (size) {
      case ModernButtonSize.small:
        return theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ?? TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case ModernButtonSize.medium:
        return theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ) ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ModernButtonSize.large:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ?? TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }
}

/// Modern icon button widget
class ModernIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const ModernIconButtonWidget({
    Key? key,
    required this.icon,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    Widget button;
    
    switch (type) {
      case ModernButtonType.primary:
        button = _buildElevatedIconButton(context, theme, isLight);
        break;
      case ModernButtonType.secondary:
        button = _buildOutlinedIconButton(context, theme, isLight);
        break;
      case ModernButtonType.text:
        button = _buildTextIconButton(context, theme, isLight);
        break;
      case ModernButtonType.ghost:
        button = _buildGhostIconButton(context, theme, isLight);
        break;
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildElevatedIconButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final iconColor = this.iconColor ?? Colors.white;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: iconColor,
        elevation: 0.0,
        shadowColor: buttonColor.withValues(alpha: 0.3),
        padding: EdgeInsets.all(3.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0.0;
          if (states.contains(WidgetState.hovered)) return 4.0;
          return 2.0;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.8);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.9);
          }
          return buttonColor;
        }),
      ),
      child: Icon(icon, size: size ?? 6.w),
    );
  }

  Widget _buildOutlinedIconButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final iconColor = this.iconColor ?? buttonColor;
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: iconColor,
        padding: EdgeInsets.all(3.w),
        side: BorderSide(color: buttonColor, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(color: buttonColor.withValues(alpha: 0.8), width: 2.0);
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(color: buttonColor.withValues(alpha: 0.8), width: 2.0);
          }
          return BorderSide(color: buttonColor, width: 2.0);
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: Icon(icon, size: size ?? 6.w),
    );
  }

  Widget _buildTextIconButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final iconColor = this.iconColor ?? buttonColor;
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: iconColor,
        padding: EdgeInsets.all(3.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.withValues(alpha: 0.05);
          }
          return Colors.transparent;
        }),
      ),
      child: Icon(icon, size: size ?? 6.w),
    );
  }

  Widget _buildGhostIconButton(BuildContext context, ThemeData theme, bool isLight) {
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final iconColor = this.iconColor ?? buttonColor;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: buttonColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: Icon(icon, size: size ?? 6.w, color: iconColor),
          ),
        ),
      ),
    );
  }
}

enum ModernButtonType {
  primary,
  secondary,
  text,
  ghost,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}
