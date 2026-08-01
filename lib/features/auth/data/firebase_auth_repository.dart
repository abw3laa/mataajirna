import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../domain/app_user.dart';
import '../domain/email_verification_required_exception.dart';
import 'auth_repository.dart';

/// التنفيذ الحقيقي المرتبط بـ Firebase.
///
/// الأمان:
/// - الدور (admin/user) يُقرأ حصراً من الـ ID Token custom claims
///   (`getIdTokenResult(true).claims['role']`). لا نخزّن ولا نثق بأي دور قادم
///   من Firestore أو من العميل نفسه. تعيين الدور يتم فقط عبر Cloud Function
///   محمية (انظر firebase/functions/index.js -> setUserRole).
/// - **تأكيد البريد الإلكتروني إلزامي**: لا يُسمح بإكمال تسجيل الدخول ما لم
///   يكن `emailVerified == true`. إن حاول مستخدم غير مؤكَّد الدخول، نعيد
///   إرسال رابط التفعيل تلقائياً ونسجّل خروجه فوراً (لا نتركه في حالة "مسجّل
///   دخوله لكنه محجوب" غامضة) مع رسالة واضحة توجّهه لبريده.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      // لا نُعيد مستخدماً لم يؤكّد بريده بعد كجلسة نشطة — يمنع دخول حساب
      // مُنشأ حديثاً ولم يُفعَّل بعد عبر جلسة محفوظة من جهاز آخر مثلاً.
      if (!fbUser.emailVerified) return null;
      // forceRefresh: true لضمان قراءة أحدث claims بعد أي تغيير في الصلاحية.
      final tokenResult = await fbUser.getIdTokenResult(true);
      return AppUser.fromClaims(
        uid: fbUser.uid,
        name: fbUser.displayName ?? '',
        email: fbUser.email ?? '',
        photoUrl: fbUser.photoURL,
        claims: tokenResult.claims ?? const {},
      );
    });
  }

  @override
  Future<AppUser> signIn({required String emailOrPhone, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: emailOrPhone,
      password: password,
    );
    final user = credential.user!;

    if (!user.emailVerified) {
      // أعد إرسال رابط التفعيل (لا يضر إن أُرسل من قبل) ثم سجّل خروجه فوراً
      // بدل تركه بجلسة "نصف مسجّلة" قد تلتبس مع الشاشات المحمية.
      try {
        await user.sendEmailVerification();
      } catch (_) {
        // نتجاهل فشل إعادة الإرسال هنا (مثل حد معدّل الإرسال) ونكمل تسجيل
        // الخروج على أي حال — الرسالة أدناه تبقى صحيحة إجمالاً.
      }
      await _auth.signOut();
      throw EmailVerificationRequiredException(
        'يجب تأكيد بريدك الإلكتروني أولاً. أرسلنا رابط تفعيل جديداً إلى $emailOrPhone.',
      );
    }

    final tokenResult = await user.getIdTokenResult(true);
    return AppUser.fromClaims(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      claims: tokenResult.claims ?? const {},
    );
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    await user.updateDisplayName(name);
    await user.sendEmailVerification();
    // نسجّل خروجه فوراً — الحساب موجود لكن لن يُعامَل كجلسة نشطة حتى يؤكّد
    // بريده ويسجّل دخوله من جديد (راجع signIn أعلاه).
    await _auth.signOut();
    throw EmailVerificationRequiredException(
      'تم إنشاء حسابك! أرسلنا رابط تفعيل إلى $email — أكّده ثم سجّل دخولك.',
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email);
}
