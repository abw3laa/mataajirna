import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_notification.dart';

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super([
          const AppNotification(
            id: 'n1',
            title: 'تم شحن طلبك!',
            body: 'طلبك رقم #45892 في طريقه إليك. يمكنك تتبع الشحنة من خلال صفحة تفاصيل الطلب.',
            type: NotificationType.shipping,
            timeAgo: 'منذ ٢ دقيقة',
            actionLabel: 'تتبع الطلب',
          ),
          const AppNotification(
            id: 'n2',
            title: 'عرض جديد متاح لك',
            body: 'استخدم الكود SAVE20 للحصول على خصم 20% على جميع المنتجات الإلكترونية. صالح لمدة 24 ساعة.',
            type: NotificationType.offer,
            timeAgo: 'منذ ١ ساعة',
            actionLabel: 'تسوق الآن',
          ),
          const AppNotification(
            id: 'n3',
            title: 'تحديث حالة الطلب',
            body: 'تم استلام طلبك رقم #45892 ويجري تجهيزه الآن.',
            type: NotificationType.orderUpdate,
            timeAgo: 'أمس',
            isRead: true,
          ),
          const AppNotification(
            id: 'n4',
            title: 'اكتمل تسجيل الدخول',
            body: 'تم تسجيل الدخول إلى حسابك من جهاز جديد (iPhone 14) في الرياض.',
            type: NotificationType.account,
            timeAgo: '٣ أيام',
            isRead: true,
          ),
        ]);

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
