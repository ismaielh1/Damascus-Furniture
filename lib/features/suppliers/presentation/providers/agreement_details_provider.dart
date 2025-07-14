// lib/features/suppliers/presentation/providers/agreement_details_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

final agreementDetailsProvider = FutureProvider.autoDispose
    .family<SupplierAgreement?, String>((ref, agreementId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase
        .from('supplier_agreements')
        .select('*, contacts(id, name)')
        .eq('id', agreementId)
        .single();
    return SupplierAgreement.fromJson(response);
  } catch (e) {
    debugPrint("Error fetching agreement details: $e");
    return null;
  }
});

final updateAgreementStatusControllerProvider =
    StateNotifierProvider.autoDispose<UpdateAgreementStatusController, bool>(
        (ref) {
  return UpdateAgreementStatusController(ref: ref);
});

class UpdateAgreementStatusController extends StateNotifier<bool> {
  final Ref _ref;
  UpdateAgreementStatusController({required Ref ref})
      : _ref = ref,
        super(false);

  Future<void> _refreshAgreementData(String agreementId) async {
    final agreement =
        await _ref.read(agreementDetailsProvider(agreementId).future);
    if (agreement?.contactId != null) {
      // --- هذا هو السطر الذي تم تصحيحه ---
      _ref.invalidate(contactFinancialSummaryProvider(agreement!.contactId!));
      _ref.invalidate(agreementsBySupplierProvider(agreement.contactId!));
    }
    _ref.invalidate(agreementsProvider);
    _ref.invalidate(agreementDetailsProvider(agreementId));
    _ref.invalidate(paymentsByAgreementProvider(agreementId));
    _ref.invalidate(agreementItemsProvider(agreementId));
  }

  Future<bool> updateAgreement({
    required BuildContext context,
    required String agreementId,
    required String notes,
    required double downPayment,
    required DateTime? expectedDeliveryDate,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'update_agreement_details',
        params: {
          'p_agreement_id': agreementId,
          'p_notes': notes,
          'p_down_payment': downPayment,
          'p_expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تحديث الاتفاقية'),
              backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> addPayment({
    required BuildContext context,
    required String agreementId,
    required double amount,
    String? notes,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'add_payment',
        params: {
          'agreement_id_input': agreementId,
          'amount_input': amount,
          'notes_input': notes,
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تمت إضافة الدفعة بنجاح'),
              backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل إضافة الدفعة: $e'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> updatePayment({
    required BuildContext context,
    required int paymentId,
    required String agreementId,
    required double newAmount,
    required String newNotes,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'update_agreement_payment',
        params: {
          'p_payment_id': paymentId,
          'p_new_amount': newAmount,
          'p_new_notes': newNotes,
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تحديث الدفعة'), backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل تحديث الدفعة: $e'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> deletePayment({
    required BuildContext context,
    required int paymentId,
    required String agreementId,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref
          .read(supabaseProvider)
          .rpc('delete_agreement_payment', params: {'p_payment_id': paymentId});
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حذف الدفعة'), backgroundColor: Colors.orange),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل حذف الدفعة: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> receiveItems({
    required BuildContext context,
    required String itemId,
    required String agreementId,
    required int quantity,
    String? notes,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'receive_agreement_item',
        params: {
          'item_id_input': int.parse(itemId),
          'quantity_received_input': quantity,
          'notes_input': notes,
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تسجيل الكمية المستلمة بنجاح'),
              backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل تسجيل الاستلام: $e'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> updateAgreementItem({
    required BuildContext context,
    required int itemId,
    required String agreementId,
    required int newQuantity,
    required double newPrice,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'update_agreement_item',
        params: {
          'p_item_id': itemId,
          'p_new_quantity': newQuantity,
          'p_new_price': newPrice,
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تحديث البند'), backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل تحديث البند: $e'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> deleteAgreementItem({
    required BuildContext context,
    required int itemId,
    required String agreementId,
  }) async {
    if (state) return false;
    state = true;
    try {
      await _ref
          .read(supabaseProvider)
          .rpc('delete_agreement_item', params: {'p_item_id': itemId});
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حذف البند'), backgroundColor: Colors.orange),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل حذف البند: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }

  Future<void> updateStatus({
    required BuildContext context,
    required String agreementId,
    required String newStatus,
  }) async {
    if (state) return;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'update_agreement_status',
        params: {
          'agreement_id_input': agreementId,
          'new_status': newStatus,
          'notes': null,
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تحديث الحالة بنجاح'),
              backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل تحديث الحالة: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      state = false;
    }
  }

  Future<void> postponeAgreement({
    required BuildContext context,
    required String agreementId,
    required DateTime newDate,
  }) async {
    if (state) return;
    state = true;
    try {
      await _ref.read(supabaseProvider).rpc(
        'postpone_agreement',
        params: {
          'agreement_id_input': agreementId,
          'new_delivery_date_input': newDate.toIso8601String(),
        },
      );
      await _refreshAgreementData(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تأجيل الاتفاقية بنجاح'),
              backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل التأجيل: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      state = false;
    }
  }
}
