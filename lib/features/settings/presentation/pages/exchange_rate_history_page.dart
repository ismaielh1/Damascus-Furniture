// lib/features/settings/presentation/pages/exchange_rate_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/settings/presentation/providers/settings_provider.dart';

class ExchangeRateHistoryPage extends ConsumerWidget {
  const ExchangeRateHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(exchangeRateHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('سجل أسعار الصرف')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(exchangeRateHistoryProvider.future),
        child: historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return const Center(child: Text('لا يوجد سجل لعرضه.'));
            }
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final rate = history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.watch_later_outlined),
                    title: Text(
                      'السعر: ${rate.rateUsdToSyp}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // -- بداية التعديل --
                    subtitle: Text(
                      'الوقت: ${DateFormat('yyyy/MM/dd, hh:mm a', 'en_US').format(rate.rateTimestamp)}',
                    ),
                    // -- نهاية التعديل --
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('حدث خطأ في جلب السجل: $e')),
        ),
      ),
    );
  }
}
