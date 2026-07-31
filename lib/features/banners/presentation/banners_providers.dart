import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/banners_repository.dart';
import '../data/mock_banners_repository.dart';
import '../domain/promo_banner.dart';

final bannersRepositoryProvider = Provider<BannersRepository>((ref) => MockBannersRepository());

final activeBannersProvider = StreamProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannersRepositoryProvider).watchBanners();
});

final allBannersProvider = StreamProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannersRepositoryProvider).watchAllBanners();
});
