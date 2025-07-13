// lib/features/suppliers/presentation/pages/manage_supplier_categories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_category_model.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_edit_category_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/category_management_provider.dart';

class ManageSupplierCategoriesPage extends ConsumerWidget {
  const ManageSupplierCategoriesPage({super.key});

  void _showAddEditDialog(
    BuildContext context, [
    SupplierCategoryModel? category,
  ]) {
    showDialog(
      context: context,
      builder: (_) => AddEditCategoryDialog(category: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(supplierCategoriesManagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة تصنيفات الموردين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'إضافة تصنيف جديد',
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(supplierCategoriesManagementProvider.future),
        child: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const Center(
                child: Text('لا توجد تصنيفات. قم بإضافة تصنيف جديد.'),
              );
            }
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(category.description ?? 'لا يوجد وصف'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: () =>
                              _showAddEditDialog(context, category),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () async {
                            final confirm =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: Text(
                                      'هل أنت متأكد من رغبتك في حذف تصنيف "${category.name}"؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (confirm) {
                              ref
                                  .read(
                                    categoryManagementControllerProvider
                                        .notifier,
                                  )
                                  .deleteCategory(context, category.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }
}
