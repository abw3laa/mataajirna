import 'package:flutter/material.dart';

/// الهوية اللونية — "نظيف وحيوي": أساسي زمردي نابض بالحياة + لون
/// تمييزي مرجاني دافئ واحد فقط (للـ CTA والخصومات)، على خلفية بيضاء دافئة.
class AppColors {
  AppColors._();

  // أساسي: أخضر-زمردي حيوي (الهوية، الأزرار، العناصر النشطة)
  static const primary = Color(0xFF0EA968);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD7F7E7);
  static const onPrimaryContainer = Color(0xFF00512B);

  // ثانوي: بنفسجي-أزرق هادئ (شارات "جديد"، عناصر معلوماتية)
  static const secondary = Color(0xFF6C63FF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE6E4FF);
  static const onSecondaryContainer = Color(0xFF2D2A85);

  // تمييزي: مرجاني دافئ — نقطة تركيز واحدة فقط (خصومات، عاجل)
  static const accent = Color(0xFFFF6B4A);
  static const onAccent = Color(0xFFFFFFFF);
  static const accentContainer = Color(0xFFFFE1D6);
  static const onAccentContainer = Color(0xFF8A2A0F);

  static const error = Color(0xFFD92D20);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFE1DC);
  static const onErrorContainer = Color(0xFF8A1C12);

  // خلفية بيضاء دافئة (ليست رمادية باردة) — جزء أساسي من "نظيف وحيوي"
  static const surface = Color(0xFFFAFAF7);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F5F0);
  static const surfaceContainer = Color(0xFFEFEFE8);
  static const surfaceContainerHigh = Color(0xFFE8E8E0);
  static const surfaceContainerHighest = Color(0xFFE0E0D6);

  static const onSurface = Color(0xFF23241F); // أسود دافئ، ليس أسود خالصاً
  static const onSurfaceVariant = Color(0xFF63665C);
  static const outline = Color(0xFF8C8F82);
  static const outlineVariant = Color(0xFFDDDED3);

  static const background = surface;
  static const onBackground = onSurface;

  // ألوان دلالية للشارات (Status Badges) — منسجمة مع اللوحة الجديدة
  static const success = Color(0xFF0EA968);
  static const warning = Color(0xFFB25E09);
  static const warningContainer = Color(0xFFFCEBD3);
  static const info = secondary;
}
