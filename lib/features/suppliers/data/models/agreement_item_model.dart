// lib/features/suppliers/data/models/agreement_item_model.dart
import 'package:equatable/equatable.dart';

class AgreementItem extends Equatable {
  final String id;
  final String itemName;
  final int totalQuantity;
  final double unitPrice;
  final DateTime expectedDeliveryDate;

  const AgreementItem({
    required this.id,
    required this.itemName,
    required this.totalQuantity,
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
      // --- بداية التعديل ---
      // تحويل الـ id إلى نص بشكل آمن للتعامل مع كل الحالات
      id: json['id'].toString(),
      // --- نهاية التعديل ---
      itemName: json['item_name'],
      totalQuantity: (json['total_quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date']),
    );
  }

  @override
  List<Object?> get props => [id];
}
