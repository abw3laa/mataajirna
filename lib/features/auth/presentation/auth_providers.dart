import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/backend_config.dart';
import '../data/auth_repository.dart';
import '../data/firebase_auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../domain/app_user.dart';

/// يبدّل تلقائياً بين Mock وFirebase حسب lib/core/config/backend_config.dart.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return kUseFirebase ? FirebaseAuthRepository() : MockAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// الدور الحالي — يُستخدم فقط لأغراض واجهة المستخدم (إخفاء/إظهار عناصر).
/// التحقق الأمني الفعلي يتم دوماً على الخادم (Firestore Rules / Cloud Functions).
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authStateProvider).value?.role;
});
