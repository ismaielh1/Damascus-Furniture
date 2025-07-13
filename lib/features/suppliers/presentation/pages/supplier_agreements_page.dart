// lib/features/suppliers/presentation/pages/supplier_agreements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/agreement_card.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/list/agreement_filters.dart';

class SupplierAgreementsPage extends ConsumerWidget {
  const SupplierAgreementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(agreementsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('اتفاقيات الموردين'),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-agreement'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة اتفاقية جديدة',
          ),
        ],
      ),
      body: Column(
        children: [
          const AgreementFilters(), // <-- Widget الجديد
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(agreementsProvider.future),
              child: agreementsAsync.when(
                data: (agreements) {
                  if (agreements.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: const Center(child: Text('لا توجد اتفاقيات تطابق هذا البحث.')),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: agreements.length,
                    itemBuilder: (context, index) => AgreementCard(agreement: agreements[index]),
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
