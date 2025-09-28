import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_design.dart';

/// 🎯 RESPONSIVE THEME: Optimized theme with responsive sizing for all devices
class ResponsiveTheme {
  ResponsiveTheme._();

  // Colors remain the same as AppTheme
  static const Color primaryLight = Color(0xFF1E2A78);
  static const Color primaryVariantLight = Color(0xFF152055);
  static const Color secondaryLight = Color(0xFF2480EA);
  static const Color secondaryVariantLight = Color(0xFF1A66C7);
  static const Color emergencyLight = Color(0xFFE22824);
  static const Color successLight = Color(0xFF28A745);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color borderSubtleLight = Color(0xFFE9ECEF);

  /// 🎯 RESPONSIVE THEME: Light theme with responsive sizing
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: Colors.white,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: Colors.white,
      tertiary: successLight,
      onTertiary: Colors.white,
      tertiaryContainer: successLight.withValues(alpha: 0.1),
      onTertiaryContainer: successLight,
      error: emergencyLight,
      onError: Colors.white,
      surface: backgroundLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: borderSubtleLight,
      outlineVariant: borderSubtleLight.withValues(alpha: 0.5),
      shadow: const Color(0x1A000000),
      scrim: Colors.black54,
      inverseSurface: const Color(0xFF121212),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF4A5BC4),
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: backgroundLight,
    dividerColor: borderSubtleLight,

    // 🎯 RESPONSIVE: AppBar with responsive sizing
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 2.0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(18), // Responsive font size
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: ResponsiveDesign.getIconSize(20), // Responsive icon size
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
        size: ResponsiveDesign.getIconSize(20),
      ),
      toolbarHeight: ResponsiveDesign.getButtonHeight() + 8, // Responsive height
    ),

    // 🎯 RESPONSIVE: Card theme with responsive sizing
    cardTheme: CardThemeData(
      color: backgroundLight,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
      ),
      margin: ResponsiveDesign.getMargin(horizontal: 12, vertical: 6),
    ),

    // 🎯 RESPONSIVE: Bottom navigation with responsive sizing
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w500,
      ),
    ),

    // 🎯 RESPONSIVE: Floating action button with responsive sizing
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: emergencyLight,
      foregroundColor: Colors.white,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(16)),
      ),
    ),

    // 🎯 RESPONSIVE: Button themes with responsive sizing
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryLight,
        elevation: 0.0,
        minimumSize: Size(double.infinity, ResponsiveDesign.getButtonHeight()),
        padding: ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: ResponsiveDesign.getFontSize(14),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0.0;
          if (states.contains(WidgetState.hovered)) return 4.0;
          return 2.0;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryVariantLight;
          }
          if (states.contains(WidgetState.hovered)) {
            return primaryLight.withValues(alpha: 0.9);
          }
          return primaryLight;
        }),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        minimumSize: Size(double.infinity, ResponsiveDesign.getButtonHeight()),
        padding: ResponsiveDesign.getPadding(horizontal: 16, vertical: 12),
        side: BorderSide(color: primaryLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: ResponsiveDesign.getFontSize(14),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: ResponsiveDesign.getPadding(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(8)),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: ResponsiveDesign.getFontSize(13),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // 🎯 RESPONSIVE: Typography with responsive sizing
    textTheme: _buildResponsiveTextTheme(),

    // 🎯 RESPONSIVE: Input decoration with responsive sizing
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: ResponsiveDesign.getPadding(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        borderSide: BorderSide(color: borderSubtleLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        borderSide: BorderSide(color: borderSubtleLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        borderSide: BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        borderSide: BorderSide(color: emergencyLight, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(12)),
        borderSide: BorderSide(color: emergencyLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryLight.withValues(alpha: 0.7),
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: emergencyLight,
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w500,
      ),
    ),

    // 🎯 RESPONSIVE: Other interactive elements
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey[300];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return Colors.grey[300];
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: borderSubtleLight, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return borderSubtleLight;
      }),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: borderSubtleLight,
      circularTrackColor: borderSubtleLight,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: borderSubtleLight,
      trackHeight: 4.0,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w400,
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(6)),
      ),
      textStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w400,
      ),
      padding: ResponsiveDesign.getPadding(horizontal: 8, vertical: 6),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(8)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryLight.withValues(alpha: 0.1),
      labelStyle: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w500,
      ),
      padding: ResponsiveDesign.getPadding(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(16)),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveDesign.getBorderRadius(16)),
      ),
    ),
  );

  /// 🎯 RESPONSIVE: Build responsive text theme
  static TextTheme _buildResponsiveTextTheme() {
    return TextTheme(
      // Display styles - responsive sizing
      displayLarge: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(32),
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(28),
        fontWeight: FontWeight.w700,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(24),
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - responsive sizing
      headlineLarge: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(22),
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(20),
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(18),
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - responsive sizing
      titleLarge: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(16),
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - responsive sizing
      bodyLarge: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(14),
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - responsive sizing
      labelLarge: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(13),
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(11),
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: ResponsiveDesign.getFontSize(10),
        fontWeight: FontWeight.w400,
        color: textSecondaryLight.withValues(alpha: 0.6),
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
