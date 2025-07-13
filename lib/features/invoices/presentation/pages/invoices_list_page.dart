// lib/features/invoices/presentation/pages/invoices_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoices_list_provider.dart';
import 'package:syria_store/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:syria_store/features/invoices/presentation/widgets/invoice_filters.dart';

class InvoicesListPage extends ConsumerWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('سجل المبيعات'),
        actions: [
          IconButton(
            onPressed: () => context.push('/create-invoice'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'فاتورة جديدة',
          ),
        ],
      ),
      body: Column(
        children: [
          const InvoiceFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(invoicesProvider.future),
              child: invoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: const Center(child: Text('لا توجد فواتير تطابق هذا البحث.')),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) => InvoiceCard(invoice: invoices[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('حدث خطأ: \${err.toString()}')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
