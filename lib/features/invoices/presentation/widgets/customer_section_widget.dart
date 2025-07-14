// lib/features/invoices/presentation/widgets/customer_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/customers/presentation/dialogs/add_edit_customer_dialog.dart';
import 'package:syria_store/features/customers/presentation/providers/customers_provider.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';

class CustomerSectionWidget extends ConsumerStatefulWidget {
  final bool isWalkInCustomer;
  final ValueChanged<bool?> onWalkInCustomerChanged;
  final TextEditingController manualInvoiceController;

  const CustomerSectionWidget({
    super.key,
    required this.isWalkInCustomer,
    required this.onWalkInCustomerChanged,
    required this.manualInvoiceController, required TextEditingController customerAutocompleteController,
  });

  @override
  ConsumerState<CustomerSectionWidget> createState() =>
      _CustomerSectionWidgetState();
}

class _CustomerSectionWidgetState extends ConsumerState<CustomerSectionWidget> {
  final _autocompleteController = TextEditingController();
  final _autocompleteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // يستمع للتغيرات خارج نطاق التركيز ليتحقق من صحة الإدخال
    _autocompleteFocusNode.addListener(() {
      if (!_autocompleteFocusNode.hasFocus) {
        // إذا كان النص لا يطابق العميل المختار، قم بمسح كل شيء
        final selectedCustomer = ref.read(invoiceFormProvider).selectedCustomer;
        if (selectedCustomer == null ||
            _autocompleteController.text != selectedCustomer.name) {
          _autocompleteController.clear();
          ref.read(invoiceFormProvider.notifier).setCustomer(null);
        }
      }
    });
  }

  @override
  void dispose() {
    _autocompleteController.dispose();
    _autocompleteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoiceState = ref.watch(invoiceFormProvider);

    // تحديث النص في الحقل إذا تم اختيار عميل
    final selectedCustomer = invoiceState.selectedCustomer;
    if (selectedCustomer != null &&
        _autocompleteController.text != selectedCustomer.name) {
      _autocompleteController.text = selectedCustomer.name;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات العميل والفاتورة', style: theme.textTheme.titleLarge),
            const Divider(),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                        controller: widget.manualInvoiceController,
                        decoration: const InputDecoration(
                            labelText: 'رقم الفاتورة (اختياري)'))),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: DateFormat('yyyy/MM/dd')
                            .format(invoiceState.invoiceDate)),
                    decoration:
                        const InputDecoration(labelText: 'تاريخ الفاتورة'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101));
                      if (pickedDate != null) {
                        ref
                            .read(invoiceFormProvider.notifier)
                            .setInvoiceDate(pickedDate);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('زبون عابر (بدون اسم)'),
              value: widget.isWalkInCustomer,
              onChanged: widget.onWalkInCustomerChanged,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (!widget.isWalkInCustomer)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Autocomplete<ContactModel>(
                      displayStringForOption: (ContactModel option) =>
                          option.name,
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<ContactModel>.empty();
                        }
                        final options = await ref.watch(
                            customerAutocompleteProvider(textEditingValue.text)
                                .future);
                        // الاختيار التلقائي إذا كانت هناك نتيجة واحدة
                        if (options.length == 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(invoiceFormProvider.notifier)
                                .setCustomer(options.first);
                          });
                        }
                        return options;
                      },
                      onSelected: (ContactModel selection) {
                        ref
                            .read(invoiceFormProvider.notifier)
                            .setCustomer(selection);
                        _autocompleteController.text = selection.name;
                      },
                      fieldViewBuilder: (context, fieldController,
                          fieldFocusNode, onFieldSubmitted) {
                        // استخدام المتحكمات الخاصة بنا
                        _autocompleteController.addListener(() {
                          fieldController.text = _autocompleteController.text;
                        });
                        _autocompleteFocusNode.addListener(() {
                          if (_autocompleteFocusNode.hasFocus) {
                            fieldFocusNode.requestFocus();
                          } else {
                            fieldFocusNode.unfocus();
                          }
                        });

                        return TextFormField(
                          controller: fieldController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                              labelText: 'ابحث عن اسم العميل أو رقمه',
                              hintText: 'اكتب للبحث...'),
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const AddEditCustomerDialog()),
                    tooltip: 'إضافة عميل جديد',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
