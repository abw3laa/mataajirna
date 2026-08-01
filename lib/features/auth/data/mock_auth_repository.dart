import 'dart:async';
import '../domain/app_user.dart';
import 'auth_repository.dart';

/// مستودع وهمي يُستخدم في التطوير المحلي وفي المعاينة بدون Firebase.
/// حسابات تجريبية:
///   - admin@matajirna.com   / أي كلمة مرور 6+ أحرف  -> دور المدير (كل الصلاحيات)
///   - manager@matajirna.com / أي كلمة مرور 6+ أحرف  -> دور المشرف (منتجات/طلبات/بانرات)
///   - أي بريد آخر                                    -> مستخدم عادي
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
    final email = emailOrPhone.trim().toLowerCase();
    final role = switch (email) {
      'admin@matajirna.com' => UserRole.admin,
      'manager@matajirna.com' => UserRole.manager,
      _ => UserRole.user,
    };
    final user = AppUser(
      uid: '$role-uid',
      name: switch (role) {
        UserRole.admin => 'مدير المتجر',
        UserRole.manager => 'مشرف المتجر',
        UserRole.user => 'أحمد عبدالله',
      },
      email: emailOrPhone,
      role: role,
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
