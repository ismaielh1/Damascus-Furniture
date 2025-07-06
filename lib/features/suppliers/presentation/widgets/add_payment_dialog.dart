// lib/features/suppliers/presentation/widgets/add_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final String agreementId;
  const AddPaymentDialog({super.key, required this.agreementId});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null) return;

      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .addPayment(
            context: context,
            agreementId: widget.agreementId,
            amount: amount,
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
    return AlertDialog(
      title: const Text('إضافة دفعة جديدة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'مبلغ الدفعة',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'الحقل مطلوب';
                if (double.tryParse(val) == null)
                  return 'الرجاء إدخال رقم صحيح';
                if (double.tryParse(val)! <= 0)
                  return 'يجب أن يكون المبلغ أكبر من صفر';
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
              : const Text('حفظ الدفعة'),
        ),
      ],
    );
  }
}
