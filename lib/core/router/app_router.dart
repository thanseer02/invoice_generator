import 'package:go_router/go_router.dart';
import '../../presentation/home_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/customers/customers_list_screen.dart';
import '../../presentation/customers/customer_form_screen.dart';
import '../../presentation/customers/customer_detail_screen.dart';
import '../../presentation/products/products_list_screen.dart';
import '../../presentation/products/product_form_screen.dart';
import '../../presentation/invoices/invoices_list_screen.dart';
import '../../presentation/invoices/invoice_form_screen.dart';
import '../../presentation/invoices/invoice_detail_screen.dart';
import '../../presentation/invoices/pdf_preview_screen.dart';
import '../../presentation/reports/reports_dashboard_screen.dart';
import '../providers/auth_provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const CustomerFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => CustomerFormScreen(customerId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => ProductFormScreen(productId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsDashboardScreen(),
      ),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoicesListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const InvoiceFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: ':id/preview',
            builder: (context, state) => PdfPreviewScreen(invoiceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => InvoiceFormScreen(invoiceId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authProvider.isLoading) return null;
      
      final bool loggedIn = authProvider.isAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
  );
}
