// import 'package:go_router/go_router.dart';
// import 'package:syria_store/features/categories/presentation/pages/categories_list_page.dart';
// import 'package:syria_store/features/logs/presentation/pages/logs_page.dart';
// import 'package:syria_store/features/products/presentation/pages/add_edit_product_page.dart';
// import 'package:syria_store/features/products/presentation/pages/product_list_page.dart';
// import 'package:syria_store/features/products/presentation/pages/product_selector_page.dart';
// import 'package:syria_store/features/suppliers/presentation/pages/add_agreement_page.dart';
// import 'package:syria_store/features/suppliers/presentation/pages/agreement_details_page.dart';
// import 'package:syria_store/features/suppliers/presentation/pages/supplier_agreements_page.dart';
// import 'package:syria_store/features/suppliers/presentation/pages/supplier_details_page.dart';
// import 'package:syria_store/features/suppliers/presentation/pages/suppliers_list_page.dart';

// final goRouter = GoRouter(
//   initialLocation: '/supplier-agreements',
//   routes: [
//     GoRoute(
//       path: '/supplier-agreements',
//       builder: (context, state) => const SupplierAgreementsPage(),
//       routes: [
//         GoRoute(
//           path: 'details/:agreementId',
//           builder: (context, state) {
//             final agreementId = state.pathParameters['agreementId']!;
//             return AgreementDetailsPage(agreementId: agreementId);
//           },
//         ),
//       ],
//     ),
//     GoRoute(
//       path: '/suppliers',
//       builder: (context, state) => const SuppliersListPage(),
//       routes: [
//         GoRoute(
//           path: ':supplierId',
//           builder: (context, state) {
//             final supplierName = state.extra as String? ?? 'تفاصيل المورد';
//             final supplierId = state.pathParameters['supplierId']!;
//             return SupplierDetailsPage(supplierId: supplierId, supplierName: supplierName);
//           },
//         ),
//       ]
//     ),
//     GoRoute(
//       path: '/products',
//       builder: (context, state) => const ProductListPage(),
//       routes: [
//         GoRoute(
//           path: 'new',
//           builder: (context, state) => const AddEditProductPage(),
//         ),
//         GoRoute(
//           path: 'select',
//           builder: (context, state) => const ProductSelectorPage(),
//         ),
//       ]
//     ),
//      GoRoute(
//         path: '/categories',
//         builder: (context, state) => const CategoriesListPage(),
//     ),
//     GoRoute(
//       path: '/add-agreement',
//       builder: (context, state) => const AddAgreementPage(),
//     ),
//     GoRoute(
//       path: '/logs',
//       builder: (context, state) => const LogsPage(),
//     ),
//   ],
// );
