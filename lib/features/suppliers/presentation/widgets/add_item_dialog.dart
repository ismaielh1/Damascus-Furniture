// lib/features/suppliers/presentation/widgets/add_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/select_product_dialog.dart';
import 'package:uuid/uuid.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({super.key});

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;
  ProductModel? _selectedProduct;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _selectProduct() async {
    final result = await showDialog<ProductModel>(
      context: context,
      builder: (_) => const SelectProductDialog(),
    );
    if (result != null) {
      setState(() {
        _selectedProduct = result;
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء اختيار منتج أولاً'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newItem = AgreementItem(
        id: const Uuid().v4(),
        // --- هذا هو السطر المطلوب إضافته ---
        productId: _selectedProduct!.id,
        // ------------------------------------
        itemName: _selectedProduct!.name,
        totalQuantity: int.parse(_quantityController.text.trim()),
        unitPrice: double.parse(_priceController.text.trim()),
        expectedDeliveryDate: _selectedDate!,
        receivedQuantitySoFar: 0,
      );
      ref.read(agreementFormProvider.notifier).addItem(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة بند جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _selectProduct,
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(
                  _selectedProduct == null
                      ? 'اختر منتج من الكتالوج'
                      : 'تغيير المنتج',
                ),
              ),
              if (_selectedProduct != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'المنتج المختار: ${_selectedProduct!.name}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'سعر الوحدة',
                  suffixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ''
                      : DateFormat('yyyy/MM/dd').format(_selectedDate!),
                ),
                decoration: const InputDecoration(
                  labelText: 'تاريخ تسليم البند',
                  hintText: 'اختر تاريخًا',
                ),
                onTap: _pickDate,
                validator: (value) =>
                    _selectedDate == null ? 'الرجاء اختيار تاريخ' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _onSave, child: const Text('إضافة')),
      ],
    );
  }
}
