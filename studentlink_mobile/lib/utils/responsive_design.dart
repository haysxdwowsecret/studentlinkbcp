import 'package:flutter/material.dart';

/// 🎯 RESPONSIVE DESIGN: Smart scaling system that adapts to different screen sizes and densities
/// This ensures UI elements are appropriately sized for all devices
class ResponsiveDesign {
  ResponsiveDesign._();

  /// Get responsive font size based on screen size and device density
  static double getFontSize(double baseSize) {
    // Base scaling factor
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    // Adjust based on screen width
    if (widthRatio < 0.8) {
      // Small screens (width < 320dp) - reduce size
      scaleFactor = 0.85;
    } else if (widthRatio > 1.2) {
      // Large screens (width > 480dp) - increase size slightly
      scaleFactor = 1.1;
    }
    
    // Adjust based on device density
    final devicePixelRatio = context.devicePixelRatio;
    if (devicePixelRatio > 3.0) {
      // High density screens - reduce size to prevent oversized elements
      scaleFactor *= 0.9;
    } else if (devicePixelRatio < 2.0) {
      // Low density screens - increase size slightly
      scaleFactor *= 1.05;
    }
    
    return (baseSize * scaleFactor).clamp(10.0, 24.0);
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    // Adjust padding based on screen size
    if (widthRatio < 0.8) {
      scaleFactor = 0.8; // Smaller padding for small screens
    } else if (widthRatio > 1.2) {
      scaleFactor = 1.2; // Larger padding for large screens
    }
    
    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0) * scaleFactor,
      bottom: (bottom ?? vertical ?? all ?? 0) * scaleFactor,
      left: (left ?? horizontal ?? all ?? 0) * scaleFactor,
      right: (right ?? horizontal ?? all ?? 0) * scaleFactor,
    );
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getMargin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      scaleFactor = 0.8;
    } else if (widthRatio > 1.2) {
      scaleFactor = 1.2;
    }
    
    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0) * scaleFactor,
      bottom: (bottom ?? vertical ?? all ?? 0) * scaleFactor,
      left: (left ?? horizontal ?? all ?? 0) * scaleFactor,
      right: (right ?? horizontal ?? all ?? 0) * scaleFactor,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(double baseRadius) {
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      scaleFactor = 0.8;
    } else if (widthRatio > 1.2) {
      scaleFactor = 1.2;
    }
    
    return (baseRadius * scaleFactor).clamp(4.0, 24.0);
  }

  /// Get responsive icon size
  static double getIconSize(double baseSize) {
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      scaleFactor = 0.8;
    } else if (widthRatio > 1.2) {
      scaleFactor = 1.1;
    }
    
    return (baseSize * scaleFactor).clamp(16.0, 32.0);
  }

  /// Get responsive button height
  static double getButtonHeight() {
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      return 40.0; // Smaller buttons for small screens
    } else if (widthRatio > 1.2) {
      return 56.0; // Larger buttons for large screens
    }
    return 48.0; // Standard button height
  }

  /// Get responsive input field height
  static double getInputHeight() {
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      return 44.0; // Smaller input fields for small screens
    } else if (widthRatio > 1.2) {
      return 56.0; // Larger input fields for large screens
    }
    return 50.0; // Standard input height
  }

  /// Check if device is small screen
  static bool get isSmallScreen {
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0;
    return widthRatio < 0.8;
  }

  /// Check if device is large screen
  static bool get isLargeScreen {
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0;
    return widthRatio > 1.2;
  }

  /// Get responsive spacing
  static double getSpacing(double baseSpacing) {
    double scaleFactor = 1.0;
    
    // Get screen width using MediaQuery
    final context = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = context.physicalSize.width / context.devicePixelRatio;
    final widthRatio = screenWidth / 360.0; // 360dp is baseline width
    
    if (widthRatio < 0.8) {
      scaleFactor = 0.8;
    } else if (widthRatio > 1.2) {
      scaleFactor = 1.2;
    }
    
    return baseSpacing * scaleFactor;
  }
}

/// 🎯 RESPONSIVE DESIGN: Extension methods for easy responsive sizing
extension ResponsiveExtensions on num {
  /// Get responsive font size
  double get sp => ResponsiveDesign.getFontSize(toDouble());
  
  /// Get responsive padding
  EdgeInsets get p => ResponsiveDesign.getPadding(all: toDouble());
  
  /// Get responsive margin
  EdgeInsets get m => ResponsiveDesign.getMargin(all: toDouble());
  
  /// Get responsive border radius
  double get r => ResponsiveDesign.getBorderRadius(toDouble());
  
  /// Get responsive icon size
  double get i => ResponsiveDesign.getIconSize(toDouble());
}

/// 🎯 RESPONSIVE DESIGN: Responsive text style builder
class ResponsiveTextStyle {
  static TextStyle get({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: ResponsiveDesign.getFontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}

/// 🎯 RESPONSIVE DESIGN: Responsive button style builder
class ResponsiveButtonStyle {
  static ButtonStyle get({
    required Color backgroundColor,
    required Color foregroundColor,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(double.infinity, height ?? ResponsiveDesign.getButtonHeight()),
      padding: padding ?? ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveDesign.getBorderRadius(12),
        ),
      ),
    );
  }
}

/// 🎯 RESPONSIVE DESIGN: Responsive input decoration builder
class ResponsiveInputDecoration {
  static InputDecoration get({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      fillColor: fillColor,
      filled: true,
      contentPadding: contentPadding ?? ResponsiveDesign.getPadding(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveDesign.getBorderRadius(12),
        ),
        borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveDesign.getBorderRadius(12),
        ),
        borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? ResponsiveDesign.getBorderRadius(12),
        ),
        borderSide: BorderSide(color: borderColor ?? Colors.blue, width: 2),
      ),
    );
  }
}
