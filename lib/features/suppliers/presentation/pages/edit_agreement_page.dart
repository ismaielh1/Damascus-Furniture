// lib/features/suppliers/presentation/pages/edit_agreement_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_agreement_model.dart';
import 'package:syria_store/features/suppliers/data/models/supplier_financials_model.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/add_payment_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/dialogs/edit_payment_dialog.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/agreement_items_provider.dart';
import 'package:syria_store/features/suppliers/presentation/providers/supplier_details_provider.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/receive_item_dialog.dart';
// ... import widgets
import 'package:syria_store/features/suppliers/presentation/widgets/edit_agreement/agreement_main_details_form.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/edit_agreement/agreement_items_editor.dart';
import 'package:syria_store/features/suppliers/presentation/widgets/edit_agreement/agreement_financials_editor.dart';

class EditAgreementPage extends ConsumerStatefulWidget {
  final String agreementId;
  const EditAgreementPage({super.key, required this.agreementId});

  @override
  ConsumerState<EditAgreementPage> createState() => _EditAgreementPageState();
}

class _EditAgreementPageState extends ConsumerState<EditAgreementPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _downPaymentController =
      TextEditingController(); // This will be updated dynamically
  DateTime? _selectedDeliveryDate;

  @override
  void initState() {
    super.initState();
    ref.listenManual(agreementDetailsProvider(widget.agreementId), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        _populateFields(next.value);
      }
    });
  }

  void _populateFields(SupplierAgreement? agreement) {
    if (agreement != null) {
      _notesController.text = agreement.agreementDetails;
      // We no longer set downPaymentController directly, it's calculated from the payments list
      _selectedDeliveryDate = agreement.expectedDeliveryDate;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _downPaymentController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      // We pass the latest down_payment value from the provider, not the controller.
      final currentDownPayment =
          ref
              .read(agreementDetailsProvider(widget.agreementId))
              .value
              ?.down_payment ??
          0.0;
      ref
          .read(updateAgreementStatusControllerProvider.notifier)
          .updateAgreement(
            context: context,
            agreementId: widget.agreementId,
            notes: _notesController.text.trim(),
            downPayment: currentDownPayment,
            expectedDeliveryDate: _selectedDeliveryDate,
          )
          .then((success) {
            if (success && mounted) {
              context.pop();
            }
          });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() => _selectedDeliveryDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agreementAsync = ref.watch(
      agreementDetailsProvider(widget.agreementId),
    );
    final isSaving = ref.watch(updateAgreementStatusControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الاتفاقية')),
      body: agreementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('خطأ في تحميل البيانات: $err')),
        data: (agreement) {
          if (agreement == null) {
            return const Center(child: Text('لم يتم العثور على الاتفاقية'));
          }
          // Update the controller for display purposes
          _downPaymentController.text = (agreement.down_payment ?? 0.0)
              .toStringAsFixed(2);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AgreementMainDetailsForm(
                    contactName: agreement.contactName ?? 'غير محدد',
                    notesController: _notesController,
                    selectedDeliveryDate: _selectedDeliveryDate,
                    onPickDate: _pickDate,
                  ),
                  const SizedBox(height: 24),

                  AgreementItemsEditor(agreementId: agreement.id),
                  const SizedBox(height: 24),

                  AgreementFinancialsEditor(
                    agreementId: agreement.id,
                    downPaymentController: _downPaymentController,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: isSaving ? null : _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('حفظ التعديلات الأساسية'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
