// lib/app/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/branches/presentation/pages/branches_list_page.dart';
import 'package:syria_store/features/categories/presentation/pages/categories_list_page.dart';
import 'package:syria_store/features/customers/presentation/pages/customers_list_page.dart';
import 'package:syria_store/features/employees/presentation/pages/employees_list_page.dart';
import 'package:syria_store/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:syria_store/features/invoices/presentation/pages/invoice_details_page.dart';
import 'package:syria_store/features/invoices/presentation/pages/invoices_list_page.dart';
import 'package:syria_store/features/logs/presentation/pages/logs_page.dart';
import 'package:syria_store/features/products/presentation/pages/add_edit_product_page.dart';
import 'package:syria_store/features/products/presentation/pages/product_list_page.dart';
import 'package:syria_store/features/products/presentation/pages/product_selector_page.dart';
import 'package:syria_store/features/reports/presentation/pages/financial_report_page.dart';
import 'package:syria_store/features/settings/presentation/pages/exchange_rate_history_page.dart';
import 'package:syria_store/features/settings/presentation/pages/settings_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/add_agreement_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/agreement_details_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_agreements_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_details_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/suppliers_list_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/edit_agreement_page.dart';

final goRouter = GoRouter(
  initialLocation: '/invoices',
  routes: [
    GoRoute(
      path: '/supplier-agreements',
      builder: (context, state) => const SupplierAgreementsPage(),
      routes: [
        GoRoute(
          path: 'details/:agreementId',
          builder: (context, state) {
            final agreementId = state.pathParameters['agreementId']!;
            return AgreementDetailsPage(agreementId: agreementId);
          },
        ),
        // -- بداية الإضافة --
        GoRoute(
          path: 'edit/:agreementId',
          builder: (context, state) {
            final agreementId = state.pathParameters['agreementId']!;
            return EditAgreementPage(agreementId: agreementId);
          },
        ),
        // -- نهاية الإضافة --
      ],
    ),
    // ... باقي المسارات تبقى كما هي
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SuppliersListPage(),
      routes: [
        GoRoute(
          path: ':supplierId',
          builder: (context, state) {
            final supplierName = state.extra as String? ?? 'تفاصيل المورد';
            final supplierId = state.pathParameters['supplierId']!;
            return SupplierDetailsPage(
              supplierId: supplierId,
              supplierName: supplierName,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/add-agreement',
      builder: (context, state) => const AddAgreementPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const AddEditProductPage(),
        ),
        GoRoute(
          path: 'edit/:productId',
          builder: (context, state) =>
              AddEditProductPage(productId: state.pathParameters['productId']),
        ),
        GoRoute(
          path: 'select',
          builder: (context, state) => const ProductSelectorPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesListPage(),
    ),
    GoRoute(
      path: '/branches',
      builder: (context, state) => const BranchesListPage(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersListPage(),
    ),
    GoRoute(
      path: '/create-invoice',
      builder: (context, state) => const CreateInvoicePage(),
    ),
    GoRoute(
      path: '/invoices',
      builder: (context, state) => const InvoicesListPage(),
      routes: [
        GoRoute(
          path: 'details/:invoiceId',
          builder: (context, state) {
            final invoiceId = state.pathParameters['invoiceId']!;
            return InvoiceDetailsPage(invoiceId: invoiceId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/employees',
      builder: (context, state) => const EmployeesListPage(),
    ),
    GoRoute(
      path: '/financial-report',
      builder: (context, state) => const FinancialReportPage(),
    ),
    GoRoute(path: '/logs', builder: (context, state) => const LogsPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'history',
          builder: (context, state) => const ExchangeRateHistoryPage(),
        ),
      ],
    ),
  ],
);
