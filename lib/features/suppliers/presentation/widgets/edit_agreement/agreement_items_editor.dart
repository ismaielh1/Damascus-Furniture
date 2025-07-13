// lib/features/suppliers/presentation/widgets/edit_agreement/agreement_items_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/edit_agreement_item_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/receive_item_dialog.dart';

class AgreementItemsEditor extends ConsumerWidget {
  final String agreementId;
  const AgreementItemsEditor({super.key, required this.agreementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(agreementItemsProvider(agreementId));
    final theme = Theme.of(context);

    void _showDeleteConfirmation(int itemId) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا البند؟ سيتم حذف كل سجلات الاستلام المتعلقة به.'),
          actions: [
            TextButton(child: const Text('إلغاء'), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(updateAgreementStatusControllerProvider.notifier).deleteAgreementItem(
                      context: context,
                      itemId: itemId,
                      agreementId: agreementId,
                    );
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("بنود الاتفاقية", style: theme.textTheme.titleLarge),
        const Divider(),
        itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('خطأ في جلب البنود: $e'),
          data: (items) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.product?.name ?? "منتج محذوف"),
                  subtitle: Text('الكمية: ${item.totalQuantity} | المستلم: ${item.receivedQuantitySoFar}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: const Text("استلام"),
                        onPressed: () => showDialog(context: context, builder: (_) => ReceiveItemDialog(item: item, agreementId: agreementId)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                        onPressed: () => showDialog(context: context, builder: (_) => EditAgreementItemDialog(item: item)),
                        tooltip: 'تعديل الكمية والسعر',
                      ),
                       IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(item.id),
                        tooltip: 'حذف البند',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
