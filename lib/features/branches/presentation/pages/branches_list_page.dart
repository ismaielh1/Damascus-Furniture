// lib/features/branches/presentation/pages/branches_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/branches/presentation/dialogs/add_edit_branch_dialog.dart';
import 'package:syria_store/features/branches/presentation/providers/branches_provider.dart';

class BranchesListPage extends ConsumerWidget {
  const BranchesListPage({super.key});

  void _showAddEditDialog(BuildContext context, {branch}) {
    showDialog(
      context: context,
      builder: (_) => AddEditBranchDialog(branch: branch),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        // -- بداية الإضافة --
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // -- نهاية الإضافة --
        title: const Text('إدارة الفروع'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'إضافة فرع جديد',
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(branchesProvider.future),
        child: branchesAsync.when(
          data: (branches) {
            if (branches.isEmpty) {
              return const Center(
                child: Text('لا توجد فروع. قم بإضافة فرع جديد.'),
              );
            }
            return ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return Card(
                  color: branch.isMain ? Colors.blue.shade50 : null,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Icon(
                      branch.isMain ? Icons.star : Icons.storefront_outlined,
                      color: branch.isMain
                          ? Colors.amber.shade700
                          : Colors.grey,
                    ),
                    title: Text(
                      branch.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(branch.address ?? 'لا يوجد عنوان'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!branch.isMain)
                          IconButton(
                            icon: const Icon(Icons.star_border_outlined),
                            onPressed: () => ref
                                .read(branchControllerProvider.notifier)
                                .setMainBranch(context, branch.id),
                            tooltip: 'جعله الفرع الرئيسي',
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () =>
                              _showAddEditDialog(context, branch: branch),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('حدث خطأ: $e')),
        ),
      ),
    );
  }
}
