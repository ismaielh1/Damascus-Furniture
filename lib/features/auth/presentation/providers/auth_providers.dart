// // lib/features/auth/presentation/providers/auth_providers.dart

// import 'package:riverpod/riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:syria_store/core/models/models.dart';
// import 'package:syria_store/features/home/presentation/providers/home_providers.dart';

// // هذا الـ Provider يراقب حالة المصادقة في Supabase
// final authStateProvider = StreamProvider<AuthState>((ref) {
//   return Supabase.instance.client.auth.onAuthStateChange;
// });

// // هذا الـ Provider يجلب بيانات AppUser للمستخدم المسجل دخوله حاليًا
// final currentUserProvider = FutureProvider<AppUser?>((ref) async {
//   // نراقب حالة المصادقة
//   final authState = ref.watch(authStateProvider);
//   final supabaseService = ref.watch(supabaseServiceProvider);

//   // إذا كان هناك مستخدم مسجل دخوله، نجلب بياناته من جدول users
//   final user = authState.value?.session?.user;
//   if (user != null) {
//     return await supabaseService.getUserData(user.id);
//   }
//   return null;
// });
