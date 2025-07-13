// lib/features/suppliers/presentation/widgets/supplier_details/financial_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

class FinancialSummaryCard extends ConsumerWidget {
  final String supplierId;
  const FinancialSummaryCard({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      supplierFinancialSummaryProvider(supplierId),
    );
    final theme = Theme.of(context);

    return summaryAsync.when(
      data: (summary) => Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('الملخص المالي', style: theme.textTheme.titleLarge),
              const Divider(height: 24),
              _buildFinancialSummaryRow(
                'إجمالي الاتفاقيات (له):',
                '\$${summary.totalAgreements.toStringAsFixed(2)}',
                Colors.blue,
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
                theme.primaryColor,
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('خطأ في جلب الملخص المالي: $e'),
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
