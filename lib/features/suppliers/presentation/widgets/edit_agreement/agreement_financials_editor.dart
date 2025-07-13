// lib/features/suppliers/presentation/widgets/edit_agreement/agreement_financials_editor.dart
import 'package:flutter/material.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/add_payment_dialog.dart';

class AgreementFinancialsEditor extends StatelessWidget {
  final String agreementId;
  final TextEditingController downPaymentController;

  const AgreementFinancialsEditor({
    super.key,
    required this.agreementId,
    required this.downPaymentController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("الدفعات المالية", style: theme.textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.add_card),
              label: const Text('إضافة دفعة'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddPaymentDialog(agreementId: agreementId),
              ),
            ),
          ],
        ),
        const Divider(),
        TextFormField(
          controller: downPaymentController,
          decoration: const InputDecoration(
            labelText: 'إجمالي الدفعات المسجلة',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: false,
        ),
      ],
    );
  }
}
