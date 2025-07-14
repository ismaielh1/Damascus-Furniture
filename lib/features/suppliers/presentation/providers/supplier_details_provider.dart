// lib/features/suppliers/presentation/providers/supplier_details_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_financials_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// -- تم تعديل اسم ووظيفة الـ Provider ليكون أكثر عمومية --
final contactFinancialSummaryProvider = FutureProvider.autoDispose
    .family<SupplierFinancialSummary, String>((ref, contactId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase.rpc(
      'get_contact_financial_summary', // استدعاء الدالة الجديدة
      params: {'p_contact_id': contactId},
    ).single(); // نستخدم single() لأن الدالة ترجع صفًا واحدًا
    return SupplierFinancialSummary.fromJson(response);
  } catch (e) {
    print("Error fetching contact financial summary: $e");
    rethrow;
  }
});

// -- باقي الـ Providers في الملف تبقى كما هي --
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
