// lib/features/invoices/presentation/pages/create_invoice_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syria_store/features/branches/data/models/branch_model.dart';
import 'package:syria_store/features/branches/presentation/providers/branches_provider.dart';
import 'package:syria_store/features/customers/presentation/dialogs/add_edit_customer_dialog.dart';
import 'package:syria_store/features/customers/presentation/providers/customers_provider.dart';
import 'package:syria_store/features/invoices/data/models/fund_model.dart';
import 'package:syria_store/features/invoices/data/models/invoice_item_model.dart';
import 'package:syria_store/features/invoices/data/models/payment_detail_model.dart';
import 'package:syria_store/features/invoices/presentation/providers/employees_provider.dart';
import 'package:syria_store/features/invoices/presentation/providers/funds_provider.dart';
import 'package:syria_store/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:syria_store/features/invoices/presentation/widgets/customer_section_widget.dart';
import 'package:syria_store/features/invoices/presentation/widgets/invoice_items_section_widget.dart';
import 'package:syria_store/features/invoices/presentation/widgets/invoice_summary_widget.dart';
import 'package:syria_store/features/invoices/presentation/widgets/payment_section_widget.dart';
import 'package:syria_store/features/products/data/models/product_model.dart';
import 'package:syria_store/features/settings/presentation/providers/settings_provider.dart';
import 'package:syria_store/features/suppliers/data/models/contact_model.dart';

class CreateInvoicePage extends ConsumerStatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  ConsumerState<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends ConsumerState<CreateInvoicePage> {
  bool _isWalkInCustomer = true;
  FundModel? _selectedUsdFund;
  FundModel? _selectedSypFund;

