// lib/features/suppliers/presentation/widgets/add_agreement/agreement_main_form.dart
import 'package:flutter/material.dart';

class AgreementMainForm extends StatelessWidget {
  final TextEditingController notesController;
  final TextEditingController downPaymentController;

  const AgreementMainForm({
    super.key,
    required this.notesController,
    required this.downPaymentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(labelText: 'ملاحظات الاتفاقية'),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: downPaymentController,
          decoration: const InputDecoration(
            labelText: 'الدفعة المقدمة (اختياري)',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
