import 'package:flutter/material.dart';
import '../utils/responsive_design.dart';

/// 🎯 RESPONSIVE WIDGETS: Pre-built responsive widgets for consistent sizing

/// Responsive button that adapts to screen size
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isOutlined;
  final bool isTextButton;
  final Widget? icon;
  final bool isLoading;

  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.isOutlined = false,
    this.isTextButton = false,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button;
    
    if (isTextButton) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          minimumSize: Size(double.infinity, ResponsiveDesign.getButtonHeight()),
          padding: ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          ),
        ),
        child: _buildButtonContent(context),
      );
    } else if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          minimumSize: Size(double.infinity, ResponsiveDesign.getButtonHeight()),
          padding: ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          ),
        ),
        child: _buildButtonContent(context),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, ResponsiveDesign.getButtonHeight()),
          padding: ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          ),
        ),
        child: _buildButtonContent(context),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: ResponsiveDesign.getButtonHeight(),
      child: button,
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: ResponsiveDesign.getIconSize(16),
        width: ResponsiveDesign.getIconSize(16),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isTextButton || isOutlined 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: ResponsiveDesign.getSpacing(8)),
          Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveDesign.getFontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Responsive text input field
class ResponsiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;

  const ResponsiveTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines = 1,
    this.enabled = true,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint ?? '',
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor: theme.colorScheme.surface,
        filled: true,
        contentPadding: ResponsiveDesign.getPadding(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
      ),
    );
  }
}

/// Responsive card widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      color: color ?? theme.cardColor,
      elevation: elevation ?? 0,
      margin: margin ?? ResponsiveDesign.getMargin(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
      ),
      child: Padding(
        padding: padding ?? ResponsiveDesign.getPadding(all: 16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        child: card,
      );
    }

    return card;
  }
}

/// Responsive icon button
class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final double? size;

  const ResponsiveIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = size ?? ResponsiveDesign.getIconSize(20);
    
    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: iconSize,
        color: color ?? theme.colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(8)),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      text,
      style: style ?? TextStyle(
        fontSize: fontSize != null 
          ? ResponsiveDesign.getFontSize(fontSize!) 
          : ResponsiveDesign.getFontSize(14),
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? theme.colorScheme.onSurface,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double height;
  final double? width;

  const ResponsiveSpacing({
    Key? key,
    required this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveDesign.getSpacing(height),
      width: width != null ? ResponsiveDesign.getSpacing(width!) : null,
    );
  }
}

/// Responsive container with consistent padding
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final BoxBorder? border;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveDesign.getPadding(all: 16),
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveDesign.getBorderRadius(12),
        ),
        border: border,
      ),
      child: child,
    );
  }
}
