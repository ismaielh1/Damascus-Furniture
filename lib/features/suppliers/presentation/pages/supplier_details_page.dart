// lib/features/suppliers/presentation/pages/supplier_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/supplier_details/agreements_list_for_supplier.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/supplier_details/financial_summary_card.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/supplier_details/recent_payments_list.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/supplier_details/receipts_log_list.dart';


class SupplierDetailsPage extends ConsumerWidget {
  final String supplierId;
  final String supplierName;
  const SupplierDetailsPage({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('سجل: $supplierName')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(supplierFinancialSummaryProvider(supplierId));
          ref.invalidate(supplierPaymentsProvider(supplierId));
          ref.invalidate(agreementsBySupplierProvider(supplierId));
          ref.invalidate(receiptsByContactProvider(supplierId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialSummaryCard(supplierId: supplierId),
              const SizedBox(height: 24),
              RecentPaymentsList(supplierId: supplierId),
              const SizedBox(height: 24),
              ReceiptsLogList(supplierId: supplierId),
              const SizedBox(height: 24),
              AgreementsListForSupplier(supplierId: supplierId),
            ],
          ),
        ),
      ),
    );
  }
}
