// lib/features/suppliers/data/models/supplier_agreement_model.dart
class SupplierAgreement {
  final String id;
  final String? supplierId;
  final String? supplierName;
  final String agreementDetails;
  final double totalAmount;
  final DateTime? expectedDeliveryDate;
  final String status;
  final double? down_payment;
  // --- ** هذا هو الحقل الذي يجب إضافته ** ---
  final List<String> documentImagePaths;

  SupplierAgreement({
    required this.id,
    this.supplierId,
    this.supplierName,
    required this.agreementDetails,
    required this.totalAmount,
    this.expectedDeliveryDate,
    required this.status,
    this.down_payment,
    required this.documentImagePaths, // مطلوب في المنشئ
  });

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
      down_payment: json['down_payment'] != null
          ? double.tryParse(json['down_payment'].toString())
          : null,
      // الاسم في قاعدة البيانات هو document_image_urls، ونحن نقوم بتحميله في الحقل الجديد
      documentImagePaths: json['document_image_urls'] != null
          ? List<String>.from(json['document_image_urls'])
          : [],
    );
  }
}
