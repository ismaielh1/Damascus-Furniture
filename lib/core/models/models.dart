// lib/core/models/models.dart

import 'package:flutter/material.dart';
// import 'package:my_store_app/l10n/app_localizations.dart'; // سنعيد تفعيله لاحقًا

// =============================================================================
// ENUMS
// =============================================================================

/// يحدد نوع الوجهة التي يجب أن ينتقل إليها البانر عند النقر عليه.
enum BannerTargetType {
  product,   // يوجه إلى صفحة منتج معين
  category,  // يوجه إلى صفحة فئة معينة
  search,    // يوجه إلى نتائج بحث معينة
  none,      // البانر غير قابل للنقر
}

// =============================================================================
// MODELS
// =============================================================================

/// نموذج بيانات الفئة (مثل: إلكترونيات، أزياء، مستلزمات المنزل).
class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl; // صورة كبيرة للفئة
  final String? parentCategoryId; // لدعم الفئات الفرعية مستقبلاً (e.g., 'ملابس' -> 'رجال')

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    this.parentCategoryId,
  });

  /// الحصول على الاسم المترجم بناءً على لغة التطبيق الحالية.
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? nameAr : nameEn;
  }
}

/// نموذج بيانات المنتج، مع إضافة حقول جديدة.
class Product {
  final String id;
  final String nameAr;
  final String nameEn;
  final String productNumber;
  final double price; // السعر بالدولار الأمريكي
  final String descriptionAr;
  final String descriptionEn;
  final List<String> imageUrls; // قائمة بالصور لعرضها في معرض صور
  final String categoryId; // لربط المنتج بالفئة التي ينتمي إليها
  final String? brand; // ماركة المنتج (اختياري)
  final List<String>? tags; // كلمات مفتاحية للبحث (اختياري)

  Product({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.productNumber,
    required this.price,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageUrls,
    required this.categoryId,
    this.brand,
    this.tags,
  });

  /// الحصول على الاسم المترجم.
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? nameAr : nameEn;
  }

  /// الحصول على الوصف المترجم.
  String getLocalizedDescription(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? descriptionAr : descriptionEn;
  }
}

/// نموذج بيانات البانر الإعلاني للشاشة الرئيسية.
class BannerAd {
  final String id;
  final String imageUrl;
  final BannerTargetType targetType; // نوع الوجهة
  final String? targetId; // معرّف المنتج أو الفئة أو كلمة البحث

  BannerAd({
    required this.id,
    required this.imageUrl,
    this.targetType = BannerTargetType.none,
    this.targetId,
  });
}

/// نموذج بيانات المستخدم (كما هو من قبل، مع الحقول الأساسية).
class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final String? profileImageUrl;
  final bool isAdmin;
  final String? locale;
  final String? address;

  AppUser({
    required this.uid,
    this.email,
    this.name,
    this.profileImageUrl,
    this.isAdmin = false,
    this.locale,
    this.address,
  });
}


/// نموذج بيانات عنصر السلة (كما هو من قبل).
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
