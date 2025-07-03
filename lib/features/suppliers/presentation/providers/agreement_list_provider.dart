// lib/features/suppliers/presentation/providers/agreement_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

// Provider لجلب قائمة الاتفاقيات الرئيسية
final agreementsProvider = FutureProvider.autoDispose<List<SupplierAgreement>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase
        .from('supplier_agreements')
        .select('*, suppliers(id, name)') // <-- جلب اسم المورد ورقمه التعريفي
        .order('created_at', ascending: false);
    return response.map((item) => SupplierAgreement.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching agreements: $e');
    rethrow;
  }
});

// --- Provider جديد لجلب اتفاقيات مورد محدد ---
final agreementsBySupplierProvider = FutureProvider.autoDispose
    .family<List<SupplierAgreement>, String>((ref, supplierId) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('supplier_agreements')
            .select('*, suppliers(id, name)')
            .eq('supplier_id', supplierId) // فلترة حسب رقم المورد
            .order('created_at', ascending: false);
        return response
            .map((item) => SupplierAgreement.fromJson(item))
            .toList();
      } catch (e) {
        print('Error fetching agreements for supplier $supplierId: $e');
        rethrow;
      }
    });
