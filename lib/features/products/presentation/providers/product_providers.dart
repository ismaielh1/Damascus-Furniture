// lib/features/products/presentation/providers/product_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final productSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final allProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);

  try {
    var query = supabase.from('products').select('*, contacts(name)');

    if (searchQuery.isNotEmpty) {
      // -- بداية التعديل: لدعم البحث ببداية الكلمة --

      // 1. تقسيم النص إلى كلمات
      final terms = searchQuery
          .trim()
          .split(' ')
          .where((s) => s.isNotEmpty)
          .toList();

      if (terms.isNotEmpty) {
        // 2. إضافة علامة البحث بالبداية ":*" إلى آخر كلمة فقط
        terms[terms.length - 1] = '${terms.last}:*';

        // 3. تجميع الكلمات من جديد
        // مثال: "طاولة خش" -> "طاولة & خش:*"
        final formattedQuery = terms.join(' & ');

        // 4. تنفيذ البحث
        query = query.textSearch('fts', formattedQuery, config: 'simple');
      }
      // -- نهاية التعديل --
    }

    final response = await query.order('created_at', ascending: false);
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response,
    );
    return data.map((item) => ProductModel.fromJson(item)).toList();
  } catch (e) {
    debugPrint('Error fetching products: $e');
    rethrow;
  }
});

final productDetailsProvider = FutureProvider.autoDispose
    .family<ProductModel?, String>((ref, productId) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('products')
            .select('*, contacts(name)')
            .eq('id', productId)
            .single();
        return ProductModel.fromJson(response);
      } catch (e) {
        debugPrint('Error fetching product details: $e');
        return null;
      }
    });

final productControllerProvider =
    StateNotifierProvider.autoDispose<ProductController, bool>((ref) {
      return ProductController(ref: ref);
    });

class ProductController extends StateNotifier<bool> {
  final Ref ref;
  ProductController({required this.ref}) : super(false);

  Future<bool> addProduct({
    required BuildContext context,
    required String name,
    required String contactId,
    String? description,
    String? unitOfMeasure,
  }) async {
    state = true;
    try {
      await ref
          .read(supabaseProvider)
          .rpc(
            'create_product_with_sku',
            params: {
              'product_name': name,
              'p_default_contact_id': contactId,
              'p_description': description,
              'p_unit_of_measure': unitOfMeasure,
            },
          );
      ref.invalidate(allProductsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة المنتج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> updateProduct({
    required BuildContext context,
    required String productId,
    required String name,
    String? description,
    String? unitOfMeasure,
  }) async {
    state = true;
    try {
      await ref
          .read(supabaseProvider)
          .rpc(
            'update_product',
            params: {
              'p_id': productId,
              'p_name': name,
              'p_description': description,
              'p_unit_of_measure': unitOfMeasure,
            },
          );
      ref.invalidate(allProductsProvider);
      ref.invalidate(productDetailsProvider(productId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المنتج بنجاح'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث المنتج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }
}
