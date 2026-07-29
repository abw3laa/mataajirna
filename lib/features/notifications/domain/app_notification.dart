import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationType { shipping, offer, orderUpdate, account }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String timeAgo;
  final bool isRead;
  final String? actionLabel;

  IconData get icon => switch (type) {
        NotificationType.shipping => Icons.local_shipping_outlined,
        NotificationType.offer => Icons.percent_rounded,
        NotificationType.orderUpdate => Icons.assignment_turned_in_outlined,
        NotificationType.account => Icons.person_outline_rounded,
      };

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timeAgo: timeAgo,
        isRead: isRead ?? this.isRead,
        actionLabel: actionLabel,
      );

  @override
  List<Object?> get props => [id, isRead];
}
