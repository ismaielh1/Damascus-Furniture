import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/categories/data/models/category_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase.from('supplier_categories').select().order('name');
  return response.map((item) => CategoryModel.fromJson(item)).toList();
});

final categoryControllerProvider = StateNotifierProvider.autoDispose<CategoryController, bool>((ref) {
  return CategoryController(ref: ref);
});

class CategoryController extends StateNotifier<bool> {
  final Ref ref;
  CategoryController({required this.ref}) : super(false);

  Future<bool> addCategory(BuildContext context, String name) async {
    state = true;
    try {
      await ref.read(supabaseProvider).from('supplier_categories').insert({'name': name});
      ref.invalidate(categoriesProvider);
      ref.invalidate(supplierCategoriesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة التصنيف بنجاح'), backgroundColor: Colors.green));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إضافة التصنيف: $e'), backgroundColor: Colors.red));
      }
      return false;
    } finally {
      state = false;
    }
  }
}
