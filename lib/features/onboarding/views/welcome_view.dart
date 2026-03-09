import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../auth/widgets/auth_bottom_sheet.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccount();
  }

  Future<void> _checkAccount() async {
    // Siempre mostrar el welcome view sin verificar cuentas previas
    // El usuario puede crear una cuenta o hacer login
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mostrar loading mientras verifica
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface,
                    const Color(0xFF1A1A2E),
                    const Color(0xFF4F7AC7),
                    const Color(0xFF1E3A8A),
                  ]
                : [
                    Colors.white,
                    Colors.white,
                    const Color(0xFFF8F9FA),
                    const Color(0xFF4F7AC7),
                    const Color(0xFF1E3A8A),
                  ],
            stops: const [0.0, 0.35, 0.5, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    ResponsiveUtils.screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.w(24),
                  vertical: ResponsiveUtils.h(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveUtils.h(60)),

                    // Logo Section
                    _buildLogoSection(),

                    SizedBox(height: ResponsiveUtils.h(60)),

                    // Welcome Text Section
                    _buildWelcomeText(context, localizations),

                    SizedBox(height: ResponsiveUtils.h(60)),

                    // Action Button - Siempre mostrar el botón de acción
                    _buildActionButton(context, localizations),
                    SizedBox(height: ResponsiveUtils.h(16)),

                    // Login Button for existing users
                    _buildLoginButton(context, localizations),

                    SizedBox(height: ResponsiveUtils.h(100)),

                    // Legal Text - Términos y Condiciones
                    _buildLegalText(context, localizations),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Image.asset(
        'assets/images/facturo_logo_with_text.png',
        width: ResponsiveUtils.isMobile
            ? ResponsiveUtils.w(140)
            : ResponsiveUtils.w(160),
        height: ResponsiveUtils.isMobile
            ? ResponsiveUtils.h(140)
            : ResponsiveUtils.h(160),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          final errorTheme = Theme.of(context);
          return Container(
            width: ResponsiveUtils.isMobile
                ? ResponsiveUtils.w(120)
                : ResponsiveUtils.w(140),
            height: ResponsiveUtils.isMobile
                ? ResponsiveUtils.h(120)
                : ResponsiveUtils.h(140),
            decoration: BoxDecoration(
              color: errorTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
              border: Border.all(
                color: errorTheme.colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.receipt(PhosphorIconsStyle.regular),
                  size: AppSizes.responsiveSp(48),
                  color: const Color(0xFF1E3A8A),
                ),
                SizedBox(height: ResponsiveUtils.h(8)),
                Text(
                  'FACTURO',
                  style: TextStyle(
                    fontSize: AppSizes.responsiveSp(18),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeText(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        Text(
          localizations.manageYourBusiness,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.responsiveSp(24),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
            height: 1.3,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: ResponsiveUtils.h(12)),
        Text(
          localizations.businessDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.responsiveSp(14),
            color: Theme.of(context).colorScheme.primary,
            height: 1.6,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.h(56),
      child: ElevatedButton(
        onPressed: () => context.go('/onboarding'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: const Color(0xFF1E3A8A),
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          localizations.startFree,
          style: TextStyle(
            fontSize: AppSizes.responsiveSp(16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final onPrimaryColor = theme.colorScheme.onPrimary;
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.h(56),
      child: OutlinedButton(
        onPressed: () => showAuthBottomSheet(
          context,
          isLogin: true,
          onSuccess: () => context.go('/dashboard'),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onPrimaryColor,
          side: BorderSide(color: onPrimaryColor, width: 2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          localizations.alreadyHaveAccountAction,
          style: TextStyle(
            fontSize: AppSizes.responsiveSp(16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalText(BuildContext context, AppLocalizations localizations) {
    final isEnglish = localizations.localeName.startsWith('en');
    final termsUrl = isEnglish
        ? AppConstants.appTermsOfServiceEn
        : AppConstants.appTermsOfServiceEs;
    final privacyUrl = isEnglish
        ? AppConstants.appPrivacyPolicyEn
        : AppConstants.appPrivacyPolicyEs;
    final legalColor = Theme.of(
      context,
    ).colorScheme.onPrimary.withValues(alpha: 0.9);

    return Padding(
      padding: EdgeInsets.only(top: ResponsiveUtils.h(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(termsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              localizations.termsOfService,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.responsiveSp(10),
                color: legalColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            ' \u2022 ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.responsiveSp(10),
              color: legalColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(privacyUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              localizations.privacyPolicy,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.responsiveSp(10),
                color: legalColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
