// lib/features/suppliers/presentation/widgets/supplier_details/recent_payments_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';

class RecentPaymentsList extends ConsumerWidget {
  final String supplierId;
  const RecentPaymentsList({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(supplierPaymentsProvider(supplierId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  leading: const Icon(Icons.payment_outlined),
                  title: Text(
                    'دفعة بقيمة \$${payment.amount.toStringAsFixed(2)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بتاريخ: ${DateFormat('yyyy/MM/dd', 'en_US').format(payment.paymentDate)}',
                      ),
                      if (payment.notes != null && payment.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'ملاحظات: ${payment.notes!}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => context.push(
                    '/supplier-agreements/details/${payment.agreementId}',
                  ),
                );
              },
            );
          },
          loading: () =>
              const SizedBox.shrink(), // No loader for a secondary list
          error: (e, s) => Text('خطأ في جلب الدفعات: $e'),
        ),
      ],
    );
  }
}
