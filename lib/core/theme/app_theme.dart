import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.accent,
      onTertiary: AppColors.onAccent,
      tertiaryContainer: AppColors.accentContainer,
      onTertiaryContainer: AppColors.onAccentContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.bodyMd().fontFamily,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSm(color: AppColors.onSurface),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56),
          textStyle: AppTextStyles.labelMd(color: AppColors.onPrimary).copyWith(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.labelMd(),
        hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        selectedLabelStyle: AppTextStyles.labelSm(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.labelSm(),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, thickness: 1),
    );
  }

  /// نسخة داكنة — تُطبَّق تلقائياً على كل عناصر Material القياسية (شريط
  /// العنوان، البطاقات، الأزرار، الحقول، القوائم السفلية...) عبر ThemeData.
  /// ⚠️ ملاحظة صراحة: النصوص والحاويات المخصَّصة في الشاشات التي تستخدم
  /// ألوان `AppColors.*` الثابتة مباشرة (بدل `Theme.of(context)`) لن تتكيّف
  /// تلقائياً مع الوضع الليلي بنفس الجودة — هذا قيد معماري معروف في الإصدار
  /// الحالي (استخدام مكثّف لـ `const AppColors.x` عبر عشرات الملفات يمنع
  /// التحويل الآمن لقيم ديناميكية بدون فحص كل استخدام يدوياً). التحسين
  /// الكامل يتطلب ترحيلاً تدريجياً لاستخدام `Theme.of(context).colorScheme`
  /// بدل الثوابت المباشرة — مرصود كخطوة تالية.
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColorsDark.primary,
      onPrimary: AppColorsDark.onPrimary,
      primaryContainer: AppColorsDark.primaryContainer,
      onPrimaryContainer: AppColorsDark.onPrimaryContainer,
      secondary: AppColorsDark.secondary,
      onSecondary: AppColorsDark.onSecondary,
      secondaryContainer: AppColorsDark.secondaryContainer,
      onSecondaryContainer: AppColorsDark.onSecondaryContainer,
      tertiary: AppColorsDark.accent,
      onTertiary: AppColorsDark.onAccent,
      tertiaryContainer: AppColorsDark.accentContainer,
      onTertiaryContainer: AppColorsDark.onAccentContainer,
      error: AppColorsDark.error,
      onError: AppColorsDark.onError,
      errorContainer: AppColorsDark.errorContainer,
      onErrorContainer: AppColorsDark.onErrorContainer,
      surface: AppColorsDark.surface,
      onSurface: AppColorsDark.onSurface,
      onSurfaceVariant: AppColorsDark.onSurfaceVariant,
      outline: AppColorsDark.outline,
      outlineVariant: AppColorsDark.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsDark.background,
      fontFamily: AppTextStyles.bodyMd().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSm(color: AppColorsDark.onSurface),
        iconTheme: const IconThemeData(color: AppColorsDark.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColorsDark.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColorsDark.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        labelStyle: AppTextStyles.labelMd(color: AppColorsDark.onSurfaceVariant),
        hintStyle: AppTextStyles.bodyMd(color: AppColorsDark.outline),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surfaceContainerLow,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.outline,
        selectedLabelStyle: AppTextStyles.labelSm(color: AppColorsDark.primary),
        unselectedLabelStyle: AppTextStyles.labelSm(color: AppColorsDark.onSurfaceVariant),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColorsDark.outlineVariant, thickness: 1),
    );
  }
}
