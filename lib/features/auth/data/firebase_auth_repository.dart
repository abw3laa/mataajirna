import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// التنفيذ الحقيقي المرتبط بـ Firebase.
/// الأمان: الدور (admin/user) يُقرأ حصراً من الـ ID Token custom claims
/// (`getIdTokenResult(true).claims['role']`). لا نخزّن ولا نثق بأي دور قادم
/// من Firestore أو من العميل نفسه. تعيين الدور يتم فقط عبر Cloud Function
/// محمية (انظر firebase/functions/index.js -> setUserRole).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
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
    final tokenResult = await credential.user!.getIdTokenResult(true);
    return AppUser.fromClaims(
      uid: credential.user!.uid,
      name: credential.user!.displayName ?? '',
      email: credential.user!.email ?? '',
      claims: tokenResult.claims ?? const {},
    );
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.updateDisplayName(name);
    // الدور الافتراضي لكل حساب جديد هو "user". أي ترقية إلى admin تتم لاحقاً
    // فقط عبر Cloud Function setUserRole يستدعيها مدير موجود مسبقاً.
    return AppUser(uid: credential.user!.uid, name: name, email: email, role: UserRole.user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email);
}
