import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/receive_item_dialog.dart';

class AgreementItemsList extends ConsumerWidget {
  final String agreementId;
  const AgreementItemsList({super.key, required this.agreementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(agreementItemsProvider(agreementId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        itemsAsync.when(
          data: (items) => items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('لا توجد بنود.'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final productName = item.product?.name ?? 'منتج غير معرف';
                    final productSku = item.product?.sku ?? 'N/A';
                    final isFullyReceived =
                        item.receivedQuantitySoFar >= item.totalQuantity;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isFullyReceived
                              ? Colors.green.shade200
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الرمز: $productSku',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الكمية المطلوبة: ${item.totalQuantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            if (item.totalQuantity > 0) ...[
                              LinearProgressIndicator(
                                value:
                                    item.receivedQuantitySoFar /
                                    item.totalQuantity,
                                backgroundColor: Colors.grey.shade300,
                                color: isFullyReceived
                                    ? Colors.green
                                    : Colors.orange,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'المستلم: ${item.receivedQuantitySoFar}',
                                    style: TextStyle(
                                      color: isFullyReceived
                                          ? Colors.green.shade800
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!isFullyReceived)
                                  TextButton.icon(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => ReceiveItemDialog(
                                        item: item,
                                        agreementId: agreementId,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('استلام كمية'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('خطأ في جلب البنود: $e'),
        ),
      ],
    );
  }
}
