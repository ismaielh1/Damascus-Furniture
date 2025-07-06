// lib/features/suppliers/presentation/pages/supplier_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/agreement_card.dart';

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
    final summaryAsync = ref.watch(
      supplierFinancialSummaryProvider(supplierId),
    );
    final paymentsAsync = ref.watch(supplierPaymentsProvider(supplierId));
    final agreementsAsync = ref.watch(agreementsBySupplierProvider(supplierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('سجل: $supplierName')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(supplierFinancialSummaryProvider(supplierId));
          ref.invalidate(supplierPaymentsProvider(supplierId));
          ref.invalidate(agreementsBySupplierProvider(supplierId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summaryAsync.when(
                data: (summary) => Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'الملخص المالي',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        _buildFinancialSummaryRow(
                          'إجمالي الاتفاقيات (له):',
                          '\$${summary.totalAgreements.toStringAsFixed(2)}',
                          Colors.red,
                        ),
                        _buildFinancialSummaryRow(
                          'إجمالي الدفعات (لنا):',
                          '\$${summary.totalPaid.toStringAsFixed(2)}',
                          Colors.green,
                        ),
                        const Divider(),
                        _buildFinancialSummaryRow(
                          'الرصيد النهائي:',
                          '\$${summary.balance.toStringAsFixed(2)}',
                          Theme.of(context).primaryColor,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('خطأ في جلب الملخص المالي: $e'),
              ),
              const SizedBox(height: 24),
              Text('آخر الدفعات', style: theme.textTheme.titleLarge),
              const Divider(),
              paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty)
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('لا توجد دفعات مسجلة.'),
                      ),
                    );
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text(
                          'دفعة بقيمة \$${payment.amount.toStringAsFixed(2)}',
                        ),
                        subtitle: Text(
                          'بتاريخ: ${DateFormat('yyyy/MM/dd').format(payment.paymentDate)}',
                        ),
                        onTap: () => context.push(
                          '/supplier-agreements/details/${payment.agreementId}',
                        ),
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => Text('خطأ في جلب الدفعات: $e'),
              ),
              const SizedBox(height: 24),
              Text('كل الاتفاقيات', style: theme.textTheme.titleLarge),
              const Divider(),
              agreementsAsync.when(
                data: (agreements) {
                  if (agreements.isEmpty)
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('لا توجد اتفاقيات لهذا المورد.'),
                      ),
                    );
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: agreements.length,
                    itemBuilder: (context, index) {
                      return AgreementCard(agreement: agreements[index]);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => Text('خطأ في جلب الاتفاقيات: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryRow(
    String title,
    String amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
