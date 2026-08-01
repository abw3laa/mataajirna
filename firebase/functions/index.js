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

/** يسمح بـ admin أو manager (لعمليات إدارة المنتجات/الطلبات اليومية، وليس
 * العمليات الحسّاسة كتغيير الأدوار التي تبقى admin فقط). */
function assertIsAdminOrManager(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول.');
  }
  const role = context.auth.token.role;
  if (role !== 'admin' && role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'هذه العملية مخصصة للمدراء والمشرفين فقط.');
  }
}

/**
 * writeAuditLog — سجل تدقيق مركزي لكل عملية إدارية حساسة (من عدّل ماذا
 * ومتى). مجموعة `auditLogs` للقراءة من قبل المدير فقط (Firestore Rules)،
 * والكتابة فيها تتم فقط من الخادم (Cloud Functions / Admin SDK) — لا يمكن
 * للعميل تلفيق سجل تدقيق مزيّف عن نفسه أبداً.
 */
async function writeAuditLog({ action, targetType, targetId, actorUid, details }) {
  await db.collection('auditLogs').add({
    action,
    targetType,
    targetId,
    actorUid: actorUid || null,
    details: details || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * createOrder — نقطة الإنشاء الرسمية الوحيدة للطلبات.
 *
 * ⚠️ هذه الدالة هي إصلاح أمني جوهري: العميل (تطبيق الجوال) لا يُرسل السعر
 * الإجمالي إطلاقاً. يُرسل فقط قائمة (productId + quantity)، والخادم هو من:
 *   1. يجلب السعر الحقيقي الحالي لكل منتج من Firestore مباشرة (وليس مما
 *      يدّعيه العميل) — يمنع التلاعب بالسعر عبر تعديل الطلب الشبكي.
 *   2. يتحقق من وجود المنتج وتوفره في المخزون.
 *   3. يتحقق من صلاحية كود الخصم (إن وُجد) من مجموعة `coupons` في الخادم
 *      فقط — العميل لا يقرأ مجموعة الكوبونات مطلقاً (Firestore Rules تمنعه).
 *   4. يحسب الضريبة والإجمالي بنفسه، ثم يكتب المستند الرسمي للطلب.
 *
 * Firestore Rules تمنع أي كتابة مباشرة من العميل على مجموعة orders تماماً
 * (`allow create: if false`) — الطريق الوحيد لإنشاء طلب هو هذه الدالة.
 */
const TAX_RATE = 0.15;

exports.createOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول لإنشاء طلب.');
  }

  const { items, couponCode, address } = data;
  if (!Array.isArray(items) || items.length === 0 || items.length > 50) {
    throw new functions.https.HttpsError('invalid-argument', 'قائمة عناصر الطلب غير صالحة.');
  }
  // تنظيف بسيط للعنوان: نص فقط، بحد أقصى معقول للطول (يمنع إدخالات ضخمة
  // عبثية أو محاولات حقن بيانات كبيرة داخل المستند).
  const cleanAddress = typeof address === 'string' ? address.trim().slice(0, 300) : null;

  // 1) إعادة بناء كل عنصر من مصدر الحقيقة (Firestore)، وليس مما أرسله العميل.
  let subtotal = 0;
  const resolvedItems = [];
  for (const rawItem of items) {
    const productId = rawItem && rawItem.productId;
    const quantity = Number(rawItem && rawItem.quantity);
    if (!productId || !Number.isInteger(quantity) || quantity < 1 || quantity > 20) {
      throw new functions.https.HttpsError('invalid-argument', 'عنصر طلب غير صالح.');
    }

    const productSnap = await db.collection('products').doc(productId).get();
    if (!productSnap.exists) {
      throw new functions.https.HttpsError('not-found', `المنتج ${productId} غير موجود.`);
    }
    const product = productSnap.data();
    if (product.inStock === false) {
      throw new functions.https.HttpsError('failed-precondition', `المنتج "${product.name}" نفد من المخزون.`);
    }

    const unitPrice = typeof product.discountPrice === 'number' ? product.discountPrice : product.price;
    subtotal += unitPrice * quantity;
    resolvedItems.push({
      productId,
      name: product.name,
      imageUrl: product.imageUrl || '',
      unitPrice,
      quantity,
      selectedColor: rawItem.selectedColor || null,
    });
  }

  // 2) التحقق من الكوبون على الخادم فقط (العميل لا يعرف قيمة الخصم الحقيقية
  // ولا يقرأ مجموعة coupons إطلاقاً).
  let discount = 0;
  let appliedCouponCode = null;
  if (couponCode) {
    const couponSnap = await db.collection('coupons').doc(String(couponCode).toUpperCase()).get();
    if (couponSnap.exists) {
      const coupon = couponSnap.data();
      const notExpired = !coupon.expiresAt || coupon.expiresAt.toDate() > new Date();
      if (coupon.isActive && notExpired) {
        discount = subtotal * ((coupon.discountPercent || 0) / 100);
        appliedCouponCode = couponSnap.id;
      }
    }
    // كود غير صالح؟ نتجاهله بصمت (نفس سلوك عدم إدخال كود) بدل كشف السبب،
    // لمنع استكشاف الأكواد الصحيحة عبر تجربة قيم مختلفة (brute force).
  }

  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * TAX_RATE;
  const total = Math.round((taxableAmount + tax) * 100) / 100;

  // 3) كتابة المستند الرسمي — الخادم فقط، عبر Admin SDK (يتجاوز Firestore
  // Rules عمداً لأنه هو نفسه مصدر الفرض الأمني هنا).
  const orderRef = db.collection('orders').doc();
  const orderData = {
    userId: context.auth.uid,
    customerName: (context.auth.token.name || context.auth.token.email || '').toString(),
    items: resolvedItems,
    subtotal,
    discount,
    couponCode: appliedCouponCode,
    tax,
    total,
    address: cleanAddress,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await orderRef.set(orderData);

  return { orderId: orderRef.id, subtotal, discount, tax, total };
});

/**
 * setUserRole — الدالة الوحيدة المسموح لها بتعيين دور لمستخدم.
 * تُستدعى فقط من قبل مدير (admin) موجود مسبقاً — bootstrap أول admin يتم
 * عبر Firebase Admin SDK/console مباشرة، وليس عبر هذه الدالة.
 *
 * ثلاثة أدوار مدعومة الآن (نظام صلاحيات متعدد المستويات):
 *   - 'admin'   : كل الصلاحيات، بما فيها تعيين أدوار مستخدمين آخرين.
 *   - 'manager' : يدير المنتجات والطلبات والبانرات، لكن لا يستطيع تعيين
 *                 أدوار أو الوصول لإعدادات حسّاسة أخرى.
 *   - 'user'    : عميل عادي (الافتراضي).
 * فقط admin يستطيع استدعاء هذه الدالة أصلاً (assertIsAdmin) — حتى لو أراد
 * manager ترقية شخص آخر لـ manager، يُرفض طلبه هنا.
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  assertIsAdmin(context);

  const { uid, role } = data;
  if (!uid || !['admin', 'manager', 'user'].includes(role)) {
    throw new functions.https.HttpsError('invalid-argument', 'uid وrole (admin|manager|user) مطلوبان.');
  }

  await admin.auth().setCustomUserClaims(uid, { role });
  await db.collection('users').doc(uid).set({ roleUpdatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

  await writeAuditLog({
    action: 'role_changed',
    targetType: 'user',
    targetId: uid,
    actorUid: context.auth.uid,
    details: { newRole: role },
  });

  return { success: true };
});

/**
 * updateOrderStatus — تحديث حالة طلب من قبل مدير أو مشرف (admin/manager)،
 * مع تسجيل سجل تدقيق.
 */
exports.updateOrderStatus = functions.https.onCall(async (data, context) => {
  assertIsAdminOrManager(context);

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

  await writeAuditLog({
    action: 'order_status_changed',
    targetType: 'order',
    targetId: orderId,
    actorUid: context.auth.uid,
    details: { newStatus: status },
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

/**
 * onProductWrite — يسجّل تلقائياً في auditLogs كل إنشاء/تعديل/حذف لمنتج،
 * بصرف النظر عن كون الكتابة جاءت من شاشة "إضافة منتج" أو "تعديل منتج"
 * (كلاهما يكتب مباشرة على Firestore من العميل، وليس عبر Cloud Function
 * مخصصة). المصدر الوحيد لهوية الفاعل هنا هو حقل `updatedBy` الذي تفرضه
 * Firestore Rules أن يطابق دوماً uid المدير الحالي — لا يمكن انتحاله.
 */
exports.onProductWrite = functions.firestore
  .document('products/{productId}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const action = !before ? 'product_created' : !after ? 'product_deleted' : 'product_updated';
    const actorUid = (after && after.updatedBy) || (before && before.updatedBy) || null;

    await writeAuditLog({
      action,
      targetType: 'product',
      targetId: context.params.productId,
      actorUid,
      details: after ? { name: after.name, price: after.price } : null,
    });
  });
