// lib/features/suppliers/data/models/supplier_financials_model.dart
import 'package:equatable/equatable.dart';

// نموذج للملخص المالي
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
      totalAgreements: (json['total_agreements'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// نموذج لسجل الدفعات
class PaymentModel extends Equatable {
  final int id; // -- تمت الإضافة --
  final double amount;
  final DateTime paymentDate;
  final String agreementId;
  final String? notes;

  const PaymentModel({
    required this.id, // -- تمت الإضافة --
    required this.amount,
    required this.paymentDate,
    required this.agreementId,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'], // -- تمت الإضافة --
      amount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(json['payment_date']),
      agreementId: json['agreement_id'].toString(),
      notes: json['notes'],
    );
  }
  
  @override
  List<Object?> get props => [id];
}

// نموذج جديد لسجل الاستلامات
class ReceiptLogModel {
  final String productName;
  final int receivedQuantity;
  final DateTime receiptDate;
  final String? notes;

  ReceiptLogModel({
    required this.productName,
    required this.receivedQuantity,
    required this.receiptDate,
    this.notes,
  });

  factory ReceiptLogModel.fromJson(Map<String, dynamic> json) {
    return ReceiptLogModel(
      productName: json['product_name'] ?? 'منتج غير محدد',
      receivedQuantity: (json['received_quantity'] as num?)?.toInt() ?? 0,
      receiptDate: DateTime.parse(json['receipt_date']),
      notes: json['notes'],
    );
  }
}
