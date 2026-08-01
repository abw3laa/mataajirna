# متجرنا (Matajirna)

تطبيق تجارة إلكترونية عربي (RTL) واحد بـ Flutter، بصلاحيتين: **مستخدم عادي** و**مدير**،
مبني حسب تصميم Stitch/Figma المرفق، بمعمارية Clean/Feature-first، Riverpod، go_router،
ودعم لغات وعملات متعددة.

## ⚠️ حالة المشروع

هذا الكود مكتوب يدوياً بالكامل (بدون تشغيل `flutter create`/`pub get`/`flutter build` فعلياً،
لأن بيئة الإنشاء لا تملك Flutter SDK ولا اتصال إنترنت لتنزيله). **قبل أول تشغيل يجب عليك محلياً:**

```bash
flutter --version   # تأكد أن لديك Flutter 3.22+ / Dart 3.3+
flutter create --platforms=android --org com.matajirna .   # يولّد مجلد android/ رسمياً (غير مرفوع في المستودع عمداً)

# تخصيص minSdk=30 واسم التطبيق (يتكيف تلقائياً مع أي صيغة Gradle، ويحذف
# السطر الأصلي أياً كانت صيغته قبل إدراج قيمتنا، لتفادي تعارض له الأولوية):
GRADLE_FILE=android/app/build.gradle.kts
if [ ! -f "$GRADLE_FILE" ]; then GRADLE_FILE=android/app/build.gradle; fi
sed -i -E '/^[[:space:]]*minSdk([[:space:]]*=|Version[[:space:]])/d' "$GRADLE_FILE"
sed -i '/defaultConfig {/a\        minSdk = 30' "$GRADLE_FILE"
sed -i 's/android:label="[^"]*"/android:label="متجرنا"/' android/app/src/main/AndroidManifest.xml

flutter pub get
flutter gen-l10n    # يولّد lib/l10n/app_localizations.dart من ملفات .arb
flutter analyze     # تحقق من عدم وجود أخطاء قبل التشغيل
flutter run
```

> **ملاحظة عن مجلد `android/`:** الأوامر أعلاه للتشغيل المحلي فقط. المستودع
> نفسه **يحتوي الآن على نسخة `android/` مُولَّدة ومُتحقَّق منها فعلياً عبر CI**
> (وليست مكتوبة يدوياً) — كل تشغيل ناجح لخطوة "بناء تطبيق أندرويد" في
> `.github/workflows/build.yml` يُعيد توليد المجلد عبر `flutter create` نفسه
> ثم يدفعه تلقائياً للمستودع (commit برسالة تحتوي `[skip ci]`)، فتبقى نسخة
> `android/` المرفوعة مضمونة التوافق دائماً مع نسخة Flutter/Gradle/AGP
> المستخدمة، دون أي كتابة يدوية عرضة للخطأ. إن استنسخت المشروع وبنيته محلياً
> بنفس نسخة Flutter (`FLUTTER_VERSION` في `build.yml`)، يمكنك تجاهل خطوة
> `flutter create` أعلاه والاعتماد على النسخة المرفوعة مباشرة.

## بيانات الدخول التجريبية (Mock — بدون Firebase)

المشروع يعمل افتراضياً بمستودعات وهمية (Mock Repositories) في `lib/features/*/data/mock_*`
بدون أي حاجة لإعداد خادم، لتجربة كل الشاشات فوراً:

| البريد الإلكتروني | كلمة المرور | الدور |
|---|---|---|
| `admin@matajirna.com` | أي كلمة مرور (6 أحرف+) | مدير |
| أي بريد آخر | أي كلمة مرور (6 أحرف+) | مستخدم عادي |

## المزايا المنفَّذة

- ✅ تطبيق Flutter واحد بصلاحيات قائمة على الدور (user/admin)
- ✅ Riverpod (State Management) + go_router (Routing + Role Guards)
- ✅ عربي RTL افتراضي + إنجليزي + تركي (`lib/l10n/*.arb`) — قابل لإضافة لغات أخرى بسهولة
- ✅ عملات متعددة: ليرة تركية / دولار / يورو / ليرة سورية، مع تحويل وتنسيق تلقائي (`lib/core/currency`)
- ✅ تسجيل مستخدمين عاديين ذاتياً (Sign Up)
- ✅ الدفع عند الاستلام (COD) فقط حالياً — قسم طرق الدفع في شاشة الدفع مُجهَّز لكن فارغ عمداً بانتظار بوابة دفع
- ✅ Android 11+ (`minSdk = 30`)
- ✅ معمارية Clean/Feature-first كاملة (`data/domain/presentation` لكل ميزة)
- ✅ فصل واضح بين حماية الواجهة (UX) والأمان الفعلي في الخادم (Firestore Rules + Cloud Functions)

## المعمارية

```
lib/
  core/            ثيم، راوتر، عناصر واجهة مشتركة، عملة، لغة
  features/
    auth/          تسجيل دخول/حساب — Mock + Firebase (جاهز)
    catalog/       منتجات وتصنيفات (رئيسية، تصنيفات، تفاصيل منتج)
    cart/          سلة المشتريات (Riverpod StateNotifier)
    checkout/      إتمام الطلب (عنوان + COD + ملخص)
    orders/        طلباتي (مستخدم) + تفاصيل الطلب
    notifications/ الإشعارات
    profile/       الملف الشخصي + إعدادات اللغة/العملة
    admin/
      dashboard/   لوحة تحكم المدير (KPIs)
      products/    إدارة المنتجات (قائمة + نموذج إضافة/تعديل)
      orders/      إدارة الطلبات (تصفية + تحديث الحالة)
firebase/
  firestore.rules  قواعد الأمان الفعلية (الفرض الملزم للصلاحيات)
  functions/       Cloud Functions (setUserRole, updateOrderStatus, onOrderCreated)
```

