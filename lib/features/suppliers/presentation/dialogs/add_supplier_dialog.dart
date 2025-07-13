import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

class AddSupplierDialog extends ConsumerStatefulWidget {
  final int? selectedCategoryId;
  const AddSupplierDialog({super.key, this.selectedCategoryId});

  @override
  ConsumerState<AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends ConsumerState<AddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (widget.selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تصنيف للمورد أولاً'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ref.read(addSupplierControllerProvider.notifier).addSupplier(
        context: context,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        categoryId: widget.selectedCategoryId!,
      ).then((newSupplier) {
        if (newSupplier != null && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addSupplierControllerProvider);
    return AlertDialog(
      title: const Text('إضافة مورد جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المورد'), validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null),
            Directionality(textDirection: TextDirection.ltr, child: TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone, textAlign: TextAlign.left)),
            TextFormField(controller: addressController, decoration: const InputDecoration(labelText: 'العنوان')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: isLoading ? null : _onSave,
          child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('حفظ'),
        ),
      ],
    );
  }
}
