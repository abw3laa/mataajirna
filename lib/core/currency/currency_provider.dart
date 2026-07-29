import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app_currency.dart';

/// يحفظ العملة المختارة حالياً (تُقرأ/تُكتب لاحقاً عبر flutter_secure_storage
/// أو SharedPreferences ليتم تذكّرها بين الجلسات).
class CurrencyNotifier extends StateNotifier<AppCurrency> {
  CurrencyNotifier() : super(AppCurrency.usd);

  void setCurrency(AppCurrency currency) => state = currency;
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, AppCurrency>(
  (ref) => CurrencyNotifier(),
);

/// يحوّل مبلغاً مخزَّناً بالريال السعودي إلى العملة الحالية وينسّقه للعرض.
class CurrencyFormatter {
  const CurrencyFormatter(this.currency);

  final AppCurrency currency;

  double convertFromSar(double amountInSar) {
    final rate = kExchangeRatesFromSar[currency] ?? 1;
    return amountInSar * rate;
  }

  String format(double amountInSar) {
    final converted = convertFromSar(amountInSar);
    final formatted = NumberFormat.decimalPattern('en').format(
      double.parse(converted.toStringAsFixed(converted >= 100 ? 0 : 2)),
    );
    return '${currency.symbol} $formatted';
  }
}

final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  final currency = ref.watch(currencyProvider);
  return CurrencyFormatter(currency);
});
