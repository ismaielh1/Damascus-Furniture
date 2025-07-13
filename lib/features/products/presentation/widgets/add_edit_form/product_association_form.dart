// lib/features/products/presentation/widgets/add_edit_form/product_association_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/categories/data/models/category_model.dart';
import 'package:syria_store/features/categories/presentation/dialogs/add_edit_category_dialog.dart';
import 'package:syria_store/features/categories/presentation/providers/category_provider.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_supplier_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_list_provider.dart';

class ProductAssociationForm extends ConsumerWidget {
  final CategoryModel? selectedCategory;
  final Supplier? selectedSupplier;
  final ValueChanged<CategoryModel?> onCategoryChanged;
  final ValueChanged<Supplier?> onSupplierChanged;

  const ProductAssociationForm({
    super.key,
    required this.selectedCategory,
    required this.selectedSupplier,
    required this.onCategoryChanged,
    required this.onSupplierChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSuppliersAsync = ref.watch(allSuppliersProvider);
    final allCategoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        // Dropdown for Categories
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: allCategoriesAsync.when(
                data: (categories) => DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  hint: const Text('اختر التصنيف'),
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: onCategoryChanged,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('خطأ: $e'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => showDialog(context: context, builder: (_) => const AddEditCategoryDialog()),
              tooltip: 'إضافة تصنيف جديد',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dropdown for Suppliers
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: allSuppliersAsync.when(
                data: (suppliers) => DropdownButtonFormField<Supplier>(
                  value: selectedSupplier,
                  hint: const Text('اختر المورد الافتراضي'),
                  decoration: const InputDecoration(labelText: 'المورد (لإنشاء الرمز)'),
                  items: suppliers.map((s) => DropdownMenuItem(value: Supplier(id: s.id, name: s.name), child: Text(s.name))).toList(),
                  onChanged: onSupplierChanged,
                  validator: (value) => value == null ? 'يجب اختيار مورد افتراضي' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('خطأ في جلب الموردين: $e'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddSupplierDialog(selectedCategoryId: selectedCategory?.id),
              ),
              tooltip: 'إضافة مورد جديد',
            ),
          ],
        ),
      ],
    );
  }
}
