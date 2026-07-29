/// العملات المدعومة في التطبيق.
/// السعر الأساسي لكل منتج يُخزَّن دائماً بالريال السعودي (SAR) في قاعدة البيانات،
/// ويتم التحويل للعرض فقط حسب اختيار المستخدم.
enum AppCurrency {
  try_('TRY', 'ليرة تركية', '₺'),
  usd('USD', 'دولار أمريكي', '\$'),
  syp('SYP', 'ليرة سورية', 'ل.س'),
  eur('EUR', 'يورو', '€');

  const AppCurrency(this.code, this.arabicName, this.symbol);

  final String code;
  final String arabicName;
  final String symbol;

  static AppCurrency fromCode(String code) {
    return AppCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCurrency.usd,
    );
  }
}

/// أسعار صرف تقريبية ثابتة (1 SAR = X من العملة المستهدفة).
/// ⚠️ هذه قيم افتراضية للتطوير فقط. في الإنتاج يجب جلبها من خدمة أسعار صرف
/// حيّة (مثلاً عبر Cloud Function مجدولة تُحدّث مستند `settings/exchangeRates`
/// في Firestore بشكل دوري) بدلاً من تثبيتها في الكود.
const Map<AppCurrency, double> kExchangeRatesFromSar = {
  AppCurrency.try_: 8.60,
  AppCurrency.usd: 0.27,
  AppCurrency.syp: 3550.0,
  AppCurrency.eur: 0.25,
};
