// lib/features/settings/presentation/widgets/exchange_rate_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/settings/presentation/providers/settings_provider.dart';

class ExchangeRateManager extends ConsumerStatefulWidget {
  const ExchangeRateManager({super.key});

  @override
  ConsumerState<ExchangeRateManager> createState() => _ExchangeRateManagerState();
}

class _ExchangeRateManagerState extends ConsumerState<ExchangeRateManager> {
  final _rateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final rate = double.tryParse(_rateController.text);
      if (rate == null) return;
      ref.read(settingsControllerProvider.notifier)
          .setTodayRate(context, rate: rate)
          .then((success) {
        if (success) {
          _rateController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestRateAsync = ref.watch(latestExchangeRateProvider);
    final isLoading = ref.watch(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('إدارة سعر الصرف', style: theme.textTheme.headlineSmall),
            IconButton(
              icon: const Icon(Icons.history_outlined),
              onPressed: () => context.push('/settings/history'),
              tooltip: 'عرض سجل الأسعار',
            ),
          ],
        ),
        const Divider(height: 24),
        latestRateAsync.when(
          data: (rate) {
            if (rate == null) {
              return Text('لم يتم تسجيل أي سعر صرف حتى الآن.', style: theme.textTheme.titleMedium);
            }
            return Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.currency_exchange, color: Colors.green),
                title: Text('آخر سعر صرف مسجل للدولار', style: theme.textTheme.titleMedium),
                subtitle: Text('في: ${DateFormat('yyyy/MM/dd, hh:mm a', 'en_US').format(rate.rateTimestamp)}'),
                trailing: Text(
                  rate.rateUsdToSyp.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('خطأ في جلب السعر: $e'),
        ),
        const SizedBox(height: 32),
        Text('إدخال سعر جديد الآن', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'سعر صرف الدولار الحالي',
                    hintText: 'مثال: 14000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'الحقل مطلوب';
                    if (double.tryParse(val) == null) return 'الرجاء إدخال رقم صحيح';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
