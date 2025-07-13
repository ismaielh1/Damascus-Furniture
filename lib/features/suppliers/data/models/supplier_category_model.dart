// lib/features/suppliers/data/models/supplier_category_model.dart
import 'package:equatable/equatable.dart';

class SupplierCategoryModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const SupplierCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory SupplierCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupplierCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}
