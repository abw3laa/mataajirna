import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    await _activateAppCheck();
    await _setupCrashlytics();
  }

  await _enforceRememberMeForAdmin();

  runApp(const ProviderScope(child: MatajirnaApp()));
}

/// Firebase App Check: يحمي كل استدعاءات Firestore/Functions/Storage من
/// الاستخدام خارج تطبيقك الرسمي (بوتات، عملاء مزيّفون، إعادة استخدام
/// مفاتيح API خارج التطبيق). في وضع debug يُستخدم مزوّد Debug (يعمل فوراً
/// بدون إعداد إضافي)، وفي الإنتاج Play Integrity (يتطلب تفعيل App Check في
/// Firebase Console وربط بصمة توقيع تطبيقك في Google Play Console — راجع
/// README.md لخطوات التفعيل الكاملة، فهذا الجزء لا يمكن أتمتته من الكود وحده).
Future<void> _activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
  } catch (e) {
    // لا نُفشل إقلاع التطبيق بسبب App Check — لو لم يُفعَّل بعد من Console،
    // سيستمر التطبيق بالعمل (فقط دون هذه الطبقة الإضافية من الحماية).
    debugPrint('تعذّر تفعيل App Check: $e');
  }
}

/// Firebase Crashlytics: يلتقط كل الأخطاء غير المعالَجة (Flutter framework
/// + Dart غير المتزامن) ويرفعها لوحدة تحكم Firebase بدل فقدانها صامتة.
/// ⚠️ يتطلب أيضاً تطبيق Gradle plugin على مستوى Android (راجع README.md)
/// بعد ربط google-services.json الحقيقي؛ بدونه لا تُرفع التقارير فعلياً
/// وإن كان استدعاء الكود نفسه آمناً (no-op) دون كسر البناء.
Future<void> _setupCrashlytics() async {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
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
