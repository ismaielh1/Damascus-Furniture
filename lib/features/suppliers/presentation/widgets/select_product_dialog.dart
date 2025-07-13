// lib/features/suppliers/presentation/widgets/select_product_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // استيراد go_router
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/products/presentation/providers/product_providers.dart';

class SelectProductDialog extends ConsumerWidget {
  const SelectProductDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    return AlertDialog(
      title: const Text('اختر منتجًا من الكتالوج'),
      // نجعل المحتوى كبيرًا ليناسب البحث والقائمة
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                // نستخدم controller مؤقت هنا أو نعتمد على إعادة البناء
                controller: TextEditingController(text: searchQuery)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: searchQuery.length),
                  ),
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو الرمز (SKU)...',
                  prefixIcon: Icon(Icons.search),
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
                      child: Text('لا توجد منتجات تطابق هذا البحث.'),
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
                          // عند اختيار منتج، يتم إغلاق الواجهة وإرجاع المنتج المختار
                          Navigator.of(context).pop(product);
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
      ),
      actions: [
        // --- بداية الإضافة ---
        // زر لإضافة منتج جديد مباشرة من هذه الواجهة
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('إضافة منتج جديد'),
          onPressed: () {
            // الانتقال إلى صفحة إضافة المنتج
            context.push('/products/new');
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
        ),
        // --- نهاية الإضافة ---
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
