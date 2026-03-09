import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/features/auth/widgets/auth_bottom_sheet.dart';

/// Screen shown to anonymous users after subscription success
/// Apple Guideline 5.1.1: Suggest (don't require) account creation
class AccountPromptView extends StatefulWidget {
  const AccountPromptView({super.key});

  @override
  State<AccountPromptView> createState() => _AccountPromptViewState();
}

class _AccountPromptViewState extends State<AccountPromptView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for 7 elements
    // 0: Info card, 1: Title, 2-5: Benefit cards, 6: Actions section
    _fadeAnimations = List.generate(7, (index) {
      final start = index * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(7, (index) {
      final start = index * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(ResponsiveUtils.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ResponsiveUtils.h(20)),

              // Info Card (index 0)
              _buildAnimatedItem(
                0,
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.w(20)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              localizations.guestAccountWarningTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: ResponsiveUtils.sp(18),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.w(8)),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.r(10),
                              ),
                            ),
                            child: Icon(
                              PhosphorIcons.info(PhosphorIconsStyle.fill),
                              color: theme.colorScheme.primary,
                              size: ResponsiveUtils.w(22),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.h(12)),
                      Text(
                        localizations.guestAccountWarningMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                          fontSize: ResponsiveUtils.sp(15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveUtils.h(32)),

              // Benefits Section Title (index 1)
              _buildAnimatedItem(
                1,
                Text(
                  localizations.whyCreateAccount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.sp(17),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.h(16)),

              // Benefit Cards (indices 2-5)
              _buildAnimatedItem(
                2,
                _buildBenefitCard(
                  theme,
                  icon: PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.fill),
                  iconColor: Colors.blue,
                  text: localizations.benefit2BackupCloud,
                ),
              ),
              SizedBox(height: ResponsiveUtils.h(12)),
              _buildAnimatedItem(
                3,
                _buildBenefitCard(
                  theme,
                  icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
                  iconColor: Colors.green,
                  text: localizations.benefit1SyncData,
                ),
              ),
              SizedBox(height: ResponsiveUtils.h(12)),
              _buildAnimatedItem(
                4,
                _buildBenefitCard(
                  theme,
                  icon: PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.fill),
                  iconColor: Colors.purple,
                  text: localizations.benefit3RecoverData,
                ),
              ),
              SizedBox(height: ResponsiveUtils.h(12)),
              _buildAnimatedItem(
                5,
                _buildBenefitCard(
                  theme,
                  icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                  iconColor: Colors.teal,
                  text: localizations.benefit4NeverLoseData,
                ),
              ),

              SizedBox(height: ResponsiveUtils.h(40)),

              // Buttons section (index 6)
              _buildAnimatedItem(
                6,
                Column(
                  children: [
                    // Continue without account Button (Primary action for compliance)
                    SizedBox(
                      height: ResponsiveUtils.h(56),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            context.go(AppConstants.dashboardRoute),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: theme.colorScheme.outline,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.r(14),
                            ),
                          ),
                        ),
                        child: Text(
                          localizations.continueWithoutAccount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.sp(17),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.h(12)),

                    Text(
                      localizations.accountOptionalPrompt,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: ResponsiveUtils.sp(13),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.h(20)),

                    // Create Account Button
                    SizedBox(
                      height: ResponsiveUtils.h(56),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => showAuthBottomSheet(
                          context,
                          isLogin: false,
                          onSuccess: () {
                            context.go(AppConstants.dashboardRoute);
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.r(14),
                            ),
                          ),
                        ),
                        child: Text(
                          localizations.createAccount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.sp(17),
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.h(12)),

                    // Already have account Button (Secondary)
                    SizedBox(
                      height: ResponsiveUtils.h(56),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => showAuthBottomSheet(
                          context,
                          isLogin: true,
                          onSuccess: () {
                            context.go(AppConstants.dashboardRoute);
                          },
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.r(14),
                            ),
                          ),
                        ),
                        child: Text(
                          localizations.alreadyHaveAccount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.sp(17),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.h(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.w(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.w(10)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(10)),
            ),
            child: Icon(icon, color: iconColor, size: ResponsiveUtils.w(22)),
          ),
          SizedBox(width: ResponsiveUtils.w(16)),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: ResponsiveUtils.sp(16),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
