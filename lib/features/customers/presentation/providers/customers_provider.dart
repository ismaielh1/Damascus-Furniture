// lib/features/customers/presentation/providers/customers_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider لجلب كل العملاء (يظل مفيداً لصفحة قائمة العملاء)
final allCustomersProvider = FutureProvider.autoDispose<List<ContactModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(customerSearchQueryProvider);

  try {
    var query = supabase.from('contacts').select().eq('is_customer', true);

    if (searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%$searchQuery%,code.ilike.%$searchQuery%,phone_number.ilike.%$searchQuery%',
      );
    }

    final response = await query.order('name', ascending: true);
    return response.map((item) => ContactModel.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching customers: $e');
    rethrow;
  }
});

// -- بداية الإضافة: Provider جديد للبحث التفاعلي في حقل الإكمال التلقائي --
final customerAutocompleteProvider = FutureProvider.autoDispose
    .family<List<ContactModel>, String>((ref, query) async {
      if (query.isEmpty) {
        return [];
      }
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('contacts')
            .select()
            .eq('is_customer', true)
            .or('name.ilike.%$query%,phone_number.ilike.%$query%')
            .limit(10); // نحدد عدد النتائج لتخفيف العبء
        return response.map((item) => ContactModel.fromJson(item)).toList();
      } catch (e) {
        print('Error during customer autocomplete search: $e');
        return [];
      }
    });
// -- نهاية الإضافة --

final customerControllerProvider =
    StateNotifierProvider.autoDispose<CustomerController, bool>((ref) {
      return CustomerController(ref: ref);
    });

class CustomerController extends StateNotifier<bool> {
  final Ref _ref;
  CustomerController({required Ref ref}) : _ref = ref, super(false);

  Future<bool> addCustomer({
    required BuildContext context,
    required String name,
    String? phone,
    String? address,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref
          .read(supabaseProvider)
          .rpc(
            'add_contact',
            params: {
              'p_name': name,
              'p_phone_number': phone,
              'p_address': address,
              'p_is_supplier': false,
              'p_is_customer': true,
              'p_category_id': null,
            },
          );
      _ref.invalidate(allCustomersProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة العميل "$name" بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة العميل: $e'),
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
