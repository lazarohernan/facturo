import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/auth/widgets/auth_bottom_sheet.dart';

class MyAccountView extends ConsumerStatefulWidget {
  static const String routeName = 'my-account';
  static const String routePath = '/profile/my-account';

  const MyAccountView({super.key});

  @override
  ConsumerState<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends ConsumerState<MyAccountView>
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

    // 7 elementos: 0: Info card, 1: Title, 2-5: Benefit cards, 6: Buttons
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
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isAnonymous =
        ref.read(authControllerProvider.notifier).isCurrentUserAnonymous;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          localizations.myAccount,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: isAnonymous
              ? _buildGuestContent(context, theme, localizations)
              : _buildRegisteredContent(context, theme, localizations),
        ),
      ),
    );
  }

  Widget _buildGuestContent(
      BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(10)),
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
              // Create Account Button (Primary)
              SizedBox(
                height: ResponsiveUtils.h(56),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAuthBottomSheet(context, isLogin: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
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

              SizedBox(height: ResponsiveUtils.h(16)),

              // Already have account Button (Secondary)
              SizedBox(
                height: ResponsiveUtils.h(56),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showAuthBottomSheet(context, isLogin: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
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
      ],
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
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveUtils.w(22),
            ),
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

  void _showAuthBottomSheet(BuildContext context, {required bool isLogin}) {
    showAuthBottomSheet(
      context,
      isLogin: isLogin,
      onSuccess: () {
        // Refresh the view after successful auth
        setState(() {});
      },
    );
  }

  Widget _buildRegisteredContent(
      BuildContext context, ThemeData theme, AppLocalizations localizations) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.userCheck(PhosphorIconsStyle.fill),
                  color: Colors.green.shade700,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.accountVerified,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.secureYourDataNow,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Account Info Section
        Text(
          localizations.accountInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 16),

        // Email Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIcons.envelope(PhosphorIconsStyle.fill),
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? localizations.noEmail,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.green,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
