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

# تخصيص minSdk=30 واسم التطبيق — يتكيف تلقائياً سواء كانت نسختك تولّد
# build.gradle (Groovy) أو build.gradle.kts (Kotlin DSL):
if [ -f android/app/build.gradle.kts ]; then
  sed -i '/defaultConfig {/a\        minSdk = 30' android/app/build.gradle.kts
else
  sed -i '/defaultConfig {/a\        minSdkVersion 30' android/app/build.gradle
fi
sed -i 's/android:label="[^"]*"/android:label="متجرنا"/' android/app/src/main/AndroidManifest.xml

flutter pub get
flutter gen-l10n    # يولّد lib/l10n/app_localizations.dart من ملفات .arb
flutter analyze     # تحقق من عدم وجود أخطاء قبل التشغيل
flutter run
```

> **لماذا لا يوجد مجلد `android/` في المستودع؟** كانت نسخة يدوية أولى منه تسبب خطأ
> `Build failed due to use of deleted Android v1 embedding.` في CI بسبب فرق دقيق في
> ملفات Gradle/Manifest تعذّر التحقق منه يدوياً بدون تشغيل Flutter SDK فعلياً. الحل
> الأضمن (المعتمد الآن هنا وفي `build.yml`) هو توليده رسمياً عبر `flutter create` نفسه
> في كل مرة — مضمون التوافق دائماً مع نسخة Flutter/Gradle/AGP المستخدمة — ثم تخصيصه
> بالأوامر أعلاه (minSdk 30، اسم التطبيق).

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

1. أنشئ مشروع Firebase وفعّل: Authentication (Email/Password)، Firestore، Functions، Storage.
2. `dart pub global activate flutterfire_cli` ثم `flutterfire configure` — يولّد `lib/firebase_options.dart`.
3. في `lib/main.dart` فعّل استدعاء `Firebase.initializeApp(...)` (موجود جاهزاً، معلَّق فقط).
4. غيّر المزوّدات التالية من Mock إلى التنفيذ الحقيقي:
   - `lib/features/auth/presentation/auth_providers.dart` → `FirebaseAuthRepository()`
   - أنشئ `FirestoreCatalogRepository` / `FirestoreOrdersRepository` مطابقة لواجهات `catalog_repository.dart` / `orders_repository.dart` (البنية جاهزة، فقط التنفيذ الفعلي بـ `cloud_firestore` مطلوب).
5. انشر القواعد والدوال:
   ```bash
   firebase deploy --only firestore:rules
   cd firebase/functions && npm install && cd ../..
   firebase deploy --only functions
   ```
6. عيّن أول مدير يدوياً عبر Firebase Admin SDK / console (Cloud Function `setUserRole` تتطلب مديراً موجوداً مسبقاً لاستدعائها — هذا مقصود أمنياً).

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
