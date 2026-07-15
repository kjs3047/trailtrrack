import 'package:flutter/material.dart';

/// Colour tokens from the "Apex Wilderness" design system (DESIGN.md).
///
/// The palette is a Material 3 tonal scheme in the "Safety & Earth" spectrum:
/// forest-green primary, deep-navy secondary, and a reserved safety-orange
/// accent used only for Action/Safety surfaces (Record FAB, active route).
class AppColors {
  AppColors._();

  // Core brand
  static const Color primary = Color(0xFF154212); // Forest green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2D5A27);
  static const Color onPrimaryContainer = Color(0xFF9DD090);
  static const Color surfaceTint = Color(0xFF3B6934);

  static const Color secondary = Color(0xFF545E76); // Deep navy
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD7E2FF);
  static const Color onSecondaryContainer = Color(0xFF5A647C);

  static const Color tertiary = Color(0xFF60233E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF7C3A55);
  static const Color onTertiaryContainer = Color(0xFFFFAAC8);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surfaces / neutrals (High-Visibility Light Mode)
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF42493E);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color outline = Color(0xFF72796E);
  static const Color outlineVariant = Color(0xFFC2C9BB);
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F2);

  /// Safety-orange accent. Not part of the generated M3 scheme — reserved by
  /// the design system strictly for Action/Safety (Record FAB, active route
  /// polyline). Do not use for decoration.
  static const Color safetyOrange = Color(0xFFF26419);
  static const Color onSafetyOrange = Color(0xFFFFFFFF);

  /// Card hairline stroke: secondary navy at ~10% opacity (per DESIGN.md,
  /// tonal layering with hard outlines instead of muddy shadows).
  static Color get cardStroke => secondary.withValues(alpha: 0.10);
}
