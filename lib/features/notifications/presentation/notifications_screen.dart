import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';
import 'notifications_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final isGuest = ref.watch(authStateProvider).value == null;

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: Text(t.appName)),
        body: EmptyView(
          title: t.guestNotificationsTitle,
          icon: Icons.notifications_none_rounded,
          action: PrimaryButton(label: t.login, onPressed: () => context.push('/login'), expand: false),
        ),
      );
    }

    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: notifications.isEmpty
          ? EmptyView(title: t.noNotifications, icon: Icons.notifications_none_rounded)
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                      child: Text(t.markAllRead),
                    ),
                    const Spacer(),
                    Text(t.notifications, style: AppTextStyles.displayLg(), textAlign: TextAlign.right),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackLg),
                for (final n in notifications)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border(
                        right: BorderSide(color: n.isRead ? Colors.transparent : AppColors.primary, width: 4),
                      ),
                      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.secondaryContainer,
                          child: Icon(n.icon, color: AppColors.onSecondaryContainer, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.stackMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(n.timeAgo, style: AppTextStyles.labelSm()),
                                  const Spacer(),
                                  Text(n.title,
                                      style: AppTextStyles.bodyMd().copyWith(fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.right),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(n.body, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant), textAlign: TextAlign.right),
                              if (n.actionLabel != null) ...[
                                const SizedBox(height: AppSpacing.stackSm),
                                OutlinedButton(onPressed: () {}, child: Text(n.actionLabel!)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
