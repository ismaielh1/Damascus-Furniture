// lib/app/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'مفروشات دمشق',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('فاتورة جديدة'),
            onTap: () {
              Navigator.pop(context);
              context.push('/create-invoice');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('سجل المبيعات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/invoices');
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('اتفاقيات الموردين'),
            onTap: () {
              Navigator.pop(context);
              context.go('/supplier-agreements');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('قائمة الموردين'),
            onTap: () {
              Navigator.pop(context);
              context.go('/suppliers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('إدارة العملاء'),
            onTap: () {
              Navigator.pop(context);
              context.go('/customers');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('إدارة المنتجات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/products');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('التقرير المالي'),
            onTap: () {
              Navigator.pop(context);
              context.go('/financial-report');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: const Text('سجل الإجراءات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/logs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
        ],
      ),
    );
  }
}
