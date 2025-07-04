// lib/app/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:syria_store/features/logs/presentation/pages/logs_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/add_agreement_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/agreement_details_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_agreements_page.dart';
import 'package:syria_store/features/suppliers/presentation/pages/supplier_details_page.dart';

final goRouter = GoRouter(
  initialLocation: '/supplier-agreements',
  routes: [
    // --- المسار الرئيسي لقائمة الاتفاقيات مع مسار فرعي للتفاصيل ---
    GoRoute(
      path: '/supplier-agreements',
      builder: (context, state) => const SupplierAgreementsPage(),
      routes: [
        GoRoute(
          // لاحظ أن المسار نسبي الآن (بدون / في البداية)
          path: 'details/:agreementId',
          builder: (context, state) {
            final agreementId = state.pathParameters['agreementId']!;
            return AgreementDetailsPage(agreementId: agreementId);
          },
        ),
      ],
    ),
    // --- المسار الجديد لصفحة تفاصيل المورد ---
    GoRoute(
      path: '/suppliers/:supplierId',
      builder: (context, state) {
        // استلام اسم المورد كـ extra data لتحسين تجربة المستخدم
        final supplierName = state.extra as String? ?? 'تفاصيل المورد';
        final supplierId = state.pathParameters['supplierId']!;
        return SupplierDetailsPage(
          supplierId: supplierId,

          supplierName: supplierName,
        );
      },
    ),
    GoRoute(
      path: '/add-agreement',
      builder: (context, state) => const AddAgreementPage(),
    ),
    GoRoute(path: '/logs', builder: (context, state) => const LogsPage()),
  ],
);
