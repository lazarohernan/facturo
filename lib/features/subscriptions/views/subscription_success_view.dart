import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class SubscriptionSuccessView extends StatefulWidget {
  final String subscriptionType;
  final bool isAnonymous;

  const SubscriptionSuccessView({
    super.key,
    required this.subscriptionType,
    this.isAnonymous = false,
  });

  @override
  State<SubscriptionSuccessView> createState() => _SubscriptionSuccessViewState();
}

class _SubscriptionSuccessViewState extends State<SubscriptionSuccessView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (widget.isAnonymous) {
      // Navigate to account prompt screen for anonymous users
      context.go('/account-prompt');
    } else {
      // Go directly to dashboard for authenticated users
      context.go(AppConstants.dashboardRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Imagen de felicitaciones
              ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                    child: Image.asset(
                      'assets/images/congrats.jpg',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),

              // Contenido con padding
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.w(20)),
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveUtils.h(4)),

                    // Success Message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            localizations.welcomeToFacturoPro,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.sp(20),
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: ResponsiveUtils.h(16)),

                          Text(
                            localizations.subscriptionActivatedSuccessfully,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: ResponsiveUtils.sp(14),
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: ResponsiveUtils.h(20)),

                          // Subscription Type Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.w(16),
                              vertical: ResponsiveUtils.h(8),
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
                            ),
                            child: Text(
                              widget.subscriptionType == 'monthly'
                                  ? localizations.monthlyPlan
                                  : localizations.annualPlan,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.h(40)),

                    // Continue Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.h(18)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            localizations.getStarted,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.sp(16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.h(16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
