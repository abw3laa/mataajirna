import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/developer_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/${DeveloperInfo.whatsappNumber}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Text('متجرنا', style: AppTextStyles.headlineMd()),
                const SizedBox(height: 4),
                Text('الإصدار 1.0.0', style: AppTextStyles.labelMd()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          const SizedBox(height: AppSpacing.stackLg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          DeveloperInfo.name.isNotEmpty ? DeveloperInfo.name[0] : '؟',
                          style: AppTextStyles.headlineSm(color: AppColors.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.stackMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DeveloperInfo.name, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                            Text(DeveloperInfo.role, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant), textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Text(DeveloperInfo.bio, style: AppTextStyles.bodyMd(), textAlign: TextAlign.right),
                  const SizedBox(height: AppSpacing.stackLg),
                  ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('تواصل عبر واتساب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Center(
            child: Text(
              'صُنع بحب من أجل تجربة عربية أصيلة 🌿',
              style: AppTextStyles.labelSm(),
            ),
          ),
        ],
      ),
    );
  }
}
