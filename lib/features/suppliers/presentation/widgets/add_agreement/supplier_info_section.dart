// lib/features/suppliers/presentation/widgets/add_agreement/supplier_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/categories/data/models/category_model.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_supplier_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

class SupplierInfoSection extends ConsumerWidget {
  final Supplier? selectedSupplier;
  final ValueChanged<Supplier?> onSupplierChanged;
  final VoidCallback onAddSupplier;

  const SupplierInfoSection({
    super.key,
    required this.selectedSupplier,
    required this.onSupplierChanged,
    required this.onAddSupplier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(supplierCategoriesProvider);
    final suppliersAsync = ref.watch(suppliersByCategoryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلومات الاتفاقية الأساسية', style: theme.textTheme.titleLarge),
        const Divider(),
        const SizedBox(height: 8),
        categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<CategoryModel>(
            hint: const Text('اختر تصنيف المورد'),
            decoration: const InputDecoration(labelText: 'التصنيف'),
            value: selectedCategory,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (category) {
              ref.read(selectedCategoryProvider.notifier).state = category;
              onSupplierChanged(null); // Reset supplier when category changes
            },
            validator: (value) => value == null ? 'الرجاء اختيار تصنيف' : null,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => Text('خطأ: $err'),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: suppliersAsync.when(
                data: (suppliers) {
                  return DropdownButtonFormField<Supplier>(
                    value: selectedSupplier,
                    hint: const Text('اختر المورد'),
                    decoration: InputDecoration(
                      labelText: 'المورد',
                      enabled: selectedCategory != null,
                    ),
                    items: suppliers
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        )
                        .toList(),
                    onChanged: onSupplierChanged,
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
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: onAddSupplier,
              tooltip: 'إضافة مورد جديد',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
