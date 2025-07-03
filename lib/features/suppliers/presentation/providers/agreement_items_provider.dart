// lib/features/suppliers/presentation/providers/agreement_items_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/data/models/agreement_item_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

// Provider لجلب قائمة البنود الخاصة باتفاقية معينة
final agreementItemsProvider = FutureProvider.autoDispose
    .family<List<AgreementItem>, String>((ref, agreementId) async {
      final supabase = ref.watch(supabaseProvider);
      try {
        final response = await supabase
            .from('agreement_items')
            .select()
            .eq('agreement_id', agreementId);

        return response.map((item) => AgreementItem.fromJson(item)).toList();
      } catch (e) {
        print('Error fetching agreement items: $e');
        rethrow;
      }
    });
