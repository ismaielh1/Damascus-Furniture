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
            leading: const Icon(Icons.history_edu_outlined),
            title: const Text('سجل الإجراءات'),
            onTap: () {
              Navigator.pop(context);
              context.go('/logs');
            },
          ),
          // يمكنك إضافة المزيد من الروابط هنا مستقبلاً
        ],
      ),
    );
  }
}
