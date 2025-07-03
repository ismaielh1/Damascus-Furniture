// lib/features/suppliers/data/models/supplier_agreement_model.dart
class SupplierAgreement {
  final String id;
  final String? supplierId;
  final String? supplierName;
  final String agreementDetails;
  final double totalAmount;
  final DateTime? expectedDeliveryDate;
  final String status;
  final double? down_payment; // <-- ** بداية الإضافة **

  SupplierAgreement({
    required this.id,
    this.supplierId,
    this.supplierName,
    required this.agreementDetails,
    required this.totalAmount,
    this.expectedDeliveryDate,
    required this.status,
    this.down_payment, // <-- إضافة للحقل الجديد
  });
  // <-- ** نهاية الإضافة **

  factory SupplierAgreement.fromJson(Map<String, dynamic> json) {
    return SupplierAgreement(
      id: json['id'] ?? '',
      supplierId: json['suppliers'] != null ? json['suppliers']['id'] : null,
      supplierName: json['suppliers'] != null
          ? json['suppliers']['name']
          : null,
      agreementDetails: json['agreement_details'] ?? '',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.tryParse(json['expected_delivery_date'])
          : null,
      status: json['status'] ?? 'غير معروف',
      // --- إضافة لتحميل قيمة العربون من قاعدة البيانات ---
      down_payment: json['down_payment'] != null
          ? double.tryParse(json['down_payment'].toString())
          : null,
    );
  }
}
