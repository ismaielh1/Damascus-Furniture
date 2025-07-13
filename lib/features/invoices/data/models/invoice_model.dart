// lib/features/invoices/data/models/invoice_model.dart
import 'package:equatable/equatable.dart';

// -- بداية الإضافة --
// تعريف الـ Enum لحالة التسليم
enum InvoiceDeliveryStatus { pending, delivered }

// دالة لتحويل النص إلى Enum
InvoiceDeliveryStatus _parseDeliveryStatus(String status) {
  switch (status) {
    case 'delivered':
      return InvoiceDeliveryStatus.delivered;
    case 'pending':
    default:
      return InvoiceDeliveryStatus.pending;
  }
}
// -- نهاية الإضافة --


class InvoiceModel extends Equatable {
  final String id;
  final String invoiceNumber;
  final String? customerName;
  final String? userName;
  final DateTime invoiceDate;
  final double totalAmount;
  final String paymentMethod;
  final InvoiceDeliveryStatus deliveryStatus; // -- تم التعديل --
  final double? discountAmount;
  final String? notes;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
    this.userName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryStatus, // -- تم التعديل --
    this.discountAmount,
    this.notes,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerName: json['contacts']?['name'],
      userName: json['profiles']?['full_name'], 
      invoiceDate: DateTime.parse(json['invoice_date']),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      deliveryStatus: _parseDeliveryStatus(json['delivery_status']), // -- تم التعديل --
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [id, invoiceNumber, customerName, userName, invoiceDate];
}
