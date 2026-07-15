import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Assembles the Material 3 [ThemeData] from the design-system tokens.
///
/// The design system specifies a High-Visibility Light Mode as the default.
/// A dark theme is intentionally out of MVP scope; [light] is the single
/// source of truth used by the app.
class AppTheme {
  AppTheme._();

  /// Spacing scale (px) from DESIGN.md. Exposed for consistent gaps.
  static const double spaceBase = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 16;
  static const double spaceMd = 24;
  static const double spaceLg = 40;
  static const double spaceXl = 64;

  /// Corner radius: Soft-Technical 4px default; pill for FAB/chips.
  static const double radiusDefault = 4;
  static const double radiusLg = 8;
  static const double radiusXl = 12;
  static const double radiusPill = 9999;

  static ColorScheme get _scheme => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    surfaceTint: AppColors.surfaceTint,
  );

  static ThemeData get light {
    final scheme = _scheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.bodyFamily,
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLg,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineLgMobile,
        titleLarge: AppTypography.headlineLgMobile,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelLarge: AppTypography.labelCaps,
        labelSmall: AppTypography.labelCaps,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.headlineFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: AppColors.cardStroke),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(AppTypography.labelCaps),
        elevation: 0,
      ),
    );
  }
}
