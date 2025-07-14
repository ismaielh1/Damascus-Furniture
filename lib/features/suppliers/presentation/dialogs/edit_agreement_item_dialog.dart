// lib/features/suppliers/presentation/dialogs/edit_agreement_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';

class EditAgreementItemDialog extends ConsumerStatefulWidget {
  final AgreementItem item;

  const EditAgreementItemDialog({super.key, required this.item});

  @override
  ConsumerState<EditAgreementItemDialog> createState() =>
      _EditAgreementItemDialogState();
}

class _EditAgreementItemDialogState
    extends ConsumerState<EditAgreementItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.totalQuantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // --- بداية التعديل ---
      // التأكد من أن معرف الاتفاقية ليس فارغاً
      if (widget.item.agreementId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: معرّف الاتفاقية مفقود')),
        );
        return;
      }
      // --- نهاية التعديل ---

      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .updateAgreementItem(
            context: context,
            itemId: widget.item.id,
            // --- بداية التعديل ---
            // استخدام علامة التعجب (!) لتأكيد أن القيمة ليست فارغة
            agreementId: widget.item.agreementId!,
            // --- نهاية التعديل ---
            newQuantity: int.parse(_quantityController.text),
            newPrice: double.parse(_priceController.text),
          )
          .then((success) {
        if (success && mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(updateAgreementStatusControllerProvider);
    return AlertDialog(
      title: Text('تعديل بند: ${widget.item.product?.name ?? ""}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'الكمية الإجمالية'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'الحقل مطلوب';
                final quantity = int.tryParse(val);
                if (quantity == null) return 'أدخل رقماً صحيحاً';
                if (quantity < widget.item.receivedQuantitySoFar) {
                  return 'لا يمكن أن تكون الكمية أقل من المستلم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'سعر الوحدة',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'الحقل مطلوب';
                if (double.tryParse(val) == null) return 'أدخل سعراً صحيحاً';
                return null;
              },
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
          onPressed: isSaving ? null : _onSave,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ التعديل'),
        ),
      ],
    );
  }
}
