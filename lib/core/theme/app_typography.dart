import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens from the "Apex Wilderness" design system (DESIGN.md).
///
/// Three families are used:
///  - Hanken Grotesk — headlines / section titles
///  - Lexend         — body copy
///  - Space Grotesk  — stats & uppercase labels (glanceable numerals)
///
/// The families are referenced by name. If the corresponding TTF assets are
/// not bundled (see pubspec `fonts:`), Flutter falls back to the platform
/// default, which keeps the build valid while preserving sizing/weight.
class AppTypography {
  AppTypography._();

  static const String headlineFamily = 'Hanken Grotesk';
  static const String bodyFamily = 'Lexend';
  static const String statFamily = 'Space Grotesk';

  // Headlines
  static const TextStyle displayLg = TextStyle(
    fontFamily: headlineFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -0.96, // -0.02em * 48
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: headlineFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headlineFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  // Stats (Space Grotesk)
  static const TextStyle statHuge = TextStyle(
    fontFamily: statFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.6, // -0.04em * 40
    color: AppColors.onSurface,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: statFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.96, // 0.08em * 12
    color: AppColors.onSurfaceVariant,
  );

  // Body (Lexend)
  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );
}
