// lib/features/suppliers/data/models/supplier_financials_model.dart

// موديل لتخزين الملخص المالي (لا تغيير هنا)
class SupplierFinancialSummary {
  final double totalAgreements;
  final double totalPaid;
  final double balance;

  SupplierFinancialSummary({
    required this.totalAgreements,
    required this.totalPaid,
    required this.balance,
  });

  factory SupplierFinancialSummary.fromJson(Map<String, dynamic> json) {
    return SupplierFinancialSummary(
      totalAgreements: (json['total_agreements'] as num? ?? 0).toDouble(),
      totalPaid: (json['total_paid'] as num? ?? 0).toDouble(),
      balance: (json['balance'] as num? ?? 0).toDouble(),
    );
  }
}

// موديل لتمثيل دفعة واحدة
class PaymentModel {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final String agreementId;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.agreementId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      // --- ** بداية الإصلاح ** ---
      // تحويل المعرّفات إلى نص بشكل آمن لتجنب خطأ الأنواع
      id: json['id'].toString(),
      agreementId: json['agreement_id'].toString(),
      // --- ** نهاية الإصلاح ** ---
      amount: (json['paid_amount'] as num? ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      notes: json['notes'],
    );
  }
}
