// lib/core/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syria_store/core/models/models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- الدالة الجديدة ---
  /// جلب بيانات AppUser من جدول users باستخدام uid
  Future<AppUser?> getUserData(String uid) async {
    try {
      final data = await _client.from('users').select().eq('id', uid).single();
      // تحويل الـ Map إلى كائن AppUser
      return AppUser(
        uid: data['id'],
        email: data['email'],
        name: data['name'],
        profileImageUrl: data['profile_image_url'],
        isAdmin: data['is_admin'] ?? false,
        locale: data['locale'],
        address: data['address'],
      );
    } catch (e) {
      // قد لا يكون المستخدم موجودًا في جدولنا بعد، أو قد يحدث خطأ
      print('Error getting user data: $e');
      return null;
    }
  }
  // --- نهاية الدالة الجديدة ---
  
  Future<Product> getProductById(String productId) async {
    try {
      final response = await _client.from('products').select().eq('id', productId).single();
      return Product(
        id: response['id'].toString(), nameAr: response['name_ar'], nameEn: response['name_en'],
        productNumber: response['product_number'], price: (response['price'] as num).toDouble(),
        descriptionAr: response['description_ar'], descriptionEn: response['description_en'],
        imageUrls: List<String>.from(response['image_urls']), categoryId: response['category_id'].toString(),
        brand: response['brand'], tags: List<String>.from(response['tags'] ?? []),
      );
    } catch (e) {
      print('Error getting product by ID from Supabase: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _client.from('products').select().eq('category_id', categoryId);
      return response.map((item) => Product(
        id: item['id'].toString(), nameAr: item['name_ar'], nameEn: item['name_en'],
        productNumber: item['product_number'], price: (item['price'] as num).toDouble(),
        descriptionAr: item['description_ar'], descriptionEn: item['description_en'],
        imageUrls: List<String>.from(item['image_urls']), categoryId: item['category_id'].toString(),
        brand: item['brand'], tags: List<String>.from(item['tags'] ?? []),
      )).toList();
    } catch (e) {
      print('Error getting products by category from Supabase: $e');
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.from('categories').select();
      return response.map((item) => Category(
        id: item['id'].toString(), nameAr: item['name_ar'], nameEn: item['name_en'],
        imageUrl: item['image_url'], parentCategoryId: item['parent_category_id']?.toString(),
      )).toList();
    } catch (e) {
      print('Error getting categories from Supabase: $e');
      rethrow;
    }
  }
  
  Future<List<BannerAd>> getBanners() async {
    try {
      final response = await _client.from('banners').select();
      return response.map((item) => BannerAd(
        id: item['id'].toString(), imageUrl: item['image_url'],
        targetType: BannerTargetType.values.byName(item['target_type'] ?? 'none'),
        targetId: item['target_id']?.toString(),
      )).toList();
    } catch (e) {
      print('Error getting banners from Supabase: $e');
      rethrow;
    }
  }
}
