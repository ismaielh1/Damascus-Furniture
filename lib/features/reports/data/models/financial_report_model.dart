// lib/features/reports/data/models/financial_report_model.dart
class SupplierFinancialReportRow {
  final String supplierId;
  final String supplierName;
  final String? supplierCode;
  final double totalAgreements;
  final double totalPaid;
  final double balance;

  SupplierFinancialReportRow({
    required this.supplierId,
    required this.supplierName,
    this.supplierCode,
    required this.totalAgreements,
    required this.totalPaid,
    required this.balance,
  });

  factory SupplierFinancialReportRow.fromJson(Map<String, dynamic> json) {
    return SupplierFinancialReportRow(
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      supplierCode: json['supplier_code'],
      totalAgreements: (json['total_agreements'] as num? ?? 0).toDouble(),
      totalPaid: (json['total_paid'] as num? ?? 0).toDouble(),
      balance: (json['balance'] as num? ?? 0).toDouble(),
    );
  }
}
