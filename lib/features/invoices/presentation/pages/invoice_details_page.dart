// lib/features/invoices/presentation/pages/invoice_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoices_list_provider.dart';
import 'package:syria_store/features/invoices/presentation/widgets/details/invoice_financial_summary.dart';
import 'package:syria_store/features/invoices/presentation/widgets/details/invoice_header_details.dart';
import 'package:syria_store/features/invoices/presentation/widgets/details/invoice_items_list_details.dart';

class InvoiceDetailsPage extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailsPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceDetailsProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(invoiceDetailsProvider(invoiceId));
          ref.invalidate(invoiceItemsProvider(invoiceId));
        },
        child: invoiceAsync.when(
          data: (invoice) {
            if (invoice == null) {
              return const Center(child: Text('لم يتم العثور على الفاتورة.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InvoiceHeaderDetails(invoice: invoice),
                  const SizedBox(height: 24),
                  InvoiceItemsListDetails(invoiceId: invoice.id),
                  const SizedBox(height: 24),
                  InvoiceFinancialSummary(invoice: invoice),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('خطأ في جلب تفاصيل الفاتورة: $err')),
        ),
      ),
    );
  }
}
