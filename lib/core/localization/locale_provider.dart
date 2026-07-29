import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// اللغات المدعومة في التطبيق. العربية هي اللغة الافتراضية و RTL.
const supportedLocales = [
  Locale('ar'),
  Locale('en'),
  Locale('tr'),
];

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar'));

  void setLocale(Locale locale) {
    if (supportedLocales.contains(locale)) {
      state = locale;
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

extension LocaleLabel on Locale {
  String get displayLabel => switch (languageCode) {
        'ar' => 'العربية',
        'en' => 'English',
        'tr' => 'Türkçe',
        _ => languageCode,
      };

  TextDirection get direction =>
      languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}
