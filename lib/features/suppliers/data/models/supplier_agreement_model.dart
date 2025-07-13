// lib/features/suppliers/data/models/supplier_agreement_model.dart
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';

class SupplierAgreement {
  final String id;
  final String? contactId;
  final String? contactName;
  final String agreementDetails;
  final double totalAmount;
  final DateTime agreement_date; // -- تم إضافة تاريخ الإنشاء --
  final DateTime? expectedDeliveryDate;
  final String status;
  final double? down_payment;
  final List<String> documentImagePaths;

  SupplierAgreement({
    required this.id,
    this.contactId,
    this.contactName,
    required this.agreementDetails,
    required this.totalAmount,
    required this.agreement_date, // -- تمت الإضافة --
    this.expectedDeliveryDate,
    required this.status,
    this.down_payment,
    required this.documentImagePaths,
  });

  factory SupplierAgreement.fromJson(Map<String, dynamic> json) {
    return SupplierAgreement(
      id: json['id'] ?? '',
      contactId: json['contacts'] != null ? json['contacts']['id'] : null,
      contactName: json['contacts'] != null ? json['contacts']['name'] : null,
      agreementDetails: json['agreement_details'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      agreement_date: DateTime.parse(json['agreement_date']), // -- تمت الإضافة --
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.tryParse(json['expected_delivery_date'])
          : null,
      status: json['status'] ?? 'غير معروف',
      down_payment: json['down_payment'] != null
          ? double.tryParse(json['down_payment'].toString())
          : null,
      documentImagePaths: json['document_image_urls'] != null
          ? List<String>.from(json['document_image_urls'])
          : [],
    );
  }
}
