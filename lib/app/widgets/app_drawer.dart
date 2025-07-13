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
            leading: const Icon(Icons.article_outlined),
            title: const Text('اتفاقيات الموردين'),
            onTap: () {
              Navigator.pop(context);
              context.go('/supplier-agreements');
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('قائمة الموردين'),
            onTap: () {
              Navigator.pop(context);
              context.go('/suppliers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('إدارة المنتجات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/products');
            },
          ),
          const Divider(),
          // --- بداية الإضافة ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'الإعدادات والإدارة',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('إدارة تصنيفات الموردين'),
            onTap: () {
              Navigator.pop(context);
              context.go('/manage-supplier-categories');
            },
          ),
          // --- نهاية الإضافة ---
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: const Text('سجل الإجراءات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/logs');
            },
          ),
        ],
      ),
    );
  }
}
