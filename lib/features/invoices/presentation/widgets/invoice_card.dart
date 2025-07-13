import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/invoices/data/models/invoice_model.dart';
// افترض وجود هذا الـ provider بناءً على السياق
import 'package:syria_store/features/reports/presentation/providers/report_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

class InvoiceCard extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // نفترض أن هذا الـ provider يجلب ملخصًا ماليًا للعميل المرتبط بالفاتورة
    final financialSummaryAsync = invoice.contactId != null
        ? ref.watch(supplierFinancialSummaryProvider(invoice.contactId!))
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${invoice.invoiceNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd').format(invoice.invoiceDate),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            Text('العميل: ${invoice.contactName ?? "زبون عابر"}'),
            Text(
              'المبلغ الإجمالي: ${NumberFormat.simpleCurrency(locale: 'en_US').format(invoice.totalAmount)}',
            ),
            const SizedBox(height: 8),

            // ==== بداية التعديل هنا ====
            if (financialSummaryAsync != null)
              financialSummaryAsync.when(
                data: (summary) {
                  // استخدام tryParse للأمان
                  final totalDue =
                      double.tryParse(
                        summary['total_due']?.toString() ?? '0.0',
                      ) ??
                      0.0;
                  final remainingBalance =
                      double.tryParse(
                        summary['remaining_balance']?.toString() ?? '0.0',
                      ) ??
                      0.0;

                  if (totalDue == 0 && remainingBalance == 0) {
                    return const SizedBox.shrink(); // لا تعرض شيئًا إذا كانت القيم صفرية
                  }

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        if (totalDue > 0)
                          Text(
                            'إجمالي الديون على العميل: ${NumberFormat.simpleCurrency(locale: 'en_US').format(totalDue)}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        if (remainingBalance != 0)
                          Text(
                            'الرصيد المتبقي للعميل: ${NumberFormat.simpleCurrency(locale: 'en_US').format(remainingBalance)}',
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) => Text(
                  'خطأ في تحميل البيانات المالية',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            // ==== نهاية التعديل ====
          ],
        ),
      ),
    );
  }
}
