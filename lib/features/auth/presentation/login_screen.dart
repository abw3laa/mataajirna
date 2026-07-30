import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/remember_me_store.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(
            emailOrPhone: _emailController.text,
            password: _passwordController.text,
          );
      await RememberMeStore.setRememberMe(_rememberMe);
      if (!mounted) return;
      // إن وصل المستخدم لهذه الشاشة أثناء محاولة إجراء محمي (كإتمام الطلب)،
      // نعيده لنفس الوجهة بدل التوجيه الافتراضي فقط.
      final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
      if (redirect != null && redirect.isNotEmpty) {
        context.go(redirect);
      }
      // إن لم يوجد مسار عودة، يتولى go_router redirect التوجيه تلقائياً
      // (رئيسية للمستخدم العادي، لوحة التحكم للمدير).
    } catch (e) {
      setState(() => _error = 'تعذّر تسجيل الدخول، تحقق من البيانات وحاول مجدداً');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // يسمح للمتصفّح كضيف بالتراجع دون إجبار على تسجيل الدخول.
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'متابعة كضيف',
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(t.welcomeBack, style: AppTextStyles.displayLg(), textAlign: TextAlign.right),
                const SizedBox(height: 8),
                Text(t.loginSubtitle, style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant), textAlign: TextAlign.right),
                const SizedBox(height: 32),
                AppTextField(
                  label: t.emailOrPhone,
                  hint: t.emailOrPhoneHint,
                  controller: _emailController,
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.password, style: AppTextStyles.labelMd()),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text(t.forgotPassword, style: AppTextStyles.labelMd(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور قصيرة جداً' : null,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(t.rememberMe, style: AppTextStyles.bodyMd()),
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(_error!, style: AppTextStyles.labelMd(color: AppColors.error)),
                ],
                const SizedBox(height: 16),
                PrimaryButton(label: t.login, onPressed: _submit, isLoading: _isLoading),
                const SizedBox(height: 24),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.or, style: AppTextStyles.labelMd()),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.noAccount, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(t.createAccount, style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
