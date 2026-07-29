import '../domain/app_user.dart';

abstract class AuthRepository {
  /// تدفّق يبثّ المستخدم الحالي (أو null عند تسجيل الخروج).
  /// التطبيق الحقيقي: FirebaseAuthRepository يبني هذا من
  /// FirebaseAuth.authStateChanges() + getIdTokenResult(true) لقراءة الدور.
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signIn({required String emailOrPhone, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}
