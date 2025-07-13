// lib/features/products/presentation/pages/add_edit_product_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/categories/data/models/category_model.dart';
import 'package:syria_store/features/products/presentation/providers/product_providers.dart';
import 'package:syria_store/features/products/presentation/widgets/add_edit_form/product_association_form.dart';
import 'package:syria_store/features/products/presentation/widgets/add_edit_form/product_primary_info_form.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_form_provider.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  final String? productId;
  const AddEditProductPage({super.key, this.productId});

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController(text: 'قطعة');
  
  Supplier? _selectedSupplier;
  CategoryModel? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if(widget.productId == null){
        // Add new product logic
        ref.read(productControllerProvider.notifier).addProduct(
          context: context,
          name: _nameController.text.trim(),
          contactId: _selectedSupplier!.id,
          description: _descriptionController.text.trim(),
          unitOfMeasure: _unitController.text.trim(),
        ).then((success) {
          if (success && mounted) context.pop();
        });
      } else {
        // Edit existing product logic
        ref.read(productControllerProvider.notifier).updateProduct(
          context: context,
          productId: widget.productId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          unitOfMeasure: _unitController.text.trim(),
        ).then((success) {
          if (success && mounted) context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(productControllerProvider);
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل منتج' : 'إضافة منتج جديد للكتالوج'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductPrimaryInfoForm(
                nameController: _nameController,
                descriptionController: _descriptionController,
                unitController: _unitController,
              ),
              const SizedBox(height: 16),
              // We hide this section in edit mode for now, as changing category/supplier of an existing product has complex implications
              if (!isEditing)
                ProductAssociationForm(
                  selectedCategory: _selectedCategory,
                  selectedSupplier: _selectedSupplier,
                  onCategoryChanged: (category) => setState(() {
                    _selectedCategory = category;
                    _selectedSupplier = null; // Reset supplier when category changes
                  }),
                  onSupplierChanged: (supplier) => setState(() => _selectedSupplier = supplier),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(isEditing ? 'حفظ التعديلات' : 'حفظ المنتج'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
