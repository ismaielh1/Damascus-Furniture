// lib/features/suppliers/data/models/agreement_item_model.dart
import 'package:equatable/equatable.dart';

class AgreementItem extends Equatable {
  final String id;
  final String productId;
  final String itemName;
  final int totalQuantity;
  final int receivedQuantitySoFar;
  final double unitPrice;
  final DateTime expectedDeliveryDate;

  const AgreementItem({
    required this.id,
    required this.productId,
    required this.itemName,
    required this.totalQuantity,
    required this.receivedQuantitySoFar,
    required this.unitPrice,
    required this.expectedDeliveryDate,
  });

  double get subtotal => totalQuantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'total_quantity': totalQuantity,
      'unit_price': unitPrice,
      'expected_delivery_date': expectedDeliveryDate.toIso8601String(),
    };
  }

  factory AgreementItem.fromJson(Map<String, dynamic> json) {
    return AgreementItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      itemName: json['products'] != null && json['products']['name'] != null
          ? json['products']['name']
          : 'منتج غير معروف',
      totalQuantity: (json['total_quantity'] as num).toInt(),
      receivedQuantitySoFar: (json['received_quantity_so_far'] as num? ?? 0)
          .toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date']),
    );
  }

  @override
  List<Object?> get props => [id, productId, receivedQuantitySoFar];
}
