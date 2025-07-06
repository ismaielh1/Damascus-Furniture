import 'package:equatable/equatable.dart';

class AgreementItem extends Equatable {
  final String id;
  final String itemName;
  final int totalQuantity;
  final int receivedQuantitySoFar;
  final double unitPrice;
  final DateTime expectedDeliveryDate;

  const AgreementItem({
    required this.id,
    required this.itemName,
    required this.totalQuantity,
    required this.receivedQuantitySoFar,
    required this.unitPrice,
    required this.expectedDeliveryDate,
  });

  double get subtotal => totalQuantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'totalQuantity': totalQuantity,
      'unitPrice': unitPrice,
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
    };
  }

  factory AgreementItem.fromJson(Map<String, dynamic> json) {
    return AgreementItem(
      id: json['id'].toString(),
      itemName: json['item_name'],
      totalQuantity: (json['total_quantity'] as num).toInt(),
      receivedQuantitySoFar: (json['received_quantity_so_far'] as num? ?? 0)
          .toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date']),
    );
  }

  @override
  List<Object?> get props => [id, receivedQuantitySoFar];
}
