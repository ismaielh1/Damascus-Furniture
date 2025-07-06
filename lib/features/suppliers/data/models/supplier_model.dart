// lib/features/suppliers/data/models/supplier_model.dart
class SupplierModel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? address;
  final String? categoryName;

  SupplierModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.address,
    this.categoryName,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    String? category;

    // قراءة التصنيف من خلال الجدول الوسيط
    if (json['supplier_category_link'] != null &&
        (json['supplier_category_link'] as List).isNotEmpty) {
      final linkData = (json['supplier_category_link'] as List).first;
      if (linkData['supplier_categories'] != null &&
          linkData['supplier_categories'] is Map) {
        final categoryData =
            linkData['supplier_categories'] as Map<String, dynamic>;
        if (categoryData['name'] != null) {
          category = categoryData['name'].toString();
        }
      }
    }

    return SupplierModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'اسم غير متوفر',
      phoneNumber: json['phone_number'],
      address: json['address'],
      categoryName: category,
    );
  }
}
