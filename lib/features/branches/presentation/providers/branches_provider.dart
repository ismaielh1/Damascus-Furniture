// lib/features/branches/presentation/providers/branches_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/branches/data/models/branch_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لجلب كل الفروع
final branchesProvider = FutureProvider.autoDispose<List<BranchModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  // الترتيب لإظهار الفرع الرئيسي أولاً
  final response = await supabase
      .from('branches')
      .select()
      .order('is_main', ascending: false)
      .order('created_at');
  return response.map((item) => BranchModel.fromJson(item)).toList();
});

// Provider للتحكم في عمليات الإضافة والتعديل وتحديد الفرع الرئيسي
final branchControllerProvider =
    StateNotifierProvider.autoDispose<BranchController, bool>((ref) {
      return BranchController(ref: ref);
    });

class BranchController extends StateNotifier<bool> {
  final Ref _ref;
  BranchController({required Ref ref}) : _ref = ref, super(false);

  Future<bool> addBranch(
    BuildContext context, {
    required String name,
    String? address,
    String? phone,
  }) async {
    state = true;
    try {
      await _ref.read(supabaseProvider).from('branches').insert({
        'name': name,
        'address': address,
        'phone_number': phone,
      });
      _ref.invalidate(branchesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة الفرع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة الفرع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> updateBranch(
    BuildContext context, {
    required String id,
    required String name,
    String? address,
    String? phone,
  }) async {
    state = true;
    try {
      await _ref
          .read(supabaseProvider)
          .from('branches')
          .update({'name': name, 'address': address, 'phone_number': phone})
          .eq('id', id);
      _ref.invalidate(branchesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الفرع بنجاح'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث الفرع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<void> setMainBranch(BuildContext context, String branchId) async {
    try {
      await _ref
          .read(supabaseProvider)
          .rpc('set_main_branch', params: {'p_branch_id': branchId});
      _ref.invalidate(branchesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديد الفرع الرئيسي: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// -- بداية الإضافة --
// Provider لحفظ الفرع الذي تم اختياره حالياً للعمل عليه
final selectedBranchProvider = StateProvider<BranchModel?>((ref) => null);
// -- نهاية الإضافة --
