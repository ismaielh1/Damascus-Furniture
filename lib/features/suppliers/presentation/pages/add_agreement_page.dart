// lib/features/suppliers/presentation/pages/add_agreement_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// --- بداية التعديل ---
// تم إضافة hide TextDirection لحل مشكلة التعارض
import 'package:intl/intl.dart' hide TextDirection;
// --- نهاية التعديل ---
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/add_item_dialog.dart';

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
      builder: (dialogContext) {
        final dialogFormKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final phoneController = TextEditingController();
        final addressController = TextEditingController();

        return AlertDialog(
          title: const Text('إضافة مورد جديد'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المورد'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'الحقل مطلوب' : null,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.left,
                  ),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(addSupplierControllerProvider);
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (dialogFormKey.currentState!.validate()) {
                            final newSupplier = await ref
                                .read(addSupplierControllerProvider.notifier)
                                .addSupplier(
                                  context: context,
                                  name: nameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  address: addressController.text.trim(),
                                  categoryId: selectedCategory.id,
                                );

                            if (newSupplier != null && mounted) {
                              setState(() => _selectedSupplier = newSupplier);
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _submitAgreement() {
    final agreementItems = ref.read(agreementFormProvider);
    final imagesToUpload = ref.read(pickedImagesProvider);

    if (_formKey.currentState!.validate() &&
        _selectedSupplier != null &&
        agreementItems.isNotEmpty) {
      ref
          .read(agreementControllerProvider.notifier)
          .createFullAgreement(
            context: context,
            supplierId: _selectedSupplier!.id,
            notes: _notesController.text.trim(),
            items: agreementItems,
            downPayment:
                double.tryParse(_downPaymentController.text.trim()) ?? 0.0,
            images: imagesToUpload,
          )
          .then((success) {
            if (success && mounted) {
              context.go('/supplier-agreements');
            }
          });
    } else if (agreementItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إضافة بند واحد على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addNewItem() {
    showDialog(context: context, builder: (_) => const AddItemDialog());
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(agreementFormProvider);
    final pickedImages = ref.watch(pickedImagesProvider);
    final grandTotal = ref.watch(agreementFormProvider.notifier).grandTotal;
    final isSaving = ref.watch(agreementControllerProvider);
    final theme = Theme.of(context);

    // محدد تنسيق الأرقام بالصيغة الإنجليزية
    final numberFormatter = NumberFormat("#,##0.00", "en_US");
    final integerFormatter = NumberFormat("0", "en_US");

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
                        DropdownButtonFormField<SupplierCategory>(
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
                  labelText: 'ملاحظات عامة',
                  hintText: 'أي تفاصيل إضافية عن الاتفاقية...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
                  FilledButton.icon(
                    onPressed: _addNewItem,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة بند'),
                  ),
                ],
              ),
              const Divider(),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('لم يتم إضافة أي بنود بعد.')),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            integerFormatter.format(index + 1),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: theme.primaryColor,
                        ),
                        title: Text(
                          item.itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            'Qty: ${integerFormatter.format(item.totalQuantity)} - Price: \$${numberFormatter.format(item.unitPrice)}',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '\$${numberFormatter.format(item.subtotal)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () => ref
                                  .read(agreementFormProvider.notifier)
                                  .removeItem(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المستندات المرفقة', style: theme.textTheme.titleLarge),
                  FilledButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('إضافة صور'),
                  ),
                ],
              ),
              const Divider(),
              if (pickedImages.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('لم يتم اختيار أي صور بعد.')),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pickedImages.length,
                    itemBuilder: (context, index) {
                      final imageFile = pickedImages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
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
                              top: -10,
                              right: -10,
                              child: IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 12,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(pickedImagesProvider.notifier)
                                      .update((state) {
                                        final newList = List<XFile>.from(state);
                                        newList.removeAt(index);
                                        return newList;
                                      });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(),
              TextFormField(
                controller: _downPaymentController,
                decoration: const InputDecoration(
                  labelText: 'العربون (دفعة أولى)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المجموع النهائي',
                      style: theme.textTheme.headlineSmall,
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '\$${numberFormatter.format(grandTotal)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submitAgreement,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('حفظ الاتفاقية النهائية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
