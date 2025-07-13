// lib/features/suppliers/presentation/pages/add_agreement_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syria_store/features/categories/data/models/category_model.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_agreement_item_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_supplier_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

final pickedImagesProvider = StateProvider.autoDispose<List<XFile>>(
  (ref) => [],
);

class AddAgreementPage extends ConsumerStatefulWidget {
  const AddAgreementPage({super.key});
  @override
  ConsumerState<AddAgreementPage> createState() => _AddAgreementPageState();
}

class _AddAgreementPageState extends ConsumerState<AddAgreementPage> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  final _notesController = TextEditingController();
  final _downPaymentController = TextEditingController();
  @override
  void dispose() {
    _notesController.dispose();
    _downPaymentController.dispose();
    Future.microtask(() {
      ref.invalidate(agreementFormProvider);
      ref.invalidate(pickedImagesProvider);
    });
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final newImages = await picker.pickMultiImage(imageQuality: 70);
    if (newImages.isNotEmpty) {
      ref
          .read(pickedImagesProvider.notifier)
          .update((state) => [...state, ...newImages]);
    }
  }

  void _showAddSupplierDialog() {
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار تصنيف أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) =>
          AddSupplierDialog(selectedCategoryId: selectedCategory.id),
    );
  }

  Future<void> _selectAndAddItem() async {
    final selectedProduct = await context.push<ProductModel>(
      '/products/select',
    );
    if (selectedProduct != null && mounted) {
      showDialog(
        context: context,
        builder: (_) => AddAgreementItemDialog(product: selectedProduct),
      );
    }
  }

  void _submitAgreement() {
    if (_formKey.currentState!.validate() &&
        _selectedSupplier != null &&
        ref.read(agreementFormProvider).isNotEmpty) {
      ref
          .read(agreementControllerProvider.notifier)
          .createFullAgreement(
            context: context,
            contactId: _selectedSupplier!.id, // تم التغيير من supplierId
            notes: _notesController.text.trim(),
            items: ref.read(agreementFormProvider),
            downPayment:
                double.tryParse(_downPaymentController.text.trim()) ?? 0,
            images: ref.read(pickedImagesProvider),
          )
          .then((success) {
            if (success && mounted) {
              context.pop();
            }
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء التأكد من اختيار مورد وإضافة بند واحد على الأقل.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(agreementFormProvider);
    final pickedImages = ref.watch(pickedImagesProvider);
    final grandTotal = ref.watch(agreementFormProvider.notifier).grandTotal;
    final isSaving = ref.watch(agreementControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء اتفاقية توريد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات الاتفاقية الأساسية',
                style: theme.textTheme.titleLarge,
              ),
              const Divider(),
              const SizedBox(height: 8),

              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(supplierCategoriesProvider);
                  return categoriesAsync.when(
                    data: (categories) =>
                        DropdownButtonFormField<CategoryModel>(
                          hint: const Text('اختر تصنيف المورد'),
                          decoration: const InputDecoration(
                            labelText: 'التصنيف',
                          ),
                          value: ref.watch(selectedCategoryProvider),
                          items: categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (category) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                category;
                            setState(() => _selectedSupplier = null);
                          },
                          validator: (value) =>
                              value == null ? 'الرجاء اختيار تصنيف' : null,
                        ),
                    loading: () => const Text("جاري تحميل التصنيفات..."),
                    error: (err, stack) => Text('خطأ: $err'),
                  );
                },
              ),

              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final suppliersAsync = ref.watch(
                          suppliersByCategoryProvider,
                        );
                        final selectedCategory = ref.watch(
                          selectedCategoryProvider,
                        );
                        return suppliersAsync.when(
                          data: (suppliers) {
                            final isSelectedSupplierInList = suppliers.any(
                              (s) => s.id == _selectedSupplier?.id,
                            );
                            final currentValue = isSelectedSupplierInList
                                ? _selectedSupplier
                                : null;

                            return DropdownButtonFormField<Supplier>(
                              value: currentValue,
                              hint: const Text('اختر المورد'),
                              decoration: InputDecoration(
                                labelText: 'المورد',
                                enabled: selectedCategory != null,
                              ),
                              items: suppliers
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (supplier) =>
                                  setState(() => _selectedSupplier = supplier),
                              validator: (value) =>
                                  (selectedCategory != null && value == null)
                                  ? 'الرجاء اختيار مورد'
                                  : null,
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: LinearProgressIndicator()),
                          ),
                          error: (err, stack) => Text('خطأ: $err'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddSupplierDialog,
                    tooltip: 'إضافة مورد جديد',
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات الاتفاقية',
                ),
                maxLines: 4,
              ),

              const Divider(height: 32),
              Text('المستندات والصور', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),

              if (pickedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pickedImages.length,
                    itemBuilder: (context, index) {
                      final imageFile = pickedImages[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      imageFile.path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(imageFile.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black.withOpacity(0.6),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(pickedImagesProvider.notifier)
                                        .update((state) {
                                          final newList = List.of(state);
                                          newList.removeAt(index);
                                          return newList;
                                        });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.attach_file),
                label: const Text('إرفاق مستندات أو صور'),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
                  FilledButton.icon(
                    onPressed: _selectAndAddItem,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('إضافة بند'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('لم يتم إضافة أي بنود بعد.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.product?.name ?? 'منتج غير معرف'),
                        subtitle: Text(
                          'الكمية: ${item.totalQuantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                              ),
                              onPressed: () => ref
                                  .read(agreementFormProvider.notifier)
                                  .removeItem(item.id.toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              const Divider(height: 32),

              Text('الملخص المالي', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),

              TextFormField(
                controller: _downPaymentController,
                decoration: const InputDecoration(
                  labelText: 'الدفعة المقدمة (اختياري)',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'المجموع الإجمالي للبنود',
                  style: theme.textTheme.titleMedium,
                ),
                trailing: Text(
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submitAgreement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('حفظ الاتفاقية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
