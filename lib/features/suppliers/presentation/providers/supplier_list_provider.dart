// lib/features/suppliers/presentation/providers/supplier_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لحفظ نص البحث في صفحة الموردين
final supplierSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider لجلب قائمة الموردين مع الفلترة حسب البحث
final allSuppliersProvider = FutureProvider.autoDispose<List<SupplierModel>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final searchQuery = ref.watch(supplierSearchQueryProvider);

  try {
    // تعديل الـ select ليقرأ التصنيف من خلال الجدول الوسيط
    var query = supabase
        .from('suppliers')
        .select(
          '*, supplier_category_link!inner(*, supplier_categories(name))',
        );

    if (searchQuery.isNotEmpty) {
      // البحث في اسم المورد أو رقم الهاتف أو العنوان
      query = query.or(
        'name.ilike.%$searchQuery%,phone_number.ilike.%$searchQuery%,address.ilike.%$searchQuery%',
      );
    }

    final response = await query.order('created_at', ascending: false);
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response,
    );

    return data.map((item) => SupplierModel.fromJson(item)).toList();
  } catch (e) {
    print('Error fetching all suppliers: $e');
    rethrow;
  }
});
