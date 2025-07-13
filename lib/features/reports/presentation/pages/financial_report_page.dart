// lib/features/reports/presentation/pages/financial_report_page.dart
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/app/widgets/app_drawer.dart';
import 'package:syria_store/core/utils/downloader.dart'
    if (dart.library.html) 'package:syria_store/core/utils/downloader_web.dart';
import 'package:syria_store/features/reports/data/models/financial_report_model.dart';
import 'package:syria_store/features/reports/presentation/providers/report_provider.dart';

class FinancialReportPage extends ConsumerWidget {
  const FinancialReportPage({super.key});

  Future<void> _exportToExcel(
    BuildContext context,
    List<SupplierFinancialReportRow> data,
  ) async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheetObject = excel['Sheet1'];

      sheetObject.isRTL = true;

      sheetObject.appendRow([
         TextCellValue('رمز المورد'),
         TextCellValue('اسم المورد'),
         TextCellValue('إجمالي الاتفاقيات (له)'),
         TextCellValue('إجمالي الدفعات (لنا)'),
         TextCellValue('الرصيد النهائي'),
      ]);

      for (var row in data) {
        sheetObject.appendRow([
          TextCellValue(row.supplierCode ?? 'N/A'),
          TextCellValue(row.supplierName),
          DoubleCellValue(row.totalAgreements),
          DoubleCellValue(row.totalPaid),
          DoubleCellValue(row.balance),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes != null) {
        await saveAndLaunchFile(fileBytes, "التقرير المالي للموردين.xlsx");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تصدير الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(financialReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('التقرير المالي للموردين'),
        actions: [
          reportAsync.when(
            data: (data) => data.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.download_for_offline_outlined),
                    onPressed: () => _exportToExcel(context, data),
                    tooltip: 'تصدير إلى Excel',
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(financialReportProvider.future),
        child: reportAsync.when(
          data: (reportData) {
            if (reportData.isEmpty) {
              return const Center(child: Text('لا توجد بيانات لعرضها.'));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      headingRowColor: MaterialStateProperty.all(
                        theme.primaryColor.withOpacity(0.1),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'رمز المورد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'اسم المورد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'إجمالي له',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'إجمالي لنا',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'الرصيد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: reportData.map((row) {
                        final balanceColor = row.balance > 0
                            ? Colors.red.shade700
                            : (row.balance < 0
                                  ? Colors.green.shade700
                                  : Colors.black);
                        return DataRow(
                          cells: [
                            DataCell(Text(row.supplierCode ?? 'N/A')),
                            DataCell(Text(row.supplierName)),
                            DataCell(
                              Text(
                                '\$${row.totalAgreements.toStringAsFixed(2)}',
                              ),
                            ),
                            DataCell(
                              Text('\$${row.totalPaid.toStringAsFixed(2)}'),
                            ),
                            DataCell(
                              Text(
                                '\$${row.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: balanceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('حدث خطأ في جلب التقرير: $e')),
        ),
      ),
    );
  }
}
