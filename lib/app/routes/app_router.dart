// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/logs/presentation/pages/logs_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/add_agreement_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/agreement_details_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_agreements_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_details_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/suppliers_list_page.dart';

final goRouter = GoRouter(
  initialLocation: '/supplier-agreements',
  routes: [
    GoRoute(
      path: '/supplier-agreements',
      builder: (context, state) => const SupplierAgreementsPage(),
      routes: [
        // صفحة تفاصيل الاتفاقية كصفحة فرعية
        GoRoute(
          path: 'details/:agreementId',
          builder: (context, state) {
            final agreementId = state.pathParameters['agreementId']!;
            return AgreementDetailsPage(agreementId: agreementId);
          },
        ),
      ],
    ),

    // --- ** بداية التعديل: تنظيم مسارات الموردين ** ---
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SuppliersListPage(),
      routes: [
        // جعل صفحة تفاصيل المورد صفحة فرعية من قائمة الموردين
        GoRoute(
          path: ':supplierId', // المسار النسبي هو رقم المورد فقط
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

    // --- ** نهاية التعديل ** ---
    GoRoute(
      path: '/add-agreement',
      builder: (context, state) => const AddAgreementPage(),
    ),
    GoRoute(path: '/logs', builder: (context, state) => const LogsPage()),
  ],
);
