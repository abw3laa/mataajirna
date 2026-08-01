import 'package:equatable/equatable.dart';

/// دور المستخدم — **يُقرأ فقط** من custom claims في Firebase ID Token.
/// لا يُسمح أبداً بتحديد الدور من مصدر يتحكم به العميل.
///
/// ثلاثة مستويات (نظام صلاحيات متعدد):
///   - admin  : كل الصلاحيات، بما فيها إدارة أدوار المستخدمين الآخرين.
///   - manager: يدير المنتجات/الطلبات/البانرات اليومية، دون صلاحيات حسّاسة
///              كتغيير الأدوار أو الوصول لسجل التدقيق الكامل.
///   - user   : عميل عادي.
enum UserRole { user, manager, admin }

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;

  bool get isAdmin => role == UserRole.admin;

  /// يشمل admin وmanager معاً — يُستخدم لبوابة الدخول العامة للوحة التحكم
  /// (الراوتر)، بينما شاشات/عمليات حسّاسة أخرى (لاحقاً) قد تتحقق من
  /// [isAdmin] حصرياً عند الحاجة.
  bool get isAdminOrManager => role == UserRole.admin || role == UserRole.manager;

  factory AppUser.fromClaims({
    required String uid,
    required String name,
    required String email,
    required Map<String, dynamic> claims,
    String? photoUrl,
  }) {
    // مصدر الحقيقة الوحيد للدور: claims['role'] القادم من الخادم (Cloud Functions
    // + Firebase Admin SDK). لا نثق بأي حقل دور مخزّن محلياً أو في Firestore
    // يمكن للمستخدم تعديله مباشرة.
    final roleStr = claims['role'] as String?;
    final role = switch (roleStr) {
      'admin' => UserRole.admin,
      'manager' => UserRole.manager,
      _ => UserRole.user,
    };
    return AppUser(uid: uid, name: name, email: email, photoUrl: photoUrl, role: role);
  }

  @override
  List<Object?> get props => [uid, name, email, role, photoUrl];
}
