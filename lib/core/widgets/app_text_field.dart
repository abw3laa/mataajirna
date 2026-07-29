import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelMd()),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          style: AppTextStyles.bodyMd(),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: hint,
            // في RTL فإن prefixIcon يظهر تلقائياً في جهة البداية (اليمين بصرياً)،
            // مطابقاً لأيقونة المستخدم/القفل الظاهرة يمين حقول تسجيل الدخول في التصميم.
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : suffixIcon,
          ),
        ),
      ],
    );
  }
}
