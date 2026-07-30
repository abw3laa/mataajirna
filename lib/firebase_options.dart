// ⚠️ هذا ملف بديل مؤقت (placeholder) فقط، لضمان أن المشروع يبني بنجاح حتى
// قبل ربط Firebase الفعلي (طالما kUseFirebase = false في backend_config.dart،
// فلن تُستدعى هذه القيم فعلياً في أي حال).
//
// عند تنفيذ خطوات "الربط الفعلي بـ Firebase" في README.md، شغّل:
//   flutterfire configure
// وسيقوم بالكتابة فوق هذا الملف تلقائياً بالقيم الحقيقية لمشروعك على Firebase
// (apiKey, appId, projectId...). لا تُعدّل هذا الملف يدوياً بعد ذلك.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions لم تُهيَّأ لمنصة الويب بعد. '
        'شغّل flutterfire configure لتوليد القيم الحقيقية.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions لم تُهيَّأ لهذه المنصة بعد. '
          'شغّل flutterfire configure لتوليد القيم الحقيقية.',
        );
    }
  }

  // قيم بديلة (placeholder) فقط — استبدلها flutterfire configure تلقائياً.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}
