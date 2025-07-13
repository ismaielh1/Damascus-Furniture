import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/data/models/invoice_item_model.dart';
import 'package:syria_store/features/invoices/data/models/payment_detail_model.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

@immutable
class InvoiceFormState {
  final ContactModel? selectedCustomer;
  final List<InvoiceItemModel> items;
  final double discount;
  final String paymentMethod;
  final List<PaymentDetailModel> payments;
  final String notes;
  final String? manualInvoiceNumber;
  final DateTime invoiceDate;
  final String deliveryStatus;

  InvoiceFormState({
    this.selectedCustomer,
    this.items = const [],
    this.discount = 0.0,
    this.paymentMethod = 'cash',
    this.payments = const [],
    this.notes = '',
    this.manualInvoiceNumber,
    DateTime? invoiceDate,
    this.deliveryStatus = 'delivered',
  }) : invoiceDate = invoiceDate ?? DateTime.now();

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalAfterDiscount => subtotal - discount;

  InvoiceFormState copyWith({
    ContactModel? selectedCustomer,
    bool clearCustomer = false,
    List<InvoiceItemModel>? items,
    double? discount,
    String? paymentMethod,
    List<PaymentDetailModel>? payments,
    String? notes,
    String? manualInvoiceNumber,
    DateTime? invoiceDate,
    String? deliveryStatus,
  }) {
    return InvoiceFormState(
      selectedCustomer: clearCustomer ? null : selectedCustomer ?? this.selectedCustomer,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
      manualInvoiceNumber: manualInvoiceNumber ?? this.manualInvoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}

final invoiceFormProvider =
    StateNotifierProvider.autoDispose<InvoiceFormNotifier, InvoiceFormState>((ref) {
  return InvoiceFormNotifier();
});

class InvoiceFormNotifier extends StateNotifier<InvoiceFormState> {
  InvoiceFormNotifier() : super(InvoiceFormState());

  void setInvoiceDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }
  void setDeliveryStatus(String status) {
    state = state.copyWith(deliveryStatus: status);
  }
  void setCustomer(ContactModel? customer) {
    state = state.copyWith(selectedCustomer: customer, clearCustomer: customer == null);
  }
  void setManualInvoiceNumber(String? number) {
    state = state.copyWith(manualInvoiceNumber: number);
  }
  void addItem(InvoiceItemModel newItem) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == newItem.product.id);
    if (existingIndex != -1) {
      final updatedItems = List<InvoiceItemModel>.from(state.items);
      updatedItems[existingIndex].quantity += newItem.quantity;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }
  void removeItem(String productId) {
    state = state.copyWith(items: state.items.where((item) => item.product.id != productId).toList());
  }
  void updateItemQuantity(String productId, int newQuantity) {
    state = state.copyWith(
        items: state.items.map((item) {
      if (item.product.id == productId) {
        item.quantity = newQuantity < 0 ? 0 : newQuantity;
      }
      return item;
    }).toList());
  }
  void updateItemPrice(String productId, double newPrice) {
    state = state.copyWith(
        items: state.items.map((item) {
      if (item.product.id == productId) {
        item.unitPrice = newPrice;
      }
      return item;
    }).toList());
  }
  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }
  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }
  void addPayment(PaymentDetailModel payment) {
    state = state.copyWith(payments: [...state.payments, payment]);
  }
  void clearPayments() {
    state = state.copyWith(payments: []);
  }
  void clearForm() {
    state = InvoiceFormState();
  }
}

final invoiceControllerProvider =
    StateNotifierProvider.autoDispose<InvoiceController, bool>((ref) {
  return InvoiceController(ref);
});

class InvoiceController extends StateNotifier<bool> {
  final Ref _ref;
  InvoiceController(this._ref) : super(false);

  Future<bool> saveInvoice(
    BuildContext context, {
    required InvoiceFormState invoiceState,
    required double exchangeRate,
    required String branchId,
    required String userId,
    int? usdFundId,
    int? sypFundId,
  }) async {
    state = true;
    try {
      final itemsJson = invoiceState.items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
              })
          .toList();

      final paymentsJson = invoiceState.payments
          .map((p) => {
                'amount': p.amount,
                'currency': p.currency,
                'exchange_rate': p.currency == 'SYP' ? exchangeRate : null,
                'fund_id': p.currency == 'USD' ? usdFundId : sypFundId,
              })
          .toList();

      await _ref.read(supabaseProvider).rpc('create_full_invoice', params: {
        'p_branch_id': branchId,
        'p_user_id': userId,
        'p_contact_id': invoiceState.selectedCustomer?.id,
        'p_payment_method': invoiceState.paymentMethod,
        'p_discount_amount': invoiceState.discount,
        'p_notes': invoiceState.notes,
        'p_invoice_number_manual': invoiceState.manualInvoiceNumber,
        'p_invoice_date': invoiceState.invoiceDate.toIso8601String(),
        'p_delivery_status': invoiceState.deliveryStatus,
        'p_items_jsonb': itemsJson,
        'p_payment_jsonb': paymentsJson
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الفاتورة بنجاح'), backgroundColor: Colors.green));
      }
      _ref.read(invoiceFormProvider.notifier).clearForm();
      return true;

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حفظ الفاتورة: $e'), backgroundColor: Colors.red));
      }
      return false;
    } finally {
      state = false;
    }
  }
}
