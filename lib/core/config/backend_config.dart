/// مفتاح تبديل مركزي واحد بين البيانات الوهمية (Mock) وFirebase الحقيقي.
///
/// ✅ مفعَّل الآن (`true`) — مرتبط بمشروع Firebase الحقيقي "matjarna-9"
/// (عبر android/app/google-services.json وlib/firebase_options.dart).
///
/// ⚠️ لضمان عمل التطبيق فعلياً وليس فقط بناءه، تأكد من إتمام هذه الخطوات في
/// Firebase Console لمشروع matjarna-9 (راجع README.md للتفاصيل الكاملة):
///   1. Authentication → فعّل مزوّد Email/Password.
///   2. Firestore Database → أنشئ قاعدة البيانات (وضع Production).
///   3. انشر القواعد: firebase deploy --only firestore:rules,storage
///   4. انشر الدوال: firebase deploy --only functions (بعد npm install في
///      مجلد firebase/functions).
///   5. عيّن أول مدير يدوياً عبر Firebase Admin SDK (راجع README.md).
/// بدون هذه الخطوات، البناء سينجح لكن الشاشات ستُظهر أخطاء اتصال عند القراءة
/// (مُعالَجة بلطف عبر AppErrorView + AppException، وليست انهياراً للتطبيق).
const bool kUseFirebase = true;
