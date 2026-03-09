import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Facturo'**
  String get appTitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessNumber.
  ///
  /// In en, this message translates to:
  /// **'Business Number'**
  String get businessNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @businessInformation.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// No description provided for @digitalSignature.
  ///
  /// In en, this message translates to:
  /// **'Digital Signature'**
  String get digitalSignature;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @selectProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Photo'**
  String get selectProfilePhoto;

  /// No description provided for @profileImageCleared.
  ///
  /// In en, this message translates to:
  /// **'Profile image cleared successfully'**
  String get profileImageCleared;

  /// No description provided for @businessLogo.
  ///
  /// In en, this message translates to:
  /// **'Business Logo'**
  String get businessLogo;

  /// No description provided for @selectLogo.
  ///
  /// In en, this message translates to:
  /// **'Select Logo'**
  String get selectLogo;

  /// No description provided for @deleteLogo.
  ///
  /// In en, this message translates to:
  /// **'Delete Logo'**
  String get deleteLogo;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editing;

  /// No description provided for @viewMode.
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get editMode;

  /// No description provided for @businessInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Business information saved successfully'**
  String get businessInfoSaved;

  /// No description provided for @errorSavingBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Error saving business information'**
  String get errorSavingBusinessInfo;

  /// No description provided for @selectImageError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get selectImageError;

  /// No description provided for @businessInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Business information updated successfully'**
  String get businessInfoUpdated;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @estimates.
  ///
  /// In en, this message translates to:
  /// **'Estimates'**
  String get estimates;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @changeLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the language of the entire application'**
  String get changeLanguageDescription;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @generateReports.
  ///
  /// In en, this message translates to:
  /// **'Generate Reports'**
  String get generateReports;

  /// No description provided for @selectDateRangeAndReportType.
  ///
  /// In en, this message translates to:
  /// **'Select a date range and report type to generate reports.'**
  String get selectDateRangeAndReportType;

  /// No description provided for @availableReports.
  ///
  /// In en, this message translates to:
  /// **'Available Reports'**
  String get availableReports;

  /// No description provided for @invoicesReport.
  ///
  /// In en, this message translates to:
  /// **'Invoices Report'**
  String get invoicesReport;

  /// No description provided for @invoicesReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all invoice data including client details, amounts, and payment status.'**
  String get invoicesReportDescription;

  /// No description provided for @estimatesReport.
  ///
  /// In en, this message translates to:
  /// **'Estimates Report'**
  String get estimatesReport;

  /// No description provided for @estimatesReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all estimates data including client details and amounts.'**
  String get estimatesReportDescription;

  /// No description provided for @expensesReport.
  ///
  /// In en, this message translates to:
  /// **'Expenses Report'**
  String get expensesReport;

  /// No description provided for @expensesReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all expenses data including categories and amounts.'**
  String get expensesReportDescription;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @noInvoicesFoundInRange.
  ///
  /// In en, this message translates to:
  /// **'No invoices found in the selected date range'**
  String get noInvoicesFoundInRange;

  /// No description provided for @noEstimatesFoundInRange.
  ///
  /// In en, this message translates to:
  /// **'No estimates found in the selected date range'**
  String get noEstimatesFoundInRange;

  /// No description provided for @noExpensesFoundInRange.
  ///
  /// In en, this message translates to:
  /// **'No expenses found in the selected date range'**
  String get noExpensesFoundInRange;

  /// No description provided for @errorExportingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Error exporting invoices'**
  String get errorExportingInvoices;

  /// No description provided for @errorExportingEstimates.
  ///
  /// In en, this message translates to:
  /// **'Error exporting estimates'**
  String get errorExportingEstimates;

  /// No description provided for @errorExportingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Error exporting expenses'**
  String get errorExportingExpenses;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @anonymousLogoutWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: Anonymous User'**
  String get anonymousLogoutWarning;

  /// No description provided for @anonymousLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You are using an anonymous account. If you log out, you will NOT be able to recover your data (invoices, clients, expenses, etc.) because there is no way to sign back in as an anonymous user.\n\nWould you like to create a permanent account before logging out to avoid losing your data?'**
  String get anonymousLogoutMessage;

  /// No description provided for @preserveYourData.
  ///
  /// In en, this message translates to:
  /// **'Preserve Your Data'**
  String get preserveYourData;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @createAccountToActivate.
  ///
  /// In en, this message translates to:
  /// **'Create your account to activate\nyour premium subscription'**
  String get createAccountToActivate;

  /// No description provided for @convertAnonymousAccount.
  ///
  /// In en, this message translates to:
  /// **'Convert your anonymous account to a permanent one\nto avoid losing your invoices and clients'**
  String get convertAnonymousAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordHint;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @acceptTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms and conditions and privacy policy'**
  String get acceptTermsAndPrivacy;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @createAccountBeforeLogout.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountBeforeLogout;

  /// No description provided for @logoutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Logout Anyway'**
  String get logoutAnyway;

  /// No description provided for @anonymousDataInfo.
  ///
  /// In en, this message translates to:
  /// **'Note: If you create a new anonymous user after logging out, you will not recover data from your previous account.'**
  String get anonymousDataInfo;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noInformation.
  ///
  /// In en, this message translates to:
  /// **'No information'**
  String get noInformation;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @freeVersion.
  ///
  /// In en, this message translates to:
  /// **'Free Version'**
  String get freeVersion;

  /// No description provided for @freemiumProgress.
  ///
  /// In en, this message translates to:
  /// **'Freemium Progress'**
  String get freemiumProgress;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @nearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near Limit!'**
  String get nearLimit;

  /// No description provided for @upgradeToFacturoPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Facturo Pro'**
  String get upgradeToFacturoPro;

  /// No description provided for @unlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all premium features and grow your business'**
  String get unlockPremiumFeatures;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Active Subscription'**
  String get noActiveSubscription;

  /// No description provided for @selectPlanToAccess.
  ///
  /// In en, this message translates to:
  /// **'Select a plan to access all Facturo features'**
  String get selectPlanToAccess;

  /// No description provided for @activeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get activeSubscription;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan'**
  String get annualPlan;

  /// No description provided for @unlimitedInvoicingMonthly.
  ///
  /// In en, this message translates to:
  /// **'Unlimited invoicing renewed monthly'**
  String get unlimitedInvoicingMonthly;

  /// No description provided for @unlimitedInvoicingAnnual.
  ///
  /// In en, this message translates to:
  /// **'Unlimited invoicing renewed annually'**
  String get unlimitedInvoicingAnnual;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(Object percent);

  /// No description provided for @whatYouGetWithPro.
  ///
  /// In en, this message translates to:
  /// **'What You Get With Pro'**
  String get whatYouGetWithPro;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @storeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Store is not available at the moment. Please try again later.'**
  String get storeNotAvailable;

  /// No description provided for @purchaseRestoration.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration initiated'**
  String get purchaseRestoration;

  /// No description provided for @chooseThePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that best fits your needs'**
  String get chooseThePlan;

  /// No description provided for @subscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionPlans;

  /// No description provided for @autoRenewalIOS.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Cancel anytime in your App Store account settings.'**
  String get autoRenewalIOS;

  /// No description provided for @autoRenewalAndroid.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Cancel anytime in your Google Play account settings.'**
  String get autoRenewalAndroid;

  /// No description provided for @sendingEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending email...'**
  String get sendingEmail;

  /// No description provided for @emailSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email sent successfully'**
  String get emailSentSuccessfully;

  /// No description provided for @errorSendingEmail.
  ///
  /// In en, this message translates to:
  /// **'Error sending email'**
  String get errorSendingEmail;

  /// No description provided for @noClientEmail.
  ///
  /// In en, this message translates to:
  /// **'No client email available. Please update the client\'s email first.'**
  String get noClientEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get resetPasswordInstructions;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetEmailSent;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'A reset link has been sent to your email'**
  String get passwordResetSuccess;

  /// No description provided for @tryAnotherEmail.
  ///
  /// In en, this message translates to:
  /// **'Try another email'**
  String get tryAnotherEmail;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @errorSendingResetLink.
  ///
  /// In en, this message translates to:
  /// **'Error sending reset link'**
  String get errorSendingResetLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get emailSent;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to continue'**
  String get checkYourEmail;

  /// No description provided for @enterEmailToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you instructions to reset your password'**
  String get enterEmailToResetPassword;

  /// No description provided for @passwordResetInstructions.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent an email with instructions to reset your password. Please check your inbox and follow the steps provided.'**
  String get passwordResetInstructions;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @didntReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Resend'**
  String get didntReceiveEmail;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get refreshData;

  /// No description provided for @financialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get netIncome;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs. Expenses'**
  String get incomeVsExpenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @newEstimate.
  ///
  /// In en, this message translates to:
  /// **'New Estimate'**
  String get newEstimate;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @newClient.
  ///
  /// In en, this message translates to:
  /// **'New Client'**
  String get newClient;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentInvoices.
  ///
  /// In en, this message translates to:
  /// **'Recent Invoices'**
  String get recentInvoices;

  /// No description provided for @recentEstimates.
  ///
  /// In en, this message translates to:
  /// **'Recent Estimates'**
  String get recentEstimates;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noRecentInvoices.
  ///
  /// In en, this message translates to:
  /// **'No recent invoices'**
  String get noRecentInvoices;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @noRecentEstimates.
  ///
  /// In en, this message translates to:
  /// **'No recent estimates'**
  String get noRecentEstimates;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total\\nClients'**
  String get totalClients;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active\\nClients'**
  String get activeClients;

  /// No description provided for @unpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid\\nInvoices'**
  String get unpaidInvoices;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @addInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add Invoice'**
  String get addInvoice;

  /// No description provided for @searchInvoices.
  ///
  /// In en, this message translates to:
  /// **'Search invoices...'**
  String get searchInvoices;

  /// No description provided for @searchByInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by invoice number or notes...'**
  String get searchByInvoiceNumber;

  /// No description provided for @noInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoicesFound;

  /// No description provided for @noInvoicesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No invoices match your search'**
  String get noInvoicesMatchSearch;

  /// No description provided for @addYourFirstInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add your first item to the invoice'**
  String get addYourFirstInvoice;

  /// No description provided for @loadingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Loading invoices...'**
  String get loadingInvoices;

  /// No description provided for @invoiceMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Invoice marked as paid'**
  String get invoiceMarkedAsPaid;

  /// No description provided for @invoiceMarkedAsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Invoice marked as unpaid'**
  String get invoiceMarkedAsUnpaid;

  /// No description provided for @invoiceCreatedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Invoice created/updated successfully'**
  String get invoiceCreatedUpdated;

  /// No description provided for @deleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Delete Invoice'**
  String get deleteInvoice;

  /// No description provided for @deleteInvoiceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this invoice?'**
  String get deleteInvoiceConfirmation;

  /// No description provided for @deleteInvoiceWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteInvoiceWarning;

  /// No description provided for @invoiceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice deleted successfully'**
  String get invoiceDeletedSuccess;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'No invoice number'**
  String get noInvoiceNumber;

  /// No description provided for @addEstimate.
  ///
  /// In en, this message translates to:
  /// **'Add Estimate'**
  String get addEstimate;

  /// No description provided for @searchEstimates.
  ///
  /// In en, this message translates to:
  /// **'Search estimates...'**
  String get searchEstimates;

  /// No description provided for @searchByEstimateNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by estimate number or notes...'**
  String get searchByEstimateNumber;

  /// No description provided for @noEstimatesFound.
  ///
  /// In en, this message translates to:
  /// **'No estimates found'**
  String get noEstimatesFound;

  /// No description provided for @noEstimatesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No estimates match your search'**
  String get noEstimatesMatchSearch;

  /// No description provided for @addYourFirstEstimate.
  ///
  /// In en, this message translates to:
  /// **'Add your first estimate by clicking the + button'**
  String get addYourFirstEstimate;

  /// No description provided for @loadingEstimates.
  ///
  /// In en, this message translates to:
  /// **'Loading estimates...'**
  String get loadingEstimates;

  /// No description provided for @estimateMarkedAsActive.
  ///
  /// In en, this message translates to:
  /// **'Estimate marked as active'**
  String get estimateMarkedAsActive;

  /// No description provided for @estimateMarkedAsExpired.
  ///
  /// In en, this message translates to:
  /// **'Estimate marked as expired'**
  String get estimateMarkedAsExpired;

  /// No description provided for @estimateCreatedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Estimate created/updated successfully'**
  String get estimateCreatedUpdated;

  /// No description provided for @deleteEstimate.
  ///
  /// In en, this message translates to:
  /// **'Delete Estimate'**
  String get deleteEstimate;

  /// No description provided for @deleteEstimateConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this estimate?'**
  String get deleteEstimateConfirmation;

  /// No description provided for @deleteEstimateWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteEstimateWarning;

  /// No description provided for @estimateDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Estimate deleted successfully'**
  String get estimateDeletedSuccess;

  /// No description provided for @noEstimateNumber.
  ///
  /// In en, this message translates to:
  /// **'No Estimate Number'**
  String get noEstimateNumber;

  /// No description provided for @convertToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Convert to Invoice'**
  String get convertToInvoice;

  /// No description provided for @estimateDetails.
  ///
  /// In en, this message translates to:
  /// **'Estimate Details'**
  String get estimateDetails;

  /// No description provided for @estimatePreview.
  ///
  /// In en, this message translates to:
  /// **'Estimate Preview'**
  String get estimatePreview;

  /// No description provided for @fillEstimateDetails.
  ///
  /// In en, this message translates to:
  /// **'Please complete the estimate details first'**
  String get fillEstimateDetails;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset Zoom'**
  String get resetZoom;

  /// No description provided for @generatePDF.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePDF;

  /// No description provided for @sendInvoice.
  ///
  /// In en, this message translates to:
  /// **'Send Invoice'**
  String get sendInvoice;

  /// No description provided for @sendByEmail.
  ///
  /// In en, this message translates to:
  /// **'Send by Email'**
  String get sendByEmail;

  /// No description provided for @printEstimate.
  ///
  /// In en, this message translates to:
  /// **'Print Estimate'**
  String get printEstimate;

  /// No description provided for @downloadPDF.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPDF;

  /// No description provided for @shareEstimate.
  ///
  /// In en, this message translates to:
  /// **'Share Estimate'**
  String get shareEstimate;

  /// No description provided for @estimateNumber.
  ///
  /// In en, this message translates to:
  /// **'Estimate Number'**
  String get estimateNumber;

  /// No description provided for @estimateDate.
  ///
  /// In en, this message translates to:
  /// **'Estimate Date'**
  String get estimateDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @clientInformation.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get clientInformation;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select a client'**
  String get selectClient;

  /// No description provided for @noClientSelected.
  ///
  /// In en, this message translates to:
  /// **'No client selected'**
  String get noClientSelected;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get addNotes;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @addSignature.
  ///
  /// In en, this message translates to:
  /// **'Add Signature'**
  String get addSignature;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get clearSignature;

  /// No description provided for @scanInvoice.
  ///
  /// In en, this message translates to:
  /// **'Scan Invoice'**
  String get scanInvoice;

  /// No description provided for @processingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Processing invoice...'**
  String get processingInvoice;

  /// No description provided for @loadingImage.
  ///
  /// In en, this message translates to:
  /// **'Loading image...'**
  String get loadingImage;

  /// No description provided for @imageLoaded.
  ///
  /// In en, this message translates to:
  /// **'Image loaded'**
  String get imageLoaded;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image'**
  String get uploadingImage;

  /// No description provided for @analyzingText.
  ///
  /// In en, this message translates to:
  /// **'Analyzing text'**
  String get analyzingText;

  /// No description provided for @textExtracted.
  ///
  /// In en, this message translates to:
  /// **'Text extracted'**
  String get textExtracted;

  /// No description provided for @extractingData.
  ///
  /// In en, this message translates to:
  /// **'Extracting data...'**
  String get extractingData;

  /// No description provided for @dataExtracted.
  ///
  /// In en, this message translates to:
  /// **'Data extracted'**
  String get dataExtracted;

  /// No description provided for @savingDocument.
  ///
  /// In en, this message translates to:
  /// **'Saving document'**
  String get savingDocument;

  /// No description provided for @processingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Processing completed'**
  String get processingCompleted;

  /// No description provided for @processingError.
  ///
  /// In en, this message translates to:
  /// **'Processing error'**
  String get processingError;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @selectImageToScan.
  ///
  /// In en, this message translates to:
  /// **'Select an image to scan'**
  String get selectImageToScan;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @ocrScanFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get ocrScanFromCamera;

  /// No description provided for @ocrScanFromCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the receipt and scan it in seconds.'**
  String get ocrScanFromCameraSubtitle;

  /// No description provided for @ocrUploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from gallery'**
  String get ocrUploadFromGallery;

  /// No description provided for @ocrUploadFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an existing image to process it.'**
  String get ocrUploadFromGallerySubtitle;

  /// No description provided for @ocrPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Document preview'**
  String get ocrPreviewTitle;

  /// No description provided for @ocrAiProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart processing'**
  String get ocrAiProcessingTitle;

  /// No description provided for @ocrAiProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use AI to detect relevant data and build your invoice automatically.'**
  String get ocrAiProcessingSubtitle;

  /// No description provided for @tipsForPerfectScanning.
  ///
  /// In en, this message translates to:
  /// **'Tips for perfect scanning'**
  String get tipsForPerfectScanning;

  /// No description provided for @ocrTipGoodLighting.
  ///
  /// In en, this message translates to:
  /// **'Ensure the image has good lighting'**
  String get ocrTipGoodLighting;

  /// No description provided for @ocrTipAlignReceipt.
  ///
  /// In en, this message translates to:
  /// **'Align the receipt inside the frame and keep the camera steady.'**
  String get ocrTipAlignReceipt;

  /// No description provided for @ocrTipForBestResults.
  ///
  /// In en, this message translates to:
  /// **'Use the Scan button to process the document.'**
  String get ocrTipForBestResults;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get usePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @errorLoadingClient.
  ///
  /// In en, this message translates to:
  /// **'Error loading client'**
  String get errorLoadingClient;

  /// No description provided for @errorImportingContact.
  ///
  /// In en, this message translates to:
  /// **'Error importing contact'**
  String get errorImportingContact;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @poNumber.
  ///
  /// In en, this message translates to:
  /// **'PO Number'**
  String get poNumber;

  /// No description provided for @errorSendingEstimate.
  ///
  /// In en, this message translates to:
  /// **'Error sending estimate'**
  String get errorSendingEstimate;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @invoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get invoicePreview;

  /// No description provided for @fillInvoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Please complete the invoice details first'**
  String get fillInvoiceDetails;

  /// No description provided for @printInvoice.
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get printInvoice;

  /// No description provided for @shareInvoice.
  ///
  /// In en, this message translates to:
  /// **'Share Invoice'**
  String get shareInvoice;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoiceDate;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @markAsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get markAsUnpaid;

  /// No description provided for @errorSendingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Error sending invoice'**
  String get errorSendingInvoice;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Client Email'**
  String get clientEmail;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Client Phone'**
  String get clientPhone;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Client Address'**
  String get clientAddress;

  /// No description provided for @clientCompany.
  ///
  /// In en, this message translates to:
  /// **'Client Company'**
  String get clientCompany;

  /// No description provided for @clientNotes.
  ///
  /// In en, this message translates to:
  /// **'Client Notes'**
  String get clientNotes;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients...'**
  String get searchClients;

  /// No description provided for @loadingClients.
  ///
  /// In en, this message translates to:
  /// **'Loading clients...'**
  String get loadingClients;

  /// No description provided for @clientCreatedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Client created/updated successfully'**
  String get clientCreatedUpdated;

  /// No description provided for @deleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get deleteClient;

  /// No description provided for @deleteClientConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this client?'**
  String get deleteClientConfirmation;

  /// No description provided for @deleteClientWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteClientWarning;

  /// No description provided for @clientDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Client deleted successfully'**
  String get clientDeletedSuccess;

  /// No description provided for @updateClient.
  ///
  /// In en, this message translates to:
  /// **'Update Client'**
  String get updateClient;

  /// No description provided for @enterClientName.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get enterClientName;

  /// No description provided for @pleaseEnterClientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter client name'**
  String get pleaseEnterClientName;

  /// No description provided for @pleaseEnterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterYourFullName;

  /// No description provided for @enterClientEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter client email'**
  String get enterClientEmail;

  /// No description provided for @enterClientPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter client phone'**
  String get enterClientPhone;

  /// No description provided for @enterClientAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter client address'**
  String get enterClientAddress;

  /// No description provided for @secondaryEmail.
  ///
  /// In en, this message translates to:
  /// **'Secondary Email'**
  String get secondaryEmail;

  /// No description provided for @enterSecondaryEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter secondary email (optional)'**
  String get enterSecondaryEmail;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @enterAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Enter address line 1'**
  String get enterAddressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// No description provided for @enterAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Enter address line 2 (optional)'**
  String get enterAddressLine2;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @clientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Client not found'**
  String get clientNotFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @errorDeletingClient.
  ///
  /// In en, this message translates to:
  /// **'Error deleting client'**
  String get errorDeletingClient;

  /// No description provided for @selectExistingClient.
  ///
  /// In en, this message translates to:
  /// **'Select existing client'**
  String get selectExistingClient;

  /// No description provided for @orCreateNewClient.
  ///
  /// In en, this message translates to:
  /// **'Or create new client'**
  String get orCreateNewClient;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenseDetails;

  /// No description provided for @expenseName.
  ///
  /// In en, this message translates to:
  /// **'Expense Name'**
  String get expenseName;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Expense Amount'**
  String get expenseAmount;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense Date'**
  String get expenseDate;

  /// No description provided for @expenseNotes.
  ///
  /// In en, this message translates to:
  /// **'Expense Notes'**
  String get expenseNotes;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get searchExpenses;

  /// No description provided for @loadingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Loading expenses...'**
  String get loadingExpenses;

  /// No description provided for @expenseCreatedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense created/updated successfully'**
  String get expenseCreatedUpdated;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// No description provided for @deleteExpenseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirmation;

  /// No description provided for @deleteExpenseWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteExpenseWarning;

  /// No description provided for @expenseDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get expenseDeletedSuccess;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @pleaseEnterExpenseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense name'**
  String get pleaseEnterExpenseName;

  /// No description provided for @pleaseEnterExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense amount'**
  String get pleaseEnterExpenseAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get estimate;

  /// No description provided for @save20.
  ///
  /// In en, this message translates to:
  /// **'Save 20%'**
  String get save20;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get pleaseTryAgainLater;

  /// No description provided for @welcomeToFacturoPro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Facturo Pro!'**
  String get welcomeToFacturoPro;

  /// No description provided for @discoverPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Discover all premium features and grow your business.'**
  String get discoverPremiumFeatures;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached!'**
  String get limitReached;

  /// No description provided for @usedAllFreeInvoices.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your {count} free invoices.'**
  String usedAllFreeInvoices(int count);

  /// No description provided for @almostAtLimit.
  ///
  /// In en, this message translates to:
  /// **'Almost at Limit!'**
  String get almostAtLimit;

  /// No description provided for @remainingFreeInvoices.
  ///
  /// In en, this message translates to:
  /// **'You have {count} free invoices left.'**
  String remainingFreeInvoices(int count);

  /// No description provided for @yourCurrentUsage.
  ///
  /// In en, this message translates to:
  /// **'Your Current Usage'**
  String get yourCurrentUsage;

  /// No description provided for @unlimitedInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Invoices'**
  String get unlimitedInvoices;

  /// No description provided for @unlimitedClients.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Clients'**
  String get unlimitedClients;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @pdfExport.
  ///
  /// In en, this message translates to:
  /// **'PDF Export'**
  String get pdfExport;

  /// No description provided for @advancedReports.
  ///
  /// In en, this message translates to:
  /// **'Advanced reports'**
  String get advancedReports;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// No description provided for @allPlansInclude.
  ///
  /// In en, this message translates to:
  /// **'All plans include:'**
  String get allPlansInclude;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @subscriptionRenewalInfo.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions auto-renew unless canceled. Manage in your store account settings.'**
  String get subscriptionRenewalInfo;

  /// No description provided for @unlockFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Potential'**
  String get unlockFullPotential;

  /// No description provided for @reachedFreeInvoiceLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your free invoice limit. Upgrade to continue invoicing without restrictions.'**
  String get reachedFreeInvoiceLimit;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @save17Percent.
  ///
  /// In en, this message translates to:
  /// **'Save 17%'**
  String get save17Percent;

  /// No description provided for @noInvoiceLimits.
  ///
  /// In en, this message translates to:
  /// **'No invoice limits'**
  String get noInvoiceLimits;

  /// No description provided for @manageAllClients.
  ///
  /// In en, this message translates to:
  /// **'Manage all clients'**
  String get manageAllClients;

  /// No description provided for @professionalFormat.
  ///
  /// In en, this message translates to:
  /// **'Professional format'**
  String get professionalFormat;

  /// No description provided for @advancedReportsFeature.
  ///
  /// In en, this message translates to:
  /// **'Advanced Reports'**
  String get advancedReportsFeature;

  /// No description provided for @analyzeYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Analyze your business'**
  String get analyzeYourBusiness;

  /// No description provided for @subscriptionsRenewAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. Manage or cancel your subscription in your App Store Account Settings.'**
  String get subscriptionsRenewAutomatically;

  /// No description provided for @planNotAvailableInStore.
  ///
  /// In en, this message translates to:
  /// **'This plan is not currently available in the store.'**
  String get planNotAvailableInStore;

  /// No description provided for @purchasesRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully'**
  String get purchasesRestoredSuccessfully;

  /// No description provided for @errorRestoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Error restoring purchases: {error}'**
  String errorRestoringPurchases(Object error);

  /// No description provided for @monthlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get monthlyBilling;

  /// No description provided for @tryFree.
  ///
  /// In en, this message translates to:
  /// **'Try Free'**
  String get tryFree;

  /// No description provided for @creatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Creating invoice...'**
  String get creatingInvoice;

  /// No description provided for @updatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Updating invoice...'**
  String get updatingInvoice;

  /// No description provided for @goToDetailsTabToCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Details\" tab to create the invoice'**
  String get goToDetailsTabToCreateInvoice;

  /// No description provided for @goToDetails.
  ///
  /// In en, this message translates to:
  /// **'Go to Details'**
  String get goToDetails;

  /// No description provided for @noItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No items added'**
  String get noItemsAdded;

  /// No description provided for @clickPlusButtonToAddItems.
  ///
  /// In en, this message translates to:
  /// **'Click the \"+\" button to add items'**
  String get clickPlusButtonToAddItems;

  /// No description provided for @noClientsMatchingSearch.
  ///
  /// In en, this message translates to:
  /// **'No clients match \"{query}\"'**
  String noClientsMatchingSearch(String query);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @noClientsYet.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClientsYet;

  /// No description provided for @addYourFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add your first client'**
  String get addYourFirstClient;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClientsFound;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search'**
  String get tryAnotherSearch;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @enterInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter invoice number'**
  String get enterInvoiceNumber;

  /// No description provided for @pleaseEnterInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invoice number'**
  String get pleaseEnterInvoiceNumber;

  /// No description provided for @changeInvoicePrefix.
  ///
  /// In en, this message translates to:
  /// **'Change invoice prefix'**
  String get changeInvoicePrefix;

  /// No description provided for @customInvoicePrefix.
  ///
  /// In en, this message translates to:
  /// **'Custom prefix'**
  String get customInvoicePrefix;

  /// No description provided for @invoicePrefixHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose a quick prefix or type your own to generate the sequence.'**
  String get invoicePrefixHelper;

  /// No description provided for @generateInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Generate invoice number automatically'**
  String get generateInvoiceNumber;

  /// No description provided for @invoiceNumberAutoGeneratedHelper.
  ///
  /// In en, this message translates to:
  /// **'It is generated automatically, but you can edit it manually.'**
  String get invoiceNumberAutoGeneratedHelper;

  /// No description provided for @enterPoNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter PO number'**
  String get enterPoNumber;

  /// No description provided for @discountsAndTaxes.
  ///
  /// In en, this message translates to:
  /// **'Discounts and Taxes'**
  String get discountsAndTaxes;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes'**
  String get enterNotes;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @updateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Update Invoice'**
  String get updateInvoice;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get discountType;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @fixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// No description provided for @taxType.
  ///
  /// In en, this message translates to:
  /// **'Tax Type'**
  String get taxType;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @reviewData.
  ///
  /// In en, this message translates to:
  /// **'Review Data'**
  String get reviewData;

  /// No description provided for @rescanDocument.
  ///
  /// In en, this message translates to:
  /// **'Rescan Document'**
  String get rescanDocument;

  /// No description provided for @scannedDocument.
  ///
  /// In en, this message translates to:
  /// **'Scanned Document'**
  String get scannedDocument;

  /// No description provided for @reviewAndEditData.
  ///
  /// In en, this message translates to:
  /// **'Review and edit extracted data'**
  String get reviewAndEditData;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @vendorName.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name'**
  String get vendorName;

  /// No description provided for @noItemsDetected.
  ///
  /// In en, this message translates to:
  /// **'No items detected'**
  String get noItemsDetected;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get rate;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @totals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get totals;

  /// No description provided for @invoiceCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Invoice created successfully'**
  String get invoiceCreatedSuccessfully;

  /// No description provided for @subscriptionActivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been activated successfully. You now have access to all premium features.'**
  String get subscriptionActivatedSuccessfully;

  /// No description provided for @nowYouCanEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Now you can enjoy:'**
  String get nowYouCanEnjoy;

  /// No description provided for @startCreatingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Start creating invoices and manage your business professionally'**
  String get startCreatingInvoices;

  /// No description provided for @redirectingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Redirecting automatically in a few seconds...'**
  String get redirectingAutomatically;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @businessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business Info'**
  String get businessInfo;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get languageAndRegion;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out Facturo, the best invoicing app! Download it here:'**
  String get shareAppMessage;

  /// No description provided for @problemTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem Title'**
  String get problemTitle;

  /// No description provided for @problemDescription.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get problemDescription;

  /// No description provided for @problemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Error creating invoice'**
  String get problemTitleHint;

  /// No description provided for @problemDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe in detail the problem you are experiencing...'**
  String get problemDescriptionHint;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @titleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters'**
  String get titleMinLength;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get descriptionRequired;

  /// No description provided for @descriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get descriptionMinLength;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @supportRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Support request sent successfully'**
  String get supportRequestSent;

  /// No description provided for @supportRequestError.
  ///
  /// In en, this message translates to:
  /// **'Error sending support request'**
  String get supportRequestError;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Facturo'**
  String get rateAppTitle;

  /// No description provided for @rateAppMessageIOS.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rate Facturo on the App Store?'**
  String get rateAppMessageIOS;

  /// No description provided for @rateAppMessageAndroid.
  ///
  /// In en, this message translates to:
  /// **'Would you like to rate Facturo on Google Play Store?'**
  String get rateAppMessageAndroid;

  /// No description provided for @rateAppCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rateAppCancel;

  /// No description provided for @rateAppRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateAppRate;

  /// No description provided for @purchaseLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your purchase'**
  String get purchaseLoadingTitle;

  /// No description provided for @purchaseLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment while we connect with the store...'**
  String get purchaseLoadingMessage;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'FREE PLAN'**
  String get freePlan;

  /// No description provided for @guestPlan.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestPlan;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get proPlan;

  /// No description provided for @getAccessToAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Get access to all features'**
  String get getAccessToAllFeatures;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All features unlocked'**
  String get allFeaturesUnlocked;

  /// No description provided for @ocrScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Invoice'**
  String get ocrScannerTitle;

  /// No description provided for @ocrWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Invoice'**
  String get ocrWelcomeTitle;

  /// No description provided for @ocrWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture or select your invoice to digitize it automatically'**
  String get ocrWelcomeSubtitle;

  /// No description provided for @ocrTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get ocrTakePhoto;

  /// No description provided for @ocrTakePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get ocrTakePhotoSubtitle;

  /// No description provided for @ocrImportFile.
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get ocrImportFile;

  /// No description provided for @ocrImportFileDescription.
  ///
  /// In en, this message translates to:
  /// **'PDF or digital document'**
  String get ocrImportFileDescription;

  /// No description provided for @ocrSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get ocrSelectImage;

  /// No description provided for @ocrSelectImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get ocrSelectImageSubtitle;

  /// No description provided for @ocrImageReady.
  ///
  /// In en, this message translates to:
  /// **'Perfect! Your image is ready'**
  String get ocrImageReady;

  /// No description provided for @ocrImageReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check that it looks good and tap \"Process\" to continue'**
  String get ocrImageReadySubtitle;

  /// No description provided for @ocrProcessInvoice.
  ///
  /// In en, this message translates to:
  /// **'Process Invoice'**
  String get ocrProcessInvoice;

  /// No description provided for @ocrChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get ocrChangeImage;

  /// No description provided for @ocrAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your invoice!'**
  String get ocrAnalyzing;

  /// No description provided for @ocrAnalyzingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are automatically extracting\\nall data from your invoice'**
  String get ocrAnalyzingSubtitle;

  /// No description provided for @ocrTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for better results'**
  String get ocrTipsTitle;

  /// No description provided for @ocrTipsButton.
  ///
  /// In en, this message translates to:
  /// **'Tips for perfect scanning'**
  String get ocrTipsButton;

  /// No description provided for @ocrTipLighting.
  ///
  /// In en, this message translates to:
  /// **'Ensure the image is well lit'**
  String get ocrTipLighting;

  /// No description provided for @ocrTipStable.
  ///
  /// In en, this message translates to:
  /// **'Keep the camera steady when taking the photo'**
  String get ocrTipStable;

  /// No description provided for @ocrTipFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus clearly on the receipt text'**
  String get ocrTipFocus;

  /// No description provided for @ocrTipShadows.
  ///
  /// In en, this message translates to:
  /// **'Avoid shadows and reflections in the image'**
  String get ocrTipShadows;

  /// No description provided for @ocrTip1.
  ///
  /// In en, this message translates to:
  /// **'Make sure the invoice is well lit'**
  String get ocrTip1;

  /// No description provided for @ocrTip2.
  ///
  /// In en, this message translates to:
  /// **'Keep the invoice straight and unfolded'**
  String get ocrTip2;

  /// No description provided for @ocrTip3.
  ///
  /// In en, this message translates to:
  /// **'Include the entire invoice in the image'**
  String get ocrTip3;

  /// No description provided for @ocrTip4.
  ///
  /// In en, this message translates to:
  /// **'Avoid shadows and reflections'**
  String get ocrTip4;

  /// No description provided for @ocrTip5.
  ///
  /// In en, this message translates to:
  /// **'Keep the camera steady when taking the photo'**
  String get ocrTip5;

  /// No description provided for @ocrTip6.
  ///
  /// In en, this message translates to:
  /// **'Better quality = Better recognition'**
  String get ocrTip6;

  /// No description provided for @ocrUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get ocrUnderstood;

  /// No description provided for @ocrImageDarkWarning.
  ///
  /// In en, this message translates to:
  /// **'The image appears very dark. Try with better lighting.'**
  String get ocrImageDarkWarning;

  /// No description provided for @ocrImageBlurryWarning.
  ///
  /// In en, this message translates to:
  /// **'The image might be blurry. Try taking another photo.'**
  String get ocrImageBlurryWarning;

  /// No description provided for @ocrCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Make sure the invoice is well lit and without shadows'**
  String get ocrCameraTooltip;

  /// No description provided for @ocrGalleryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select a clear and sharp image of your invoice'**
  String get ocrGalleryTooltip;

  /// No description provided for @ocrErrorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get ocrErrorSelectingImage;

  /// No description provided for @ocrErrorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Error processing image'**
  String get ocrErrorProcessingImage;

  /// No description provided for @waitBeforeRefresh.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} seconds before refreshing again'**
  String waitBeforeRefresh(int seconds);

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @paidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Paid Invoices'**
  String get paidInvoices;

  /// No description provided for @pendingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Pending Invoices'**
  String get pendingInvoices;

  /// No description provided for @yourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Your Business'**
  String get yourBusiness;

  /// No description provided for @responsiveDesign.
  ///
  /// In en, this message translates to:
  /// **'Responsive Design'**
  String get responsiveDesign;

  /// No description provided for @testResponsiveDesign.
  ///
  /// In en, this message translates to:
  /// **'Test the responsive design'**
  String get testResponsiveDesign;

  /// No description provided for @howAppAdapts.
  ///
  /// In en, this message translates to:
  /// **'See how the application adapts to different screen sizes'**
  String get howAppAdapts;

  /// No description provided for @viewResponsiveExample.
  ///
  /// In en, this message translates to:
  /// **'View Responsive Example'**
  String get viewResponsiveExample;

  /// No description provided for @noDataToShow.
  ///
  /// In en, this message translates to:
  /// **'No data to show'**
  String get noDataToShow;

  /// No description provided for @addInvoicesOrExpenses.
  ///
  /// In en, this message translates to:
  /// **'Add paid invoices or expenses\\nto see the chart'**
  String get addInvoicesOrExpenses;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @digitalSignatureScreen.
  ///
  /// In en, this message translates to:
  /// **'Digital Signature'**
  String get digitalSignatureScreen;

  /// No description provided for @signHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get signHere;

  /// No description provided for @saveSignature.
  ///
  /// In en, this message translates to:
  /// **'Save Signature'**
  String get saveSignature;

  /// No description provided for @signatureCleared.
  ///
  /// In en, this message translates to:
  /// **'Signature cleared'**
  String get signatureCleared;

  /// No description provided for @signatureSaved.
  ///
  /// In en, this message translates to:
  /// **'Signature saved successfully'**
  String get signatureSaved;

  /// No description provided for @pleaseSignFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add your signature first'**
  String get pleaseSignFirst;

  /// No description provided for @signatureInstructions.
  ///
  /// In en, this message translates to:
  /// **'Use your finger or stylus to create your digital signature in the area below'**
  String get signatureInstructions;

  /// No description provided for @signatureOptional.
  ///
  /// In en, this message translates to:
  /// **'Signature (Optional)'**
  String get signatureOptional;

  /// No description provided for @addYourSignature.
  ///
  /// In en, this message translates to:
  /// **'Add your signature'**
  String get addYourSignature;

  /// No description provided for @signatureAdded.
  ///
  /// In en, this message translates to:
  /// **'Signature added successfully'**
  String get signatureAdded;

  /// No description provided for @extractedData.
  ///
  /// In en, this message translates to:
  /// **'Extracted Data'**
  String get extractedData;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @manageYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Manage your business\nintelligently'**
  String get manageYourBusiness;

  /// No description provided for @businessDescription.
  ///
  /// In en, this message translates to:
  /// **'Create invoices, manage expenses and keep\nyour business organized from anywhere'**
  String get businessDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @onboardingWhatBusinessType.
  ///
  /// In en, this message translates to:
  /// **'What type of business do you have?'**
  String get onboardingWhatBusinessType;

  /// No description provided for @onboardingSelectBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Select the type that best describes your activity'**
  String get onboardingSelectBusinessType;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingConfigureProfile.
  ///
  /// In en, this message translates to:
  /// **'Configure your personal profile to access all application features.'**
  String get onboardingConfigureProfile;

  /// No description provided for @onboardingBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Your business information'**
  String get onboardingBusinessInfo;

  /// No description provided for @onboardingTellUsAboutBusiness.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business to personalize your experience'**
  String get onboardingTellUsAboutBusiness;

  /// No description provided for @onboardingBusinessCategory.
  ///
  /// In en, this message translates to:
  /// **'What does your business do?'**
  String get onboardingBusinessCategory;

  /// No description provided for @onboardingSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select the category that best describes your activity'**
  String get onboardingSelectCategory;

  /// No description provided for @onboardingStep2Of4.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 4'**
  String get onboardingStep2Of4;

  /// No description provided for @onboardingStep3Of4.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 4'**
  String get onboardingStep3Of4;

  /// No description provided for @onboardingStep4Of4.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 4'**
  String get onboardingStep4Of4;

  /// No description provided for @onboardingUploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get onboardingUploadLogo;

  /// No description provided for @onboardingChangeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change logo'**
  String get onboardingChangeLogo;

  /// No description provided for @onboardingBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get onboardingBusinessName;

  /// No description provided for @onboardingBusinessNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: My Store'**
  String get onboardingBusinessNameHint;

  /// No description provided for @onboardingBusinessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your business name'**
  String get onboardingBusinessNameRequired;

  /// No description provided for @onboardingBusinessInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business to personalize your experience'**
  String get onboardingBusinessInfoSubtitle;

  /// No description provided for @onboardingLogoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Logo removed'**
  String get onboardingLogoRemoved;

  /// No description provided for @onboardingBusinessPhone.
  ///
  /// In en, this message translates to:
  /// **'Business Phone'**
  String get onboardingBusinessPhone;

  /// No description provided for @onboardingBusinessPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: +1 555 123-4567'**
  String get onboardingBusinessPhoneHint;

  /// No description provided for @onboardingBusinessPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get onboardingBusinessPhoneInvalid;

  /// No description provided for @onboardingBusinessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get onboardingBusinessAddress;

  /// No description provided for @onboardingBusinessAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get onboardingBusinessAddressHint;

  /// No description provided for @onboardingAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get onboardingAddPhoto;

  /// No description provided for @onboardingSearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search category...'**
  String get onboardingSearchCategory;

  /// No description provided for @onboardingAlmostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done!'**
  String get onboardingAlmostDone;

  /// No description provided for @onboardingReviewInfo.
  ///
  /// In en, this message translates to:
  /// **'Review the information you have configured before creating your account.'**
  String get onboardingReviewInfo;

  /// No description provided for @onboardingBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get onboardingBusinessType;

  /// No description provided for @onboardingTypeSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected type'**
  String get onboardingTypeSelected;

  /// No description provided for @onboardingNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get onboardingNotSelected;

  /// No description provided for @onboardingAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get onboardingAccountInfo;

  /// No description provided for @onboardingFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get onboardingFullName;

  /// No description provided for @onboardingNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get onboardingNotSpecified;

  /// No description provided for @onboardingEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get onboardingEmail;

  /// No description provided for @onboardingPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get onboardingPassword;

  /// No description provided for @onboardingNotSpecifiedPassword.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get onboardingNotSpecifiedPassword;

  /// No description provided for @onboardingNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get onboardingNextSteps;

  /// No description provided for @onboardingInitialPlan.
  ///
  /// In en, this message translates to:
  /// **'Initial plan'**
  String get onboardingInitialPlan;

  /// No description provided for @onboardingFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan (5 invoices)'**
  String get onboardingFreePlan;

  /// No description provided for @onboardingAdditionalConfig.
  ///
  /// In en, this message translates to:
  /// **'Additional configuration'**
  String get onboardingAdditionalConfig;

  /// No description provided for @onboardingAvailableFromProfile.
  ///
  /// In en, this message translates to:
  /// **'Available from your profile'**
  String get onboardingAvailableFromProfile;

  /// No description provided for @businessTypeRetail.
  ///
  /// In en, this message translates to:
  /// **'Store/Retail'**
  String get businessTypeRetail;

  /// No description provided for @businessTypeRetailDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical product sales'**
  String get businessTypeRetailDesc;

  /// No description provided for @businessTypeServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get businessTypeServices;

  /// No description provided for @businessTypeServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Consulting, repairs, etc.'**
  String get businessTypeServicesDesc;

  /// No description provided for @businessTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant/Bar'**
  String get businessTypeRestaurant;

  /// No description provided for @businessTypeRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Food and beverages'**
  String get businessTypeRestaurantDesc;

  /// No description provided for @businessTypeFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get businessTypeFreelance;

  /// No description provided for @businessTypeFreelanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Independent work'**
  String get businessTypeFreelanceDesc;

  /// No description provided for @businessTypeEcommerce.
  ///
  /// In en, this message translates to:
  /// **'E-commerce'**
  String get businessTypeEcommerce;

  /// No description provided for @businessTypeEcommerceDesc.
  ///
  /// In en, this message translates to:
  /// **'Online sales'**
  String get businessTypeEcommerceDesc;

  /// No description provided for @businessTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get businessTypeOther;

  /// No description provided for @businessTypeOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Custom type'**
  String get businessTypeOtherDesc;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(Object step, Object total);

  /// No description provided for @onboardingWhatKindOfBusiness.
  ///
  /// In en, this message translates to:
  /// **'What kind of business do you have?'**
  String get onboardingWhatKindOfBusiness;

  /// No description provided for @onboardingSetupProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to get started'**
  String get onboardingSetupProfile;

  /// No description provided for @onboardingWhatDoesBusinessDo.
  ///
  /// In en, this message translates to:
  /// **'What does your business do?'**
  String get onboardingWhatDoesBusinessDo;

  /// No description provided for @onboardingBusinessTypeRetail.
  ///
  /// In en, this message translates to:
  /// **'Store/Retail'**
  String get onboardingBusinessTypeRetail;

  /// No description provided for @onboardingBusinessTypeServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get onboardingBusinessTypeServices;

  /// No description provided for @onboardingBusinessTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant/Bar'**
  String get onboardingBusinessTypeRestaurant;

  /// No description provided for @onboardingBusinessTypeFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get onboardingBusinessTypeFreelance;

  /// No description provided for @onboardingBusinessTypeEcommerce.
  ///
  /// In en, this message translates to:
  /// **'E-commerce'**
  String get onboardingBusinessTypeEcommerce;

  /// No description provided for @onboardingBusinessTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingBusinessTypeOther;

  /// No description provided for @onboardingBusinessTypeRetailDesc.
  ///
  /// In en, this message translates to:
  /// **'Sale of physical products'**
  String get onboardingBusinessTypeRetailDesc;

  /// No description provided for @onboardingBusinessTypeServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Service provision'**
  String get onboardingBusinessTypeServicesDesc;

  /// No description provided for @onboardingBusinessTypeRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Food and beverages'**
  String get onboardingBusinessTypeRestaurantDesc;

  /// No description provided for @onboardingBusinessTypeFreelanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Independent work'**
  String get onboardingBusinessTypeFreelanceDesc;

  /// No description provided for @onboardingBusinessTypeEcommerceDesc.
  ///
  /// In en, this message translates to:
  /// **'Online sales'**
  String get onboardingBusinessTypeEcommerceDesc;

  /// No description provided for @onboardingBusinessTypeOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Other type of business'**
  String get onboardingBusinessTypeOtherDesc;

  /// No description provided for @businessCategoryRetail.
  ///
  /// In en, this message translates to:
  /// **'Retail Store'**
  String get businessCategoryRetail;

  /// No description provided for @businessCategoryRetailDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical product sales and retail'**
  String get businessCategoryRetailDesc;

  /// No description provided for @businessCategoryFoodBeverage.
  ///
  /// In en, this message translates to:
  /// **'Food & Beverage'**
  String get businessCategoryFoodBeverage;

  /// No description provided for @businessCategoryFoodBeverageDesc.
  ///
  /// In en, this message translates to:
  /// **'Restaurants, cafes, bars and catering'**
  String get businessCategoryFoodBeverageDesc;

  /// No description provided for @businessCategoryProfessionalServices.
  ///
  /// In en, this message translates to:
  /// **'Professional Services'**
  String get businessCategoryProfessionalServices;

  /// No description provided for @businessCategoryProfessionalServicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Consulting, legal, accounting and business services'**
  String get businessCategoryProfessionalServicesDesc;

  /// No description provided for @businessCategoryHealthBeauty.
  ///
  /// In en, this message translates to:
  /// **'Health & Beauty'**
  String get businessCategoryHealthBeauty;

  /// No description provided for @businessCategoryHealthBeautyDesc.
  ///
  /// In en, this message translates to:
  /// **'Salons, spas, gyms and wellness services'**
  String get businessCategoryHealthBeautyDesc;

  /// No description provided for @businessCategoryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction & Contractors'**
  String get businessCategoryConstruction;

  /// No description provided for @businessCategoryConstructionDesc.
  ///
  /// In en, this message translates to:
  /// **'Construction, remodeling and maintenance services'**
  String get businessCategoryConstructionDesc;

  /// No description provided for @businessCategoryAutomotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get businessCategoryAutomotive;

  /// No description provided for @businessCategoryAutomotiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto repair shops, parts sales and automotive services'**
  String get businessCategoryAutomotiveDesc;

  /// No description provided for @businessCategoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get businessCategoryTechnology;

  /// No description provided for @businessCategoryTechnologyDesc.
  ///
  /// In en, this message translates to:
  /// **'IT services, software development and repairs'**
  String get businessCategoryTechnologyDesc;

  /// No description provided for @businessCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education & Training'**
  String get businessCategoryEducation;

  /// No description provided for @businessCategoryEducationDesc.
  ///
  /// In en, this message translates to:
  /// **'Schools, academies and training centers'**
  String get businessCategoryEducationDesc;

  /// No description provided for @businessCategoryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get businessCategoryRealEstate;

  /// No description provided for @businessCategoryRealEstateDesc.
  ///
  /// In en, this message translates to:
  /// **'Property sales, rentals and management'**
  String get businessCategoryRealEstateDesc;

  /// No description provided for @businessCategoryManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get businessCategoryManufacturing;

  /// No description provided for @businessCategoryManufacturingDesc.
  ///
  /// In en, this message translates to:
  /// **'Production and manufacturing of products'**
  String get businessCategoryManufacturingDesc;

  /// No description provided for @businessCategoryAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture & Livestock'**
  String get businessCategoryAgriculture;

  /// No description provided for @businessCategoryAgricultureDesc.
  ///
  /// In en, this message translates to:
  /// **'Agricultural and livestock production and related services'**
  String get businessCategoryAgricultureDesc;

  /// No description provided for @businessCategoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation & Logistics'**
  String get businessCategoryTransportation;

  /// No description provided for @businessCategoryTransportationDesc.
  ///
  /// In en, this message translates to:
  /// **'Transportation, shipping and storage services'**
  String get businessCategoryTransportationDesc;

  /// No description provided for @businessCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment & Events'**
  String get businessCategoryEntertainment;

  /// No description provided for @businessCategoryEntertainmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Event organization, entertainment and recreation'**
  String get businessCategoryEntertainmentDesc;

  /// No description provided for @businessCategoryWholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Trade'**
  String get businessCategoryWholesale;

  /// No description provided for @businessCategoryWholesaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Distribution and wholesale sales'**
  String get businessCategoryWholesaleDesc;

  /// No description provided for @businessCategoryCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative Services'**
  String get businessCategoryCreative;

  /// No description provided for @shareBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Business'**
  String get shareBusinessProfile;

  /// No description provided for @warningOcrDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Warning: Some OCR data could not be loaded'**
  String get warningOcrDataNotLoaded;

  /// No description provided for @errorExportingImage.
  ///
  /// In en, this message translates to:
  /// **'Error exporting image'**
  String get errorExportingImage;

  /// No description provided for @exportAsJpg.
  ///
  /// In en, this message translates to:
  /// **'Export as JPG'**
  String get exportAsJpg;

  /// No description provided for @exportAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// No description provided for @downloadCsvFile.
  ///
  /// In en, this message translates to:
  /// **'Download CSV file'**
  String get downloadCsvFile;

  /// No description provided for @regPromptFirstInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'First invoice created!'**
  String get regPromptFirstInvoiceTitle;

  /// No description provided for @regPromptFirstInvoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Great job! You created your first invoice. Don\'t you think it\'s time to save it?'**
  String get regPromptFirstInvoiceSubtitle;

  /// No description provided for @regPromptFirstInvoiceBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose your invoices'**
  String get regPromptFirstInvoiceBenefit1;

  /// No description provided for @regPromptFirstInvoiceBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Access from any device'**
  String get regPromptFirstInvoiceBenefit2;

  /// No description provided for @regPromptFirstInvoiceBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Improve your organization'**
  String get regPromptFirstInvoiceBenefit3;

  /// No description provided for @regPromptFirstInvoiceCta.
  ///
  /// In en, this message translates to:
  /// **'Save my invoice'**
  String get regPromptFirstInvoiceCta;

  /// No description provided for @regPromptFirstInvoiceDismiss.
  ///
  /// In en, this message translates to:
  /// **'Keep trying'**
  String get regPromptFirstInvoiceDismiss;

  /// No description provided for @regPromptTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Great to have you here!'**
  String get regPromptTimeTitle;

  /// No description provided for @regPromptTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We see you\'re getting the most out of the app. Create your free account to back up your information and access more benefits.'**
  String get regPromptTimeSubtitle;

  /// No description provided for @regPromptTimeCta.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get regPromptTimeCta;

  /// No description provided for @regPromptTimeDismiss.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get regPromptTimeDismiss;

  /// No description provided for @activePlan.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get activePlan;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @manageInAppStore.
  ///
  /// In en, this message translates to:
  /// **'Manage in App Store'**
  String get manageInAppStore;

  /// No description provided for @errorRestoringPurchasesWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error restoring purchases: {error}'**
  String errorRestoringPurchasesWithMessage(Object error);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @createPermanentAccount.
  ///
  /// In en, this message translates to:
  /// **'Create permanent account'**
  String get createPermanentAccount;

  /// No description provided for @deleteDataAndLogout.
  ///
  /// In en, this message translates to:
  /// **'Delete data and log out'**
  String get deleteDataAndLogout;

  /// No description provided for @profileCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile completed successfully!'**
  String get profileCompletedSuccessfully;

  /// No description provided for @accountConnectedWithGoogleActivating.
  ///
  /// In en, this message translates to:
  /// **'Account connected with Google! Activating subscription...'**
  String get accountConnectedWithGoogleActivating;

  /// No description provided for @accountConnectedWithGoogleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account connected with Google successfully!'**
  String get accountConnectedWithGoogleSuccess;

  /// No description provided for @accountConnectedWithAppleActivating.
  ///
  /// In en, this message translates to:
  /// **'Account connected with Apple! Activating subscription...'**
  String get accountConnectedWithAppleActivating;

  /// No description provided for @accountConnectedWithAppleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account connected with Apple successfully!'**
  String get accountConnectedWithAppleSuccess;

  /// No description provided for @errorActivatingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Error activating subscription: {error}'**
  String errorActivatingSubscription(Object error);

  /// No description provided for @howDoYouWantToShare.
  ///
  /// In en, this message translates to:
  /// **'How do you want to share?'**
  String get howDoYouWantToShare;

  /// No description provided for @textMessage.
  ///
  /// In en, this message translates to:
  /// **'Text Message'**
  String get textMessage;

  /// No description provided for @textMessageDescription.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp, SMS or email'**
  String get textMessageDescription;

  /// No description provided for @contactFile.
  ///
  /// In en, this message translates to:
  /// **'Contact File'**
  String get contactFile;

  /// No description provided for @contactFileDescription.
  ///
  /// In en, this message translates to:
  /// **'For others to save you in their contacts'**
  String get contactFileDescription;

  /// No description provided for @errorSharingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorSharingProfile;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @completeYourProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile!'**
  String get completeYourProfileTitle;

  /// No description provided for @completeYourProfileTooltipBody.
  ///
  /// In en, this message translates to:
  /// **'Add your personal and business information so your invoices and documents look more professional.'**
  String get completeYourProfileTooltipBody;

  /// No description provided for @completeYourProfileTooltipCta.
  ///
  /// In en, this message translates to:
  /// **'Tap here to get started →'**
  String get completeYourProfileTooltipCta;

  /// No description provided for @profileCompletionStatus.
  ///
  /// In en, this message translates to:
  /// **'Profile {percentage}% complete'**
  String profileCompletionStatus(int percentage);

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be permanently deleted:'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountDataList.
  ///
  /// In en, this message translates to:
  /// **'• All invoices and estimates\n• All clients and expenses\n• Business information\n• All settings and preferences'**
  String get deleteAccountDataList;

  /// No description provided for @deleteAccountSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ You cannot delete your account while you have an active subscription.\n\nYou must first cancel your subscription in:\nSettings > Apple ID > Subscriptions > Facturo\n\nOnce cancelled, you will be able to delete your account.'**
  String get deleteAccountSubscriptionWarning;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountConfirmationHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get deleteAccountConfirmationHint;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountButton;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(Object error);

  /// No description provided for @confirmationTextDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirmation text does not match'**
  String get confirmationTextDoesNotMatch;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @guestUserWarning.
  ///
  /// In en, this message translates to:
  /// **'You are using a guest account. If you log out, you will lose all your data.'**
  String get guestUserWarning;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Easy and Fast Invoicing'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create professional invoices'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'Generate personalized invoices in seconds. Send to your clients instantly and keep complete control of your finances.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Expense Control'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan and organize'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Scan your receipts with our smart scanning technology. Digitize and organize your expenses automatically without manual effort.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Boost Your Business'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Visualize your growth'**
  String get onboardingPage3Subtitle;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Manage your clients and visualize your business growth with detailed reports and real-time statistics.'**
  String get onboardingPage3Description;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Start Free'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan included'**
  String get onboardingPage4Subtitle;

  /// No description provided for @onboardingPage4Description.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all basic features at no cost. Upgrade whenever you want to unlock full potential.'**
  String get onboardingPage4Description;

  /// No description provided for @continueForFree.
  ///
  /// In en, this message translates to:
  /// **'Continue Free'**
  String get continueForFree;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Facturo'**
  String get appName;

  /// No description provided for @enablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Push Notifications'**
  String get enablePushNotifications;

  /// No description provided for @enablePushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when the app is closed'**
  String get enablePushNotificationsDescription;

  /// No description provided for @pushNotificationsEnabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Push notifications enabled successfully!'**
  String get pushNotificationsEnabledSuccessfully;

  /// No description provided for @permissionDeniedEnableInSettings.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable notifications in Settings.'**
  String get permissionDeniedEnableInSettings;

  /// No description provided for @pushNotificationsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Push notifications are not available yet. Firebase configuration required.'**
  String get pushNotificationsNotAvailable;

  /// No description provided for @enableWeeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Enable Weekly Digest'**
  String get enableWeeklyDigest;

  /// No description provided for @enableWeeklyDigestDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a summary of your activity every week'**
  String get enableWeeklyDigestDescription;

  /// No description provided for @weeklyDigestConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Weekly Digest Configuration'**
  String get weeklyDigestConfiguration;

  /// No description provided for @whenWouldYouLikeToReceiveSummary.
  ///
  /// In en, this message translates to:
  /// **'When would you like to receive your summary?'**
  String get whenWouldYouLikeToReceiveSummary;

  /// No description provided for @dayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of Week'**
  String get dayOfWeek;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy secure link to clipboard'**
  String get copyLinkDescription;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @shareLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Share online link via apps'**
  String get shareLinkDescription;

  /// No description provided for @generateNewLink.
  ///
  /// In en, this message translates to:
  /// **'Generate New Link'**
  String get generateNewLink;

  /// No description provided for @generateNewLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a fresh link'**
  String get generateNewLinkDescription;

  /// No description provided for @allNotificationsAlreadyRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications are already read'**
  String get allNotificationsAlreadyRead;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @selectImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose from your gallery'**
  String get selectImageDescription;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get newReport;

  /// No description provided for @pushNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Push notifications disabled'**
  String get pushNotificationsDisabled;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown Category'**
  String get unknownCategory;

  /// No description provided for @notificationsPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationsPush;

  /// No description provided for @notificationsPushDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts outside the application'**
  String get notificationsPushDescription;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @weeklySummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Statistics and weekly activity summary'**
  String get weeklySummaryDescription;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @professionalServices.
  ///
  /// In en, this message translates to:
  /// **'Professional Services'**
  String get professionalServices;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @construction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get construction;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @retail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get retail;

  /// No description provided for @retailStore.
  ///
  /// In en, this message translates to:
  /// **'Retail Store'**
  String get retailStore;

  /// No description provided for @foodAndBeverage.
  ///
  /// In en, this message translates to:
  /// **'Food and Beverage'**
  String get foodAndBeverage;

  /// No description provided for @fileFormat.
  ///
  /// In en, this message translates to:
  /// **'File Format'**
  String get fileFormat;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal;

  /// No description provided for @invoicesProcessed.
  ///
  /// In en, this message translates to:
  /// **'Invoices Processed'**
  String get invoicesProcessed;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @reportId.
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportId;

  /// No description provided for @ocrItem.
  ///
  /// In en, this message translates to:
  /// **'OCR Item'**
  String get ocrItem;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @discountOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get discountOff;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalLabel;

  /// No description provided for @taxLabel.
  ///
  /// In en, this message translates to:
  /// **'TAX'**
  String get taxLabel;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'DISCOUNT'**
  String get discountLabel;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @insufficientInfoToShare.
  ///
  /// In en, this message translates to:
  /// **'Insufficient information to share'**
  String get insufficientInfoToShare;

  /// No description provided for @failedToCreateContactFile.
  ///
  /// In en, this message translates to:
  /// **'Could not create contact file. Sharing as text...'**
  String get failedToCreateContactFile;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @failedToSaveCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to save category'**
  String get failedToSaveCategory;

  /// No description provided for @deleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete Receipt'**
  String get deleteReceipt;

  /// No description provided for @deleteReceiptConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receipt?'**
  String get deleteReceiptConfirmation;

  /// No description provided for @createInvoiceFromScan.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice from Scan'**
  String get createInvoiceFromScan;

  /// No description provided for @initializationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical Initialization Error'**
  String get initializationErrorTitle;

  /// No description provided for @initializationErrorHelp.
  ///
  /// In en, this message translates to:
  /// **'Please verify your configuration (.env file) and internet connection. Then, restart the application.'**
  String get initializationErrorHelp;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cropProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop profile photo'**
  String get cropProfilePhoto;

  /// No description provided for @cropBusinessLogo.
  ///
  /// In en, this message translates to:
  /// **'Crop business logo'**
  String get cropBusinessLogo;

  /// No description provided for @cropDocument.
  ///
  /// In en, this message translates to:
  /// **'Crop document'**
  String get cropDocument;

  /// No description provided for @saveScannedReceiptOnly.
  ///
  /// In en, this message translates to:
  /// **'Save Scanned Receipt Only'**
  String get saveScannedReceiptOnly;

  /// No description provided for @saveScannedReceipt.
  ///
  /// In en, this message translates to:
  /// **'Save Scanned Receipt'**
  String get saveScannedReceipt;

  /// No description provided for @chooseHowToSave.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to save this receipt'**
  String get chooseHowToSave;

  /// No description provided for @saveAsExpense.
  ///
  /// In en, this message translates to:
  /// **'Save as Expense'**
  String get saveAsExpense;

  /// No description provided for @saveAsInvoice.
  ///
  /// In en, this message translates to:
  /// **'Save as Invoice'**
  String get saveAsInvoice;

  /// No description provided for @saveReceiptOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Just save the receipt without creating an expense or invoice'**
  String get saveReceiptOnlyDescription;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @sendEstimate.
  ///
  /// In en, this message translates to:
  /// **'Send Estimate'**
  String get sendEstimate;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset View'**
  String get resetView;

  /// No description provided for @deleteCategoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{categoryName}\"?'**
  String deleteCategoryConfirmation(Object categoryName);

  /// No description provided for @deleteCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone and may affect existing expenses.'**
  String get deleteCategoryWarning;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @estimateLabel.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATE'**
  String get estimateLabel;

  /// No description provided for @billToLabel.
  ///
  /// In en, this message translates to:
  /// **'BILL TO'**
  String get billToLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// No description provided for @validUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'VALID UNTIL'**
  String get validUntilLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rateLabel;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get qtyLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amountLabel;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'SUBTOTAL'**
  String get subtotalLabel;

  /// No description provided for @notAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableLabel;

  /// No description provided for @yourBusinessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Business Name'**
  String get yourBusinessNameLabel;

  /// No description provided for @businessAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddressLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @applicable.
  ///
  /// In en, this message translates to:
  /// **'Applicable'**
  String get applicable;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get descriptionHint;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPriceLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @additionalDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetailsLabel;

  /// No description provided for @additionalDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter any additional details'**
  String get additionalDetailsHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @estimateInformation.
  ///
  /// In en, this message translates to:
  /// **'Estimate Information'**
  String get estimateInformation;

  /// No description provided for @estimateNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Estimate Number *'**
  String get estimateNumberRequired;

  /// No description provided for @enterEstimateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter estimate number'**
  String get enterEstimateNumber;

  /// No description provided for @pleaseEnterEstimateNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter an estimate number'**
  String get pleaseEnterEstimateNumber;

  /// No description provided for @estimateDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Estimate Date *'**
  String get estimateDateRequired;

  /// No description provided for @selectEstimateDate.
  ///
  /// In en, this message translates to:
  /// **'Select estimate date'**
  String get selectEstimateDate;

  /// No description provided for @validUntilRequired.
  ///
  /// In en, this message translates to:
  /// **'Valid Until *'**
  String get validUntilRequired;

  /// No description provided for @selectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Select expiry date'**
  String get selectExpiryDate;

  /// No description provided for @poNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'PO Number'**
  String get poNumberOptional;

  /// No description provided for @enterPoNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter purchase order number (optional)'**
  String get enterPoNumberOptional;

  /// No description provided for @clientRequired.
  ///
  /// In en, this message translates to:
  /// **'Client *'**
  String get clientRequired;

  /// No description provided for @pleaseSelectClient.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get pleaseSelectClient;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @additionalNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get additionalNotesOptional;

  /// No description provided for @estimateItems.
  ///
  /// In en, this message translates to:
  /// **'Estimate Items'**
  String get estimateItems;

  /// No description provided for @createEstimate.
  ///
  /// In en, this message translates to:
  /// **'Create Estimate'**
  String get createEstimate;

  /// No description provided for @updateEstimate.
  ///
  /// In en, this message translates to:
  /// **'Update Estimate'**
  String get updateEstimate;

  /// No description provided for @clientNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Selected client is no longer available'**
  String get clientNoLongerAvailable;

  /// No description provided for @pdfStyle.
  ///
  /// In en, this message translates to:
  /// **'PDF Style'**
  String get pdfStyle;

  /// No description provided for @choosePdfStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF Style'**
  String get choosePdfStyle;

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  /// No description provided for @sendViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Send via Email'**
  String get sendViaEmail;

  /// No description provided for @sendPdfViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Send PDF via email'**
  String get sendPdfViaEmail;

  /// No description provided for @sendViaTextMessage.
  ///
  /// In en, this message translates to:
  /// **'Send via Text Message'**
  String get sendViaTextMessage;

  /// No description provided for @sendPdfViaTextMessage.
  ///
  /// In en, this message translates to:
  /// **'Send PDF via text message'**
  String get sendPdfViaTextMessage;

  /// No description provided for @sendViaLink.
  ///
  /// In en, this message translates to:
  /// **'Send via Link'**
  String get sendViaLink;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @linkReadyTapToShare.
  ///
  /// In en, this message translates to:
  /// **'Link ready - tap to share'**
  String get linkReadyTapToShare;

  /// No description provided for @generateAndShareOnlineLink.
  ///
  /// In en, this message translates to:
  /// **'Generate and share online link'**
  String get generateAndShareOnlineLink;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @downloadPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Download PDF file'**
  String get downloadPdfFile;

  /// No description provided for @exportAsImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportAsImage;

  /// No description provided for @downloadAsPngImage.
  ///
  /// In en, this message translates to:
  /// **'Download as PNG image'**
  String get downloadAsPngImage;

  /// No description provided for @generatingPngImage.
  ///
  /// In en, this message translates to:
  /// **'Generating PNG image...'**
  String get generatingPngImage;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get noExpensesFound;

  /// No description provided for @noExpensesMatchSearchCriteria.
  ///
  /// In en, this message translates to:
  /// **'No expenses match your search criteria'**
  String get noExpensesMatchSearchCriteria;

  /// No description provided for @addFirstExpenseToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to get started'**
  String get addFirstExpenseToGetStarted;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @noExpensesForYear.
  ///
  /// In en, this message translates to:
  /// **'No expenses for {year}'**
  String noExpensesForYear(String year);

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @tryDifferentYearOrAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different year or add a new expense'**
  String get tryDifferentYearOrAddExpense;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @areYouSureDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the expense for {merchant}?'**
  String areYouSureDeleteExpense(String merchant);

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date *'**
  String get dateRequired;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @merchantRequired.
  ///
  /// In en, this message translates to:
  /// **'Merchant *'**
  String get merchantRequired;

  /// No description provided for @enterMerchantName.
  ///
  /// In en, this message translates to:
  /// **'Enter merchant name'**
  String get enterMerchantName;

  /// No description provided for @pleaseEnterMerchantName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a merchant name'**
  String get pleaseEnterMerchantName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @financialInformation.
  ///
  /// In en, this message translates to:
  /// **'Financial Information'**
  String get financialInformation;

  /// No description provided for @totalAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Total Amount *'**
  String get totalAmountRequired;

  /// No description provided for @enterTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter total amount'**
  String get enterTotalAmount;

  /// No description provided for @pleaseEnterTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the total amount'**
  String get pleaseEnterTotalAmount;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @taxAmount.
  ///
  /// In en, this message translates to:
  /// **'Tax Amount'**
  String get taxAmount;

  /// No description provided for @taxAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Tax Amount (Optional)'**
  String get taxAmountOptional;

  /// No description provided for @enterTaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter tax amount'**
  String get enterTaxAmount;

  /// No description provided for @pleaseEnterTotalAmountFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter total amount first'**
  String get pleaseEnterTotalAmountFirst;

  /// No description provided for @taxCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Tax cannot be negative'**
  String get taxCannotBeNegative;

  /// No description provided for @taxCannotBeGreaterThanTotal.
  ///
  /// In en, this message translates to:
  /// **'Tax cannot be greater than total'**
  String get taxCannotBeGreaterThanTotal;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @receiptImage.
  ///
  /// In en, this message translates to:
  /// **'Receipt Image'**
  String get receiptImage;

  /// No description provided for @addReceiptImage.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt Image'**
  String get addReceiptImage;

  /// No description provided for @noReceiptImage.
  ///
  /// In en, this message translates to:
  /// **'No receipt image'**
  String get noReceiptImage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the application'**
  String get selectYourPreferredLanguage;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @chooseHowDatesShouldBeDisplayed.
  ///
  /// In en, this message translates to:
  /// **'Choose how dates should be displayed'**
  String get chooseHowDatesShouldBeDisplayed;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Date Format'**
  String get selectDateFormat;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select day'**
  String get selectDay;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @taxRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate (%)'**
  String get taxRateLabel;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginWelcome;

  /// No description provided for @socialLoginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get socialLoginGoogle;

  /// No description provided for @socialLoginApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get socialLoginApple;

  /// No description provided for @renewingInDays.
  ///
  /// In en, this message translates to:
  /// **'Renewing in {days} days'**
  String renewingInDays(int days);

  /// No description provided for @autoRenewalActive.
  ///
  /// In en, this message translates to:
  /// **'Auto-renewal active'**
  String get autoRenewalActive;

  /// No description provided for @manageSubscriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'To manage your subscription, go to your account settings in the app store.'**
  String get manageSubscriptionHelp;

  /// No description provided for @currentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlanLabel;

  /// No description provided for @changePlanInstruction.
  ///
  /// In en, this message translates to:
  /// **'To change to {planName}, cancel your current plan and subscribe to the new plan from the store.'**
  String changePlanInstruction(String planName);

  /// No description provided for @managingKeychain.
  ///
  /// In en, this message translates to:
  /// **'Managing keychain...'**
  String get managingKeychain;

  /// No description provided for @alreadyHaveAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get alreadyHaveAccountAction;

  /// No description provided for @noCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategoriesTitle;

  /// No description provided for @addFirstCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense category'**
  String get addFirstCategoryMessage;

  /// No description provided for @noAnonymousUserToConvert.
  ///
  /// In en, this message translates to:
  /// **'No anonymous user to convert'**
  String get noAnonymousUserToConvert;

  /// No description provided for @noAnonymousUserToLink.
  ///
  /// In en, this message translates to:
  /// **'No anonymous user to link'**
  String get noAnonymousUserToLink;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmailAddress;

  /// No description provided for @pleaseEnterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your business name'**
  String get pleaseEnterBusinessName;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get pleaseEnterAddress;

  /// No description provided for @selectHowToCapture.
  ///
  /// In en, this message translates to:
  /// **'Select how to capture'**
  String get selectHowToCapture;

  /// No description provided for @selectHowToCaptureInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select how to capture the invoice'**
  String get selectHowToCaptureInvoice;

  /// No description provided for @selectImageFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImageFromGallery;

  /// No description provided for @chooseFromGalleryDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose from your gallery'**
  String get chooseFromGalleryDescription;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'When you have notifications, they will appear here'**
  String get noNotificationsMessage;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get clearAllNotifications;

  /// No description provided for @clearAllNotificationsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications? This action cannot be undone.'**
  String get clearAllNotificationsConfirmation;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications have been cleared'**
  String get allNotificationsCleared;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @errorInMyApp.
  ///
  /// In en, this message translates to:
  /// **'Application Error'**
  String get errorInMyApp;

  /// No description provided for @envMissingError.
  ///
  /// In en, this message translates to:
  /// **'SUPABASE_URL and SUPABASE_ANON_KEY must be defined in your .env file'**
  String get envMissingError;

  /// No description provided for @businessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Business name is required'**
  String get businessNameRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @sendPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Send PDF File'**
  String get sendPdfFile;

  /// No description provided for @downloadAndSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Download and share PDF'**
  String get downloadAndSharePdf;

  /// No description provided for @exportAsPng.
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get exportAsPng;

  /// No description provided for @downloadAsImage.
  ///
  /// In en, this message translates to:
  /// **'Download as image'**
  String get downloadAsImage;

  /// No description provided for @deleteOnlineLink.
  ///
  /// In en, this message translates to:
  /// **'Delete Online Link'**
  String get deleteOnlineLink;

  /// No description provided for @removeSharedLink.
  ///
  /// In en, this message translates to:
  /// **'Remove shared link'**
  String get removeSharedLink;

  /// No description provided for @sharePngFile.
  ///
  /// In en, this message translates to:
  /// **'Share PNG File'**
  String get sharePngFile;

  /// No description provided for @shareViaOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Share via other apps'**
  String get shareViaOtherApps;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  /// No description provided for @downloadToLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'Download to local storage'**
  String get downloadToLocalStorage;

  /// No description provided for @deleteOnlineLinkConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the online link? This action cannot be undone.'**
  String get deleteOnlineLinkConfirmation;

  /// No description provided for @copySecureLinkToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy secure online link to clipboard'**
  String get copySecureLinkToClipboard;

  /// No description provided for @shareOnlineLinkViaApps.
  ///
  /// In en, this message translates to:
  /// **'Share online link via other apps'**
  String get shareOnlineLinkViaApps;

  /// No description provided for @createFreshLink.
  ///
  /// In en, this message translates to:
  /// **'Create a fresh link'**
  String get createFreshLink;

  /// No description provided for @sharePdfFile.
  ///
  /// In en, this message translates to:
  /// **'Share PDF File'**
  String get sharePdfFile;

  /// No description provided for @couldNotAccessDownloads.
  ///
  /// In en, this message translates to:
  /// **'Could not access Downloads directory'**
  String get couldNotAccessDownloads;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @linkShared.
  ///
  /// In en, this message translates to:
  /// **'Link shared'**
  String get linkShared;

  /// No description provided for @pdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved'**
  String get pdfSaved;

  /// No description provided for @pngSaved.
  ///
  /// In en, this message translates to:
  /// **'PNG saved'**
  String get pngSaved;

  /// No description provided for @linkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Link deleted'**
  String get linkDeleted;

  /// No description provided for @linkGenerated.
  ///
  /// In en, this message translates to:
  /// **'Link generated'**
  String get linkGenerated;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirmation;

  /// No description provided for @taxable.
  ///
  /// In en, this message translates to:
  /// **'Taxable'**
  String get taxable;

  /// No description provided for @signatureSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signature saved successfully'**
  String get signatureSavedSuccessfully;

  /// No description provided for @noSignatureAvailable.
  ///
  /// In en, this message translates to:
  /// **'No signature available'**
  String get noSignatureAvailable;

  /// No description provided for @pleaseSelectBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Please select a business type'**
  String get pleaseSelectBusinessType;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @categoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get mustAcceptTerms;

  /// No description provided for @noClientsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No clients available'**
  String get noClientsAvailable;

  /// No description provided for @selectAClient.
  ///
  /// In en, this message translates to:
  /// **'Select a client'**
  String get selectAClient;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @receiptUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt updated successfully'**
  String get receiptUpdatedSuccessfully;

  /// No description provided for @receiptDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted successfully'**
  String get receiptDeletedSuccessfully;

  /// No description provided for @receiptSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved successfully'**
  String get receiptSavedSuccessfully;

  /// No description provided for @duplicateReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible Duplicate'**
  String get duplicateReceiptTitle;

  /// No description provided for @duplicateReceiptMessage.
  ///
  /// In en, this message translates to:
  /// **'A similar receipt was already saved in the last 24 hours. Do you want to save it anyway?'**
  String get duplicateReceiptMessage;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get saveAnyway;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// No description provided for @errorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error updating'**
  String get errorUpdating;

  /// No description provided for @errorClearingImage.
  ///
  /// In en, this message translates to:
  /// **'Error clearing image'**
  String get errorClearingImage;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @errorClearingLogo.
  ///
  /// In en, this message translates to:
  /// **'Error clearing logo'**
  String get errorClearingLogo;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get errorSaving;

  /// No description provided for @errorSavingSignature.
  ///
  /// In en, this message translates to:
  /// **'Error saving signature'**
  String get errorSavingSignature;

  /// No description provided for @serviceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Service not available'**
  String get serviceNotAvailable;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// No description provided for @errorLoadingExpense.
  ///
  /// In en, this message translates to:
  /// **'Error loading expense'**
  String get errorLoadingExpense;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @noEstimateLinkAvailable.
  ///
  /// In en, this message translates to:
  /// **'No estimate link available. Please generate one first.'**
  String get noEstimateLinkAvailable;

  /// No description provided for @generatingNewLink.
  ///
  /// In en, this message translates to:
  /// **'Generating new link...'**
  String get generatingNewLink;

  /// No description provided for @errorLoadingCategory.
  ///
  /// In en, this message translates to:
  /// **'Error loading category'**
  String get errorLoadingCategory;

  /// No description provided for @imageExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Image export coming soon'**
  String get imageExportComingSoon;

  /// No description provided for @errorExportingCsv.
  ///
  /// In en, this message translates to:
  /// **'Error exporting CSV'**
  String get errorExportingCsv;

  /// No description provided for @errorCreatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Error creating invoice'**
  String get errorCreatingInvoice;

  /// No description provided for @errorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Error processing image'**
  String get errorProcessingImage;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorSavingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Error saving receipt'**
  String get errorSavingReceipt;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @errorUpdatingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Error updating receipt'**
  String get errorUpdatingReceipt;

  /// No description provided for @errorInitiatingOcr.
  ///
  /// In en, this message translates to:
  /// **'Error initiating OCR'**
  String get errorInitiatingOcr;

  /// No description provided for @businessCategoryCreativeDesc.
  ///
  /// In en, this message translates to:
  /// **'Design, advertising, marketing and media'**
  String get businessCategoryCreativeDesc;

  /// No description provided for @businessCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get businessCategoryOther;

  /// No description provided for @businessCategoryOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Other type of business not listed'**
  String get businessCategoryOtherDesc;

  /// No description provided for @onboardingFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: John Doe'**
  String get onboardingFullNameHint;

  /// No description provided for @onboardingFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get onboardingFullNameRequired;

  /// No description provided for @onboardingEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get onboardingEmailRequired;

  /// No description provided for @onboardingEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get onboardingEmailInvalid;

  /// No description provided for @onboardingEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: john@example.com'**
  String get onboardingEmailHint;

  /// No description provided for @onboardingPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get onboardingPasswordHint;

  /// No description provided for @onboardingPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get onboardingPasswordRequired;

  /// No description provided for @onboardingPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get onboardingPasswordMinLength;

  /// No description provided for @onboardingConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get onboardingConfirmPassword;

  /// No description provided for @onboardingConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get onboardingConfirmPasswordHint;

  /// No description provided for @onboardingConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get onboardingConfirmPasswordRequired;

  /// No description provided for @onboardingPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get onboardingPasswordMismatch;

  /// No description provided for @onboardingPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get onboardingPhotoAdded;

  /// No description provided for @onboardingPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get onboardingPhotoRemoved;

  /// No description provided for @onboardingCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get onboardingCreatingAccount;

  /// No description provided for @onboardingCreateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get onboardingCreateMyAccount;

  /// No description provided for @onboardingEditInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit information'**
  String get onboardingEditInformation;

  /// No description provided for @onboardingCompleteAllInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required information.'**
  String get onboardingCompleteAllInfo;

  /// No description provided for @onboardingAccountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome to Facturo.'**
  String get onboardingAccountCreatedSuccess;

  /// No description provided for @onboardingAccountCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating account'**
  String get onboardingAccountCreationError;

  /// No description provided for @onboardingUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error creating account'**
  String get onboardingUnexpectedError;

  /// No description provided for @onboardingImageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get onboardingImageSelectionError;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get errorChangingPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @savedReceipts.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedReceipts;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @noSavedReceipts.
  ///
  /// In en, this message translates to:
  /// **'No saved receipts'**
  String get noSavedReceipts;

  /// No description provided for @scanFirstReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan your first receipt to start saving them'**
  String get scanFirstReceipt;

  /// No description provided for @receiptViewed.
  ///
  /// In en, this message translates to:
  /// **'Receipt viewed'**
  String get receiptViewed;

  /// No description provided for @receiptExported.
  ///
  /// In en, this message translates to:
  /// **'Receipt exported'**
  String get receiptExported;

  /// No description provided for @receiptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted'**
  String get receiptDeleted;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @ocrTipStraight.
  ///
  /// In en, this message translates to:
  /// **'Keep the receipt straight and wrinkle-free'**
  String get ocrTipStraight;

  /// No description provided for @ocrTipCloseUp.
  ///
  /// In en, this message translates to:
  /// **'Get close enough for the text to be legible'**
  String get ocrTipCloseUp;

  /// No description provided for @ocrExtractingText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text...'**
  String get ocrExtractingText;

  /// No description provided for @ocrAnalyzingData.
  ///
  /// In en, this message translates to:
  /// **'Analyzing data...'**
  String get ocrAnalyzingData;

  /// No description provided for @ocrParsingData.
  ///
  /// In en, this message translates to:
  /// **'Processing information...'**
  String get ocrParsingData;

  /// No description provided for @ocrValidatingData.
  ///
  /// In en, this message translates to:
  /// **'Validating information...'**
  String get ocrValidatingData;

  /// No description provided for @ocrReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Extracted Data'**
  String get ocrReviewTitle;

  /// No description provided for @ocrReviewInstructions.
  ///
  /// In en, this message translates to:
  /// **'Review and edit the extracted data before creating an invoice'**
  String get ocrReviewInstructions;

  /// No description provided for @ocrPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to enlarge'**
  String get ocrPreviewHint;

  /// No description provided for @ocrCreateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get ocrCreateInvoice;

  /// No description provided for @ocrEditBeforeCreate.
  ///
  /// In en, this message translates to:
  /// **'Edit and Create Invoice'**
  String get ocrEditBeforeCreate;

  /// No description provided for @ocrSaveOnly.
  ///
  /// In en, this message translates to:
  /// **'Save Receipt Only'**
  String get ocrSaveOnly;

  /// No description provided for @ocrRescan.
  ///
  /// In en, this message translates to:
  /// **'Re-scan'**
  String get ocrRescan;

  /// No description provided for @ocrBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get ocrBasicInfo;

  /// No description provided for @ocrCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get ocrCompany;

  /// No description provided for @ocrInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get ocrInvoiceNumber;

  /// No description provided for @ocrDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ocrDate;

  /// No description provided for @ocrFinancialInfo.
  ///
  /// In en, this message translates to:
  /// **'Financial Information'**
  String get ocrFinancialInfo;

  /// No description provided for @ocrSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get ocrSubtotal;

  /// No description provided for @ocrTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get ocrTax;

  /// No description provided for @ocrTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ocrTotal;

  /// No description provided for @ocrItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ocrItems;

  /// No description provided for @ocrAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get ocrAddItem;

  /// No description provided for @ocrNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get ocrNoItems;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @saveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Save Receipt'**
  String get saveReceipt;

  /// No description provided for @receiptSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved successfully'**
  String get receiptSavedSuccess;

  /// No description provided for @receiptSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving receipt'**
  String get receiptSaveError;

  /// No description provided for @invoiceCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice created successfully'**
  String get invoiceCreatedSuccess;

  /// No description provided for @invoiceCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating invoice'**
  String get invoiceCreateError;

  /// No description provided for @scannedReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scanned Receipt'**
  String get scannedReceipt;

  /// No description provided for @scannedImage.
  ///
  /// In en, this message translates to:
  /// **'Scanned Image'**
  String get scannedImage;

  /// No description provided for @tapToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Tap to enlarge'**
  String get tapToEnlarge;

  /// No description provided for @receiptDetails.
  ///
  /// In en, this message translates to:
  /// **'Receipt Details'**
  String get receiptDetails;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @deleteImageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImageConfirmation;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel Edit'**
  String get cancelEdit;

  /// No description provided for @saveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get saveInvoice;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan Document'**
  String get scanDocument;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @deleteProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile Image'**
  String get deleteProfileImage;

  /// No description provided for @deleteProfileImageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile image?'**
  String get deleteProfileImageConfirmation;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @errorRefreshingData.
  ///
  /// In en, this message translates to:
  /// **'Error refreshing data'**
  String get errorRefreshingData;

  /// No description provided for @errorLoadingClients.
  ///
  /// In en, this message translates to:
  /// **'Error loading clients'**
  String get errorLoadingClients;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImage;

  /// No description provided for @couldNotOpenEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get couldNotOpenEmailApp;

  /// No description provided for @errorSharingEstimate.
  ///
  /// In en, this message translates to:
  /// **'Error sharing estimate'**
  String get errorSharingEstimate;

  /// No description provided for @errorSharingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Error sharing invoice'**
  String get errorSharingInvoice;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF'**
  String get errorGeneratingPdf;

  /// No description provided for @errorGeneratingPng.
  ///
  /// In en, this message translates to:
  /// **'Error generating PNG'**
  String get errorGeneratingPng;

  /// No description provided for @errorSavingPng.
  ///
  /// In en, this message translates to:
  /// **'Error saving PNG'**
  String get errorSavingPng;

  /// No description provided for @errorDeletingLink.
  ///
  /// In en, this message translates to:
  /// **'Error deleting link'**
  String get errorDeletingLink;

  /// No description provided for @noImageToPreview.
  ///
  /// In en, this message translates to:
  /// **'No image to preview'**
  String get noImageToPreview;

  /// No description provided for @errorLoadingClientsEs.
  ///
  /// In en, this message translates to:
  /// **'Error cargando clientes'**
  String get errorLoadingClientsEs;

  /// No description provided for @invoiceHasBeenMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Invoice has been marked as paid'**
  String get invoiceHasBeenMarkedAsPaid;

  /// No description provided for @invoiceIsPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Invoice is pending payment'**
  String get invoiceIsPendingPayment;

  /// No description provided for @previewImage.
  ///
  /// In en, this message translates to:
  /// **'Preview Image'**
  String get previewImage;

  /// No description provided for @uploadInvoiceImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Invoice Image'**
  String get uploadInvoiceImage;

  /// No description provided for @startFree.
  ///
  /// In en, this message translates to:
  /// **'Try Free'**
  String get startFree;

  /// No description provided for @unlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock PRO'**
  String get unlockPro;

  /// No description provided for @welcomeToFacturo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Facturo'**
  String get welcomeToFacturo;

  /// No description provided for @usageLimits.
  ///
  /// In en, this message translates to:
  /// **'Usage limits'**
  String get usageLimits;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get start;

  /// No description provided for @invoiceScans.
  ///
  /// In en, this message translates to:
  /// **'Invoice scans'**
  String get invoiceScans;

  /// No description provided for @freemiumLimitInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Invoices'**
  String freemiumLimitInvoicesTitle(int count);

  /// No description provided for @freemiumLimitInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create up to {count} professional invoices'**
  String freemiumLimitInvoicesSubtitle(int count);

  /// No description provided for @freemiumLimitClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Clients'**
  String freemiumLimitClientsTitle(int count);

  /// No description provided for @freemiumLimitClientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage up to {count} clients'**
  String freemiumLimitClientsSubtitle(int count);

  /// No description provided for @freemiumLimitEstimatesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Estimates'**
  String freemiumLimitEstimatesTitle(int count);

  /// No description provided for @freemiumLimitEstimatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate up to {count} quotes'**
  String freemiumLimitEstimatesSubtitle(int count);

  /// No description provided for @freemiumLimitOcrTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Receipt scans'**
  String freemiumLimitOcrTitle(int count);

  /// No description provided for @freemiumLimitOcrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Digitize {count} receipts'**
  String freemiumLimitOcrSubtitle(int count);

  /// No description provided for @freemiumLimitReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Reports'**
  String freemiumLimitReportsTitle(int count);

  /// No description provided for @freemiumLimitReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate {count} detailed reports'**
  String freemiumLimitReportsSubtitle(int count);

  /// No description provided for @allYears.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allYears;

  /// No description provided for @categoryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccessfully;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

  /// No description provided for @paywallDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited invoicing\nCreate professional invoices without limits and grow your business like never before'**
  String get paywallDefaultMessage;

  /// No description provided for @invoiceEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Invoice {documentNumber}'**
  String invoiceEmailSubject(String documentNumber);

  /// No description provided for @invoiceEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Please find attached the invoice for your recent transaction.\n\n'**
  String get invoiceEmailBody;

  /// No description provided for @invoiceEmailThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business, {clientName}!\n\n'**
  String invoiceEmailThankYou(String clientName);

  /// No description provided for @invoiceEmailAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due: {amount}\n\n'**
  String invoiceEmailAmountDue(String amount);

  /// No description provided for @invoiceEmailContact.
  ///
  /// In en, this message translates to:
  /// **'For any questions, please contact us.'**
  String get invoiceEmailContact;

  /// No description provided for @estimateEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Estimate {documentNumber}'**
  String estimateEmailSubject(String documentNumber);

  /// No description provided for @estimateEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Please find attached the estimate for your consideration.\n\n'**
  String get estimateEmailBody;

  /// No description provided for @estimateEmailThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your interest, {clientName}!\n\n'**
  String estimateEmailThankYou(String clientName);

  /// No description provided for @estimateEmailTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimate total: {amount}\n\n'**
  String estimateEmailTotal(String amount);

  /// No description provided for @passwordRecoveryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password recovery feature coming soon'**
  String get passwordRecoveryComingSoon;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// No description provided for @anonymousSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'To subscribe to a PRO plan, you first need to create a permanent account. This will ensure your subscription is linked to your account.\n\nWould you like to create an account now?'**
  String get anonymousSubscriptionWarning;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @googleAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Google account connected! Activating subscription...'**
  String get googleAccountConnected;

  /// No description provided for @googleAccountConnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google account connected successfully!'**
  String get googleAccountConnectedSuccess;

  /// No description provided for @appleAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Apple account connected! Activating subscription...'**
  String get appleAccountConnected;

  /// No description provided for @appleAccountConnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Apple account connected successfully!'**
  String get appleAccountConnectedSuccess;

  /// No description provided for @planActive.
  ///
  /// In en, this message translates to:
  /// **'Active Plan'**
  String get planActive;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet.'**
  String get networkError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get tryAgainLater;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @invalidDateRange.
  ///
  /// In en, this message translates to:
  /// **'Invalid date range'**
  String get invalidDateRange;

  /// No description provided for @convertReceipt.
  ///
  /// In en, this message translates to:
  /// **'Convert Receipt'**
  String get convertReceipt;

  /// No description provided for @chooseConversionType.
  ///
  /// In en, this message translates to:
  /// **'Choose how to convert this receipt'**
  String get chooseConversionType;

  /// No description provided for @convertToExpense.
  ///
  /// In en, this message translates to:
  /// **'Convert to Expense'**
  String get convertToExpense;

  /// No description provided for @convertToExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Register this receipt as an expense for tracking'**
  String get convertToExpenseDescription;

  /// No description provided for @convertToInvoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an invoice to send to a client'**
  String get convertToInvoiceDescription;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @expenseCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense created successfully'**
  String get expenseCreatedSuccessfully;

  /// No description provided for @errorCreatingExpense.
  ///
  /// In en, this message translates to:
  /// **'Error creating expense'**
  String get errorCreatingExpense;

  /// No description provided for @tapReceiptToViewOrScan.
  ///
  /// In en, this message translates to:
  /// **'Tap a receipt to view details, or scan a new one'**
  String get tapReceiptToViewOrScan;

  /// No description provided for @unknownCompany.
  ///
  /// In en, this message translates to:
  /// **'Unknown Company'**
  String get unknownCompany;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @selectFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Select from photos'**
  String get selectFromPhotos;

  /// No description provided for @chooseHowToAddReceipt.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add a receipt'**
  String get chooseHowToAddReceipt;

  /// No description provided for @processingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Processing Receipt...'**
  String get processingReceipt;

  /// No description provided for @processingResults.
  ///
  /// In en, this message translates to:
  /// **'Processing results...'**
  String get processingResults;

  /// No description provided for @sendingToAI.
  ///
  /// In en, this message translates to:
  /// **'Sending for processing...'**
  String get sendingToAI;

  /// No description provided for @initializingAI.
  ///
  /// In en, this message translates to:
  /// **'Initializing processing...'**
  String get initializingAI;

  /// No description provided for @improveYourDocument.
  ///
  /// In en, this message translates to:
  /// **'Improve your document'**
  String get improveYourDocument;

  /// No description provided for @improveYourDocumentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Improve your document'**
  String get improveYourDocumentTooltip;

  /// No description provided for @makeInvoicesMoreProfessional.
  ///
  /// In en, this message translates to:
  /// **'To make your invoices look more professional, we recommend adding:'**
  String get makeInvoicesMoreProfessional;

  /// No description provided for @makeEstimatesMoreProfessional.
  ///
  /// In en, this message translates to:
  /// **'To make your estimates look more professional, we recommend adding:'**
  String get makeEstimatesMoreProfessional;

  /// No description provided for @addBusinessLogo.
  ///
  /// In en, this message translates to:
  /// **'Business logo'**
  String get addBusinessLogo;

  /// No description provided for @addBusinessLogoDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your logo to give identity to your documents'**
  String get addBusinessLogoDescription;

  /// No description provided for @addDigitalSignature.
  ///
  /// In en, this message translates to:
  /// **'Digital signature'**
  String get addDigitalSignature;

  /// No description provided for @addDigitalSignatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Include your signature for more formality'**
  String get addDigitalSignatureDescription;

  /// No description provided for @elementsOptionalButImprove.
  ///
  /// In en, this message translates to:
  /// **'These elements are optional but improve presentation'**
  String get elementsOptionalButImprove;

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// No description provided for @configureButton.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configureButton;

  /// No description provided for @scanningProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning Progress'**
  String get scanningProgress;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete!'**
  String get complete;

  /// No description provided for @receiptLinkedToInvoice.
  ///
  /// In en, this message translates to:
  /// **'This receipt is already linked to an invoice.'**
  String get receiptLinkedToInvoice;

  /// No description provided for @failedToDeleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete receipt'**
  String get failedToDeleteReceipt;

  /// No description provided for @errorDeletingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Error deleting receipt'**
  String get errorDeletingReceipt;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @otpCooldown.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} seconds before requesting another code'**
  String otpCooldown(int seconds);

  /// No description provided for @otpSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP code sent to your email'**
  String get otpSentToEmail;

  /// No description provided for @enter6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enter6DigitCode;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtpCode;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @accountCreatedWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Account created with Google!'**
  String get accountCreatedWithGoogle;

  /// No description provided for @accountCreatedWithApple.
  ///
  /// In en, this message translates to:
  /// **'Account created with Apple!'**
  String get accountCreatedWithApple;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign in cancelled'**
  String get signInCancelled;

  /// No description provided for @errorConnectingGoogle.
  ///
  /// In en, this message translates to:
  /// **'Error connecting with Google'**
  String get errorConnectingGoogle;

  /// No description provided for @errorConnectingApple.
  ///
  /// In en, this message translates to:
  /// **'Error connecting with Apple'**
  String get errorConnectingApple;

  /// No description provided for @enterCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email'**
  String get enterCodeSentToEmail;

  /// No description provided for @willSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code by email'**
  String get willSendVerificationCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @dontHaveAccountCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get dontHaveAccountCreateOne;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get iAcceptThe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @andThe.
  ///
  /// In en, this message translates to:
  /// **'and the'**
  String get andThe;

  /// No description provided for @errorSendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Error sending OTP code'**
  String get errorSendingOtp;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @otpCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Please request a new code.'**
  String get otpCodeExpired;

  /// No description provided for @otpCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code is invalid. Please verify and try again.'**
  String get otpCodeInvalid;

  /// No description provided for @accountNotFoundCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please create an account first.'**
  String get accountNotFoundCreateFirst;

  /// No description provided for @guestAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Account'**
  String get guestAccountWarningTitle;

  /// No description provided for @guestAccountWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'You are using the app as a guest. If you uninstall the app, log out, or change devices, you will permanently lose all your data (invoices, clients, expenses).'**
  String get guestAccountWarningMessage;

  /// No description provided for @secureYourDataNow.
  ///
  /// In en, this message translates to:
  /// **'Create a permanent account to protect your information'**
  String get secureYourDataNow;

  /// No description provided for @whyCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Why create an account?'**
  String get whyCreateAccount;

  /// No description provided for @benefit1SyncData.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across devices'**
  String get benefit1SyncData;

  /// No description provided for @benefit2BackupCloud.
  ///
  /// In en, this message translates to:
  /// **'Automatic cloud backup'**
  String get benefit2BackupCloud;

  /// No description provided for @benefit3RecoverData.
  ///
  /// In en, this message translates to:
  /// **'Recover data if you change devices'**
  String get benefit3RecoverData;

  /// No description provided for @benefit4NeverLoseData.
  ///
  /// In en, this message translates to:
  /// **'Never lose your invoices and clients'**
  String get benefit4NeverLoseData;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account Verified'**
  String get accountVerified;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to protect your invoices and clients'**
  String get createAccountSubtitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get loginSubtitle;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get termsAgreement;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loginSuccessful;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @accountOptionalPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you want to save and sync your data across devices, create an account or sign in.'**
  String get accountOptionalPrompt;

  /// No description provided for @convertReceiptToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Convert this receipt to a new invoice?'**
  String get convertReceiptToInvoice;

  /// No description provided for @convertReceiptToExpense.
  ///
  /// In en, this message translates to:
  /// **'Convert this receipt to a new expense?'**
  String get convertReceiptToExpense;

  /// No description provided for @confirmDeleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receipt?'**
  String get confirmDeleteReceipt;

  /// No description provided for @emailAppOpenedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email app opened successfully'**
  String get emailAppOpenedSuccessfully;

  /// No description provided for @errorOpeningEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Error opening email app'**
  String get errorOpeningEmailApp;

  /// No description provided for @errorGeneratingLink.
  ///
  /// In en, this message translates to:
  /// **'Error generating link'**
  String get errorGeneratingLink;

  /// No description provided for @noLinkAvailable.
  ///
  /// In en, this message translates to:
  /// **'No link available. Please generate a link first.'**
  String get noLinkAvailable;

  /// No description provided for @errorExportingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF'**
  String get errorExportingPdf;

  /// No description provided for @pngExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PNG exported successfully'**
  String get pngExportedSuccessfully;

  /// No description provided for @errorExportingPng.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PNG'**
  String get errorExportingPng;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @pdfSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get pdfSubtotal;

  /// No description provided for @pdfTel.
  ///
  /// In en, this message translates to:
  /// **'Tel:'**
  String get pdfTel;

  /// No description provided for @pdfEmail.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get pdfEmail;

  /// No description provided for @createExpense.
  ///
  /// In en, this message translates to:
  /// **'Create Expense'**
  String get createExpense;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency...'**
  String get searchCurrency;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @currencyUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Currency updated to'**
  String get currencyUpdatedTo;

  /// No description provided for @currencySettings.
  ///
  /// In en, this message translates to:
  /// **'Currency Settings'**
  String get currencySettings;

  /// No description provided for @selectYourPreferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred currency for invoices and reports'**
  String get selectYourPreferredCurrency;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @dateWithFormat.
  ///
  /// In en, this message translates to:
  /// **'Date (MM/DD/YYYY)'**
  String get dateWithFormat;

  /// No description provided for @letsStartWithBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with your basic information'**
  String get letsStartWithBasicInfo;

  /// No description provided for @tapToAddProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add profile photo'**
  String get tapToAddProfilePhoto;

  /// No description provided for @exampleName.
  ///
  /// In en, this message translates to:
  /// **'Ex: John Doe'**
  String get exampleName;

  /// No description provided for @exampleEmail.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get exampleEmail;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @tellUsAboutYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business'**
  String get tellUsAboutYourBusiness;

  /// No description provided for @tapToAddBusinessLogo.
  ///
  /// In en, this message translates to:
  /// **'Tap to add business logo'**
  String get tapToAddBusinessLogo;

  /// No description provided for @exampleBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Ex: My Business LLC'**
  String get exampleBusinessName;

  /// No description provided for @exampleAddress.
  ///
  /// In en, this message translates to:
  /// **'Ex: 123 Main Street'**
  String get exampleAddress;

  /// No description provided for @exampleWebsite.
  ///
  /// In en, this message translates to:
  /// **'Ex: https://mysite.com'**
  String get exampleWebsite;

  /// No description provided for @whatDoesYourBusinessDo.
  ///
  /// In en, this message translates to:
  /// **'What does your business do?'**
  String get whatDoesYourBusinessDo;

  /// No description provided for @selectCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the category that best describes your business'**
  String get selectCategoryDescription;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get changeProfilePicture;

  /// No description provided for @importFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get importFromContacts;

  /// No description provided for @createdFromOcrReceipt.
  ///
  /// In en, this message translates to:
  /// **'Created from OCR receipt\nInvoice #: {number}'**
  String createdFromOcrReceipt(String number);

  /// No description provided for @createdFromOcrScan.
  ///
  /// In en, this message translates to:
  /// **'Created from OCR scan\nCompany: {company}'**
  String createdFromOcrScan(String company);

  /// No description provided for @itemNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String itemNumberLabel(int number);

  /// No description provided for @qtyTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'Qty: {qty} × \${price}'**
  String qtyTimesPrice(String qty, String price);

  /// No description provided for @doubleTapToScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Double tap to scan a receipt'**
  String get doubleTapToScanReceipt;

  /// No description provided for @doubleTapToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view notifications'**
  String get doubleTapToViewNotifications;

  /// No description provided for @doubleTapToOpenMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'Double tap to open more options'**
  String get doubleTapToOpenMoreOptions;

  /// No description provided for @currentSignature.
  ///
  /// In en, this message translates to:
  /// **'Current Signature'**
  String get currentSignature;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category Name *'**
  String get categoryNameRequired;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @loadingCategoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading category details...'**
  String get loadingCategoryDetails;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// No description provided for @uploadingToCloud.
  ///
  /// In en, this message translates to:
  /// **'Uploading to cloud...'**
  String get uploadingToCloud;

  /// No description provided for @shareOnlineLink.
  ///
  /// In en, this message translates to:
  /// **'Share Online Link'**
  String get shareOnlineLink;

  /// No description provided for @generatingPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF file...'**
  String get generatingPdfFile;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllFeatures;

  /// No description provided for @unlimitedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedLabel;

  /// No description provided for @cloudLabel.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloudLabel;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @excelXlsx.
  ///
  /// In en, this message translates to:
  /// **'Excel (XLSX)'**
  String get excelXlsx;

  /// No description provided for @totalRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'Total Records: {count}'**
  String totalRecordsCount(int count);

  /// No description provided for @totalAmountFormatted.
  ///
  /// In en, this message translates to:
  /// **'Total Amount: {amount}'**
  String totalAmountFormatted(String amount);

  /// No description provided for @pdfFormat.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfFormat;

  /// No description provided for @pushNotificationsRequirePermissions.
  ///
  /// In en, this message translates to:
  /// **'Push notifications require system permissions. You can change these permissions in your device settings.'**
  String get pushNotificationsRequirePermissions;

  /// No description provided for @pdfInvoice.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get pdfInvoice;

  /// No description provided for @pdfBillTo.
  ///
  /// In en, this message translates to:
  /// **'BILL TO'**
  String get pdfBillTo;

  /// No description provided for @pdfFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get pdfFrom;

  /// No description provided for @pdfDate.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get pdfDate;

  /// No description provided for @pdfDue.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get pdfDue;

  /// No description provided for @pdfOnReceipt.
  ///
  /// In en, this message translates to:
  /// **'On Receipt'**
  String get pdfOnReceipt;

  /// No description provided for @pdfPoNumber.
  ///
  /// In en, this message translates to:
  /// **'PO #'**
  String get pdfPoNumber;

  /// No description provided for @pdfDescription.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get pdfDescription;

  /// No description provided for @pdfRate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get pdfRate;

  /// No description provided for @pdfQty.
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get pdfQty;

  /// No description provided for @pdfAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get pdfAmount;

  /// No description provided for @pdfTotalDue.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DUE'**
  String get pdfTotalDue;

  /// No description provided for @pdfTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get pdfTotal;

  /// No description provided for @pdfBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get pdfBalanceDue;

  /// No description provided for @pdfNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get pdfNA;

  /// No description provided for @pdfOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get pdfOff;

  /// No description provided for @pdfInvoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'INVOICE DETAILS'**
  String get pdfInvoiceDetails;

  /// No description provided for @pdfInvoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get pdfInvoiceDate;

  /// No description provided for @pdfDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get pdfDueDate;

  /// No description provided for @pdfDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get pdfDetails;

  /// No description provided for @pdfDateSigned.
  ///
  /// In en, this message translates to:
  /// **'DATE SIGNED'**
  String get pdfDateSigned;

  /// No description provided for @pdfPayableTo.
  ///
  /// In en, this message translates to:
  /// **'Please Make Checks Payable to:'**
  String get pdfPayableTo;

  /// No description provided for @pdfAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get pdfAttachments;

  /// No description provided for @pdfPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pdfPageOf(int current, int total);

  /// No description provided for @pdfImageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} image} other{{count} images}}'**
  String pdfImageCount(int count);

  /// No description provided for @pdfFallbackBusiness.
  ///
  /// In en, this message translates to:
  /// **'Your Business'**
  String get pdfFallbackBusiness;

  /// No description provided for @pdfFallbackClient.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get pdfFallbackClient;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
