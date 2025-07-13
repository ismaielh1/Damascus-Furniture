import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/customers/presentation/providers/customers_provider.dart';

class AddEditCustomerDialog extends ConsumerStatefulWidget {
  const AddEditCustomerDialog({super.key});

  @override
  ConsumerState<AddEditCustomerDialog> createState() =>
      _AddEditCustomerDialogState();
}

class _AddEditCustomerDialogState extends ConsumerState<AddEditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ref.read(customerControllerProvider.notifier).addCustomer(
            context: context,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          ).then((success) {
            if (success && mounted) {
              Navigator.of(context).pop();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(customerControllerProvider);
    return AlertDialog(
      title: const Text('إضافة عميل جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
              keyboardType: TextInputType.phone,
            ),
             const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان (اختياري)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: isLoading ? null : _onSave,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
