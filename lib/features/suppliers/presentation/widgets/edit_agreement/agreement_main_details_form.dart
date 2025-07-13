// lib/features/suppliers/presentation/widgets/edit_agreement/agreement_main_details_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgreementMainDetailsForm extends StatelessWidget {
  final String contactName;
  final TextEditingController notesController;
  final DateTime? selectedDeliveryDate;
  final VoidCallback onPickDate;

  const AgreementMainDetailsForm({
    super.key,
    required this.contactName,
    required this.notesController,
    required this.selectedDeliveryDate,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المورد: $contactName', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text("التفاصيل الأساسية", style: theme.textTheme.titleMedium),
            const Divider(),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات الاتفاقية'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedDeliveryDate != null
                    ? DateFormat('yyyy/MM/dd').format(selectedDeliveryDate!)
                    : '',
              ),
              decoration: const InputDecoration(
                labelText: 'تاريخ التسليم المتوقع',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: onPickDate,
            ),
          ],
        ),
      ),
    );
  }
}
