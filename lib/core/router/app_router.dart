import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/app_shell.dart';
import '../../presentation/home_screen.dart';
import '../../presentation/analytics/analytics_screen.dart';
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
import '../../presentation/expenses/expenses_list_screen.dart';
import '../../presentation/expenses/expense_form_screen.dart';
import '../../presentation/settings/company_profile_screen.dart';
import '../../presentation/settings/app_settings_screen.dart';
import '../../presentation/settings/backup_settings_screen.dart';
import '../../presentation/settings/notification_settings_screen.dart';
import '../../presentation/settings/lock_screen.dart';
import '../../domain/models/expense.dart';
import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellDashboard');
final GlobalKey<NavigatorState> _shellNavigatorInvoicesKey = GlobalKey<NavigatorState>(debugLabel: 'shellInvoices');
final GlobalKey<NavigatorState> _shellNavigatorCustomersKey = GlobalKey<NavigatorState>(debugLabel: 'shellCustomers');
final GlobalKey<NavigatorState> _shellNavigatorProductsKey = GlobalKey<NavigatorState>(debugLabel: 'shellProducts');
final GlobalKey<NavigatorState> _shellNavigatorExpensesKey = GlobalKey<NavigatorState>(debugLabel: 'shellExpenses');
final GlobalKey<NavigatorState> _shellNavigatorReportsKey = GlobalKey<NavigatorState>(debugLabel: 'shellReports');

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authProvider,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const CompanyProfileScreen(),
      ),
      GoRoute(
        path: '/app-settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: '/backup-settings',
        builder: (context, state) => const BackupSettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorInvoicesKey,
            routes: [
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
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCustomersKey,
            routes: [
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
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProductsKey,
            routes: [
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
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorExpensesKey,
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) {
                      final expense = state.extra as Expense?;
                      return ExpenseFormScreen(expense: expense);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorReportsKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsDashboardScreen(),
              ),
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
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
