// lib/features/branches/data/models/branch_model.dart
import 'package:equatable/equatable.dart';

class BranchModel extends Equatable {
  final String id;
  final String name;
  final String? address;
  final String? phoneNumber;
  final bool isMain;

  const BranchModel({
    required this.id,
    required this.name,
    this.address,
    this.phoneNumber,
    required this.isMain,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      isMain: json['is_main'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id];
}
