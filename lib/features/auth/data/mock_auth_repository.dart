import 'dart:async';
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// مستودع وهمي يُستخدم في التطوير المحلي وفي المعاينة بدون Firebase.
/// حسابات تجريبية:
///   - admin@matajirna.com / admin123  -> دور المدير
///   - user@matajirna.com  / user123   -> دور المستخدم العادي
///
/// ⚠️ في أي بيئة تحتوي بيانات حقيقية يجب استبدال هذا بـ
/// FirebaseAuthRepository حيث يُشتق الدور من custom claims فقط.
class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signIn({required String emailOrPhone, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final isAdmin = emailOrPhone.trim().toLowerCase() == 'admin@matajirna.com';
    final user = AppUser(
      uid: isAdmin ? 'admin-uid' : 'user-uid',
      name: isAdmin ? 'مدير المتجر' : 'أحمد عبدالله',
      email: emailOrPhone,
      role: isAdmin ? UserRole.admin : UserRole.user,
    );
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = AppUser(uid: 'new-user-uid', name: name, email: email, role: UserRole.user);
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
