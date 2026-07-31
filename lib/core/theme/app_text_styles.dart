import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// هوية تايبوغرافية بطبقتين لتباين بصري واضح (بدل استخدام خط واحد لكل شيء):
/// - العناوين (display/headline): خط "Almarai" بأوزان ثقيلة — شخصية أوضح.
/// - النصوص والتسميات (body/label): "IBM Plex Sans Arabic" — قراءة مريحة.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _heading({
    required double size,
    required FontWeight weight,
    required double height,
    Color color = AppColors.onSurface,
  }) {
    return GoogleFonts.almarai(
      fontSize: size,
      fontWeight: weight,
      height: height / size,
      color: color,
      letterSpacing: 0,
    );
  }

  static TextStyle _body({
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
      letterSpacing: 0,
    );
  }

  static TextStyle displayLg({Color? color}) =>
      _heading(size: 30, weight: FontWeight.w800, height: 42, color: color ?? AppColors.onSurface);

  static TextStyle headlineMd({Color? color}) =>
      _heading(size: 24, weight: FontWeight.w700, height: 34, color: color ?? AppColors.onSurface);

  static TextStyle headlineSm({Color? color}) =>
      _heading(size: 20, weight: FontWeight.w700, height: 28, color: color ?? AppColors.onSurface);

  static TextStyle bodyLg({Color? color}) =>
      _body(size: 18, weight: FontWeight.w400, height: 28, color: color ?? AppColors.onSurface);

  static TextStyle bodyMd({Color? color}) =>
      _body(size: 16, weight: FontWeight.w400, height: 24, color: color ?? AppColors.onSurface);

  static TextStyle labelMd({Color? color}) =>
      _body(size: 14, weight: FontWeight.w500, height: 20, color: color ?? AppColors.onSurfaceVariant);

  static TextStyle labelSm({Color? color}) =>
      _body(size: 12, weight: FontWeight.w500, height: 16, color: color ?? AppColors.onSurfaceVariant);
}
