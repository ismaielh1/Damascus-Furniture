// lib/features/invoices/presentation/widgets/customer_section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/customers/presentation/dialogs/add_edit_customer_dialog.dart';
import 'package:syria_store/features/customers/presentation/providers/customers_provider.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';

class CustomerSectionWidget extends ConsumerWidget {
  final bool isWalkInCustomer;
  final ValueChanged<bool?> onWalkInCustomerChanged;
  final TextEditingController manualInvoiceController;
  final TextEditingController customerAutocompleteController;

  const CustomerSectionWidget({
    super.key,
    required this.isWalkInCustomer,
    required this.onWalkInCustomerChanged,
    required this.manualInvoiceController,
    required this.customerAutocompleteController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceState = ref.watch(invoiceFormProvider);

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
                    controller: manualInvoiceController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الفاتورة (اختياري)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat(
                        'yyyy/MM/dd',
                      ).format(invoiceState.invoiceDate),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الفاتورة',
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
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
              value: isWalkInCustomer,
              onChanged: onWalkInCustomerChanged,
            ),
            if (!isWalkInCustomer)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Autocomplete<ContactModel>(
                      displayStringForOption: (ContactModel option) =>
                          option.name,
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                            if (textEditingValue.text == '') {
                              return const Iterable<ContactModel>.empty();
                            }
                            return await ref.watch(
                              customerAutocompleteProvider(
                                textEditingValue.text,
                              ).future,
                            );
                          },
                      onSelected: (ContactModel selection) {
                        ref
                            .read(invoiceFormProvider.notifier)
                            .setCustomer(selection);
                        customerAutocompleteController.text = selection.name;
                      },
                      fieldViewBuilder:
                          (
                            BuildContext context,
                            TextEditingController fieldController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: fieldController,
                              focusNode: fieldFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'ابحث عن اسم العميل أو رقمه',
                              ),
                            );
                          },
                      optionsViewBuilder:
                          (
                            BuildContext context,
                            AutocompleteOnSelected<ContactModel> onSelected,
                            Iterable<ContactModel> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  height: 200.0,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final ContactModel option = options
                                              .elementAt(index);
                                          return GestureDetector(
                                            onTap: () => onSelected(option),
                                            child: ListTile(
                                              title: Text(option.name),
                                              subtitle: Text(
                                                option.phoneNumber ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const AddEditCustomerDialog(),
                    ),
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
