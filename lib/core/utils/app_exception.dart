import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/domain/email_verification_required_exception.dart';

/// يترجم أي استثناء تقني (Firebase Auth / Cloud Functions / شبكة) إلى رسالة
/// عربية مفهومة للمستخدم النهائي. **لا تعرض أبداً** `error.toString()` أو
/// `exception.message` الخام مباشرة في الواجهة — قد تحتوي تفاصيل داخلية
/// (أسماء حقول، مسارات خادم) لا تخص المستخدم ولا ينبغي كشفها، بجانب كونها
/// غير مفهومة له. التفاصيل التقنية الكاملة تبقى فقط في سجلات التطوير
/// (`debugPrint`/console) عند الحاجة، وليس في واجهة المستخدم.
class AppException {
  AppException._();

  static String friendlyMessage(Object error) {
    if (error is EmailVerificationRequiredException) {
      return error.message; // رسالة مُعدّة مسبقاً وآمنة للعرض مباشرة
    }
    if (error is FirebaseAuthException) {
      return _authMessage(error.code);
    }
    if (error is FirebaseFunctionsException) {
      return _functionsMessage(error.code, error.message);
    }
    if (error is StateError) {
      return error.message;
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
  }

  /// هل هذا الاستثناء "معلومة" (تأكيد بريد مثلاً) وليس خطأً فعلياً؟ تستخدمه
  /// الواجهة لاختيار لون العرض (أزرق/أخضر بدل أحمر).
  static bool isInformational(Object error) => error is EmailVerificationRequiredException;

  static String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. تواصل مع الدعم.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً، اختر كلمة أقوى.';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى الانتظار قليلاً ثم إعادة المحاولة.';
      case 'network-request-failed':
        return 'تعذّر الاتصال بالإنترنت، تحقق من اتصالك وحاول مجدداً.';
      default:
        return 'تعذّر تسجيل الدخول، تحقق من البيانات وحاول مجدداً.';
    }
  }

  static String _functionsMessage(String code, String? message) {
    switch (code) {
      case 'unauthenticated':
        return 'يجب تسجيل الدخول لإتمام هذا الإجراء.';
      case 'permission-denied':
        return 'ليست لديك صلاحية لتنفيذ هذا الإجراء.';
      case 'not-found':
        return message ?? 'العنصر المطلوب غير موجود.';
      case 'failed-precondition':
        return message ?? 'لا يمكن إتمام العملية حالياً.';
      case 'invalid-argument':
        return 'البيانات المُرسلة غير صحيحة، تحقق منها وحاول مجدداً.';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً، حاول لاحقاً.';
      default:
        return 'تعذّر إتمام العملية، حاول مرة أخرى.';
    }
  }
}
