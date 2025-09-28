import 'package:flutter/material.dart';

/// Performance-optimized theme configuration
class PerformanceTheme {
  /// Optimized text styles with better rendering performance
  static const TextStyle optimizedHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle optimizedHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const TextStyle optimizedHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle optimizedTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle optimizedTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static const TextStyle optimizedTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle optimizedBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle optimizedBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.25,
  );

  static const TextStyle optimizedBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const TextStyle optimizedLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle optimizedLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static const TextStyle optimizedLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  /// Optimized button styles
  static ButtonStyle get optimizedElevatedButtonStyle => ElevatedButton.styleFrom(
    elevation: 2,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: optimizedLabelLarge,
  );

  static ButtonStyle get optimizedOutlinedButtonStyle => OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: optimizedLabelLarge,
  );

  static ButtonStyle get optimizedTextButtonStyle => TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: optimizedLabelLarge,
  );

  /// Optimized input decoration
  static InputDecoration get optimizedInputDecoration => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    filled: true,
    fillColor: Colors.grey.shade50,
  );

  /// Optimized card theme
  static CardTheme get optimizedCardTheme => CardTheme(
    elevation: 2,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8),
  );

  /// Optimized app bar theme
  static AppBarTheme get optimizedAppBarTheme => const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    titleTextStyle: optimizedTitleLarge,
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  );

  /// Optimized bottom navigation bar theme
  static BottomNavigationBarThemeData get optimizedBottomNavTheme => const BottomNavigationBarThemeData(
    elevation: 8,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: optimizedLabelSmall,
    unselectedLabelStyle: optimizedLabelSmall,
  );

  /// Optimized floating action button theme
  static FloatingActionButtonThemeData get optimizedFABTheme => const FloatingActionButtonThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  /// Optimized scroll physics
  static const ScrollPhysics optimizedScrollPhysics = BouncingScrollPhysics(
    parent: RangeMaintainingScrollPhysics(),
  );

  /// Optimized animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  /// Optimized curve
  static const Curve optimizedCurve = Curves.easeInOutCubic;
}
