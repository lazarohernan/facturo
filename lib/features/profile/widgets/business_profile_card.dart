import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../providers/user_profile_provider.dart';

/// Tarjeta minimalista que muestra el perfil completo del negocio
class BusinessProfileCard extends ConsumerWidget {
  const BusinessProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);

    final businessName = (profile.businessName ?? '').trim();
    final ownerName = (profile.fullName ?? '').trim();
    final email = (profile.email ?? '').trim();
    final tel = (profile.tel ?? '').trim();
    final address = (profile.address ?? '').trim();
    final website = (profile.website ?? '').trim();

    final hasBusinessName = businessName.isNotEmpty;
    final hasOwnerName = ownerName.isNotEmpty;
    final hasEmail = email.isNotEmpty;
    final hasTel = tel.isNotEmpty;
    final hasAddress = address.isNotEmpty;
    final hasWebsite = website.isNotEmpty;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.w(20)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: ResponsiveUtils.w(72),
                          height: ResponsiveUtils.h(72),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                            child: profile.businessLogoUrl != null
                                ? Image.network(
                                    profile.businessLogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Iconsax.building_outline,
                                        size: ResponsiveUtils.sp(36),
                                        color: theme.colorScheme.primary,
                                      );
                                    },
                                  )
                                : Icon(
                                    Iconsax.building_outline,
                                    size: ResponsiveUtils.sp(36),
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.w(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasBusinessName ? businessName : localizations.businessName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (profile.businessNumber != null && (profile.businessNumber ?? '').isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: ResponsiveUtils.h(6)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.w(10),
                                      vertical: ResponsiveUtils.h(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(999)),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.20),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getBusinessCategoryName(profile.businessNumber!, context),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hasWebsite)
                      Padding(
                        padding: EdgeInsets.only(top: ResponsiveUtils.h(14)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.w(12),
                            vertical: ResponsiveUtils.h(10),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.global_outline,
                                size: ResponsiveUtils.sp(16),
                                color: Colors.white,
                              ),
                              SizedBox(width: ResponsiveUtils.w(8)),
                              Expanded(
                                child: Text(
                                  website,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                color: theme.colorScheme.surface,
                padding: EdgeInsets.all(ResponsiveUtils.w(18)),
                child: Column(
                  children: [
                    if (hasOwnerName) ...[
                      _InfoRow(
                        icon: Iconsax.user_outline,
                        label: localizations.fullName,
                        value: ownerName,
                        theme: theme,
                      ),
                      SizedBox(height: ResponsiveUtils.h(10)),
                      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.10)),
                      SizedBox(height: ResponsiveUtils.h(10)),
                    ],
                    if (hasEmail) ...[
                      _InfoRow(
                        icon: Iconsax.sms_outline,
                        label: localizations.email,
                        value: email,
                        theme: theme,
                      ),
                      SizedBox(height: ResponsiveUtils.h(10)),
                      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.10)),
                      SizedBox(height: ResponsiveUtils.h(10)),
                    ],
                    if (hasTel) ...[
                      _InfoRow(
                        icon: Iconsax.call_outline,
                        label: localizations.phone,
                        value: tel,
                        theme: theme,
                      ),
                      SizedBox(height: ResponsiveUtils.h(10)),
                      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.10)),
                      SizedBox(height: ResponsiveUtils.h(10)),
                    ],
                    if (hasAddress)
                      _InfoRow(
                        icon: Iconsax.location_outline,
                        label: localizations.address,
                        value: address,
                        theme: theme,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBusinessCategoryName(String category, BuildContext context) {
    switch (category) {
      case 'retail':
        return AppLocalizations.of(context).retail;
      case 'services':
        return AppLocalizations.of(context).services;
      case 'restaurant':
        return AppLocalizations.of(context).restaurant;
      case 'construction':
        return AppLocalizations.of(context).construction;
      case 'technology':
        return AppLocalizations.of(context).technology;
      case 'health':
        return AppLocalizations.of(context).health;
      case 'education':
        return AppLocalizations.of(context).education;
      case 'professional_services':
        return AppLocalizations.of(context).professionalServices;
      case 'other':
        return AppLocalizations.of(context).other;
      default:
        return category;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.w(8)),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
          ),
          child: Icon(
            icon,
            size: ResponsiveUtils.sp(20),
            color: theme.colorScheme.primary,
          ),
        ),
        
        SizedBox(width: ResponsiveUtils.w(12)),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: ResponsiveUtils.h(2)),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
