// lib/features/suppliers/presentation/pages/agreement_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/details/agreement_actions_panel.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/details/agreement_documents_section.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/details/agreement_financial_summary.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/details/agreement_header_card.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/details/agreement_items_list.dart';

class AgreementDetailsPage extends ConsumerWidget {
  final String agreementId;
  const AgreementDetailsPage({super.key, required this.agreementId});

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending_delivery':
        return {
          'color': Colors.orange.shade700,
          'icon': Icons.hourglass_top,
          'text': 'قيد التسليم'
        };
      case 'completed':
        return {
          'color': Colors.green.shade700,
          'icon': Icons.check_circle,
          'text': 'مكتمل'
        };
      case 'delayed':
        return {
          'color': Colors.red.shade700,
          'icon': Icons.error,
          'text': 'متأخر'
        };
      case 'cancelled':
        return {
          'color': Colors.grey.shade700,
          'icon': Icons.cancel,
          'text': 'ملغي'
        };
      default:
        return {'color': Colors.grey, 'icon': Icons.help, 'text': 'غير معروف'};
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementAsync = ref.watch(agreementDetailsProvider(agreementId));
    final itemsAsync = ref.watch(agreementItemsProvider(agreementId));
    final isUpdating = ref.watch(updateAgreementStatusControllerProvider);

    void handleUpdateStatus(String newStatus) {
      ref.read(updateAgreementStatusControllerProvider.notifier).updateStatus(
          context: context, agreementId: agreementId, newStatus: newStatus);
    }

    void handlePostpone() async {
      final agreement = agreementAsync.value;
      if (agreement == null) return;
      final newDate = await showDatePicker(
        context: context,
        initialDate: agreement.expectedDeliveryDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (newDate != null) {
        ref
            .read(updateAgreementStatusControllerProvider.notifier)
            .postponeAgreement(
                context: context, agreementId: agreementId, newDate: newDate);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الاتفاقية')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(agreementDetailsProvider(agreementId));
          ref.invalidate(agreementItemsProvider(agreementId));
        },
        child: agreementAsync.when(
          data: (agreement) {
            if (agreement == null) {
              return const Center(child: Text('لم يتم العثور على الاتفاقية.'));
            }
            final statusInfo = _getStatusInfo(agreement.status);

            // --- بداية إضافة المنطق الجديد ---
            final items = itemsAsync.value ?? [];
            bool allItemsReceived = items.isNotEmpty &&
                items.every(
                    (item) => item.receivedQuantitySoFar >= item.totalQuantity);
            bool isFullyPaid =
                (agreement.totalAmount - (agreement.down_payment ?? 0)) <= 0;
            bool canBeCompleted = allItemsReceived && isFullyPaid;
            // --- نهاية إضافة المنطق الجديد ---

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AgreementHeaderCard(
                      agreement: agreement, statusInfo: statusInfo),
                  const SizedBox(height: 20),
                  AgreementItemsList(agreementId: agreement.id),
                  const Divider(height: 32),
                  AgreementFinancialSummary(
                      agreement: agreement, isUpdating: isUpdating),
                  const SizedBox(height: 20),
                  AgreementDocumentsSection(agreement: agreement),
                  const Divider(height: 32),
                  AgreementActionsPanel(
                    isUpdating: isUpdating,
                    onMarkAsCompleted: canBeCompleted
                        ? () => handleUpdateStatus('completed')
                        : null, // <-- تطبيق المنطق هنا
                    onPostpone: handlePostpone,
                    onCancel: () => handleUpdateStatus('cancelled'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('خطأ في جلب تفاصيل الاتفاقية: $err')),
        ),
      ),
    );
  }
}
