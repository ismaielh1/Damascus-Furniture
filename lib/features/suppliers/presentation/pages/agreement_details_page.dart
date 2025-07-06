import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/add_payment_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/private_storage_image.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/receive_item_dialog.dart';

class AgreementDetailsPage extends ConsumerWidget {
  final String agreementId;
  const AgreementDetailsPage({super.key, required this.agreementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementAsync = ref.watch(agreementDetailsProvider(agreementId));
    final itemsAsync = ref.watch(agreementItemsProvider(agreementId));
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

    void showAddPaymentDialog() {
      showDialog(
        context: context,
        builder: (_) => AddPaymentDialog(agreementId: agreementId),
      );
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

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(agreementDetailsProvider(agreementId));
              ref.invalidate(agreementItemsProvider(agreementId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(theme, agreement, statusInfo),
                  const SizedBox(height: 20),

                  Text('بنود الاتفاقية', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  itemsAsync.when(
                    data: (items) => items.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('لا توجد بنود.'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isFullyReceived =
                                  item.receivedQuantitySoFar >=
                                  item.totalQuantity;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                elevation: 1.5,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: isFullyReceived
                                        ? Colors.green.shade200
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.itemName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${item.subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'الكمية المطلوبة: ${item.totalQuantity} × السعر: \$${item.unitPrice.toStringAsFixed(2)}',
                                      ),
                                      const SizedBox(height: 8),
                                      if (item.receivedQuantitySoFar > 0 &&
                                          item.totalQuantity > 0) ...[
                                        LinearProgressIndicator(
                                          value:
                                              item.receivedQuantitySoFar /
                                              item.totalQuantity,
                                          backgroundColor: Colors.grey.shade300,
                                          color: isFullyReceived
                                              ? Colors.green
                                              : Colors.orange,
                                          minHeight: 6,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'المستلم: ${item.receivedQuantitySoFar}',
                                              style: TextStyle(
                                                color: isFullyReceived
                                                    ? Colors.green.shade800
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (!isFullyReceived)
                                            TextButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      ReceiveItemDialog(
                                                        item: item,
                                                        agreementId:
                                                            agreementId,
                                                      ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.add,
                                                size: 18,
                                              ),
                                              label: const Text('استلام كمية'),
                                            ),
                                        ],
                                      ),
                                    ],
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الملخص المالي', style: theme.textTheme.titleLarge),
                      if (!isUpdating)
                        TextButton.icon(
                          icon: const Icon(Icons.add_card),
                          label: const Text('إضافة دفعة'),
                          onPressed: showAddPaymentDialog,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildFinancialRow(
                    theme,
                    'المجموع الإجمالي:',
                    '\$${agreement.totalAmount.toStringAsFixed(2)}',
                  ),
                  _buildFinancialRow(
                    theme,
                    'المبلغ المدفوع:',
                    '\$${(agreement.down_payment ?? 0).toStringAsFixed(2)}',
                  ),
                  const Divider(thickness: 1, height: 24),
                  _buildFinancialRow(
                    theme,
                    'المبلغ المتبقي:',
                    '\$${remainingAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),

                  const SizedBox(height: 20),
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
                  const Divider(height: 32),

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
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('خطأ في جلب تفاصيل الاتفاقية: $err')),
      ),
    );
  }

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
