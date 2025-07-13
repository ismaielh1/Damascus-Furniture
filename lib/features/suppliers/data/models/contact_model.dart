import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final String id;
  final String name;
  final String? code;
  final String? phoneNumber;
  final String? address;
  final bool isSupplier;
  final bool isCustomer;
  final String? categoryName;

  const ContactModel({
    required this.id,
    required this.name,
    this.code,
    this.phoneNumber,
    this.address,
    required this.isSupplier,
    required this.isCustomer,
    this.categoryName,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    String? category;
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

    return ContactModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'اسم غير متوفر',
      code: json['code']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      isSupplier: json['is_supplier'] ?? false,
      isCustomer: json['is_customer'] ?? false,
      categoryName: category,
    );
  }

  @override
  List<Object?> get props => [id];
}
