// lib/features/products/presentation/widgets/add_edit_form/product_primary_info_form.dart
import 'package:flutter/material.dart';

class ProductPrimaryInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController unitController;

  const ProductPrimaryInfoForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.unitController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'اسم المنتج'),
          validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: unitController,
          decoration: const InputDecoration(labelText: 'وحدة القياس'),
          validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
        ),
      ],
    );
  }
}
