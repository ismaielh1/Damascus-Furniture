// lib/features/products/data/models/product_model.dart
class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String unitOfMeasure;
  final String? defaultSupplierId;

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.unitOfMeasure,
    this.defaultSupplierId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      unitOfMeasure: json['unit_of_measure'],
      defaultSupplierId: json['default_supplier_id'],
    );
  }
}
