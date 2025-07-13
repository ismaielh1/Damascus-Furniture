import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final employeesProvider = FutureProvider.autoDispose<List<ContactModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase.from('profiles').select('id, full_name');
    
    return response.map((item) => ContactModel(
      id: item['id'], 
      name: item['full_name'] ?? 'موظف غير مسمى',
      isSupplier: false,
      isCustomer: false,
    )).toList();
  } catch (e) {
    print('Error fetching employees: $e');
    rethrow;
  }
});

final selectedEmployeeProvider = StateProvider<ContactModel?>((ref) => null);

final employeeControllerProvider = StateNotifierProvider.autoDispose<EmployeeController, bool>((ref) {
  return EmployeeController(ref);
});

class EmployeeController extends StateNotifier<bool> {
  final Ref _ref;
  EmployeeController(this._ref) : super(false);

  Future<bool> addEmployee(BuildContext context, {required String fullName}) async {
    state = true;
    try {
      await _ref.read(supabaseProvider).from('profiles').insert({'full_name': fullName});
      _ref.invalidate(employeesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تمت إضافة الموظف بنجاح'),
            backgroundColor: Colors.green));
      }
      return true;
    } catch(e) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('فشل إضافة الموظف: $e'),
            backgroundColor: Colors.red));
      }
      return false;
    } finally {
      state = false;
    }
  }
}
