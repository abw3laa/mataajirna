import 'package:equatable/equatable.dart';

/// دور المستخدم — **يُقرأ فقط** من custom claims في Firebase ID Token.
/// لا يُسمح أبداً بتحديد الدور من مصدر يتحكم به العميل.
enum UserRole { user, admin }

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
    return AppUser(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      role: roleStr == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, role, photoUrl];
}
