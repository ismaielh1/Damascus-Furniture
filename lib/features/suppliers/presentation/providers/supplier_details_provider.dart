// lib/features/suppliers/presentation/providers/supplier_details_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_financials_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لجلب الملخص المالي
final supplierFinancialSummaryProvider = FutureProvider.autoDispose
    .family<SupplierFinancialSummary, String>((ref, supplierId) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase.rpc(
        'get_supplier_financial_summary',
        params: {'supplier_id_input': supplierId},
      );
      return SupplierFinancialSummary.fromJson(response);
    });

// Provider لجلب قائمة الدفعات
final supplierPaymentsProvider = FutureProvider.autoDispose
    .family<List<PaymentModel>, String>((ref, supplierId) async {
      final supabase = ref.watch(supabaseProvider);
      // نحتاج للانضمام إلى جدول الاتفاقيات للفلترة حسب المورد
      final response = await supabase
          .from('agreement_payments')
          .select('*, supplier_agreements!inner(supplier_id)')
          .eq('supplier_agreements.supplier_id', supplierId)
          .order('payment_date', ascending: false);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );
      return data.map((item) => PaymentModel.fromJson(item)).toList();
    });
