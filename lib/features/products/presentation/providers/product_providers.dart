// lib/features/products/presentation/providers/product_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لحفظ نص البحث في صفحة المنتجات
final productSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

// Provider لجلب قائمة كل المنتجات مع البحث
final allProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);

  try {
    var query = supabase.from('products').select();

    if (searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,sku.ilike.%$searchQuery%');
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

// Provider للتحكم في عمليات إضافة وتعديل المنتجات
final productControllerProvider =
    StateNotifierProvider.autoDispose<ProductController, bool>((ref) {
      return ProductController(ref: ref);
    });

class ProductController extends StateNotifier<bool> {
  final Ref _ref;
  // --- ** بداية الإصلاح: تصحيح طريقة تهيئة المتغير ** ---
  ProductController({required Ref ref}) : _ref = ref, super(false);
  // --- ** نهاية الإصلاح ** ---

  // دالة لاستدعاء RPC لإضافة منتج جديد
  Future<bool> addProduct({
    required BuildContext context,
    required String name,
    required String supplierId,
    String? description,
    String? unitOfMeasure,
  }) async {
    state = true;
    try {
      await _ref
          .read(supabaseProvider)
          .rpc(
            'create_product_with_sku',
            params: {
              'product_name': name,
              'p_supplier_id': supplierId,
              'p_description': description,
              'p_unit_of_measure': unitOfMeasure,
            },
          );

      _ref.invalidate(allProductsProvider); // تحديث قائمة المنتجات
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
}
