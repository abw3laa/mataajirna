import 'package:flutter/material.dart';

/// كل الألوان مأخوذة حرفياً من design tokens في premium_arabic_commerce/DESIGN.md
class AppColors {
  AppColors._();

  static const primary = Color(0xFF003178);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0D47A1);
  static const onPrimaryContainer = Color(0xFFA1BBFF);

  static const secondary = Color(0xFF006A62);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF81F3E5);
  static const onSecondaryContainer = Color(0xFF006F66);

  static const tertiary = Color(0xFF602100);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF853100);
  static const onTertiaryContainer = Color(0xFFFFA781);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const surface = Color(0xFFF9F9FB);
  static const surfaceDim = Color(0xFFD9DADC);
  static const surfaceBright = Color(0xFFF9F9FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F3F5);
  static const surfaceContainer = Color(0xFFEEEEF0);
  static const surfaceContainerHigh = Color(0xFFE8E8EA);
  static const surfaceContainerHighest = Color(0xFFE2E2E4);

  static const onSurface = Color(0xFF1A1C1D);
  static const onSurfaceVariant = Color(0xFF434652);
  static const outline = Color(0xFF737783);
  static const outlineVariant = Color(0xFFC3C6D4);

  static const background = Color(0xFFF9F9FB);
  static const onBackground = Color(0xFF1A1C1D);

  // ألوان دلالية للشارات (Status Badges)
  static const success = Color(0xFF00875A);
  static const warning = Color(0xFF8A5A00);
  static const info = secondary;
}
