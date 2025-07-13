// lib/features/suppliers/presentation/dialogs/edit_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_financials_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';

class EditPaymentDialog extends ConsumerStatefulWidget {
  final PaymentModel payment;
  final String agreementId;

  const EditPaymentDialog({
    super.key,
    required this.payment,
    required this.agreementId,
  });

  @override
  ConsumerState<EditPaymentDialog> createState() => _EditPaymentDialogState();
}

class _EditPaymentDialogState extends ConsumerState<EditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.payment.amount.toString(),
    );
    _notesController = TextEditingController(text: widget.payment.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .updatePayment(
            context: context,
            paymentId: widget.payment.id,
            agreementId: widget.agreementId,
            newAmount: double.parse(_amountController.text),
            newNotes: _notesController.text.trim(),
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
      title: const Text('تعديل الدفعة'),
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
