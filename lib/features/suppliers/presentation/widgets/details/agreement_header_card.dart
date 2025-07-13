import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

class AgreementHeaderCard extends StatelessWidget {
  final SupplierAgreement agreement;
  final Map<String, dynamic> statusInfo;

  const AgreementHeaderCard({
    super.key,
    required this.agreement,
    required this.statusInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agreement.contactName ?? 'مورد غير محدد',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'الحالة: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 18),
                const SizedBox(width: 4),
                Text(
                  statusInfo['text'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: statusInfo['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (agreement.expectedDeliveryDate != null)
              Row(
                children: [
                  const Text(
                    'تاريخ التسليم: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat(
                      'yyyy/MM/dd',
                      'en_US',
                    ).format(agreement.expectedDeliveryDate!),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            const Text(
              'الملاحظات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              agreement.agreementDetails.isNotEmpty
                  ? agreement.agreementDetails
                  : 'لا يوجد',
            ),
          ],
        ),
      ),
    );
  }
}
