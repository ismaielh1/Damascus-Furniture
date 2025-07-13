// lib/features/invoices/presentation/widgets/payment_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/data/models/fund_model.dart';
import 'package:syria_store/features/invoices/presentation/providers/funds_provider.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';

class PaymentSectionWidget extends ConsumerWidget {
  final TextEditingController usdPaymentController;
  final TextEditingController sypPaymentController;
  final ValueChanged<FundModel?> onUsdFundChanged;
  final ValueChanged<FundModel?> onSypFundChanged;
  final FundModel? selectedUsdFund;
  final FundModel? selectedSypFund;

  const PaymentSectionWidget({
    super.key,
    required this.usdPaymentController,
    required this.sypPaymentController,
    required this.onUsdFundChanged,
    required this.onSypFundChanged,
    this.selectedUsdFund,
    this.selectedSypFund,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceState = ref.watch(invoiceFormProvider);
    final usdFunds = ref.watch(usdFundsProvider);
    final sypFunds = ref.watch(sypFundsProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدفع', style: theme.textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children: [
                ToggleButtons(
                  isSelected: [
                    invoiceState.paymentMethod == 'cash',
                    invoiceState.paymentMethod == 'credit',
                  ],
                  onPressed: (index) => ref
                      .read(invoiceFormProvider.notifier)
                      .setPaymentMethod(index == 0 ? 'cash' : 'credit'),
                  borderRadius: BorderRadius.circular(8),
                  constraints: const BoxConstraints(minHeight: 40.0),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('نقدي'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('آجل'),
                    ),
                  ],
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: invoiceState.deliveryStatus,
                    decoration: const InputDecoration(
                      labelText: 'حالة التسليم',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'delivered',
                        child: Text('تم التسليم'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('قيد التسليم'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(invoiceFormProvider.notifier)
                            .setDeliveryStatus(val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'تسجيل دفعة (رعبون أو دفعة كاملة):',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: usdPaymentController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المدفوع \$',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<FundModel>(
                    hint: const Text('صندوق الدولار'),
                    value: selectedUsdFund,
                    items: usdFunds
                        .map(
                          (f) =>
                              DropdownMenuItem(value: f, child: Text(f.name)),
                        )
                        .toList(),
                    onChanged: onUsdFundChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: sypPaymentController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المدفوع ل.س',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<FundModel>(
                    hint: const Text('صندوق السوري'),
                    value: selectedSypFund,
                    items: sypFunds
                        .map(
                          (f) =>
                              DropdownMenuItem(value: f, child: Text(f.name)),
                        )
                        .toList(),
                    onChanged: onSypFundChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
