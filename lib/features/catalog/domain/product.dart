import 'package:equatable/equatable.dart';
import '../../../core/widgets/status_badge.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price, // مخزّن دوماً بالريال السعودي (SAR) كعملة مرجعية
    this.discountPrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    this.gallery = const [],
    this.colors = const [],
    required this.inStock,
    this.badgeLabel,
    this.badgeTone = BadgeTone.primary,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final List<String> gallery;
  final List<String> colors;
  final bool inStock;
  final String? badgeLabel;
  final BadgeTone badgeTone;

  @override
  List<Object?> get props => [id, name, price, discountPrice, inStock];
}
