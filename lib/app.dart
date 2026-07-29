import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class MatajirnaApp extends ConsumerWidget {
  const MatajirnaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'متجرنا',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // نفرض اتجاه RTL/LTR يدوياً استناداً إلى اللغة المختارة حالياً، بحيث
        // يبقى التخطيط عربياً بالكامل RTL بشكل افتراضي، ويتحول لـ LTR فقط
        // عند اختيار الإنجليزية.
        return Directionality(textDirection: locale.direction, child: child!);
      },
      routerConfig: router,
    );
  }
}
