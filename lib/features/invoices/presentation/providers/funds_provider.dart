// lib/features/invoices/presentation/providers/funds_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/data/models/fund_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider رئيسي لجلب كل الصناديق مرة واحدة
final allFundsProvider = FutureProvider.autoDispose<List<FundModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final response = await supabase.from('funds').select();
  return response.map((item) => FundModel.fromJson(item)).toList();
});

// Provider لفلترة صناديق الدولار فقط
final usdFundsProvider = Provider.autoDispose<List<FundModel>>((ref) {
  final allFunds = ref.watch(allFundsProvider).value;
  if (allFunds == null) return [];
  return allFunds.where((fund) => fund.currency == 'USD').toList();
});

// Provider لفلترة صناديق الليرة السورية فقط
final sypFundsProvider = Provider.autoDispose<List<FundModel>>((ref) {
  final allFunds = ref.watch(allFundsProvider).value;
  if (allFunds == null) return [];
  return allFunds.where((fund) => fund.currency == 'SYP').toList();
});
