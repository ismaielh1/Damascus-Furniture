import 'package:flutter/material.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/private_storage_image.dart';

class AgreementDocumentsSection extends StatelessWidget {
  final SupplierAgreement agreement;
  const AgreementDocumentsSection({super.key, required this.agreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المستندات المرفقة', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (agreement.documentImagePaths.isEmpty)
          const Text('لا توجد مستندات مرفقة.')
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: agreement.documentImagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = agreement.documentImagePaths[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: PrivateStorageImage(imagePath: imagePath),
                );
              },
            ),
          ),
      ],
    );
  }
}
