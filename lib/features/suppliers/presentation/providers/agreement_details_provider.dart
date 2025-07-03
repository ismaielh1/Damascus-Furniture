// lib/features/suppliers/presentation/providers/agreement_details_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart'; // <-- استيراد الـ provider الرئيسي

// Provider لجلب تفاصيل اتفاقية واحدة
final agreementDetailsProvider = FutureProvider.autoDispose.family<SupplierAgreement?, String>((ref, agreementId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase.from('supplier_agreements').select('*, suppliers(name)').eq('id', agreementId).single();
    return SupplierAgreement.fromJson(response);
  } catch (e) { return null; }
});

// Controller لتحديث حالة الاتفاقية
final updateAgreementStatusControllerProvider = StateNotifierProvider.autoDispose<UpdateAgreementStatusController, bool>((ref) {
  return UpdateAgreementStatusController(ref: ref);
});
class UpdateAgreementStatusController extends StateNotifier<bool> {
  final Ref _ref;
  UpdateAgreementStatusController({required Ref ref}) : _ref = ref, super(false);

  Future<void> _refreshProviders(String agreementId) async {
    _ref.invalidate(agreementsProvider);
    await _ref.refresh(agreementDetailsProvider(agreementId).future);
  }

  Future<void> updateStatus({ required BuildContext context, required String agreementId, required String newStatus, }) async {
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc('update_agreement_status', params: { 'agreement_id_input': agreementId, 'new_status': newStatus, 'notes': null });
      await _refreshProviders(agreementId);
      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة بنجاح'), backgroundColor: Colors.blue)); }
    } catch (e) {
      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحديث الحالة: $e'), backgroundColor: Colors.red)); }
    } finally { state = false; }
  }

  Future<void> postponeAgreement({ required BuildContext context, required String agreementId, required DateTime newDate, }) async {
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc('postpone_agreement', params: { 'agreement_id_input': agreementId, 'new_delivery_date_input': newDate.toIso8601String(), });
      await _refreshProviders(agreementId);
      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأجيل الاتفاقية بنجاح'), backgroundColor: Colors.blue)); }
    } catch (e) {
      if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التأجيل: $e'), backgroundColor: Colors.red)); }
    } finally { state = false; }
  }
}
