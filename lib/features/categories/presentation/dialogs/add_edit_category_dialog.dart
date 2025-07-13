import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/categories/presentation/providers/category_provider.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  const AddEditCategoryDialog({super.key});

  @override
  ConsumerState<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ref.read(categoryControllerProvider.notifier)
          .addCategory(context, _nameController.text.trim())
          .then((success) {
            if (success && mounted) {
              Navigator.of(context).pop();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(categoryControllerProvider);
    return AlertDialog(
      title: const Text('إضافة تصنيف جديد'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'اسم التصنيف'),
          validator: (val) => (val == null || val.isEmpty) ? 'الحقل مطلوب' : null,
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
