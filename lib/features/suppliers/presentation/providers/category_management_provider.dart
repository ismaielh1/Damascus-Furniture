// lib/features/suppliers/presentation/providers/category_management_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_category_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// لجلب قائمة التصنيفات
final supplierCategoriesManagementProvider =
    FutureProvider.autoDispose<List<SupplierCategoryModel>>((ref) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('supplier_categories')
            .select()
            .order('name');
        return response
            .map((item) => SupplierCategoryModel.fromJson(item))
            .toList();
      } catch (e) {
        debugPrint('Error fetching supplier categories: $e');
        rethrow;
      }
    });

// للتحكم في عمليات الإضافة والتعديل والحذف
final categoryManagementControllerProvider =
    StateNotifierProvider.autoDispose<CategoryManagementController, bool>((
      ref,
    ) {
      return CategoryManagementController(ref: ref);
    });

class CategoryManagementController extends StateNotifier<bool> {
  final Ref _ref;
  CategoryManagementController({required Ref ref}) : _ref = ref, super(false);

  Future<bool> _execute(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (state) return false;
    state = true;
    try {
      await action();
      // تحديث قائمة التصنيفات في هذه الواجهة وفي واجهة إضافة اتفاقية
      _ref.invalidate(supplierCategoriesManagementProvider);
      _ref.invalidate(supplierCategoriesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> addCategory({
    required BuildContext context,
    required String name,
    String? description,
  }) async {
    return _execute(context, () async {
      await _ref.read(supabaseProvider).from('supplier_categories').insert({
        'name': name,
        'description': description,
      });
    }, 'تمت إضافة التصنيف بنجاح');
  }

  Future<bool> updateCategory({
    required BuildContext context,
    required int id,
    required String name,
    String? description,
  }) async {
    return _execute(context, () async {
      await _ref
          .read(supabaseProvider)
          .from('supplier_categories')
          .update({'name': name, 'description': description})
          .eq('id', id);
    }, 'تم تحديث التصنيف بنجاح');
  }

  Future<bool> deleteCategory(BuildContext context, int id) async {
    return _execute(context, () async {
      await _ref
          .read(supabaseProvider)
          .from('supplier_categories')
          .delete()
          .eq('id', id);
    }, 'تم حذف التصنيف بنجاح');
  }
}
