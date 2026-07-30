import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// يخزّن تفضيل "تذكرني" محلياً على الجهاز.
///
/// الافتراضي `true` (يبقى المستخدم مسجّلاً دخوله بين الجلسات، وهو سلوك
/// Firebase Auth الطبيعي على الجوال). عند تعطيله من قبل حساب **أدمن**
/// تحديداً، يُسجَّل خروجه تلقائياً في كل تشغيل بارد جديد للتطبيق
/// (راجع `ref.listen(authStateProvider, ...)` في lib/app.dart).
class RememberMeStore {
  RememberMeStore._();

  static const _storage = FlutterSecureStorage();
  static const _key = 'remember_me';

  static Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _key);
    if (value == null) return true; // افتراضياً: تذكّرني مفعّل
    return value == 'true';
  }

  static Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _key, value: value.toString());
  }
}
