import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

// Providers لحفظ حالة الفلترة (تبقى كما هي)
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<String?>((ref) => null);

// --- ** بداية التعديل: تبسيط Provider الاتفاقيات ** ---
final agreementsProvider = FutureProvider.autoDispose<List<SupplierAgreement>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  try {
    // الآن نقوم فقط باستدعاء الدالة الذكية التي أنشأناها مع تمرير الفلاتر
    final response = await supabase
        .rpc(
          'search_agreements',
          params: {'search_query': searchQuery, 'status_filter': statusFilter},
        )
        .select(
          '*, suppliers(id, name)',
        ); // وما زلنا نستطيع طلب البيانات المرتبطة

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response,
    );
    return data.map((item) => SupplierAgreement.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching agreements: $e');
    rethrow;
  }
});
// --- ** نهاية التعديل ** ---

final agreementsBySupplierProvider = FutureProvider.autoDispose
    .family<List<SupplierAgreement>, String>((ref, supplierId) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('supplier_agreements')
            .select('*, suppliers(id, name)')
            .eq('supplier_id', supplierId)
            .order('created_at', ascending: false);

        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          response,
        );
        return data.map((item) => SupplierAgreement.fromJson(item)).toList();
      } catch (e) {
        print('Error fetching agreements for supplier $supplierId: $e');
        rethrow;
      }
    });
