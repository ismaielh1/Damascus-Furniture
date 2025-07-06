// lib/features/products/presentation/pages/add_edit_product_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/products/presentation/providers/product_providers.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  const AddEditProductPage({super.key});

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController(text: 'قطعة');
  Supplier? _selectedSupplier;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(productControllerProvider.notifier)
          .addProduct(
            context: context,
            name: _nameController.text.trim(),
            supplierId: _selectedSupplier!.id,
            description: _descriptionController.text.trim(),
            unitOfMeasure: _unitController.text.trim(),
          )
          .then((success) {
            if (success && mounted) {
              context.pop();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(
      suppliersByCategoryProvider,
    ); // Note: This might need adjustment if categories aren't used
    final isLoading = ref.watch(productControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة منتج جديد للكتالوج')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              // يتطلب اختيار مورد افتراضي لإنشاء الرمز SKU
              DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                hint: const Text('اختر المورد الافتراضي'),
                decoration: const InputDecoration(
                  labelText: 'المورد الافتراضي (لإنشاء الرمز)',
                ),
                items:
                    suppliersAsync.asData?.value
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        )
                        .toList() ??
                    [],
                onChanged: (supplier) =>
                    setState(() => _selectedSupplier = supplier),
                validator: (value) =>
                    value == null ? 'يجب اختيار مورد افتراضي' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'وحدة القياس'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'الحقل مطلوب' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('حفظ المنتج'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
