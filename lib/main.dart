import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/backend_config.dart';
import 'core/storage/remember_me_store.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/mock_auth_repository.dart';
import 'app.dart';
// يُولَّد هذا الملف تلقائياً عبر `flutterfire configure` (راجع README.md،
// قسم "الربط الفعلي بـ Firebase"). لن يوجد قبل تشغيل ذلك الأمر، لذا يبقى
// الاستيراد آمناً فقط لأن firebase_options.dart سيصبح موجوداً حينها.
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await _enforceRememberMeForAdmin();

  runApp(const ProviderScope(child: MatajirnaApp()));
}

/// "تذكرني": Firebase Auth يُبقي الجلسة محفوظة تلقائياً بين مرات تشغيل
/// التطبيق. إن كانت هناك جلسة أدمن محفوظة من قبل ولم يفعّل صاحبها "تذكرني"
/// وقتها، نسجّل خروجه هنا — مرة واحدة فقط عند كل إقلاع بارد جديد، **قبل**
/// عرض أي واجهة — بدل الاعتماد على مستمع لاحق قد يلتبس مع تسجيل دخول
/// تفاعلي جديد لنفس الجلسة. لا يؤثر هذا على المستخدمين العاديين إطلاقاً.
Future<void> _enforceRememberMeForAdmin() async {
  final authRepo = kUseFirebase ? FirebaseAuthRepository() : MockAuthRepository();
  final persistedUser = await authRepo.authStateChanges().first;
  if (persistedUser != null && persistedUser.isAdmin) {
    final remember = await RememberMeStore.getRememberMe();
    if (!remember) {
      await authRepo.signOut();
    }
  }
}
