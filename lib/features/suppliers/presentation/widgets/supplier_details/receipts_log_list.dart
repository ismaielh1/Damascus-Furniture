// lib/features/suppliers/presentation/widgets/supplier_details/receipts_log_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

class ReceiptsLogList extends ConsumerWidget {
  final String supplierId;
  const ReceiptsLogList({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsByContactProvider(supplierId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('سجل الاستلامات', style: theme.textTheme.titleLarge),
        const Divider(),
        receiptsAsync.when(
          data: (receipts) {
            if (receipts.isEmpty)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('لا توجد استلامات مسجلة.'),
                ),
              );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    'استلام ${receipt.receivedQuantity} من "${receipt.productName}"',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بتاريخ: ${DateFormat('yyyy/MM/dd', 'en_US').format(receipt.receiptDate)}',
                      ),
                      if (receipt.notes != null && receipt.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ملاحظات: ${receipt.notes!}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('خطأ في جلب سجل الاستلامات: $e'),
        ),
      ],
    );
  }
}
