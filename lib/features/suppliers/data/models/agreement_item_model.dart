// lib/features/suppliers/data/models/agreement_item_model.dart
import 'package:equatable/equatable.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';

class AgreementItem extends Equatable {
  final int id;
  final String? agreementId; // تم التعديل ليقبل القيمة الفارغة
  final ProductModel? product;
  final int totalQuantity;
  final double unitPrice;
  final int receivedQuantitySoFar;
  final DateTime? expectedDeliveryDate; // تم التعديل ليقبل القيمة الفارغة

  const AgreementItem({
    required this.id,
    this.agreementId,
    this.product,
    required this.totalQuantity,
    required this.unitPrice,
    required this.receivedQuantitySoFar,
    this.expectedDeliveryDate,
  });

  double get subtotal => totalQuantity * unitPrice;

  @override
  List<Object?> get props => [
        id,
        product,
        totalQuantity,
        unitPrice,
        receivedQuantitySoFar,
      ];

  factory AgreementItem.fromJson(Map<String, dynamic> json) {
    return AgreementItem(
      id: json['id'],
      agreementId: json['agreement_id'],
      product: json['products'] != null
          ? ProductModel.fromJson(json['products'])
          : null,
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      receivedQuantitySoFar:
          (json['received_quantity_so_far'] as num?)?.toInt() ?? 0,
      // استخدام tryParse للتعامل مع القيم الفارغة بأمان
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.tryParse(json['expected_delivery_date'])
          : null,
    );
  }
}
