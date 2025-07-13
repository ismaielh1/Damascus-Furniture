// lib/features/settings/presentation/widgets/general_management_panel.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralManagementPanel extends StatelessWidget {
  const GeneralManagementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإدارة العامة', style: theme.textTheme.headlineSmall),
        const Divider(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('إدارة الفروع'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/branches'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('إدارة التصنيفات'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/categories'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('إدارة الموظفين'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/employees'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
