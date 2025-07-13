// lib/features/invoices/data/models/invoice_item_model.dart
import 'package:syria_store/features/products/data/models/product_model.dart';

class InvoiceItemModel {
  final ProductModel product;
  int quantity;
  double unitPrice;

  InvoiceItemModel({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}
