import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// المقاسات مطابقة لقسم typography في DESIGN.md
/// الخط: IBM Plex Sans Arabic
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = AppColors.onSurface,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: size,
      fontWeight: weight,
      height: height / size,
      color: color,
      letterSpacing: 0, // العربية: بدون تباعد أحرف
    );
  }

  static TextStyle displayLg({Color? color}) =>
      _base(size: 30, weight: FontWeight.w700, height: 42, color: color ?? AppColors.onSurface);

  static TextStyle headlineMd({Color? color}) =>
      _base(size: 24, weight: FontWeight.w600, height: 34, color: color ?? AppColors.onSurface);

  static TextStyle headlineSm({Color? color}) =>
      _base(size: 20, weight: FontWeight.w600, height: 28, color: color ?? AppColors.onSurface);

  static TextStyle bodyLg({Color? color}) =>
      _base(size: 18, weight: FontWeight.w400, height: 28, color: color ?? AppColors.onSurface);

  static TextStyle bodyMd({Color? color}) =>
      _base(size: 16, weight: FontWeight.w400, height: 24, color: color ?? AppColors.onSurface);

  static TextStyle labelMd({Color? color}) =>
      _base(size: 14, weight: FontWeight.w500, height: 20, color: color ?? AppColors.onSurfaceVariant);

  static TextStyle labelSm({Color? color}) =>
      _base(size: 12, weight: FontWeight.w500, height: 16, color: color ?? AppColors.onSurfaceVariant);
}
