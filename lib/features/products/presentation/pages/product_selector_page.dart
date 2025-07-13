// lib/features/products/presentation/pages/product_selector_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/products/presentation/providers/product_providers.dart';

class ProductSelectorPage extends ConsumerWidget {
  const ProductSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('اختر منتجًا')),
      // -- بداية الإضافة --
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/new'),
        label: const Text('إضافة منتج جديد'),
        icon: const Icon(Icons.add),
      ),
      // -- نهاية الإضافة --
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: searchQuery)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: searchQuery.length),
                ),
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
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('لا توجد منتجات تطابق البحث.'),
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
                      onTap: () {
                        // عند اختيار منتج، نرجع إلى الصفحة السابقة مع إرسال المنتج المختار
                        context.pop(product);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('حدث خطأ: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
