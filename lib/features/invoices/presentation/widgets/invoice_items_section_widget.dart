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
                final selectedProduct =
                    await context.push<ProductModel>('/products/select');
                if (selectedProduct != null) {
                  ref.read(invoiceFormProvider.notifier).addItem(
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
                onStateChange: (qty, price) {
                  ref
                      .read(invoiceFormProvider.notifier)
                      .updateItem(items[index].product.id, qty, price);
                },
              );
            },
          ),
      ],
    );
  }
}

class InvoiceItemRow extends ConsumerStatefulWidget {
  final InvoiceItemModel item;
  final int itemNumber;
  final VoidCallback onRemove;
  final Function(int qty, double price) onStateChange;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.itemNumber,
    required this.onRemove,
    required this.onStateChange,
  });

  @override
  ConsumerState<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends ConsumerState<InvoiceItemRow> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalController = TextEditingController();

  final _qtyFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _totalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _updateControllersText();

    // --- بداية التعديل: مسح النص عند التركيز ---
    _qtyFocusNode.addListener(() {
      if (_qtyFocusNode.hasFocus) {
        _qtyController.clear();
      }
    });
    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        _priceController.clear();
      }
    });
    _totalFocusNode.addListener(() {
      if (_totalFocusNode.hasFocus) {
        _totalController.clear();
      }
    });
    // --- نهاية التعديل ---
  }

  @override
  void didUpdateWidget(covariant InvoiceItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      _updateControllersText();
    }
  }

  void _updateControllersText() {
    if (!_qtyFocusNode.hasFocus) {
      _qtyController.text = widget.item.quantity.toString();
    }
    if (!_priceFocusNode.hasFocus) {
      _priceController.text = widget.item.unitPrice.toStringAsFixed(2);
    }
    if (!_totalFocusNode.hasFocus) {
      _totalController.text = widget.item.subtotal.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _totalController.dispose();

    _qtyFocusNode.dispose();
    _priceFocusNode.dispose();
    _totalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('${widget.itemNumber}.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(widget.item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: _buildTextField(
                        _qtyController, 'الكمية', _qtyFocusNode, (val) {
                      final qty = int.tryParse(val) ?? 0;
                      final price =
                          double.tryParse(_priceController.text) ?? 0.0;
                      widget.onStateChange(qty, price);
                    })),
                const SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: _buildTextField(
                        _priceController, 'السعر', _priceFocusNode, (val) {
                      final price = double.tryParse(val) ?? 0.0;
                      final qty = int.tryParse(_qtyController.text) ?? 0;
                      widget.onStateChange(qty, price);
                    }, isPrice: true)),
                const SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: _buildTextField(
                        _totalController, 'الإجمالي', _totalFocusNode, (val) {
                      final total = double.tryParse(val) ?? 0.0;
                      final quantity = int.tryParse(_qtyController.text) ?? 1;
                      if (quantity > 0) {
                        widget.onStateChange(quantity, total / quantity);
                      }
                    }, isPrice: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      FocusNode focusNode, ValueChanged<String> onChanged,
      {bool isPrice = false}) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration:
          InputDecoration(labelText: label, prefixText: isPrice ? '\$ ' : null),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: onChanged,
    );
  }
}
