// lib/features/suppliers/presentation/providers/agreement_items_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final agreementItemsProvider = FutureProvider.autoDispose.family<List<AgreementItem>, String>((ref, agreementId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase
        .from('agreement_items')
        .select('*, products(*)') // ** تعديل مهم: جلب كل بيانات المنتج المرتبط **
        .eq('agreement_id', agreementId);
        
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
    return data.map((item) => AgreementItem.fromJson(item)).toList();
  } catch(e) {
    print('Error fetching agreement items: $e');
    rethrow;
  }
});
