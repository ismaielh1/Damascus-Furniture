// lib/features/invoices/presentation/widgets/details/invoice_header_details.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/invoices/data/models/invoice_model.dart';

class InvoiceHeaderDetails extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceHeaderDetails({super.key, required this.invoice});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('فاتورة مبيعات', style: theme.textTheme.headlineSmall),
                Chip(label: Text(invoice.paymentMethod == 'cash' ? 'نقدي' : 'آجل')),
              ],
            ),
            const Divider(),
            _buildInfoRow(context, Icons.person_outline, 'العميل:', invoice.customerName ?? 'زبون عابر'),
            _buildInfoRow(context, Icons.confirmation_number_outlined, 'رقم الفاتورة:', invoice.invoiceNumber),
            _buildInfoRow(context, Icons.calendar_today_outlined, 'تاريخ الفاتورة:', DateFormat('yyyy/MM/dd').format(invoice.invoiceDate)),
            _buildInfoRow(context, Icons.badge_outlined, 'البائع:', invoice.userName ?? 'غير محدد'),
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              _buildInfoRow(context, Icons.note_alt_outlined, 'ملاحظات:', invoice.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
