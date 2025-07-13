// lib/features/suppliers/presentation/providers/supplier_details_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_financials_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final supplierFinancialSummaryProvider = FutureProvider.autoDispose
    .family<SupplierFinancialSummary, String>((ref, contactId) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase.rpc(
        'get_supplier_financial_summary',
        params: {'supplier_id_input': contactId},
      );
      return SupplierFinancialSummary.fromJson(response);
    });

final supplierPaymentsProvider = FutureProvider.autoDispose
    .family<List<PaymentModel>, String>((ref, contactId) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase
          .from('agreement_payments')
          .select('*, supplier_agreements!inner(id, contact_id)')
          .eq('supplier_agreements.contact_id', contactId)
          .order('payment_date', ascending: false);

      final List<Map<String, dynamic>> data = List.from(response);
      return data.map((item) => PaymentModel.fromJson(item)).toList();
    });

// -- بداية الإضافة --
// Provider جديد لجلب الدفعات الخاصة باتفاقية واحدة
final paymentsByAgreementProvider = FutureProvider.autoDispose
    .family<List<PaymentModel>, String>((ref, agreementId) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase
          .from('agreement_payments')
          .select()
          .eq('agreement_id', agreementId)
          .order('payment_date', ascending: false);
      final List<Map<String, dynamic>> data = List.from(response);
      return data.map((item) => PaymentModel.fromJson(item)).toList();
    });
// -- نهاية الإضافة --

final receiptsByContactProvider = FutureProvider.autoDispose
    .family<List<ReceiptLogModel>, String>((ref, contactId) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase.rpc(
        'get_receipts_by_contact',
        params: {'contact_id_input': contactId},
      );
      final List<Map<String, dynamic>> data = List.from(response);
      return data.map((item) => ReceiptLogModel.fromJson(item)).toList();
    });
