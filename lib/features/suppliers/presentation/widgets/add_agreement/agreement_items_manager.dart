// lib/features/suppliers/presentation/widgets/add_agreement/agreement_items_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

class AgreementItemsManager extends ConsumerWidget {
  final VoidCallback onAddItem;
  const AgreementItemsManager({super.key, required this.onAddItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(agreementFormProvider);
    final grandTotal = ref.watch(agreementFormProvider.notifier).grandTotal;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
            FilledButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('إضافة بند'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('لم يتم إضافة أي بنود بعد.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.product?.name ?? 'منتج غير معرف'),
                  subtitle: Text(
                    'الكمية: ${item.totalQuantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade700,
                        ),
                        onPressed: () => ref
                            .read(agreementFormProvider.notifier)
                            .removeItem(item.id.toString()), // ✅
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        ListTile(
          title: Text(
            'المجموع الإجمالي للبنود',
            style: theme.textTheme.titleMedium,
          ),
          trailing: Text(
            '\$${grandTotal.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
