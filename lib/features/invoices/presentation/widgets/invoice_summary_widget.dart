// lib/features/invoices/presentation/widgets/invoice_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';

class InvoiceSummaryWidget extends ConsumerWidget {
  final TextEditingController discountController;
  final double totalAfterDiscount;

  const InvoiceSummaryWidget({
    super.key,
    required this.discountController,
    required this.totalAfterDiscount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceState = ref.watch(invoiceFormProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع الفرعي:', style: theme.textTheme.titleMedium),
                Text(
                  '\$${invoiceState.subtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('الخصم:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '0.0',
                      prefixText: '\$ ',
                    ),
                    onChanged: (value) {
                      // We can directly call the notifier if we pass it, or let the parent handle it
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع النهائي:', style: theme.textTheme.titleLarge),
                Text(
                  '\$${totalAfterDiscount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
