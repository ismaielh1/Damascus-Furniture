import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/customers/presentation/dialogs/add_edit_customer_dialog.dart';
import 'package:syria_store/features/customers/presentation/providers/customers_provider.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';


class CustomersListPage extends ConsumerStatefulWidget {
  const CustomersListPage({super.key});

  @override
  ConsumerState<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends ConsumerState<CustomersListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(customerSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddEditCustomerDialog());
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(allCustomersProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('قائمة العملاء')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'إضافة عميل جديد',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل بالاسم أو الرقم...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(customerSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(allCustomersProvider.future),
              child: customersAsync.when(
                data: (customers) {
                  if (customers.isEmpty) {
                    return const Center(
                      child: Text('لا يوجد عملاء. قم بإضافة عميل جديد.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(customer.name.isNotEmpty ? customer.name[0] : '?'),
                          ),
                          title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(customer.phoneNumber ?? 'لا يوجد رقم هاتف'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // لاحقاً: سننتقل إلى صفحة سجل العميل
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('حدث خطأ: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
