// lib/features/invoices/presentation/widgets/invoice_items_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/invoices/data/models/invoice_item_model.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';

class InvoiceItemsSectionWidget extends ConsumerWidget {
  const InvoiceItemsSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(invoiceFormProvider).items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('بنود الفاتورة', style: theme.textTheme.titleLarge),
            FilledButton.icon(
              onPressed: () async {
                final selectedProduct = await context.push<ProductModel>(
                  '/products/select',
                );
                if (selectedProduct != null) {
                  ref
                      .read(invoiceFormProvider.notifier)
                      .addItem(
                        InvoiceItemModel(
                          product: selectedProduct,
                          quantity: 1,
                          unitPrice: 0.0,
                        ),
                      );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة بند'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('لم يتم إضافة أي بنود.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return InvoiceItemRow(
                key: ValueKey(items[index].product.id),
                item: items[index],
                itemNumber: index + 1,
                onRemove: () => ref
                    .read(invoiceFormProvider.notifier)
                    .removeItem(items[index].product.id),
                onQuantityChanged: (qty) => ref
                    .read(invoiceFormProvider.notifier)
                    .updateItemQuantity(items[index].product.id, qty),
                onPriceChanged: (price) => ref
                    .read(invoiceFormProvider.notifier)
                    .updateItemPrice(items[index].product.id, price),
              );
            },
          ),
      ],
    );
  }
}

// This sub-widget can stay here or be in its own file. Keeping it here is fine.
class InvoiceItemRow extends StatefulWidget {
  final InvoiceItemModel item;
  final int itemNumber;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.itemNumber,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onPriceChanged,
  });
  @override
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.item.quantity == 0 ? '' : widget.item.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice == 0.0
          ? ''
          : widget.item.unitPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentQty = widget.item.quantity == 0
            ? ''
            : widget.item.quantity.toString();
        if (_qtyController.text != currentQty) {
          _qtyController.text = currentQty;
        }

        final currentPrice = widget.item.unitPrice == 0.0
            ? ''
            : widget.item.unitPrice.toStringAsFixed(2);
        if (_priceController.text != currentPrice) {
          _priceController.text = currentPrice;
        }

        _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length),
        );
        _priceController.selection = TextSelection.fromPosition(
          TextPosition(offset: _priceController.text.length),
        );
      }
    });
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${widget.itemNumber}.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      hintText: '1',
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (val) =>
                        widget.onQuantityChanged(int.tryParse(val) ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      prefixText: '\$',
                      hintText: '0.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (val) =>
                        widget.onPriceChanged(double.tryParse(val) ?? 0.0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'الإجمالي',
                      border: OutlineInputBorder(),
                    ),
                    child: Center(
                      child: Text(
                        '\$${widget.item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
