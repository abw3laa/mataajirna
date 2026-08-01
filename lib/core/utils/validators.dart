/// دوال تحقق مشتركة لكل النماذج في التطبيق — مركزية بدل تكرار نفس المنطق
/// (أو نسيانه) في كل شاشة. كل الدوال تُعيد `null` عند الصحة، أو رسالة خطأ
/// عربية عند الفشل، مطابقة لتوقيع `FormFieldValidator<String>`.
class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'هذا الحقل'}) {
    if (value != null && value.trim().length > max) {
      return '$fieldName طويل جداً (الحد الأقصى $max حرفاً)';
    }
    return null;
  }

  /// اسم (منتج، مستخدم...): غير فارغ، وبطول معقول.
  static String? name(String? value, {int maxLen = 100}) {
    final requiredError = required(value, fieldName: 'الاسم');
    if (requiredError != null) return requiredError;
    return maxLength(value, maxLen, fieldName: 'الاسم');
  }

  static String? description(String? value, {int maxLen = 2000}) {
    return maxLength(value, maxLen, fieldName: 'الوصف');
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value.trim())) return 'صيغة البريد الإلكتروني غير صحيحة';
    return null;
  }

  static String? password(String? value, {int minLen = 6}) {
    if (value == null || value.length < minLen) {
      return 'كلمة المرور يجب ألا تقل عن $minLen أحرف';
    }
    return null;
  }

  /// سعر: رقم صالح، غير سالب، وضمن حد أقصى معقول (يمنع أخطاء إدخال جسيمة
  /// مثل عشرات الأصفار الزائدة عن طريق الخطأ).
  static String? price(String? value, {double max = 1000000}) {
    if (value == null || value.trim().isEmpty) return 'السعر مطلوب';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'أدخل رقماً صحيحاً';
    if (parsed < 0) return 'السعر لا يمكن أن يكون سالباً';
    if (parsed > max) return 'السعر أكبر من الحد المسموح';
    return null;
  }

  /// نسبة خصم: رقم بين 0 و100، اختياري (حقل فارغ = بدون خصم).
  static String? discountPercent(String? value) {
    if (value == null || value.trim().isEmpty) return null; // اختياري
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'أدخل نسبة صحيحة';
    if (parsed < 0 || parsed > 100) return 'النسبة يجب أن تكون بين 0 و100';
    return null;
  }

  /// كمية (عدد صحيح موجب) — للمخزون أو الطلبات.
  static String? quantity(String? value, {int max = 999}) {
    if (value == null || value.trim().isEmpty) return 'الكمية مطلوبة';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'أدخل عدداً صحيحاً';
    if (parsed < 1) return 'الكمية يجب أن تكون 1 على الأقل';
    if (parsed > max) return 'الكمية أكبر من الحد المسموح';
    return null;
  }

  /// عنوان توصيل: غير فارغ، حد أدنى للطول (يمنع عناوين غير مفيدة كحرف واحد)
  /// وحد أقصى معقول.
  static String? address(String? value, {int minLen = 8, int maxLen = 300}) {
    if (value == null || value.trim().isEmpty) return 'العنوان مطلوب';
    if (value.trim().length < minLen) return 'اكتب عنواناً أكثر تفصيلاً';
    return maxLength(value, maxLen, fieldName: 'العنوان');
  }

  /// رقم هاتف: أرقام فقط (مع سماح بـ + في البداية)، طول معقول.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهاتف مطلوب';
    final pattern = RegExp(r'^\+?[0-9]{8,15}$');
    if (!pattern.hasMatch(value.trim())) return 'رقم هاتف غير صحيح';
    return null;
  }

  /// ينظّف نصاً قبل الحفظ: يزيل الفراغات الزائدة من الطرفين، ويضغط الفراغات
  /// المتكررة داخلياً إلى فراغ واحد. استخدمه دوماً قبل كتابة نص المستخدم في
  /// قاعدة البيانات.
  static String sanitize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
