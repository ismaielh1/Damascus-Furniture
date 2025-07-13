// lib/features/invoices/data/models/fund_model.dart
import 'package:equatable/equatable.dart';

class FundModel extends Equatable {
  final int id;
  final String name;
  // -- بداية الإضافة --
  final String currency; // 'USD' or 'SYP'
  final String type; // 'cash' or 'bank'
  // -- نهاية الإضافة --

  const FundModel({
    required this.id,
    required this.name,
    // -- بداية الإضافة --
    required this.currency,
    required this.type,
    // -- نهاية الإضافة --
  });

  factory FundModel.fromJson(Map<String, dynamic> json) {
    return FundModel(
      id: json['id'],
      name: json['name'],
      // -- بداية الإضافة --
      currency: json['currency'],
      type: json['type'],
      // -- نهاية الإضافة --
    );
  }

  @override
  // -- تعديل --
  List<Object?> get props => [id, name, currency, type];
}
