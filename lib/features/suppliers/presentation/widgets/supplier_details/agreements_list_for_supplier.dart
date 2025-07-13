// lib/features/suppliers/presentation/widgets/supplier_details/agreements_list_for_supplier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/agreement_card.dart';

class AgreementsListForSupplier extends ConsumerWidget {
  final String supplierId;
  const AgreementsListForSupplier({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(agreementsBySupplierProvider(supplierId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }
}