  final _discountController = TextEditingController();
  final _usdPaymentController = TextEditingController();
  final _sypPaymentController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualInvoiceController = TextEditingController();
  final _customerAutocompleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final employees = ref.read(employeesProvider).valueOrNull;
      if (employees != null && employees.isNotEmpty) {
        ref.read(selectedEmployeeProvider.notifier).state = employees.first;
      }
      final branches = ref.read(branchesProvider).valueOrNull;
      if (branches != null && branches.isNotEmpty) {
        final mainBranch = branches.firstWhere(
          (b) => b.isMain,
          orElse: () => branches.first,
        );
        ref.read(selectedBranchProvider.notifier).state = mainBranch;
      }
    });

    _discountController.addListener(() {
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      ref.read(invoiceFormProvider.notifier).setDiscount(discount);
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    _usdPaymentController.dispose();
    _sypPaymentController.dispose();
    _notesController.dispose();
    _manualInvoiceController.dispose();
    _customerAutocompleteController.dispose();
    super.dispose();
  }

  void _onSaveInvoice() {
    final invoiceState = ref.read(invoiceFormProvider);
    final selectedBranch = ref.read(selectedBranchProvider);
    final selectedEmployee = ref.read(selectedEmployeeProvider);
    final latestRate =
        ref.read(latestExchangeRateProvider).value?.rateUsdToSyp ?? 0.0;

    // -- بداية التعديل --
    // 1. إنشاء قائمة الدفعات بشكل منفصل
    final List<PaymentDetailModel> payments = [];
    final double usdAmount = double.tryParse(_usdPaymentController.text) ?? 0.0;
    if (usdAmount > 0) {
      payments.add(
        PaymentDetailModel(
          amount: usdAmount,
          currency: 'USD',
          fundId: _selectedUsdFund?.id,
        ),
      );
    }

    final double sypAmount = double.tryParse(_sypPaymentController.text) ?? 0.0;
    if (sypAmount > 0) {
      if (latestRate == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تحديد سعر صرف صالح'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      payments.add(
        PaymentDetailModel(
          amount: sypAmount,
          currency: 'SYP',
          exchangeRate: latestRate,
          fundId: _selectedSypFund?.id,
        ),
      );
    }
    // -- نهاية التعديل --

    // ... (Validation logic can be added here)

    ref
        .read(invoiceControllerProvider.notifier)
        .saveInvoice(
          context,
          // 2. تمرير القائمة الجاهزة
          invoiceState: invoiceState.copyWith(
            notes: _notesController.text.trim(),
            manualInvoiceNumber: _manualInvoiceController.text.trim(),
            payments: payments,
          ),
          exchangeRate: latestRate,
          branchId: selectedBranch!.id,
          userId: selectedEmployee!.id,
        )
        .then((success) {
          if (success) _resetForm();
        });
  }

  void _resetForm() {
    ref.read(invoiceFormProvider.notifier).clearForm();
    _discountController.clear();
    _usdPaymentController.clear();
    _sypPaymentController.clear();
    _notesController.clear();
    _manualInvoiceController.clear();
    _customerAutocompleteController.clear();
    setState(() {
      _isWalkInCustomer = true;
      _selectedUsdFund = null;
      _selectedSypFund = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoiceState = ref.watch(invoiceFormProvider);
    final isSaving = ref.watch(invoiceControllerProvider);
    final totalAfterDiscount = invoiceState.totalAfterDiscount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: _buildBranchSelector(),
        actions: [
          _buildExchangeRateDisplay(),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _resetForm,
            tooltip: 'فاتورة جديدة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ref
                    .watch(employeesProvider)
                    .when(
                      data: (employees) =>
                          DropdownButtonFormField<ContactModel>(
                            value: ref.watch(selectedEmployeeProvider),
                            decoration: const InputDecoration(
                              labelText: 'البائع',
                              border: InputBorder.none,
                            ),
                            items: employees
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (employee) =>
                                ref
                                        .read(selectedEmployeeProvider.notifier)
                                        .state =
                                    employee,
                          ),
                      loading: () => const Text('جاري تحميل الموظفين...'),
                      error: (e, s) => const Text('خطأ في تحميل الموظفين'),
                    ),
              ),
            ),
            const SizedBox(height: 16),

            CustomerSectionWidget(
              isWalkInCustomer: _isWalkInCustomer,
              onWalkInCustomerChanged: (value) {
                setState(() {
                  _isWalkInCustomer = value ?? true;
                  if (_isWalkInCustomer) {
                    ref.read(invoiceFormProvider.notifier).setCustomer(null);
                    _customerAutocompleteController.clear();
                  }
                });
              },
              manualInvoiceController: _manualInvoiceController,
              customerAutocompleteController: _customerAutocompleteController,
            ),
            const SizedBox(height: 24),

            const InvoiceItemsSectionWidget(),
            const SizedBox(height: 24),

            InvoiceSummaryWidget(
              discountController: _discountController,
              totalAfterDiscount: totalAfterDiscount,
            ),
            const SizedBox(height: 24),

            PaymentSectionWidget(
              usdPaymentController: _usdPaymentController,
              sypPaymentController: _sypPaymentController,
              selectedUsdFund: _selectedUsdFund,
              selectedSypFund: _selectedSypFund,
              onUsdFundChanged: (fund) =>
                  setState(() => _selectedUsdFund = fund),
              onSypFundChanged: (fund) =>
                  setState(() => _selectedSypFund = fund),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات على الفاتورة',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: isSaving || invoiceState.items.isEmpty
                  ? null
                  : _onSaveInvoice,
              icon: isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
              label: isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('حفظ الفاتورة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector() {
    final branchesAsync = ref.watch(branchesProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);
    return branchesAsync.when(
      data: (branches) {
        if (selectedBranch == null && branches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final mainBranch = branches.firstWhere(
                (b) => b.isMain,
                orElse: () => branches.first,
              );
              ref.read(selectedBranchProvider.notifier).state = mainBranch;
            }
          });
        }
        return DropdownButton<BranchModel>(
          value: selectedBranch,
          hint: const Text('اختر الفرع', style: TextStyle(color: Colors.white)),
          isExpanded: false,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
          dropdownColor: Theme.of(context).primaryColor,
          items: branches
              .map(
                (branch) => DropdownMenuItem<BranchModel>(
                  value: branch,
                  child: Text(branch.name),
                ),
              )
              .toList(),
          onChanged: (branch) =>
              ref.read(selectedBranchProvider.notifier).state = branch,
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
      error: (e, s) => const Icon(Icons.error, color: Colors.red),
    );
  }

  Widget _buildExchangeRateDisplay() {
    final theme = Theme.of(context);
    final latestRateAsync = ref.watch(latestExchangeRateProvider);
    return latestRateAsync.when(
      data: (rate) => rate == null
          ? const Tooltip(
              message: 'لم يتم تحديد سعر صرف',
              child: Icon(Icons.warning, color: Colors.yellow),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  'سعر الصرف: ${rate.rateUsdToSyp}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const Tooltip(
        message: 'خطأ في جلب سعر الصرف',
        child: Icon(Icons.error, color: Colors.red),
      ),
    );
  }
}
