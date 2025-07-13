// lib/features/invoices/presentation/widgets/details/invoice_financial_summary.dart
import 'package:flutter/material.dart';
import 'package:syria_store/features/invoices/data/models/invoice_model.dart';

class InvoiceFinancialSummary extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoiceFinancialSummary({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = invoice.totalAmount + (invoice.discountAmount ?? 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFinancialRow(theme, 'المجموع الفرعي:', '\$${subtotal.toStringAsFixed(2)}'),
            _buildFinancialRow(theme, 'الخصم:', '-\$${(invoice.discountAmount ?? 0).toStringAsFixed(2)}'),
            const Divider(),
            _buildFinancialRow(
              theme,
              'المجموع النهائي:',
              '\$${invoice.totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(ThemeData theme, String title, String value, {bool isTotal = false}) {
    final style = isTotal
        ? theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)
        : theme.textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
