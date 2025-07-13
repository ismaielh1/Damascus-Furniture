// lib/features/employees/presentation/dialogs/add_edit_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/presentation/providers/employees_provider.dart';

class AddEditEmployeeDialog extends ConsumerStatefulWidget {
  const AddEditEmployeeDialog({super.key});

  @override
  ConsumerState<AddEditEmployeeDialog> createState() =>
      _AddEditEmployeeDialogState();
}

class _AddEditEmployeeDialogState extends ConsumerState<AddEditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(employeeControllerProvider.notifier)
          .addEmployee(context, fullName: _nameController.text.trim())
          .then((success) {
            if (success) Navigator.of(context).pop();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(employeeControllerProvider);
    return AlertDialog(
      title: const Text('إضافة موظف جديد'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'الاسم الكامل للموظف'),
          validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _onSave,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
