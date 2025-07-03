// lib/features/suppliers/presentation/widgets/agreement_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

class AgreementCard extends StatelessWidget {
  final SupplierAgreement agreement;
  const AgreementCard({super.key, required this.agreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int? daysRemaining;
    if (agreement.expectedDeliveryDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deliveryDate = DateTime(
        agreement.expectedDeliveryDate!.year,
        agreement.expectedDeliveryDate!.month,
        agreement.expectedDeliveryDate!.day,
      );
      daysRemaining = deliveryDate.difference(today).inDays;
    }
    final Map<String, dynamic> statusInfo = _getStatusInfo(
      agreement.status,
      theme,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // استخدام 'push' مع المسار النسبي الجديد
          context.push('/supplier-agreements/details/${agreement.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // عند الضغط على اسم المورد، ننتقل لصفحته الخاصة
                        if (agreement.supplierId != null) {
                          context.go(
                            '/suppliers/${agreement.supplierId}',
                            extra: agreement.supplierName,
                          );
                        }
                      },
                      child: Text(
                        agreement.supplierName ?? 'مورد غير محدد',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo['icon'],
                          color: statusInfo['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusInfo['text'],
                          style: TextStyle(
                            color: statusInfo['color'],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                agreement.agreementDetails.isNotEmpty
                    ? agreement.agreementDetails
                    : 'لا توجد تفاصيل للملاحظات.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (daysRemaining != null &&
                      daysRemaining >= 0 &&
                      agreement.status == 'pending_delivery')
                    _buildInfoChip(
                      theme,
                      Icons.hourglass_bottom_outlined,
                      'باقي $daysRemaining يوم',
                      color: daysRemaining < 7
                          ? Colors.red.shade700
                          : theme.colorScheme.primary,
                    ),
                  const Spacer(),
                  if (agreement.expectedDeliveryDate != null)
                    _buildInfoChip(
                      theme,
                      Icons.calendar_today_outlined,
                      DateFormat(
                        'yyyy/MM/dd',
                        'ar',
                      ).format(agreement.expectedDeliveryDate!),
                    ),
                ],
              ),
            ],
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

  Widget _buildInfoChip(
    ThemeData theme,
    IconData icon,
    String label, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? theme.textTheme.bodySmall?.color),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
