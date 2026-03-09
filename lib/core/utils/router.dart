import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/widgets/main_navigation.dart';
import 'package:facturo/features/dashboard/views/dashboard_view.dart';
import 'package:facturo/features/invoices/views/invoices_view.dart';
import 'package:facturo/features/invoices/views/invoice_detail_view.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/estimates/views/estimates_view.dart';
import 'package:facturo/features/expenses/views/expenses_view.dart';
import 'package:facturo/features/expenses/views/expense_list_view.dart';
import 'package:facturo/features/expenses/views/expense_detail_view.dart';
import 'package:facturo/features/expenses/views/expense_category_list_view.dart';
import 'package:facturo/features/expenses/views/expense_category_detail_view.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/clients/views/clients_view.dart';
import 'package:facturo/features/clients/views/client_detail_view.dart';
import 'package:facturo/features/reports/views/reports_view.dart';
import 'package:facturo/features/profile/views/profile_view.dart';
import 'package:facturo/features/profile/views/business_profile_view.dart';
import 'package:facturo/features/profile/views/business_info_edit_view.dart';
import 'package:facturo/features/profile/views/user_profile_edit_view.dart';
import 'package:facturo/features/profile/views/onboarding/profile_onboarding_step1.dart';
import 'package:facturo/features/profile/views/onboarding/profile_onboarding_step2.dart';
import 'package:facturo/features/profile/views/onboarding/profile_onboarding_step3.dart';
import 'package:facturo/features/profile/views/my_account_view.dart';
import 'package:facturo/features/settings/views/language_settings_view.dart';
import 'package:facturo/features/settings/views/currency_settings_view.dart';
import 'package:facturo/features/subscriptions/views/subscription_view.dart';
import 'package:facturo/features/subscriptions/views/subscription_success_view.dart';
import 'package:facturo/features/subscriptions/views/account_prompt_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/features/estimates/views/estimate_detail_view.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/common/widgets/responsive_example_widget.dart';
import 'package:facturo/features/signature/views/digital_signature_view.dart';
import 'package:facturo/features/ocr/views/receipt_uploader.dart';
import 'package:facturo/features/ocr/views/ocr_review_view.dart';
import 'package:facturo/features/ocr/views/receipt_detail_view.dart';
import 'package:facturo/features/ocr/models/ocr_scan.dart';
import 'package:facturo/features/onboarding/views/welcome_view.dart';
import 'package:facturo/features/onboarding/views/onboarding_view.dart';
import 'package:facturo/features/auth/views/auth_wrapper_view.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart' as auth;
import 'package:facturo/features/notifications/views/notifications_view.dart';
import 'package:facturo/features/notifications/views/notification_settings_view.dart';
import 'dart:io';

class AppRoutes {
  static const String home = 'home';
  static const String subscriptions = 'subscriptions';
  static const String onboarding = 'onboarding';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Escuchar cambios en el auth state para refrescar el router
  ref.listen<auth.AuthStateData>(
    auth.authControllerProvider,
    (previous, next) {},
  );

  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(auth.authControllerProvider);
      final currentLocation = state.uri.toString();

      // IMPORTANTE: Si estamos en /login, NUNCA redirigir automáticamente
      if (currentLocation == '/login') {
        return null;
      }

      // Si está cargando, NO redirigir - mantener ubicación actual
      if (authState.state == auth.AuthState.loading) {
        return null;
      }

      // Si hay usuario (anónimo o permanente) y está en welcome/onboarding/landing, ir al dashboard
      // Pero NO redirigir si está en subscriptions, login, o rutas de registro (el usuario puede querer pagar primero)
      // IMPORTANTE: No redirigir desde /login - el usuario eligió "Ya tengo cuenta"
      final noRedirectRoutes = [
        '/subscriptions',
        '/login',
        '/register-after-payment',
      ];
      if ((authState.state == auth.AuthState.authenticated ||
              authState.state == auth.AuthState.anonymous) &&
          (state.uri.toString() == '/welcome' ||
              state.uri.toString() == '/onboarding') &&
          !noRedirectRoutes.contains(state.uri.toString())) {
        return AppConstants.dashboardRoute;
      }

