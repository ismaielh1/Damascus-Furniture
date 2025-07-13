// lib/features/suppliers/presentation/widgets/receive_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';

class ReceiveItemDialog extends ConsumerStatefulWidget {
  final AgreementItem item;
  final String agreementId;
  const ReceiveItemDialog({
    super.key,
    required this.item,
    required this.agreementId,
  });

  @override
  ConsumerState<ReceiveItemDialog> createState() => _ReceiveItemDialogState();
}

class _ReceiveItemDialogState extends ConsumerState<ReceiveItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text);
      if (quantity == null) return;

      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .receiveItems(
            context: context,
            itemId: widget.item.id.toString(), // ✅ تم التعديل هنا
            agreementId: widget.agreementId,
            quantity: quantity,
            notes: _notesController.text.trim(),
          )
          .then((success) {
            if (success && mounted) {
              Navigator.of(context).pop();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(updateAgreementStatusControllerProvider);
    final remainingQuantity =
        widget.item.totalQuantity - widget.item.receivedQuantitySoFar;
    return AlertDialog(
      title: Text('استلام: ${widget.item.product?.name ?? "منتج غير معرف"}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكمية المطلوبة: ${widget.item.totalQuantity}'),
            Text('الكمية المستلمة: ${widget.item.receivedQuantitySoFar}'),
            Text(
              'الكمية المتبقية: $remainingQuantity',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'الكمية المستلمة الآن',
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'الحقل مطلوب';
                final quantity = int.tryParse(val);
                if (quantity == null) return 'الرجاء إدخال رقم صحيح';
                if (quantity <= 0) return 'يجب أن تكون الكمية أكبر من صفر';
                if (quantity > remainingQuantity)
                  return 'لا يمكن استلام كمية أكبر من المتبقية';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
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
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد الاستلام'),
        ),
      ],
    );
  }
}
