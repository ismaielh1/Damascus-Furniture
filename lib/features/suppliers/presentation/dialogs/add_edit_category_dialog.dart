// lib/features/suppliers/presentation/widgets/add_edit_category_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_category_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/category_management_provider.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final SupplierCategoryModel? category;
  const AddEditCategoryDialog({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryDialog> createState() =>
      _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(categoryManagementControllerProvider.notifier);
      final isEditing = widget.category != null;

      Future<bool> action;
      if (isEditing) {
        action = notifier.updateCategory(
          context: context,
          id: widget.category!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        action = notifier.addCategory(
          context: context,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }
      action.then((success) {
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(categoryManagementControllerProvider);
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم التصنيف'),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
              maxLines: 2,
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
