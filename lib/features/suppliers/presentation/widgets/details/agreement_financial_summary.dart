// lib/features/suppliers/presentation/widgets/details/agreement_financial_summary.dart
import 'package:flutter/material.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/add_payment_dialog.dart';

class AgreementFinancialSummary extends StatelessWidget {
  final SupplierAgreement agreement;
  final bool isUpdating;

  const AgreementFinancialSummary({
    super.key,
    required this.agreement,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingAmount = agreement.totalAmount - (agreement.down_payment ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الملخص المالي', style: theme.textTheme.titleLarge),
            if (!isUpdating)
              TextButton.icon(
                icon: const Icon(Icons.add_card),
                label: const Text('إضافة دفعة'),
                onPressed: () => showDialog(context: context, builder: (_) => AddPaymentDialog(agreementId: agreement.id)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _buildFinancialRow(theme, 'المجموع الإجمالي:', '\$${agreement.totalAmount.toStringAsFixed(2)}'),
        _buildFinancialRow(theme, 'المبلغ المدفوع:', '\$${(agreement.down_payment ?? 0).toStringAsFixed(2)}'),
        const Divider(thickness: 1, height: 24),
        _buildFinancialRow(theme, 'المبلغ المتبقي:', '\$${remainingAmount.toStringAsFixed(2)}', isTotal: true),
      ],
    );
  }

  Widget _buildFinancialRow(ThemeData theme, String title, String value, {bool isTotal = false}) {
    // -- بداية التعديل الكامل للدالة --
    // نحدد الستايل الأساسي من السمة
    TextStyle? baseStyle = isTotal
        ? theme.textTheme.titleLarge
        : theme.textTheme.titleMedium;

    // في حال كان الستايل فارغاً من السمة، نستخدم قيمة افتراضية آمنة
    baseStyle ??= const TextStyle(fontSize: 16);

    // نطبق التعديلات على الستايل الآمن
    final titleStyle = baseStyle.copyWith(
      color: isTotal ? theme.primaryColor : Colors.black87,
      fontWeight: isTotal ? FontWeight.bold : baseStyle.fontWeight,
    );
    
    final valueStyle = baseStyle.copyWith(
      color: isTotal ? theme.primaryColor : baseStyle.color,
      fontWeight: isTotal ? FontWeight.bold : baseStyle.fontWeight,
    );
    // -- نهاية التعديل الكامل للدالة --
        
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: titleStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
