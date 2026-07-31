import 'package:equatable/equatable.dart';

class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.badgeLabel,
    required this.ctaLabel,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String badgeLabel;
  final String ctaLabel;
  final bool isActive;

  PromoBanner copyWith({String? title, String? badgeLabel, String? ctaLabel, bool? isActive}) {
    return PromoBanner(
      id: id,
      title: title ?? this.title,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, title, badgeLabel, ctaLabel, isActive];
}
