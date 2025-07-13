// lib/features/invoices/presentation/widgets/details/invoice_items_list_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoices_list_provider.dart';

class InvoiceItemsListDetails extends ConsumerWidget {
  final String invoiceId;
  const InvoiceItemsListDetails({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(invoiceItemsProvider(invoiceId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('البنود', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        itemsAsync.when(
          data: (items) {
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item.product.name),
                    subtitle: Text('الكمية: ${item.quantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}'),
                    trailing: Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('خطأ في جلب البنود: $e'),
        ),
      ],
    );
  }
}
