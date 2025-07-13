// lib/features/employees/presentation/pages/employees_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/employees/presentation/dialogs/add_edit_employee_dialog.dart';
import 'package:syria_store/features/invoices/presentation/providers/employees_provider.dart';

class EmployeesListPage extends ConsumerWidget {
  const EmployeesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الموظفين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddEditEmployeeDialog(),
        ),
        child: const Icon(Icons.add),
        tooltip: 'إضافة موظف جديد',
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(employeesProvider.future),
        child: employeesAsync.when(
          data: (employees) => ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(employee.name),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
