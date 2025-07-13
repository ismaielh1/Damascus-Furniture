// lib/features/suppliers/presentation/widgets/agreement_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';

class AgreementCard extends StatelessWidget {
  final SupplierAgreement agreement;
  const AgreementCard({super.key, required this.agreement});

  void _showContextMenu(BuildContext context, Offset tapPosition) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'print',
          child: Row(
            children: [
              Icon(Icons.print_outlined, color: Colors.grey),
              SizedBox(width: 8),
              Text('طباعة / تصدير'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    );

    switch (result) {
      case 'edit':
        context.push('/supplier-agreements/edit/${agreement.id}');
        break;
      case 'delete':
        print('حذف الاتفاقية: ${agreement.id}');
        break;
      case 'print':
        print('طباعة الاتفاقية: ${agreement.id}');
        break;
    }
  }

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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onLongPressStart: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        onSecondaryTapDown: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        child: InkWell(
          onTap: () {
            context.push('/supplier-agreements/details/${agreement.id}');
          },
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
                      child: Row(
                        children: [
                          Text(
                            agreement.contactName ?? 'مورد غير محدد',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (agreement.contactId != null)
                            IconButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.info_outline,
                                color: theme.primaryColor.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () => context.push(
                                '/suppliers/${agreement.contactId}',
                                extra: agreement.contactName,
                              ),
                              tooltip: 'عرض سجل المورد',
                            ),
                        ],
                      ),
                    ),
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
                      : 'لا توجد ملاحظات.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      theme,
                      Icons.today_outlined,
                      "تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd', 'en_US').format(agreement.agreement_date)}",
                    ),
                    if (agreement.expectedDeliveryDate != null)
                      _buildInfoChip(
                        theme,
                        Icons.calendar_today_outlined,
                        "تسليم: ${DateFormat('yyyy/MM/dd', 'en_US').format(agreement.expectedDeliveryDate!)}",
                        color: (daysRemaining ?? 0) < 3
                            ? Colors.red.shade700
                            : null,
                      ),
                  ],
                ),
              ],
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
