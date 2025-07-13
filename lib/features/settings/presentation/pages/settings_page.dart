// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/features/settings/presentation/widgets/exchange_rate_manager.dart';
import 'package:syria_store/features/settings/presentation/widgets/general_management_panel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExchangeRateManager(),
            SizedBox(height: 40),
            GeneralManagementPanel(),
          ],
        ),
      ),
    );
  }
}
