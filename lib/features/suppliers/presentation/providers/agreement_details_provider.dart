import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final agreementDetailsProvider = FutureProvider.autoDispose
    .family<SupplierAgreement?, String>((ref, agreementId) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('supplier_agreements')
            .select('*, suppliers(id, name)')
            .eq('id', agreementId)
            .single();
        return SupplierAgreement.fromJson(response);
      } catch (e) {
        debugPrint("Error fetching agreement details: $e");
        return null;
      }
    });

final updateAgreementStatusControllerProvider =
    StateNotifierProvider.autoDispose<UpdateAgreementStatusController, bool>((
      ref,
    ) {
      return UpdateAgreementStatusController(ref: ref);
    });

class UpdateAgreementStatusController extends StateNotifier<bool> {
  final Ref _ref;
  UpdateAgreementStatusController({required Ref ref})
    : _ref = ref,
      super(false);

  Future<void> _refreshAllProviders(String agreementId) async {
    _ref.invalidate(agreementsProvider);
    _ref.invalidate(agreementDetailsProvider(agreementId));
    _ref.invalidate(agreementItemsProvider(agreementId));
    try {
      final agreement = await _ref.read(
        agreementDetailsProvider(agreementId).future,
      );
      if (agreement?.supplierId != null) {
        _ref.invalidate(agreementsBySupplierProvider(agreement!.supplierId!));
      }
    } catch (_) {}
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
      await _ref
          .read(supabaseProvider)
          .rpc(
            'receive_agreement_item',
            params: {
              'item_id_input': int.parse(itemId),
              'quantity_received_input': quantity,
              'notes_input': notes,
            },
          );

      await _refreshAllProviders(agreementId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الكمية المستلمة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الاستلام: $e'),
            backgroundColor: Colors.red,
          ),
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
      await _ref
          .read(supabaseProvider)
          .rpc(
            'add_payment',
            params: {
              'agreement_id_input': agreementId,
              'amount_input': amount,
              'notes_input': notes,
            },
          );
      await _refreshAllProviders(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة الدفعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة الدفعة: $e'),
            backgroundColor: Colors.red,
          ),
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
      await _ref
          .read(supabaseProvider)
          .rpc(
            'update_agreement_status',
            params: {
              'agreement_id_input': agreementId,
              'new_status': newStatus,
              'notes': null,
            },
          );
      await _refreshAllProviders(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الحالة بنجاح'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث الحالة: $e'),
            backgroundColor: Colors.red,
          ),
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
      await _ref
          .read(supabaseProvider)
          .rpc(
            'postpone_agreement',
            params: {
              'agreement_id_input': agreementId,
              'new_delivery_date_input': newDate.toIso8601String(),
            },
          );
      await _refreshAllProviders(agreementId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأجيل الاتفاقية بنجاح'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التأجيل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      state = false;
    }
  }
}
