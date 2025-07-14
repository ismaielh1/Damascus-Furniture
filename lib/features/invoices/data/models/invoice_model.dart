// lib/features/invoices/data/models/invoice_model.dart
import 'package:equatable/equatable.dart';

enum InvoiceDeliveryStatus { pending, delivered }

InvoiceDeliveryStatus _parseDeliveryStatus(String? status) {
  switch (status) {
    case 'delivered':
      return InvoiceDeliveryStatus.delivered;
    case 'pending':
    default:
      return InvoiceDeliveryStatus.pending;
  }
}

class InvoiceModel extends Equatable {
  final String id;
  final String invoiceNumber;
  final String? contactId; // <-- تمت الإضافة هنا
  final String? customerName;
  final String? userName;
  final DateTime invoiceDate;
  final double totalAmount;
  final String paymentMethod;
  final InvoiceDeliveryStatus deliveryStatus;
  final double? discountAmount;
  final String? notes;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.contactId, // <-- تمت الإضافة هنا
    this.customerName,
    this.userName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryStatus,
    this.discountAmount,
    this.notes,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      contactId: json['contact_id'], // <-- تمت الإضافة هنا
      customerName: json['contacts']?['name'],
      userName: json['profiles']?['full_name'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      deliveryStatus: _parseDeliveryStatus(json['delivery_status']),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props =>
      [id, invoiceNumber, contactId, customerName, userName, invoiceDate];
}
