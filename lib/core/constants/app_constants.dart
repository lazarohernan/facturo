class AppConstants {
  // App Info
  static const String appName = 'Facturo';
  static const String appTagline = 'Invoice Management Made Simple';
  static const String appVersion = '1.0.5';

  // Auth Messages
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed';
  static const String registerSuccess = 'Registration successful';
  static const String registerFailed = 'Registration failed';
  static const String passwordResetEmailSent = 'Password reset email sent';
  static const String passwordResetFailed =
      'Failed to send password reset email';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/';
  static const String profileRoute = '/profile';
  static const String subscriptionsRoute = '/subscriptions';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String dashboardRoute = '/dashboard';

  // Feature Routes
  static const String invoicesRoute = '/invoices';
  static const String addInvoiceRoute = '/invoices/new';
  static const String invoiceFormRoute =
      '/invoices/new'; // Alias for addInvoiceRoute
  static const String addEditInvoiceRoute = '/invoices/edit';
  static const String estimatesRoute = '/estimates';
  static const String addEstimateRoute = '/estimates/new';
  static const String estimateFormRoute =
      '/estimates/new'; // Alias for addEstimateRoute
  static const String addEditEstimateRoute = '/estimates/edit';
  static const String expensesRoute = '/expenses';
  static const String addExpenseRoute = '/expenses/new';
  static const String expenseFormRoute =
      '/expenses/new'; // Alias for addExpenseRoute
  static const String addEditExpenseRoute = '/expenses/edit';
  static const String clientsRoute = '/clients';
  static const String addClientRoute = '/clients/new';
  static const String clientFormRoute =
      '/clients/new'; // Alias for addClientRoute
  static const String addEditClientRoute = '/clients/edit';
  static const String clientDetailRoute = '/clients/:id';
  static const String reportsRoute = '/reports';
  static const String languageSettingsRoute = '/language-settings';
  static const String currencySettingsRoute = '/currency-settings';
  static const String subscriptionSuccessRoute = '/subscription-success';
  static const String digitalSignatureRoute = '/digital-signature';
  static const String businessInfoRoute = '/profile/business-info';
  static const String userProfileEditRoute = '/profile/user-profile-edit';

  // Other constants
  static const String appDescription = 'Invoice management app';
  static const String appAuthor = 'Facturo';
  static const String appEmail = 'facturohn@gmail.com';
  static const String appWebsite = 'https://facturoapp.com';
  
  // Privacy Policy URLs (language-specific)
  static const String appPrivacyPolicyEn = 'https://facturoapp.com/privacy-policy-en.html';
  static const String appPrivacyPolicyEs = 'https://facturoapp.com/privacy-policy.html';
  
  // Terms of Service URLs (language-specific)
  static const String appTermsOfServiceEn = 'https://facturoapp.com/terms-and-conditions-en.html';
  static const String appTermsOfServiceEs = 'https://facturoapp.com/terms-and-conditions.html';
  
  // Legacy URLs (for backward compatibility)
  static const String appPrivacyPolicy = appPrivacyPolicyEn;
  static const String appTermsOfService = appTermsOfServiceEn;
}
