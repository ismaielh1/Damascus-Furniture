// lib/features/suppliers/presentation/pages/suppliers_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // استيراد go_router
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_list_provider.dart';

class SuppliersListPage extends ConsumerStatefulWidget {
  const SuppliersListPage({super.key});

  @override
  ConsumerState<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends ConsumerState<SuppliersListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(supplierSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(allSuppliersProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('قائمة الموردين'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن مورد بالاسم، الرقم أو العنوان...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              onChanged: (value) {
                ref.read(supplierSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(allSuppliersProvider.future),
              child: suppliersAsync.when(
                data: (suppliers) {
                  if (suppliers.isEmpty) {
                    return const Center(child: Text('لا يوجد موردين يطابقون هذا البحث.'));
                  }
                  return ListView.builder(
                    itemCount: suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(supplier.name.isNotEmpty ? supplier.name[0] : '?'),
                          ),
                          title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(supplier.categoryName ?? 'غير مصنف'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // --- ** بداية التعديل: تفعيل الانتقال ** ---
                            context.push('/suppliers/${supplier.id}', extra: supplier.name);
                            // --- ** نهاية التعديل ** ---
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('حدث خطأ: ${err.toString()}')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
