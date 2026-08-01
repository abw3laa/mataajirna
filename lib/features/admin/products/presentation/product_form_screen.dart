import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/product.dart';
import '../../../catalog/presentation/catalog_providers.dart';

/// شاشة موحّدة للإضافة والتعديل. productId == null => إضافة منتج جديد.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  String? _categoryId;
  bool _inStock = true;
  bool _isSaving = false;
  bool _loaded = false;
  bool _isPickingImage = false;
  Uint8List? _pickedImageBytes;
  String? _uploadedImageUrl;
  String? _existingImageUrl;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEdit = widget.productId != null;

    if (isEdit && !_loaded) {
      final existingAsync =
          ref.watch(productDetailsProvider(widget.productId!));
      existingAsync.whenData((p) {
        if (p != null && !_loaded) {
          _nameController.text = p.name;
          _descController.text = p.description;
          _priceController.text = p.price.toStringAsFixed(0);
          _categoryId = p.categoryId;
          _inStock = p.inStock;
          _existingImageUrl = p.imageUrl;
          _loaded = true;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? t.editProfile : t.addNewProduct)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          children: [
            if (!isEdit) ...[
              Text(t.addNewProduct,
                  style: AppTextStyles.headlineMd(),
                  textAlign: TextAlign.right),
              const SizedBox(height: 4),
              Text(t.addNewProductSubtitle,
                  style:
                      AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.right),
              const SizedBox(height: AppSpacing.stackLg),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.basicInfo,
                        style: AppTextStyles.headlineSm(),
                        textAlign: TextAlign.right),
                    const SizedBox(height: AppSpacing.stackMd),
                    AppTextField(
                      label: t.productName,
                      hint: t.productNameHint,
                      controller: _nameController,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    AppTextField(
                      label: t.productDescription,
                      hint: t.productDescriptionHint,
                      controller: _descController,
                      maxLines: 4,
                      validator: Validators.description,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    Align(
                        alignment: Alignment.centerRight,
                        child:
                            Text(t.category, style: AppTextStyles.labelMd())),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        value: _categoryId,
                        hint: Text(t.selectCategory),
                        items: [
                          for (final c in categories)
                            DropdownMenuItem(value: c.id, child: Text(c.name))
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text(t.stockStatus,
                            style: AppTextStyles.labelMd())),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(t.outOfStock),
                        Radio<bool>(
                            value: false,
                            // ignore: deprecated_member_use
                            groupValue: _inStock,
                            // ignore: deprecated_member_use
                            onChanged: (v) => setState(() => _inStock = v!)),
                        Text(t.inStock),
                        Radio<bool>(
                            value: true,
                            // ignore: deprecated_member_use
                            groupValue: _inStock,
                            // ignore: deprecated_member_use
                            onChanged: (v) => setState(() => _inStock = v!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.productImage,
                        style: AppTextStyles.headlineSm(),
                        textAlign: TextAlign.right),
                    const SizedBox(height: AppSpacing.stackMd),
                    InkWell(
                      onTap: _isPickingImage ? null : _pickImage,
                      child: Container(
                        height: 140,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.outlineVariant, width: 1.5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: _isPickingImage
                            ? const Center(child: CircularProgressIndicator())
                            : _pickedImageBytes != null
                                ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover, width: double.infinity)
                                : _existingImageUrl != null
                                    ? Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity)
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_photo_alternate_outlined,
                                              size: 32, color: AppColors.outline),
                                          const SizedBox(height: 8),
                                          Text(t.uploadImageHint,
                                              style: AppTextStyles.bodyMd(
                                                  color: AppColors.onSurfaceVariant)),
                                          const SizedBox(height: 4),
                                          Text(t.uploadImageLimit,
                                              style: AppTextStyles.labelSm()),
                                        ],
                                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.pricing,
                        style: AppTextStyles.headlineSm(),
                        textAlign: TextAlign.right),
                    const SizedBox(height: AppSpacing.stackMd),
                    AppTextField(
                      label: t.basePrice,
                      hint: '0.00',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: Validators.price,
                    ),
                    const SizedBox(height: AppSpacing.stackLg),
                    AppTextField(
                      label: t.discountPercent,
                      hint: '0',
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      validator: Validators.discountPercent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Row(
              children: [
                Expanded(
                    child: SecondaryButton(
                        label: t.cancel, onPressed: () => context.pop())),
                const SizedBox(width: AppSpacing.stackMd),
                Expanded(
                  child: PrimaryButton(
                    label: t.save,
                    icon: Icons.save_outlined,
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.stackLg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final productId = widget.productId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final result = await ImageUploadService.pickCompressAndUpload(
        storagePath: 'products/$productId.jpg',
      );
      if (result != null) {
        setState(() {
          _pickedImageBytes = result.bytes;
          _uploadedImageUrl = result.downloadUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر رفع الصورة، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final price = double.parse(_priceController.text);
      final discountPercent = double.tryParse(_discountController.text) ?? 0;
      final discountPrice =
          discountPercent > 0 ? price * (1 - discountPercent / 100) : null;

      // أولوية رابط الصورة: (1) الرابط المرفوع فعلياً للتو، (2) رابط الصورة
      // الحالية إن كنا نعدّل منتجاً موجوداً ولم تُغيَّر صورته، (3) صورة
      // بديلة عشوائية فقط كملاذ أخير (منتج جديد بلا صورة مختارة).
      final imageUrl = _uploadedImageUrl ??
          _existingImageUrl ??
          'https://picsum.photos/seed/${_nameController.text.hashCode}/600';

      // ⚠️ استدعاء الكتابة هذا في الإنتاج يمر عبر Cloud Function/Firestore
      // ويُرفض من الخادم لأي مستخدم لا يحمل role == admin — بصرف النظر عن
      // وصول المستخدم لهذه الشاشة من عدمه على العميل.
      await ref.read(catalogRepositoryProvider).upsertProduct(
            Product(
              id: widget.productId ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              name: Validators.sanitize(_nameController.text),
              description: Validators.sanitize(_descController.text),
              price: price,
              discountPrice: discountPrice,
              categoryId: _categoryId ?? 'electronics',
              categoryName: _categoryId ?? '',
              imageUrl: imageUrl,
              inStock: _inStock,
            ),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
