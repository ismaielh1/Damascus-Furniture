// lib/features/suppliers/presentation/widgets/add_agreement/agreement_attachments.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final pickedImagesProvider = StateProvider.autoDispose<List<XFile>>(
  (ref) => [],
);

class AgreementAttachments extends ConsumerWidget {
  final VoidCallback onPickImages;
  const AgreementAttachments({super.key, required this.onPickImages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pickedImages = ref.watch(pickedImagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text('المستندات والصور', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (pickedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedImages.length,
              itemBuilder: (context, index) {
                final imageFile = pickedImages[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                imageFile.path,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(imageFile.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                            onPressed: () {
                              ref.read(pickedImagesProvider.notifier).update((
                                state,
                              ) {
                                final newList = List.of(state);
                                newList.removeAt(index);
                                return newList;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickImages,
          icon: const Icon(Icons.attach_file),
          label: const Text('إرفاق مستندات أو صور'),
        ),
      ],
    );
  }
}
