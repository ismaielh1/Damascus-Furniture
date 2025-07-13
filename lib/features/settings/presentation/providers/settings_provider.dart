// lib/features/settings/presentation/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/settings/data/models/exchange_rate_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لجلب آخر سعر صرف مسجل
final latestExchangeRateProvider =
    FutureProvider.autoDispose<ExchangeRateModel?>((ref) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('daily_exchange_rates')
            .select()
            .order(
              'rate_timestamp',
              ascending: false,
            ) // الترتيب حسب الوقت الدقيق
            .limit(1)
            .single();
        return ExchangeRateModel.fromJson(response);
      } catch (e) {
        print('No exchange rate found: $e');
        return null;
      }
    });

// Provider جديد لجلب كل سجل أسعار الصرف
final exchangeRateHistoryProvider =
    FutureProvider.autoDispose<List<ExchangeRateModel>>((ref) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase
          .from('daily_exchange_rates')
          .select()
          .order(
            'rate_timestamp',
            ascending: false,
          ); // الترتيب حسب الوقت الدقيق
      return response.map((item) => ExchangeRateModel.fromJson(item)).toList();
    });

// Controller لحفظ سعر الصرف
final settingsControllerProvider =
    StateNotifierProvider.autoDispose<SettingsController, bool>((ref) {
      return SettingsController(ref: ref);
    });

class SettingsController extends StateNotifier<bool> {
  final Ref _ref;
  SettingsController({required Ref ref}) : _ref = ref, super(false);

  Future<bool> setTodayRate(
    BuildContext context, {
    required double rate,
  }) async {
    state = true;
    try {
      // لم نعد نستخدم upsert، بل نضيف سجلاً جديداً في كل مرة
      await _ref.read(supabaseProvider).from('daily_exchange_rates').insert({
        'rate_usd_to_syp': rate,
        // سيتم إضافة التاريخ والوقت الحالي تلقائياً من قاعدة البيانات
      });

      _ref.invalidate(latestExchangeRateProvider);
      _ref.invalidate(exchangeRateHistoryProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ سعر الصرف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ سعر الصرف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }
}
