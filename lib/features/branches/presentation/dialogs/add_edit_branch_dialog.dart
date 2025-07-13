// lib/features/branches/presentation/dialogs/add_edit_branch_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/branches/data/models/branch_model.dart';
import 'package:syria_store/features/branches/presentation/providers/branches_provider.dart';

class AddEditBranchDialog extends ConsumerStatefulWidget {
  final BranchModel? branch;
  const AddEditBranchDialog({super.key, this.branch});

  @override
  ConsumerState<AddEditBranchDialog> createState() =>
      _AddEditBranchDialogState();
}

class _AddEditBranchDialogState extends ConsumerState<AddEditBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _addressController = TextEditingController(
      text: widget.branch?.address ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.branch?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(branchControllerProvider.notifier);
      final future = widget.branch == null
          ? notifier.addBranch(
              context,
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
            )
          : notifier.updateBranch(
              context,
              id: widget.branch!.id,
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
            );

      future.then((success) {
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(branchControllerProvider);
    final isEditing = widget.branch != null;

    return AlertDialog(
      title: Text(isEditing ? 'تعديل فرع' : 'إضافة فرع جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الفرع'),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان (اختياري)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
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
