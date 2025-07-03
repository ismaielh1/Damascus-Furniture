// lib/features/logs/presentation/pages/logs_page.dart
import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الإجراءات'),
      ),
      body: const Center(
        child: Text('سيتم بناء هذه الصفحة لاحقًا لعرض كل السجلات'),
      ),
    );
  }
}