      // Si no hay usuario y no está en rutas permitidas sin auth, ir a welcome
      // Permitir acceso a: welcome, onboarding, registro post-pago, login, auth routes
      // IMPORTANTE: /login y /auth/* están permitidos para que el usuario pueda acceder sin autenticación
      final allowedUnauthRoutes = [
        '/welcome',
        '/onboarding',
        '/register-after-payment',
        '/login',
        '/auth/',
        AppConstants.subscriptionsRoute,
        AppConstants.subscriptionSuccessRoute,
        '/account-prompt',
      ];
      if (authState.state == auth.AuthState.unauthenticated &&
          !allowedUnauthRoutes.any(
            (route) => state.uri.toString().startsWith(route),
          )) {
        return '/welcome';
      }

      return null;
    },
    routes: [
      // Welcome Route (Entry point)
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeView(),
      ),

      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),

      // Auth Routes - Direct Registration (uses AuthBottomSheet)
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const AuthWrapperView(isLogin: false),
      ),

      // Auth Routes - Anonymous User Conversion (uses AuthBottomSheet)
      GoRoute(
        path: '/auth/convert',
        builder: (context, state) => const AuthWrapperView(isLogin: false),
      ),

      // Anonymous Conversion from Subscription Flow (uses AuthBottomSheet)
      GoRoute(
        path: '/anonymous-conversion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AuthWrapperView(
            isLogin: false,
            fromSubscription: extra?['fromSubscription'] as bool? ?? false,
            selectedPlan: extra?['selectedPlan'] as String?,
          );
        },
      ),

      // Auth Routes - Login for existing users (uses AuthBottomSheet)
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthWrapperView(isLogin: true),
      ),

      // Main Navigation Route - contiene todas las pantallas principales con BottomNavigationBar
      GoRoute(
        path: AppConstants.dashboardRoute,
        builder: (context, state) =>
            const MainNavigation(initialIndex: 0, child: DashboardView()),
      ),

      // Feature Routes - ahora son rutas anidadas dentro de MainNavigation
      GoRoute(
        path: AppConstants.invoicesRoute,
        builder: (context, state) =>
            const MainNavigation(initialIndex: 1, child: InvoicesView()),
      ),
      GoRoute(
        path: InvoiceDetailView.routePath,
        builder: (context, state) {
          final invoice = state.extra as Invoice?;
          return InvoiceDetailView(invoice: invoice);
        },
      ),
      GoRoute(
        path: InvoiceDetailView.createRoutePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InvoiceDetailView(
            invoice: extra?['invoice'] as Invoice?,
            ocrData: extra?['ocrData'] as Map<String, dynamic>?,
            autoStartOCR: extra?['autoStartOCR'] == true,
          );
        },
      ),
      GoRoute(
        path: AppConstants.estimatesRoute,
        builder: (context, state) =>
            const MainNavigation(initialIndex: 2, child: EstimatesView()),
      ),
      GoRoute(
        path: EstimateDetailView.routePath,
        builder: (context, state) {
          final estimate = state.extra as Estimate?;
          return EstimateDetailView(estimate: estimate);
        },
      ),

      // Expenses Routes
      GoRoute(
        path: AppConstants.expensesRoute,
        builder: (context, state) =>
            const MainNavigation(initialIndex: 3, child: ExpensesView()),
      ),
      GoRoute(
        path: ExpenseListView.routePath,
        builder: (context, state) => const ExpenseListView(),
      ),
      GoRoute(
        path: ExpenseDetailView.routePath,
        builder: (context, state) {
          final expense = state.extra as Expense?;
          return ExpenseDetailView(expense: expense);
        },
      ),
      GoRoute(
        path: ExpenseCategoryListView.routePath,
        builder: (context, state) => const ExpenseCategoryListView(),
      ),
      GoRoute(
        path: ExpenseCategoryDetailView.routePath,
        builder: (context, state) {
          final category = state.extra as ExpenseCategory?;
          return ExpenseCategoryDetailView(category: category);
        },
      ),

      // Clients Routes
      GoRoute(
        path: AppConstants.clientsRoute,
        builder: (context, state) => const ClientsView(),
      ),
      GoRoute(
        path: '/clients/new',
        builder: (context, state) => const ClientDetailView(),
      ),
      GoRoute(
        path: '/clients/:id',
        builder: (context, state) {
          final clientId = state.pathParameters['id']!;
          return ClientDetailView(clientId: clientId);
        },
      ),
      GoRoute(
        path: AppConstants.reportsRoute,
        builder: (context, state) =>
            const MainNavigation(initialIndex: 4, child: ReportsView()),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfileView(),
      ),
      // Business Profile Card View
      GoRoute(
        path: '/business-profile',
        builder: (context, state) => const BusinessProfileView(),
      ),
      // Profile subroutes
      GoRoute(
        path: AppConstants.businessInfoRoute,
        builder: (context, state) => const BusinessInfoEditView(),
      ),
      GoRoute(
        path: AppConstants.userProfileEditRoute,
        builder: (context, state) => const UserProfileEditView(),
      ),
      GoRoute(
        path: AppConstants.languageSettingsRoute,
        builder: (context, state) => const LanguageSettingsView(),
      ),
      GoRoute(
        path: AppConstants.currencySettingsRoute,
        builder: (context, state) => const CurrencySettingsView(),
      ),
      GoRoute(
        path: AppConstants.digitalSignatureRoute,
        builder: (context, state) => const DigitalSignatureView(),
      ),

      // Profile Onboarding Routes
      GoRoute(
        path: '/profile-onboarding/step1',
        builder: (context, state) => const ProfileOnboardingStep1(),
      ),
      GoRoute(
        path: '/profile-onboarding/step2',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProfileOnboardingStep2(previousData: extra);
        },
      ),
      GoRoute(
        path: '/profile-onboarding/step3',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProfileOnboardingStep3(previousData: extra);
        },
      ),

      // My Account Route
      GoRoute(
        path: '/profile/my-account',
        builder: (context, state) => const MyAccountView(),
      ),

      // OCR Routes
      GoRoute(
        path: '/receipt-uploader',
        builder: (context, state) => const ReceiptUploaderPage(),
      ),
      GoRoute(
        path: '/ocr/review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OCRReviewView(
            imageFile: extra['imageFile'] as File,
            extractedData: extra['extractedData'] as Map<String, dynamic>,
          );
        },
      ),
      GoRoute(
        path: '/receipt-detail',
        builder: (context, state) {
          final receipt = state.extra as OCRScan;
          return ReceiptDetailView(receipt: receipt);
        },
      ),

      // Subscription Routes

      // Subscription Routes
      GoRoute(
        path: '/subscriptions',
        name: AppRoutes.subscriptions,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SubscriptionView(
            title: extra?['title'] ?? 'Facturo Pro',
            message: extra?['message'] ?? 'Unlock unlimited invoicing',
            icon: Icons.workspace_premium,
            isFirstTimePaywall: extra?['isFirstTimePaywall'] ?? false,
            selectedPlan: extra?['selectedPlan'] as String?,
            autoStartPurchase: extra?['autoStartPurchase'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/responsive-example',
        builder: (context, state) => const ResponsiveExampleWidget(),
      ),

      // Notifications Route
      GoRoute(
        path: NotificationsView.routePath,
        name: NotificationsView.routeName,
        builder: (context, state) => const NotificationsView(),
      ),

      // Notification Settings Route
      GoRoute(
        path: NotificationSettingsView.routePath,
        name: NotificationSettingsView.routeName,
        builder: (context, state) => const NotificationSettingsView(),
      ),

      // OCR routes temporarily removed until views are available
      GoRoute(
        path: AppConstants.subscriptionSuccessRoute,
        builder: (context, state) {
          final subscriptionType =
              state.uri.queryParameters['type'] ?? 'monthly';
          final isAnonymous =
              state.uri.queryParameters['isAnonymous'] == 'true';
          return SubscriptionSuccessView(
            subscriptionType: subscriptionType,
            isAnonymous: isAnonymous,
          );
        },
      ),

      // Account Prompt Route - shown to anonymous users after subscription success
      GoRoute(
        path: '/account-prompt',
        builder: (context, state) => const AccountPromptView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: Text(AppLocalizations.of(context).goToDashboard),
            ),
          ],
        ),
      ),
    ),
  );
});

class AppRouter {
  static GoRouter get router => throw UnimplementedError(
    'Use routerProvider instead of AppRouter.router',
  );
}
