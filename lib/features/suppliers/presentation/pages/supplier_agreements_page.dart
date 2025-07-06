import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/agreement_card.dart';

class SupplierAgreementsPage extends ConsumerStatefulWidget {
  const SupplierAgreementsPage({super.key});

  @override
  ConsumerState<SupplierAgreementsPage> createState() =>
      _SupplierAgreementsPageState();
}

class _SupplierAgreementsPageState
    extends ConsumerState<SupplierAgreementsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // مزامنة حقل البحث مع الـ provider عند بدء التشغيل
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agreementsAsync = ref.watch(agreementsProvider);
    final selectedStatus = ref.watch(statusFilterProvider);

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
          // --- ** بداية الإضافة: شريط البحث والفلترة ** ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مورد أو تفاصيل اتفاقية...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: selectedStatus == null,
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).state =
                                null,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('قيد التسليم'),
                        selected: selectedStatus == 'pending_delivery',
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).state =
                                'pending_delivery',
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        selectedColor: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('مكتمل'),
                        selected: selectedStatus == 'completed',
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).state =
                                'completed',
                        backgroundColor: Colors.green.withOpacity(0.1),
                        selectedColor: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('ملغي'),
                        selected: selectedStatus == 'cancelled',
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).state =
                                'cancelled',
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        selectedColor: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- ** نهاية الإضافة ** ---
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
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const Center(
                            child: Text('لا توجد اتفاقيات تطابق هذا البحث.'),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}
