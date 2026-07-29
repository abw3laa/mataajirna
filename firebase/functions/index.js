/**
 * Cloud Functions — طبقة الفرض الأمني للعمليات الحساسة.
 *
 * هذه الدوال هي المكان الوحيد المسموح فيه بتغيير أدوار المستخدمين أو حالة
 * الطلبات من قبل المدير. كل دالة تتحقق من صلاحية المستدعي عبر
 * `context.auth.token.role` (custom claim) قبل تنفيذ أي عملية كتابة —
 * ولا تثق إطلاقاً بأي قيمة يرسلها العميل ضمن body/data الطلب.
 *
 * التشغيل: firebase deploy --only functions (بعد firebase init functions)
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

/** يتأكد أن المستدعي مسجّل دخول ويحمل دور admin ضمن الـ ID Token الخاص به. */
function assertIsAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول.');
  }
  if (context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'هذه العملية مخصصة للمدراء فقط.');
  }
}

/**
 * setUserRole — الدالة الوحيدة المسموح لها بتعيين دور "admin" لمستخدم.
 * تُستدعى فقط من قبل مدير موجود مسبقاً (bootstrap أول مدير يتم عبر
 * Firebase Admin SDK/console مباشرة، وليس عبر هذه الدالة).
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  assertIsAdmin(context);

  const { uid, role } = data;
  if (!uid || !['admin', 'user'].includes(role)) {
    throw new functions.https.HttpsError('invalid-argument', 'uid و role (admin|user) مطلوبان.');
  }

  await admin.auth().setCustomUserClaims(uid, { role });
  await db.collection('users').doc(uid).set({ roleUpdatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

  return { success: true };
});

/**
 * updateOrderStatus — تحديث حالة طلب من قبل المدير، مع تسجيل سجل تدقيق.
 * يُفضَّل استخدام هذه الدالة بدلاً من كتابة مباشرة على المستند من العميل،
 * رغم أن Firestore Rules تمنع أي تحديث من غير المدير على أي حال.
 */
exports.updateOrderStatus = functions.https.onCall(async (data, context) => {
  assertIsAdmin(context);

  const { orderId, status } = data;
  const validStatuses = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];
  if (!orderId || !validStatuses.includes(status)) {
    throw new functions.https.HttpsError('invalid-argument', 'orderId وstatus صالح مطلوبان.');
  }

  const orderRef = db.collection('orders').doc(orderId);
  await orderRef.update({
    status,
    statusHistory: admin.firestore.FieldValue.arrayUnion({
      status,
      changedBy: context.auth.uid,
      changedAt: new Date().toISOString(),
    }),
  });

  return { success: true };
});

/**
 * onOrderCreated — مثال Trigger: يُنشئ إشعاراً للمستخدم عند إنشاء طلب جديد.
 * يوضح كيف تُنشأ الإشعارات من الخادم فقط (Firestore Rules تمنع العميل من
 * الكتابة المباشرة في مجموعة notifications).
 */
exports.onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    await db
      .collection('notifications')
      .doc(order.userId)
      .collection('items')
      .add({
        title: 'تم استلام طلبك',
        body: `طلبك رقم #${context.params.orderId} قيد المعالجة الآن.`,
        type: 'orderUpdate',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  });
