// lib/features/invoices/presentation/widgets/invoice_filters.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoices_list_provider.dart';

class InvoiceFilters extends ConsumerStatefulWidget {
  const InvoiceFilters({super.key});

  @override
  ConsumerState<InvoiceFilters> createState() => _InvoiceFiltersState();
}

class _InvoiceFiltersState extends ConsumerState<InvoiceFilters> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(invoiceSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentFilter = ref.watch(invoicePaymentMethodFilterProvider);
    final deliveryFilter = ref.watch(invoiceDeliveryStatusFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'ابحث برقم الفاتورة، اسم العميل...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              ref.read(invoiceSearchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: [
              FilterChip(
                label: const Text('الكل'),
                selected: paymentFilter == null && deliveryFilter == null,
                onSelected: (_) {
                  ref.read(invoicePaymentMethodFilterProvider.notifier).state = null;
                  ref.read(invoiceDeliveryStatusFilterProvider.notifier).state = null;
                },
              ),
              FilterChip(
                label: const Text('نقدي'),
                selected: paymentFilter == 'cash',
                onSelected: (selected) => ref.read(invoicePaymentMethodFilterProvider.notifier).state = selected ? 'cash' : null,
              ),
              FilterChip(
                label: const Text('آجل'),
                selected: paymentFilter == 'credit',
                onSelected: (selected) => ref.read(invoicePaymentMethodFilterProvider.notifier).state = selected ? 'credit' : null,
              ),
              FilterChip(
                label: const Text('تم التسليم'),
                selected: deliveryFilter == 'delivered',
                backgroundColor: Colors.green.withOpacity(0.1),
                selectedColor: Colors.green.shade700,
                onSelected: (selected) => ref.read(invoiceDeliveryStatusFilterProvider.notifier).state = selected ? 'delivered' : null,
              ),
              FilterChip(
                label: const Text('قيد التسليم'),
                selected: deliveryFilter == 'pending',
                backgroundColor: Colors.orange.withOpacity(0.1),
                selectedColor: Colors.orange.shade700,
                onSelected: (selected) => ref.read(invoiceDeliveryStatusFilterProvider.notifier).state = selected ? 'pending' : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
