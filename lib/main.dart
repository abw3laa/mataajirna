import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/backend_config.dart';
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

  runApp(const ProviderScope(child: MatajirnaApp()));
}
