// lib/features/invoices/presentation/widgets/invoice_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/invoices/data/models/invoice_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

class InvoiceCard extends ConsumerWidget {
  // -- التصحيح الأول: استخدام اسم الكلاس الصحيح --
  final InvoiceModel invoice;

  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // نفترض أن هذا الـ provider يجلب ملخصًا ماليًا للعميل المرتبط بالفاتورة
    final financialSummaryAsync = invoice.customerName != null
        ? ref.watch(supplierFinancialSummaryProvider(
            invoice.id)) // Assuming customerId is on invoice
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
            Text('العميل: ${invoice.customerName ?? "زبون عابر"}'),
            Text(
              'المبلغ الإجمالي: ${NumberFormat.simpleCurrency(locale: 'en_US').format(invoice.totalAmount)}',
            ),
            const SizedBox(height: 8),

            // -- التصحيح الثاني: استخدام . للوصول للبيانات --
            if (financialSummaryAsync != null)
              financialSummaryAsync.when(
                data: (summary) {
                  // استخدام dot notation والأسماء الصحيحة من الموديل
                  final balance = summary.balance;

                  // لا نعرض شيئًا إذا كان الرصيد صفرًا
                  if (balance == 0) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'الرصيد المتبقي للعميل: ${NumberFormat.simpleCurrency(locale: 'en_US').format(balance)}',
                          style: TextStyle(
                              color: balance > 0
                                  ? Colors.red.shade700
                                  : Colors.green.shade700),
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
          ],
        ),
      ),
    );
  }
}
