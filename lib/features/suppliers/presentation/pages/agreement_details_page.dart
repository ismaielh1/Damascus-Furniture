// lib/features/suppliers/presentation/pages/agreement_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';

class AgreementDetailsPage extends ConsumerWidget {
  final String agreementId;
  const AgreementDetailsPage({super.key, required this.agreementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementAsync = ref.watch(agreementDetailsProvider(agreementId));
    final itemsAsync = ref.watch(
      agreementItemsProvider(agreementId),
    ); // <-- مشاهدة provider البنود
    final isUpdating = ref.watch(updateAgreementStatusControllerProvider);
    final theme = Theme.of(context);

    void handleUpdateStatus(String newStatus) {
      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .updateStatus(
            context: context,
            agreementId: agreementId,
            newStatus: newStatus,
          );
    }

    void handlePostpone() async {
      final agreement = agreementAsync.value;
      if (agreement == null) return;
      final newDate = await showDatePicker(
        context: context,
        initialDate: agreement.expectedDeliveryDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (newDate != null) {
        ref
            .read(updateAgreementStatusControllerProvider.notifier)
            .postponeAgreement(
              context: context,
              agreementId: agreementId,
              newDate: newDate,
            );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الاتفاقية')),
      body: agreementAsync.when(
        data: (agreement) {
          if (agreement == null)
            return const Center(child: Text('لم يتم العثور على الاتفاقية.'));

          final statusInfo = _getStatusInfo(agreement.status, theme);
          final remainingAmount =
              agreement.totalAmount - (agreement.down_payment ?? 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(theme, agreement, statusInfo),
                const SizedBox(height: 20),

                // --- عرض البنود ---
                Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                itemsAsync.when(
                  data: (items) => items.isEmpty
                      ? const Text('لا توجد بنود.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'الكمية: ${item.totalQuantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('خطأ في جلب البنود: $e'),
                ),
                const Divider(height: 32),

                // --- الملخص المالي ---
                Text('الملخص المالي', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildFinancialRow(
                  theme,
                  'المجموع الإجمالي:',
                  '\$${agreement.totalAmount.toStringAsFixed(2)}',
                ),
                _buildFinancialRow(
                  theme,
                  'العربون المدفوع:',
                  '\$${(agreement.down_payment ?? 0).toStringAsFixed(2)}',
                ),
                const Divider(thickness: 1, height: 24),
                _buildFinancialRow(
                  theme,
                  'المبلغ المتبقي:',
                  '\$${remainingAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                const SizedBox(height: 32),

                // --- الإجراءات ---
                Text('الإجراءات', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (isUpdating)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        onPressed: () => handleUpdateStatus('completed'),
                        icon: Icons.check_circle_outline,
                        label: 'تم التسليم',
                        color: Colors.green,
                      ),
                      _buildActionButton(
                        onPressed: handlePostpone,
                        icon: Icons.edit_calendar_outlined,
                        label: 'تأجيل',
                        color: Colors.orange,
                      ),
                      _buildActionButton(
                        onPressed: () => handleUpdateStatus('cancelled'),
                        icon: Icons.cancel_outlined,
                        label: 'إلغاء',
                        color: Colors.red,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('خطأ في جلب تفاصيل الاتفاقية: $err')),
      ),
    );
  }

  // --- ويدجتس مساعدة لتحسين قراءة الكود ---

  Widget _buildHeaderCard(
    ThemeData theme,
    SupplierAgreement agreement,
    Map<String, dynamic> statusInfo,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agreement.supplierName ?? 'مورد غير محدد',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'الحالة: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 18),
                const SizedBox(width: 4),
                Text(
                  statusInfo['text'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: statusInfo['color'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (agreement.expectedDeliveryDate != null)
              Row(
                children: [
                  const Text(
                    'تاريخ التسليم: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat(
                      'yyyy/MM/dd',
                      'ar',
                    ).format(agreement.expectedDeliveryDate!),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            const Text(
              'الملاحظات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              agreement.agreementDetails.isNotEmpty
                  ? agreement.agreementDetails
                  : 'لا يوجد',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(
    ThemeData theme,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style?.copyWith(
              color: isTotal ? theme.primaryColor : Colors.black87,
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status, ThemeData theme) {
    switch (status) {
      case 'pending_delivery':
        return {
          'color': Colors.orange.shade700,
          'icon': Icons.hourglass_top,
          'text': 'قيد التسليم',
        };
      case 'completed':
        return {
          'color': Colors.green.shade700,
          'icon': Icons.check_circle,
          'text': 'مكتمل',
        };
      case 'delayed':
        return {
          'color': Colors.red.shade700,
          'icon': Icons.error,
          'text': 'متأخر',
        };
      case 'cancelled':
        return {
          'color': Colors.grey.shade700,
          'icon': Icons.cancel,
          'text': 'ملغي',
        };
      default:
        return {'color': Colors.grey, 'icon': Icons.help, 'text': 'غير معروف'};
    }
  }
}
