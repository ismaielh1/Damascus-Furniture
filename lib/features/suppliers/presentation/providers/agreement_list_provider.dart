// lib/features/suppliers/presentation/providers/agreement_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<String?>((ref) => null);

final agreementsProvider = FutureProvider.autoDispose<List<SupplierAgreement>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  try {
    // ملاحظة: دالة search_agreements في قاعدة البيانات قد تحتاج لتحديث لاحقاً
    final response = await supabase
        .rpc(
          'search_agreements',
          params: {'search_query': searchQuery, 'status_filter': statusFilter},
        )
        .select(
          '*, contacts(id, name)',
        ); // -- تعديل -- : من suppliers إلى contacts

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response,
    );
    return data.map((item) => SupplierAgreement.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching agreements: $e');
    rethrow;
  }
});

// Provider لجلب اتفاقيات مورد (جهة اتصال) محدد
final agreementsBySupplierProvider = FutureProvider.autoDispose
    .family<List<SupplierAgreement>, String>((ref, contactId) async {
      // -- تعديل -- : من supplierId
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('supplier_agreements')
            .select('*, contacts(id, name)') // -- تعديل --
            .eq('contact_id', contactId) // -- تعديل --
            .order('created_at', ascending: false);

        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          response,
        );
        return data.map((item) => SupplierAgreement.fromJson(item)).toList();
      } catch (e) {
        print('Error fetching agreements for contact $contactId: $e');
        rethrow;
      }
    });
