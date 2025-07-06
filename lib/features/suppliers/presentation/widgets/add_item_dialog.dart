import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';
import 'package:uuid/uuid.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({super.key});
  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newItem = AgreementItem(
        id: const Uuid().v4(),
        itemName: _nameController.text.trim(),
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
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم البند/الصنف'),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
              ),
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