## الانتقال من Mock إلى Firebase الحقيقي

المشروع الآن به **مفتاح تبديل واحد**: `lib/core/config/backend_config.dart` → `kUseFirebase`.
طالما هو `false` (الوضع الافتراضي) يعمل التطبيق ببيانات وهمية بدون أي إعداد. اتبع هذه
الخطوات بالترتيب، ثم غيّره إلى `true`:

1. **أنشئ مشروع Firebase**: اذهب إلى https://console.firebase.google.com → Add project.
2. **فعّل الخدمات المطلوبة** من القائمة الجانبية: Authentication (فعّل مزوّد Email/Password) → Firestore Database (ابدأ في وضع Production) → Storage.
3. **أضف تطبيق أندرويد** داخل مشروع Firebase بـ package name بالضبط:
   ```
   com.matajirna.mataajirna
   ```
   (هذا هو applicationId الذي يولّده `flutter create --org com.matajirna .` تلقائياً — لا تغيّره إلا إذا غيّرت `--org` في build.yml وREADME معاً).
4. على جهازك (وليس هنا): ثبّت الأدوات وسجّل الدخول بحساب Google الذي أنشأت به المشروع:
   ```bash
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure
   ```
   اختر مشروع Firebase الذي أنشأته، ومنصة Android فقط. هذا يستبدل `lib/firebase_options.dart`
   (الموجود حالياً كنسخة placeholder) بالقيم الحقيقية لمشروعك، ويُضيف `android/app/google-services.json`.

   > ⚠️ ملاحظة: مجلد `android/` في هذا المستودع **غير مرفوع** (يُولَّد عبر `flutter create` — راجع الأعلى)، لذا نفّذ `flutter create --platforms=android --org com.matajirna .` أولاً إن لم يكن موجوداً محلياً، قبل `flutterfire configure`.

5. غيّر `kUseFirebase` إلى `true` في `lib/core/config/backend_config.dart`.
6. انشر قواعد الأمان والدوال:
   ```bash
   firebase deploy --only firestore:rules
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions
   ```
7. عيّن أول مدير يدوياً (Cloud Function `setUserRole` تتطلب مديراً موجوداً مسبقاً لاستدعائها — هذا مقصود أمنياً):
   ```bash
   node -e "
   const admin = require('firebase-admin');
   admin.initializeApp();
   admin.auth().setCustomUserClaims('UID_المستخدم_هنا', { role: 'admin' })
     .then(() => console.log('تم') );
   "
   ```
   (احصل على UID من Firebase Console → Authentication → Users، بعد أن يسجّل ذلك المستخدم حساباً عادياً أولاً من التطبيق).
8. **لتفعيل بناء CI مع Firebase**: أضف محتوى `android/app/google-services.json` كسرّ باسم `GOOGLE_SERVICES_JSON` في المستودع (Settings → Secrets and variables → Actions)، ثم فعّل السطر المُعلَّق في `.github/workflows/build.yml` الذي يكتبه قبل خطوة البناء، وأضف تطبيق Gradle plugin: `id("com.google.gms.google-services")` في `android/app/build.gradle` بعد توليده.

بعد هذه الخطوات، البيانات كلها (منتجات، تصنيفات، طلبات، مستخدمين) تصبح حقيقية عبر Firestore،
والمصادقة عبر Firebase Auth، بنفس الشاشات تماماً بلا أي تعديل إضافي.

## نموذج الأمان (مهم)

- **لا تثق أبداً بالعميل لتحديد الدور.** الدور مصدره الوحيد هو custom claim على Firebase
  ID Token (`role: admin|user`)، يُضبط فقط عبر Cloud Function `setUserRole` المحمية.
- توجيه `go_router` (`lib/core/router/app_router.dart`) الذي يُخفي شاشات `/admin/*` عن غير
  المدير هو **حماية واجهة فقط** لمنع الوميض/التخمين — **وليس** حاجزاً أمنياً.
- الفرض الفعلي والملزم دائماً في `firebase/firestore.rules` و Cloud Functions، واللذان
  يعيدان التحقق من `request.auth.token.role` على كل عملية حساسة، بصرف النظر عمّا يرسله العميل.

## الفروقات عن التصميم الأصلي / افتراضات

- لا توجد شاشة `checkout` ضمن ملفات Stitch المرفقة — صُممت شاشة دفع بسيطة (عنوان + COD + ملخص)
  بنفس لغة التصميم (بطاقات بيضاء، أزرار Deep Indigo) حسب توجيهاتكم.
- طرق الدفع الإلكترونية متروكة فارغة عمداً (COD فقط حالياً) بانتظار اختيار بوابة الدفع.
- العملة المرجعية المخزَّنة في قاعدة البيانات هي الريال السعودي (SAR)، والعرض يتحول تلقائياً
  حسب اختيار المستخدم؛ أسعار الصرف الحالية في `lib/core/currency/app_currency.dart` **ثابتة
  للتطوير فقط** ويجب ربطها بخدمة أسعار صرف حية قبل الإنتاج.

## أيقونة التطبيق

بما أن مجلد `android/` يُولَّد الآن تلقائياً عبر `flutter create` (انظر أعلاه)، فإن الأيقونة
الافتراضية هي أيقونة Flutter القياسية. لإضافة أيقونة رسمية للمتجر، أسهل طريقة هي حزمة
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons): أضف الحزمة
والصورة المصدر إلى `pubspec.yaml` ثم شغّل `dart run flutter_launcher_icons` بعد توليد
مجلد `android/`.
