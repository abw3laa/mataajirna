import '../domain/promo_banner.dart';

abstract class BannersRepository {
  /// البانرات النشطة فقط — تُستخدم في واجهة المستخدم (الرئيسية).
  Stream<List<PromoBanner>> watchBanners();

  /// كل البانرات بما فيها غير النشطة — لشاشة إدارة البانرات في لوحة التحكم.
  Stream<List<PromoBanner>> watchAllBanners();

  /// كتابة تُقبل من الخادم للمدير فقط (Firestore Rules)، تماماً كباقي
  /// عمليات إدارة الكتالوج.
  Future<void> upsertBanner(PromoBanner banner);
  Future<void> deleteBanner(String id);
}
