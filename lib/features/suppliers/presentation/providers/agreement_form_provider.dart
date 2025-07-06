import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

class SupplierCategory extends Equatable {
  final int id;
  final String name;
  const SupplierCategory({required this.id, required this.name});
  @override
  List<Object?> get props => [id];
}

class Supplier extends Equatable {
  final String id;
  final String name;
  const Supplier({required this.id, required this.name});
  @override
  List<Object?> get props => [id];
}

final supplierCategoriesProvider =
    FutureProvider.autoDispose<List<SupplierCategory>>((ref) async {
      final supabase = ref.watch(supabaseProvider);
      final response = await supabase
          .from('supplier_categories')
          .select('id, name')
          .order('name');
      return response
          .map((item) => SupplierCategory(id: item['id'], name: item['name']))
          .toList();
    });

final selectedCategoryProvider = StateProvider.autoDispose<SupplierCategory?>(
  (ref) => null,
);

final suppliersByCategoryProvider = FutureProvider.autoDispose<List<Supplier>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  if (selectedCategory == null) return [];
  final response = await supabase
      .from('suppliers')
      .select('id, name, supplier_category_link!inner(category_id)')
      .eq('supplier_category_link.category_id', selectedCategory.id)
      .order('name');
  return response
      .map((item) => Supplier(id: item['id'], name: item['name']))
      .toList();
});

final agreementFormProvider =
    StateNotifierProvider.autoDispose<
      AgreementFormNotifier,
      List<AgreementItem>
    >((ref) {
      return AgreementFormNotifier();
    });

class AgreementFormNotifier extends StateNotifier<List<AgreementItem>> {
  AgreementFormNotifier() : super([]);
  void addItem(AgreementItem item) {
    state = [...state, item];
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  double get grandTotal => state.fold(0.0, (sum, item) => sum + item.subtotal);

  void clear() {
    state = [];
  }
}

final addSupplierControllerProvider =
    StateNotifierProvider.autoDispose<AddSupplierController, bool>((ref) {
      return AddSupplierController(ref: ref);
    });

class AddSupplierController extends StateNotifier<bool> {
  final Ref _ref;
  AddSupplierController({required Ref ref}) : _ref = ref, super(false);
  Future<Supplier?> addSupplier({
    required BuildContext context,
    required String name,
    String? phone,
    String? address,
    required int categoryId,
  }) async {
    if (state) return null;
    state = true;
    try {
      final supabase = _ref.read(supabaseProvider);
      final newSupplierData = await supabase
          .from('suppliers')
          .insert({'name': name, 'phone_number': phone, 'address': address})
          .select()
          .single();
      final newSupplierId = newSupplierData['id'];
      await supabase.from('supplier_category_link').insert({
        'supplier_id': newSupplierId,
        'category_id': categoryId,
      });
      _ref.invalidate(suppliersByCategoryProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة "$name" بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return Supplier(id: newSupplierId, name: name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة المورد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      state = false;
    }
  }
}

final agreementControllerProvider =
    StateNotifierProvider.autoDispose<AgreementController, bool>((ref) {
      return AgreementController(ref: ref);
    });

class AgreementController extends StateNotifier<bool> {
  final Ref _ref;
  AgreementController({required Ref ref}) : _ref = ref, super(false);

  Future<bool> createFullAgreement({
    required BuildContext context,
    required String supplierId,
    String? notes,
    required List<AgreementItem> items,
    double downPayment = 0,
    required List<XFile> images,
  }) async {
    if (state) return false;
    state = true;
    try {
      final supabase = _ref.read(supabaseProvider);
      List<String> imagePaths = []; // سنحفظ المسارات هنا

      if (images.isNotEmpty) {
        final String agreementFolder =
            'public/agreements/${DateTime.now().millisecondsSinceEpoch}';
        const bucketName = 'agreement-documents';

        for (final image in images) {
          final fileName = image.name;
          final uploadPath = '$agreementFolder/$fileName';

          if (kIsWeb) {
            await supabase.storage
                .from(bucketName)
                .uploadBinary(
                  uploadPath,
                  await image.readAsBytes(),
                  fileOptions: FileOptions(contentType: image.mimeType),
                );
          } else {
            await supabase.storage
                .from(bucketName)
                .upload(uploadPath, File(image.path));
          }

          imagePaths.add(uploadPath);
        }
      }

      final itemsList = items.map((item) => item.toJson()).toList();

      await _ref
          .read(supabaseProvider)
          .rpc(
            'create_full_agreement',
            params: {
              'supplier_id_input': supplierId,
              'notes_input': notes,
              'items_jsonb_in': itemsList,
              'down_payment_input': downPayment,
              'document_urls_input': imagePaths,
            },
          );

      _ref.invalidate(agreementsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الاتفاقية بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الاتفاقية: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      state = false;
    }
  }
}
