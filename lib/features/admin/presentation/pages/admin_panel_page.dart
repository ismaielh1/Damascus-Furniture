// lib/features/admin/presentation/pages/admin_panel_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminPanelPage extends ConsumerWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // قائمة بالوظائف الإدارية
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('إدارة المنتجات'),
            subtitle: const Text('إضافة، تعديل، وحذف المنتجات'),
            onTap: () {
              // TODO: Navigate to Manage Products screen
              print('Navigate to Manage Products');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('إدارة الفئات'),
            subtitle: const Text('إضافة، تعديل، وحذف الفئات'),
            onTap: () {
              // TODO: Navigate to Manage Categories screen
              print('Navigate to Manage Categories');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.view_carousel_outlined),
            title: const Text('إدارة البانرات'),
            subtitle: const Text('إضافة، تعديل، وحذف البانرات الإعلانية'),
            onTap: () {
              // TODO: Navigate to Manage Banners screen
              print('Navigate to Manage Banners');
            },
          ),
        ],
      ),
    );
  }
}
