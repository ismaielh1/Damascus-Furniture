// lib/features/suppliers/presentation/widgets/private_storage_image.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_list_provider.dart';

class PrivateStorageImage extends ConsumerWidget {
  final String imagePath;
  const PrivateStorageImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref
          .read(supabaseProvider)
          .storage
          .from('agreement-documents')
          .createSignedUrl(imagePath, 60), // 60 ثانية صلاحية للرابط
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Tooltip(
            message: 'فشل تحميل الصورة',
            child: Icon(Icons.error_outline, color: Colors.red),
          );
        }

        final signedUrl = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            signedUrl,
            width: 150,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stack) => const Tooltip(
              message: 'فشل تحميل الصورة من الرابط',
              child: Icon(Icons.broken_image_outlined, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}
