// lib/features/reports/presentation/providers/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/reports/data/models/financial_report_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

final financialReportProvider =
    FutureProvider.autoDispose<List<SupplierFinancialReportRow>>((ref) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase.rpc(
          'get_all_suppliers_financial_summary',
        );
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          response,
        );
        return data
            .map((item) => SupplierFinancialReportRow.fromJson(item))
            .toList();
      } catch (e) {
        print('Error fetching financial report: $e');
        rethrow;
      }
    });
