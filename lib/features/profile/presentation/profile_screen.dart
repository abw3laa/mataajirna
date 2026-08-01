import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/app_currency.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          if (user == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person_outline_rounded, size: 32, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(t.guestProfileTitle, style: AppTextStyles.headlineSm(), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(
                      t.guestProfileSubtitle,
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: Text(t.login),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: Text(t.createAccount),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : '؟',
                        style: AppTextStyles.headlineMd(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(user.name, style: AppTextStyles.headlineSm()),
                    const SizedBox(height: 4),
                    Text(user.email, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.stackMd),
                    OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)), child: Text(t.editProfile)),
                  ],
                ),
              ),
            ),
          if (user != null) ...[
            const SizedBox(height: AppSpacing.stackLg),
            Card(
              child: Column(
                children: [
                  _tile(context, icon: Icons.location_on_outlined, label: t.savedAddresses, onTap: () {}),
                  const Divider(height: 1),
                  _tile(context, icon: Icons.help_outline_rounded, label: t.helpCenter, onTap: () {}),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.stackLg),
          Card(
            child: _tile(context, icon: Icons.info_outline_rounded, label: 'عن التطبيق', onTap: () => context.push('/about')),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.appSettings, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      DropdownButton<Locale>(
                        value: locale,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final l in supportedLocales)
                            DropdownMenuItem(value: l, child: Text(l.displayLabel)),
                        ],
                        onChanged: (v) {
                          if (v != null) ref.read(localeProvider.notifier).setLocale(v);
                        },
                      ),
                      const Spacer(),
                      Text(t.language, style: AppTextStyles.labelMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      DropdownButton<AppCurrency>(
                        value: currency,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final c in AppCurrency.values)
                            DropdownMenuItem(value: c, child: Text('${c.arabicName} (${c.symbol})')),
                        ],
                        onChanged: (v) {
                          if (v != null) ref.read(currencyProvider.notifier).setCurrency(v);
                        },
                      ),
                      const Spacer(),
                      Text(t.currency, style: AppTextStyles.labelMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    children: [
                      DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: ThemeMode.system, child: Text('حسب النظام')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('فاتح')),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('داكن')),
                        ],
                        onChanged: (v) {
                          if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v);
                        },
                      ),
                      const Spacer(),
                      const Text('المظهر', style: AppTextStyles.labelMd()),
                    ],
                  ),
                ],
              ),
            ),
          ),
            Card(
              child: ListTile(
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/home');
                },
                leading: const CircleAvatar(
                  backgroundColor: AppColors.errorContainer,
                  child: Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                ),
                title: Text(t.logout, style: AppTextStyles.bodyMd(color: AppColors.error), textAlign: TextAlign.right),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.chevron_left_rounded, color: AppColors.outline),
      title: Text(label, textAlign: TextAlign.right),
      trailing: CircleAvatar(backgroundColor: AppColors.surfaceContainer, child: Icon(icon, size: 18, color: AppColors.primary)),
    );
  }
}
