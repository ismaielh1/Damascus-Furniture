// lib/features/products/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/products/presentation/providers/product_providers.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('إدارة المنتجات (الكتالوج)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add),
        tooltip: 'إضافة منتج جديد',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: searchQuery),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الرمز (SKU)...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(productSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(allProductsProvider.future),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('لا توجد منتجات. قم بإضافة منتج جديد.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(product.sku)),
                        title: Text(product.name),
                        subtitle: Text('وحدة القياس: ${product.unitOfMeasure}'),
                        // onTap: () => context.push('/products/edit/${product.id}'), // للتعديل مستقبلاً
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('حدث خطأ: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
