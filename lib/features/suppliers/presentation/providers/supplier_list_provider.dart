import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final supplierSearchQueryProvider = StateProvider<String>((ref) => '');

final allSuppliersProvider =
    FutureProvider.autoDispose<List<ContactModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(supplierSearchQueryProvider);

  try {
    var query = supabase
        .from('contacts')
        .select(
          '*, supplier_category_link!inner(*, supplier_categories(name))',
        )
        .eq('is_supplier', true);

    if (searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%$searchQuery%,code.ilike.%$searchQuery%,phone_number.ilike.%$searchQuery%,address.ilike.%$searchQuery%',
      );
    }
    final response = await query.order('created_at', ascending: false);
    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);

    return data.map((item) => ContactModel.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching all suppliers (contacts): $e');
    rethrow;
  }
});
