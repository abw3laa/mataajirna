import 'dart:async';
import '../domain/promo_banner.dart';
import 'banners_repository.dart';

class MockBannersRepository implements BannersRepository {
  final _controller = StreamController<List<PromoBanner>>.broadcast();

  final List<PromoBanner> _banners = [
    const PromoBanner(
      id: 'b1',
      title: 'خصم يصل إلى 50%\nعلى الإلكترونيات',
      badgeLabel: 'عرض خاص',
      ctaLabel: 'تسوق الآن',
    ),
  ];

  void _emit() => _controller.add(List.unmodifiable(_banners));

  @override
  Stream<List<PromoBanner>> watchBanners() async* {
    yield _banners.where((b) => b.isActive).toList();
    yield* _controller.stream.map((list) => list.where((b) => b.isActive).toList());
  }

  @override
  Stream<List<PromoBanner>> watchAllBanners() async* {
    yield _banners;
    yield* _controller.stream;
  }

  @override
  Future<void> upsertBanner(PromoBanner banner) async {
    final idx = _banners.indexWhere((b) => b.id == banner.id);
    if (idx == -1) {
      _banners.add(banner);
    } else {
      _banners[idx] = banner;
    }
    _emit();
  }

  @override
  Future<void> deleteBanner(String id) async {
    _banners.removeWhere((b) => b.id == id);
    _emit();
  }
}
