// lib/features/invoices/presentation/providers/invoices_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/invoices/data/models/invoice_item_model.dart';
import 'package:syria_store/features/invoices/data/models/invoice_model.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Providers for search and filtering
final invoiceSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');
final invoicePaymentMethodFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final invoiceDeliveryStatusFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// Provider to fetch all invoices using the RPC function
final invoicesProvider =
    FutureProvider.autoDispose<List<InvoiceModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(invoiceSearchQueryProvider);
  final paymentMethod = ref.watch(invoicePaymentMethodFilterProvider);
  final deliveryStatus = ref.watch(invoiceDeliveryStatusFilterProvider);

  try {
    final response = await supabase.rpc(
      'search_invoices',
      params: {
        'p_search_query': searchQuery,
        'p_payment_method_filter': paymentMethod,
        'p_delivery_status_filter': deliveryStatus,
      },
    ).select('*, contacts(id, name), profiles(id, full_name)');

    // --- بداية الإضافة: طباعة البيانات الخام للفحص ---
    print('Raw Supabase Response for Invoices: $response');
    // --- نهاية الإضافة ---

    final List<Map<String, dynamic>> data = List.from(response);
    return data.map((item) => InvoiceModel.fromJson(item)).toList();
  } catch (e, s) {
    print('Error fetching invoices: $e');
    print('Stacktrace: $s');
    rethrow;
  }
});

// Provider to fetch details of a single invoice
final invoiceDetailsProvider = FutureProvider.autoDispose
    .family<InvoiceModel?, String>((ref, invoiceId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase
        .from('invoices')
        .select('*, contacts(id, name), profiles(id, full_name)')
        .eq('id', invoiceId)
        .single();
    return InvoiceModel.fromJson(response);
  } catch (e) {
    print('Error fetching invoice details: $e');
    return null;
  }
});

// Provider to fetch items of a specific invoice
final invoiceItemsProvider = FutureProvider.autoDispose
    .family<List<InvoiceItemModel>, String>((ref, invoiceId) async {
  final supabase = ref.watch(supabaseProvider);
  try {
    final response = await supabase
        .from('invoice_items')
        .select('*, products(*)')
        .eq('invoice_id', invoiceId);

    return response.map((item) {
      return InvoiceItemModel(
        product: ProductModel.fromJson(item['products']),
        quantity: item['quantity'],
        unitPrice: (item['unit_price'] as num).toDouble(),
      );
    }).toList();
  } catch (e) {
    print('Error fetching invoice items: $e');
    rethrow;
  }
});
