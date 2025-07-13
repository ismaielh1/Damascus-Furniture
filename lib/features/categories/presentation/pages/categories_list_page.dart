// lib/features/categories/presentation/pages/categories_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/categories/presentation/dialogs/add_edit_category_dialog.dart';
import 'package:syria_store/features/categories/presentation/providers/category_provider.dart';

class CategoriesListPage extends ConsumerWidget {
  const CategoriesListPage({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddEditCategoryDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        // -- بداية الإضافة --
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // -- نهاية الإضافة --
        title: const Text('إدارة التصنيفات'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'إضافة تصنيف جديد',
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(categoriesProvider.future),
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
                return ListTile(
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade700,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('حدث خطأ: $e')),
        ),
      ),
    );
  }
}
