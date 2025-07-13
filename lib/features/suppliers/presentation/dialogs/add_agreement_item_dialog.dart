import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:uuid/uuid.dart';

class AddAgreementItemDialog extends ConsumerStatefulWidget {
  final ProductModel product;
  final String agreementId; // ✅ أضفنا المعرف هنا

  const AddAgreementItemDialog({
    super.key,
    required this.product,
    required this.agreementId,
  });

  @override
  ConsumerState<AddAgreementItemDialog> createState() =>
      _AddAgreementItemDialogState();
}

class _AddAgreementItemDialogState
    extends ConsumerState<AddAgreementItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newItem = AgreementItem(
        id: const Uuid().v4(),
        agreementId: widget.agreementId.toString(), // ✅ تحويل إلى String
        productId: widget.product.id.toString(), // ✅ تحويل إلى String
        product: widget.product,
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
      title: Text('إضافة "${widget.product.name}" للاتفاقية'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'الكمية (${widget.product.unitOfMeasure})',
                ),
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
                ),
                onTap: _pickDate,
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
