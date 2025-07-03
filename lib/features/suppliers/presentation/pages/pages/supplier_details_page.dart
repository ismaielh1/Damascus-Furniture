// lib/features/suppliers/presentation/pages/supplier_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
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
    // مشاهدة الـ provider الجديد مع تمرير رقم المورد
    final agreementsAsync = ref.watch(agreementsBySupplierProvider(supplierId));

    return Scaffold(
      appBar: AppBar(title: Text('سجل المورد: $supplierName')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(agreementsBySupplierProvider(supplierId).future),
        child: agreementsAsync.when(
          data: (agreements) {
            if (agreements.isEmpty) {
              return const Center(child: Text('لا توجد اتفاقيات لهذا المورد.'));
            }
            // استخدام نفس بطاقة الاتفاقية لعرض البيانات
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: agreements.length,
              itemBuilder: (context, index) =>
                  AgreementCard(agreement: agreements[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('حدث خطأ: ${err.toString()}')),
        ),
      ),
    );
  }
}
