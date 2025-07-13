// lib/features/products/data/models/product_model.dart

class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String unitOfMeasure;
  final String? defaultContactId; // تم التعديل من defaultSupplierId
  final String? contactName; // تم التعديل من supplierName

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.unitOfMeasure,
    this.defaultContactId,
    this.contactName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      unitOfMeasure: json['unit_of_measure'],
      defaultContactId: json['default_contact_id'], // تم التعديل
      // قراءة اسم جهة الاتصال من العلاقة الجديدة 'contacts'
      contactName: json['contacts'] != null
          ? json['contacts']['name']
          : null, // تم التعديل
    );
  }
}
