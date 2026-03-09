import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';

import 'package:facturo/features/subscriptions/services/subscription_service.dart';
import 'package:facturo/features/subscriptions/models/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/providers/theme_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/services/store_rating_service.dart';
import 'package:facturo/features/profile/widgets/support_modal.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _isSubscriptionBannerVisible = true;

  @override
  void initState() {
    super.initState();

    // Cargar el perfil del usuario cuando se inicializa la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final profileState = ref.watch(userProfileProvider);
    final isLoading = profileState.state == UserProfileState.loading;
    final themeMode = ref.watch(themeProvider);
    final subscriptionAsync = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading && profileState.fullName == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with user info
                  _buildUserHeader(context, theme, user, profileState,
                      subscriptionAsync, localizations),

                  // Subscription Banner (only show if no active subscription)
                  _buildSubscriptionBanner(
                      context, theme, subscriptionAsync, localizations),

                  // Account section
                  _buildAccountSection(context, theme, localizations),

                  // Preferences section
                  _buildPreferencesSection(
                      context, theme, localizations, themeMode, ref),

                  // Support section
                  _buildSupportSection(context, theme, localizations),

                  // Logout button
                  _buildLogoutButton(context, theme, localizations, ref),

                  // Version info
                  _buildVersionInfo(context, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme, user,
      profileState, subscriptionAsync, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.w(16),
          vertical: ResponsiveUtils.h(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar cuadrado con bordes redondeados
            _buildSquareAvatar(theme, profileState),
            SizedBox(width: ResponsiveUtils.w(14)),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profileState.fullName?.isNotEmpty == true
                        ? profileState.fullName!
                        : 'Usuario',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.sp(16),
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Mostrar email solo si el usuario no es anónimo
                  if ((profileState.email ?? user?.email) != null && 
                      (profileState.email ?? user?.email)!.isNotEmpty) ...[
                    SizedBox(height: ResponsiveUtils.h(2)),
                    Text(
                      profileState.email ?? user?.email ?? AppLocalizations.of(context).noEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: ResponsiveUtils.sp(12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.h(4)),
                  ] else ...[
                    // Si es anónimo, solo poner un pequeño espacio entre nombre y badge
                    SizedBox(height: ResponsiveUtils.h(2)),
                  ],
                  
                  _buildSubscriptionStatusBadge(
                      theme, subscriptionAsync, localizations),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear un avatar cuadrado con bordes redondeados
  Widget _buildSquareAvatar(ThemeData theme, UserProfile profileState) {
    final size = ResponsiveUtils.w(56); // 56x56 píxeles
    final borderRadius = ResponsiveUtils.r(12);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: profileState.profileImg != null &&
                profileState.profileImg!.isNotEmpty
            ? Image.network(
                profileState.profileImg!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: size.toInt(),
                cacheHeight: size.toInt(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingSquareAvatar(theme, size);
                },
                errorBuilder: (context, url, error) => _buildDefaultSquareAvatar(theme, size),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  );
                },
              )
            : _buildDefaultSquareAvatar(theme, size),
      ),
    );
  }

  Widget _buildDefaultSquareAvatar(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Icon(
        Iconsax.user_outline,
        size: ResponsiveUtils.sp(24),
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLoadingSquareAvatar(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Center(
        child: SizedBox(
          width: ResponsiveUtils.sp(20),
          height: ResponsiveUtils.sp(20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // Método optimizado para mostrar el estado de suscripción
  Widget _buildSubscriptionStatusBadge(ThemeData theme,
      dynamic subscriptionAsync, AppLocalizations localizations) {
    // Extraer datos de suscripción de forma segura
    final subscription = subscriptionAsync is AsyncData ? subscriptionAsync.value : null;
    final isActive = subscription?.isActive ?? false;

    // Verificar si el usuario es anónimo
    final isAnonymous = ref.read(authControllerProvider.notifier).isCurrentUserAnonymous;

    // Determinar texto del plan basado en el estado de suscripción
    final String planText;

    if (!isActive || subscription == null) {
      // Mostrar "Guest/Invitado" si es anónimo, "Free Plan" si está registrado
      planText = isAnonymous ? localizations.guestPlan : localizations.freePlan;
    } else {
      // Solo mostrar el tipo si la suscripción está activa
      planText = subscription!.type == SubscriptionType.monthly
          ? localizations.monthlyPlan
          : subscription!.type == SubscriptionType.annual
              ? localizations.annualPlan
              : localizations.proPlan;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(8),
        vertical: ResponsiveUtils.h(3),
      ),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Iconsax.crown_1_outline : Iconsax.crown_outline,
            size: ResponsiveUtils.sp(12), // Apple HIG: icons paired with text
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ResponsiveUtils.w(4)),
          Text(
            planText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveUtils.sp(12), // Apple HIG: minimum 11pt
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Subscription banner for users without active subscription
  /// Shows an attractive, dismissible banner encouraging upgrade
  Widget _buildSubscriptionBanner(BuildContext context, ThemeData theme,
      dynamic subscriptionAsync, AppLocalizations localizations) {
    // Check if user has active subscription
    final hasActiveSubscription = subscriptionAsync is AsyncData &&
        subscriptionAsync.value?.isActive == true;

    // Don't show banner if user has subscription, still loading, or dismissed it
    if (hasActiveSubscription ||
        subscriptionAsync is AsyncLoading ||
        !_isSubscriptionBannerVisible) {
      return const SizedBox.shrink();
    }

    final isSpanish = localizations.localeName.startsWith('es');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
            theme.colorScheme.tertiary.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Iconsax.crown_1_bold,
              size: ResponsiveUtils.w(100),
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.w(8)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(10)),
                      ),
                      child: Icon(
                        Iconsax.crown_1_bold,
                        color: Colors.white,
                        size: ResponsiveUtils.w(24),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSpanish ? 'Facturo PRO' : 'Facturo PRO',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.sp(16),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.h(2)),
                          Text(
                            localizations.unlockAllFeatures,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: ResponsiveUtils.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSubscriptionBannerVisible = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveUtils.w(4)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.close_circle_outline,
                          color: Colors.white,
                          size: ResponsiveUtils.w(20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.h(12)),
                // Features row
                Row(
                  children: [
                    _buildBannerFeature(
                      Iconsax.unlimited_outline,
                      localizations.unlimitedLabel,
                    ),
                    SizedBox(width: ResponsiveUtils.w(16)),
                    _buildBannerFeature(
                      Iconsax.scan_outline,
                      'OCR',
                    ),
                    SizedBox(width: ResponsiveUtils.w(16)),
                    _buildBannerFeature(
                      Iconsax.cloud_outline,
                      localizations.cloudLabel,
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.h(12)),
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSmartPaywall(context, localizations),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.h(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(10)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      localizations.viewPlans,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.sp(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget for banner features
  Widget _buildBannerFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: ResponsiveUtils.w(14),
        ),
        SizedBox(width: ResponsiveUtils.w(4)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: ResponsiveUtils.sp(12), // Apple HIG: minimum 11pt
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(
      BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.account,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.user_outline,
            title: localizations.myAccount,
            onTap: () {
              context.push('/profile/my-account');
            },
            showArrow: true,
            textColor: ProfileColors.edit,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.building_outline,
            title: localizations.businessInfo,
            onTap: () {
              context.push(AppConstants.businessInfoRoute);
            },
            showArrow: true,
            textColor: ProfileColors.business,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.user_edit_outline,
            title: localizations.editProfile,
            onTap: () {
              context.push(AppConstants.userProfileEditRoute);
            },
            showArrow: true,
            textColor: ProfileColors.edit,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.edit_outline,
            title: localizations.digitalSignature,
            onTap: () {
              context.push(AppConstants.digitalSignatureRoute);
            },
            showArrow: true,
            textColor: ProfileColors.edit,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.trash_outline,
            title: localizations.deleteAccount,
            onTap: () => _showDeleteAccountDialog(context, localizations, ref),
            showArrow: true,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, ThemeData theme,
      AppLocalizations localizations, ThemeMode themeMode, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.preferences,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.language_square_outline,
            title: localizations.languageAndRegion,
            onTap: () {
              context.push(AppConstants.languageSettingsRoute);
            },
            showArrow: true,
            textColor: ProfileColors.language,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.dollar_circle_outline,
            title: localizations.currency,
            onTap: () {
              context.push(AppConstants.currencySettingsRoute);
            },
            showArrow: true,
            textColor: ProfileColors.business,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.notification_outline,
            title: localizations.notifications,
            onTap: () {
              context.push('/notification-settings');
            },
            showArrow: true,
            textColor: ProfileColors.notifications,
          ),
          _buildThemeTile(context, theme, themeMode, ref, localizations),
        ],
      ),
    );
  }

  Widget _buildSupportSection(
      BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.support,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.message_outline,
            title: localizations.contactSupport,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const SupportModal(),
              );
            },
            showArrow: true,
            textColor: ProfileColors.support,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.refresh_outline,
            title: localizations.restorePurchases,
            onTap: () => _handleRestorePurchases(),
            showArrow: true,
            textColor: ProfileColors.subscription,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.star_outline,
            title: localizations.rateUs,
            onTap: () async {
              // Mostrar diálogo de confirmación antes de abrir la store
              final shouldOpenStore = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(localizations.rateAppTitle),
                    content: Text(
                      Platform.isIOS
                          ? localizations.rateAppMessageIOS
                          : localizations.rateAppMessageAndroid,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(localizations.rateAppCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(localizations.rateAppRate),
                      ),
                    ],
                  );
                },
              );

              if (shouldOpenStore == true) {
                await StoreRatingService.openStoreForRating();
              }
            },
            showArrow: true,
            textColor: ProfileColors.rating,
          ),
          Builder(
            builder: (context) {
              return _buildMenuTile(
                context,
                theme,
                icon: Iconsax.send_2_outline,
                title: localizations.shareApp,
                onTap: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final storeUrl = Platform.isIOS
                      ? 'https://apps.apple.com/app/facturo/id1234567890'
                      : 'https://play.google.com/store/apps/details?id=com.facturo.app';
                  Share.share(
                    '${localizations.shareAppMessage} $storeUrl',
                    sharePositionOrigin: box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : Rect.zero,
                  );
                },
                showArrow: true,
                textColor: ProfileColors.support,
              );
            },
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.shield_tick_outline,
            title: localizations.privacyPolicy,
            onTap: () async {
              final isEnglish = localizations.localeName.startsWith('en');
              final privacyUrl = isEnglish ? AppConstants.appPrivacyPolicyEn : AppConstants.appPrivacyPolicyEs;
              final uri = Uri.parse(privacyUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            showArrow: true,
            textColor: ProfileColors.support,
          ),
          _buildMenuTile(
            context,
            theme,
            icon: Iconsax.document_text_outline,
            title: localizations.termsOfService,
            onTap: () async {
              final isEnglish = localizations.localeName.startsWith('en');
              final termsUrl = isEnglish ? AppConstants.appTermsOfServiceEn : AppConstants.appTermsOfServiceEs;
              final uri = Uri.parse(termsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            showArrow: true,
            textColor: ProfileColors.support,
          ),
        ],
      ),
    );
  }

  /// Muestra bottom sheet antes de cerrar sesión si es usuario invitado
  /// Retorna: 'cancel' para cancelar, 'convert' para convertir a permanente, 'delete' para eliminar datos
  Future<String> _showAnonymousLogoutWarning(
      BuildContext context, AppLocalizations localizations) async {
    final theme = Theme.of(context);
    return await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUtils.r(24)),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(24),
              ResponsiveUtils.h(24),
              ResponsiveUtils.w(24),
              ResponsiveUtils.h(32) + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: ResponsiveUtils.w(40),
                    height: ResponsiveUtils.h(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(2)),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(20)),
                // Title
                Text(
                  localizations.guestAccountWarningTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveUtils.sp(20),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(8)),
                // Description
                Text(
                  localizations.guestUserWarning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.sp(14),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(28)),
                // Primary: Create permanent account
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.h(52),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop('convert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                      ),
                    ),
                    child: Text(
                      localizations.createPermanentAccount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.sp(16),
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(12)),
                // Secondary: Delete data and log out
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.h(52),
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop('delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                      ),
                    ),
                    child: Text(
                      localizations.deleteDataAndLogout,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.sp(16),
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(8)),
                // Tertiary: Cancel
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop('cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    child: Text(
                      localizations.cancel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveUtils.sp(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        'cancel';
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme,
      AppLocalizations localizations, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: _buildMenuTile(
        context,
        theme,
        icon: Iconsax.logout_outline,
        title: localizations.logout,
        onTap: () async {
          final authController = ref.read(authControllerProvider.notifier);
          final isAnonymous = authController.isCurrentUserAnonymous;
          
          // Si es usuario anónimo, mostrar advertencia con 3 opciones
          if (isAnonymous) {
            final action = await _showAnonymousLogoutWarning(context, localizations);
            
            if (!context.mounted) return;
            
            switch (action) {
              case 'cancel':
                return; // No hacer nada
              case 'convert':
                // Navegar a conversión de anónimo a permanente
                context.go('/auth/convert');
                return;
              case 'delete':
                // Continuar con logout (eliminará datos)
                break;
              default:
                return;
            }
          }
          
          await authController.signOut();
          if (context.mounted) {
            context.go('/welcome');
          }
        },
        showArrow: false,
        textColor: ProfileColors.logout,
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.w(20)),
      child: Center(
        child: Text(
          'Version ${AppConstants.appVersion}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.sp(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool showArrow,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.w(20),
          vertical: ResponsiveUtils.h(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.w(24),
              color: textColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ResponsiveUtils.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: ResponsiveUtils.sp(16),
                      color: textColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: ResponsiveUtils.h(2)),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveUtils.sp(14),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Iconsax.arrow_right_3_outline,
                size: ResponsiveUtils.w(20),
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeData theme,
      ThemeMode themeMode, WidgetRef ref, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(20),
        vertical: ResponsiveUtils.h(16),
      ),
      child: Row(
        children: [
          Icon(
            themeMode == ThemeMode.dark
                ? Iconsax.sun_1_outline
                : Iconsax.moon_outline,
            size: ResponsiveUtils.w(24),
            color: themeMode == ThemeMode.dark
                ? ProfileColors.theme
                : ProfileColors.theme,
          ),
          SizedBox(width: ResponsiveUtils.w(16)),
          Expanded(
            child: Text(
              localizations.theme,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  /// Muestra el paywall inteligente desde el perfil
  Future<void> _showSmartPaywall(BuildContext context, AppLocalizations localizations) async {
    // Navegar directamente al paywall sin depender del checker async
    // Esto evita el problema del doble clic cuando el provider está cargando
    await context.push(
      AppConstants.subscriptionsRoute,
      extra: {
        'title': localizations.upgradeToPro,
        'message': localizations.getAccessToAllFeatures,
        'iconCode': Icons.star.codePoint.toString(),
        'isFirstTimePaywall': false,
      },
    );
  }

  /// Maneja la restauración de compras
  Future<void> _handleRestorePurchases() async {
    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      await subscriptionService.restorePurchases(context: context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).purchasesRestoredSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.errorRestoringPurchases(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra el diálogo de confirmación para eliminar cuenta
  Future<void> _showDeleteAccountDialog(
      BuildContext context, AppLocalizations localizations, WidgetRef ref) async {
    final subscriptionAsync = ref.read(currentSubscriptionProvider);
    final hasActiveSubscription = subscriptionAsync is AsyncData &&
        subscriptionAsync.value?.isActive == true;
    
    final confirmationController = TextEditingController();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Iconsax.warning_2_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(localizations.deleteAccountTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.deleteAccountWarning,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(localizations.deleteAccountDescription),
              const SizedBox(height: 8),
              Text(
                localizations.deleteAccountDataList,
                style: const TextStyle(fontSize: 14),
              ),
              if (hasActiveSubscription) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    localizations.deleteAccountSubscriptionWarning,
                    style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                localizations.deleteAccountConfirmation,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmationController,
                decoration: InputDecoration(
                  hintText: localizations.deleteAccountConfirmationHint,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: hasActiveSubscription ? null : () {
              final isEnglish = localizations.localeName.startsWith('en');
              final expectedText = isEnglish ? 'DELETE' : 'ELIMINAR';
              
              if (confirmationController.text.trim().toUpperCase() == expectedText) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.confirmationTextDoesNotMatch),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: hasActiveSubscription ? Colors.grey : Colors.red,
            ),
            child: Text(localizations.deleteAccountButton),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(localizations.deleteAccountButton),
                ],
              ),
            ),
          ),
        ),
      );

      // Eliminar cuenta
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar indicador de carga

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.accountDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar a welcome
          context.go('/welcome');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.errorDeletingAccount(result['error'] ?? 'Unknown error')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
