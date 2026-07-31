import '../../../core/widgets/status_badge.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import 'catalog_repository.dart';

class MockCatalogRepository implements CatalogRepository {
  final _categories = <ProductCategory>[
    const ProductCategory(
        id: 'electronics',
        name: 'الإلكترونيات',
        imageUrl: 'https://picsum.photos/seed/electronics/200'),
    const ProductCategory(
        id: 'fashion',
        name: 'الأزياء',
        imageUrl: 'https://picsum.photos/seed/fashion/200'),
    const ProductCategory(
        id: 'home',
        name: 'المنزل',
        imageUrl: 'https://picsum.photos/seed/home/200'),
    const ProductCategory(
        id: 'perfumes',
        name: 'عطور',
        imageUrl: 'https://picsum.photos/seed/perfumes/200'),
  ];

  late final List<Product> _products = [
    const Product(
      id: 'p1',
      name: 'عطر خشبي للرجال - 100 مل',
      description: 'عطر خشبي فاخر بثبات عالٍ ورائحة دافئة تدوم طوال اليوم.',
      price: 300,
      discountPrice: 250,
      categoryId: 'perfumes',
      categoryName: 'عطور',
      imageUrl: 'https://picsum.photos/seed/perfume1/600',
      inStock: true,
      badgeLabel: 'خصم',
      badgeTone: BadgeTone.accent,
    ),
    const Product(
      id: 'p2',
      name: 'سماعات رأس لاسلكية بخاصية إلغاء الضوضاء',
      description:
          'سماعات لاسلكية بجودة صوت استثنائية وعزل ضوضاء نشط لمدة استماع تصل إلى 30 ساعة.',
      price: 499,
      categoryId: 'electronics',
      categoryName: 'إلكترونيات',
      imageUrl: 'https://picsum.photos/seed/headphones1/600',
      inStock: true,
      badgeLabel: 'جديد',
      badgeTone: BadgeTone.primary,
    ),
    const Product(
      id: 'p3',
      name: 'طقم أكواب قهوة سيراميك فاخر',
      description:
          'طقم مكوّن من 6 أكواب سيراميك بتصميم أنيق مناسب للاستخدام اليومي والضيافة.',
      price: 120,
      categoryId: 'home',
      categoryName: 'المنزل',
      imageUrl: 'https://picsum.photos/seed/cups1/600',
      inStock: true,
    ),
    const Product(
      id: 'p4',
      name: 'ساعة ذكية متقدمة مع تتبع اللياقة',
      description:
          'ساعة ذكية بشاشة AMOLED ومستشعرات صحية متكاملة ومقاومة للماء.',
      price: 899,
      discountPrice: 719,
      categoryId: 'electronics',
      categoryName: 'إلكترونيات',
      imageUrl: 'https://picsum.photos/seed/watch1/600',
      inStock: true,
      badgeLabel: 'خصم 20%',
      badgeTone: BadgeTone.accent,
    ),
    const Product(
      id: 'p5',
      name: 'لابتوب ألترا بوك 14 بوصة معالج i7',
      description: 'أداء قوي وتصميم رفيع مثالي للعمل والإبداع أثناء التنقل.',
      price: 5200,
      categoryId: 'electronics',
      categoryName: 'لابتوبات',
      imageUrl: 'https://picsum.photos/seed/laptop1/600',
      inStock: true,
      badgeLabel: 'خصم 15%',
      badgeTone: BadgeTone.accent,
    ),
    const Product(
      id: 'p6',
      name: 'هاتف ذكي برو ماكس 256 جيجابايت',
      description: 'كاميرا احترافية وأداء فائق مع شاشة عرض متطورة.',
      price: 4500,
      discountPrice: 3999,
      categoryId: 'electronics',
      categoryName: 'جوالات',
      imageUrl: 'https://picsum.photos/seed/phone1/600',
      inStock: true,
      badgeLabel: 'جديد',
    ),
    const Product(
      id: 'p7',
      name: 'ساعة ذكية رياضية الجيل الثامن',
      description: 'مصممة للرياضيين مع تتبع دقيق لجميع الأنشطة البدنية.',
      price: 1200,
      categoryId: 'electronics',
      categoryName: 'ساعات ذكية',
      imageUrl: 'https://picsum.photos/seed/watch2/600',
      inStock: false,
      badgeLabel: 'نفد المخزون',
      badgeTone: BadgeTone.neutral,
    ),
    const Product(
      id: 'p8',
      name: 'سماعات رأس لاسلكية عازلة للضوضاء',
      description: 'راحة فائقة لجلسات الاستماع الطويلة مع صوت نقي ومتوازن.',
      price: 850,
      categoryId: 'electronics',
      categoryName: 'سماعات',
      imageUrl: 'https://picsum.photos/seed/headphones2/600',
      inStock: true,
    ),
    const Product(
      id: 'p9',
      name: 'حقيبة جلدية فاخرة',
      description:
          'صُنعت هذه الحقيبة من أجود أنواع الجلد الطبيعي، مصممة لتلبي احتياجاتك اليومية مع الحفاظ على مظهرك الأنيق. تحتوي على جيوب داخلية متعددة لتنظيم أغراضك بسهولة، وحزام كتف قابل للتعديل لراحة قصوى.',
      price: 550,
      discountPrice: 450,
      categoryId: 'fashion',
      categoryName: 'حقائب',
      imageUrl: 'https://picsum.photos/seed/bag1/600',
      gallery: [
        'https://picsum.photos/seed/bag1/600',
        'https://picsum.photos/seed/bag1b/600',
        'https://picsum.photos/seed/bag1c/600',
      ],
      colors: ['#C9A876', '#1A1C1D', '#7A4B26'],
      inStock: true,
      badgeLabel: 'جديد',
      badgeTone: BadgeTone.success,
    ),
    const Product(
      id: 'p10',
      name: 'نظارات شمسية كلاسيكية',
      description: 'حماية كاملة من الأشعة فوق البنفسجية بتصميم أنيق خالد.',
      price: 300,
      categoryId: 'fashion',
      categoryName: 'إكسسوارات',
      imageUrl: 'https://picsum.photos/seed/sunglasses1/600',
      inStock: true,
    ),
    const Product(
      id: 'p11',
      name: 'محفظة جلدية',
      description: 'محفظة جلد طبيعي أنيقة بعدة جيوب لحفظ البطاقات والنقود.',
      price: 120,
      categoryId: 'fashion',
      categoryName: 'إكسسوارات',
      imageUrl: 'https://picsum.photos/seed/wallet1/600',
      inStock: true,
    ),
  ];

  @override
  Stream<List<ProductCategory>> watchCategories() => Stream.value(_categories);

  @override
  Stream<List<Product>> watchProducts({String? categoryId, String? query}) {
    var list = _products.toList();
    if (categoryId != null && categoryId != 'all') {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      list = list
          .where((p) => p.name.contains(q) || p.description.contains(q))
          .toList();
    }
    return Stream.value(list);
  }

  @override
  Future<Product?> getProduct(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertProduct(Product product) async {
    // ⚠️ هذا مسموح هنا فقط لأنه Mock للتطوير. في الإنتاج هذا الاستدعاء
    // يذهب عبر Cloud Function/Firestore ويُرفض من الخادم إن لم يكن
    // المستخدم يحمل role == admin ضمن الـ ID Token الخاص به.
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx == -1) {
      _products.add(product);
    } else {
      _products[idx] = product;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }
}
