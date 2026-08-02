// خيارات Firebase الحقيقية لمشروع "matjarna-9" — مُستخرجة مباشرة من
// android/app/google-services.json (وليست قيماً بديلة/placeholder).
//
// هذه القيم هي معرّفات عميل عامة (Client-side identifiers) مصمَّمة لتكون
// مضمَّنة داخل تطبيقات الجوال أصلاً — الحماية الفعلية تأتي من Firestore/
// Storage Security Rules وقيد اسم حزمة أندرويد (package name)، وليس من
// إخفاء هذه القيم. راجع firebase/firestore.rules وfirebase/storage.rules.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions لم تُهيَّأ لمنصة الويب بعد. '
        'شغّل flutterfire configure لتوليد القيم الحقيقية لها.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions لم تُهيَّأ لهذه المنصة بعد. '
          'شغّل flutterfire configure لتوليد القيم الحقيقية لها.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbacQMexyXNbe38uFnsOupDkS7w78-Fkk',
    appId: '1:265784029182:android:16ab4ee7aa6b7f6d77daaf',
    messagingSenderId: '265784029182',
    projectId: 'matjarna-9',
    storageBucket: 'matjarna-9.firebasestorage.app',
  );
}
