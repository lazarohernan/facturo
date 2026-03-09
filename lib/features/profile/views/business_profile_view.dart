import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../widgets/business_profile_card.dart';
import '../providers/user_profile_provider.dart';

/// Vista completa del perfil del negocio
class BusinessProfileView extends ConsumerWidget {
  const BusinessProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_outline, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          localizations.businessInfo,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.w(16),
                ResponsiveUtils.h(12),
                ResponsiveUtils.w(16),
                ResponsiveUtils.h(120),
              ),
              child: Column(
                children: [
                  const BusinessProfileCard(),
                  SizedBox(height: ResponsiveUtils.h(12)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.w(16),
            ResponsiveUtils.h(12),
            ResponsiveUtils.w(16),
            ResponsiveUtils.h(12),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareBusinessProfile(context, ref),
                  icon: Icon(Iconsax.share_outline, size: ResponsiveUtils.sp(18)),
                  label: Text(localizations.shareBusinessProfile),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.h(14)),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.w(12)),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/profile'),
                  icon: Icon(Iconsax.edit_2_outline, size: ResponsiveUtils.sp(18)),
                  label: Text(localizations.editProfile),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.h(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareBusinessProfile(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final localizations = AppLocalizations.of(context);
    
    // Validate that there's information to share
    if (!_hasShareableInfo(profile)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.insufficientInfoToShare),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    // Show share options dialog
    final shareOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.howDoYouWantToShare),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.message_text_outline),
              title: Text(localizations.textMessage),
              subtitle: Text(localizations.textMessageDescription),
              onTap: () => Navigator.pop(context, 'text'),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Iconsax.profile_2user_outline),
              title: Text(localizations.contactFile),
              subtitle: Text(localizations.contactFileDescription),
              onTap: () => Navigator.pop(context, 'vcard'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );

    if (shareOption == null || !context.mounted) return;

    try {
      if (shareOption == 'text') {
        await _shareAsText(profile, context);
      } else if (shareOption == 'vcard') {
        await _shareAsVCard(profile, context);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorSharingProfile}: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  bool _hasShareableInfo(profile) {
    return (profile.businessName?.trim().isNotEmpty ?? false) ||
           (profile.fullName?.trim().isNotEmpty ?? false) ||
           (profile.email?.trim().isNotEmpty ?? false) ||
           (profile.tel?.trim().isNotEmpty ?? false);
  }

  Future<void> _shareAsText(profile, BuildContext context) async {
    final businessName = profile.businessName?.trim() ?? '';
    final ownerName = profile.fullName?.trim() ?? '';
    final email = profile.email?.trim() ?? '';
    final tel = profile.tel?.trim() ?? '';
    final address = profile.address?.trim() ?? '';
    final website = profile.website?.trim() ?? '';
    final category = profile.businessNumber != null 
        ? _getBusinessCategoryName(profile.businessNumber!, context) 
        : '';
    
    final shareText = StringBuffer();
    
    // Header
    shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
    if (businessName.isNotEmpty) {
      shareText.writeln('📋 $businessName');
      if (category.isNotEmpty) {
        shareText.writeln('   $category');
      }
    } else if (ownerName.isNotEmpty) {
      shareText.writeln('👤 $ownerName');
    }
    shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
    shareText.writeln();
    
    // Contact information
    if (ownerName.isNotEmpty && businessName.isNotEmpty) {
      shareText.writeln('👤 Contacto: $ownerName');
    }
    
    if (tel.isNotEmpty) {
      shareText.writeln('📞 Teléfono: $tel');
    }
    
    if (email.isNotEmpty) {
      shareText.writeln('✉️  Email: $email');
    }
    
    if (address.isNotEmpty) {
      shareText.writeln('📍 Dirección: $address');
    }
    
    if (website.isNotEmpty) {
      shareText.writeln('🌐 Web: $website');
    }
    
    shareText.writeln();
    shareText.writeln('━━━━━━━━━━━━━━━━━━━━');
    shareText.writeln('Compartido desde Facturo 📱');
    
    await Share.share(
      shareText.toString(),
      subject: businessName.isNotEmpty 
          ? 'Información de contacto - $businessName' 
          : 'Información de contacto',
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
    );
  }

  Future<void> _shareAsVCard(profile, BuildContext context) async {
    final businessName = profile.businessName?.trim() ?? '';
    final ownerName = profile.fullName?.trim() ?? '';
    final email = profile.email?.trim() ?? '';
    final tel = profile.tel?.trim() ?? '';
    final address = profile.address?.trim() ?? '';
    final website = profile.website?.trim() ?? '';
    final category = profile.businessNumber != null 
        ? _getBusinessCategoryName(profile.businessNumber!, context) 
        : '';

    // Generate vCard format
    final vCard = StringBuffer();
    vCard.writeln('BEGIN:VCARD');
    vCard.writeln('VERSION:3.0');
    
    // Name
    if (ownerName.isNotEmpty) {
      final nameParts = ownerName.split(' ');
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      vCard.writeln('N:$lastName;$firstName;;;');
      vCard.writeln('FN:$ownerName');
    }
    
    // Organization
    if (businessName.isNotEmpty) {
      vCard.writeln('ORG:$businessName');
      if (category.isNotEmpty) {
        vCard.writeln('TITLE:$category');
      }
    }
    
    // Contact info
    if (tel.isNotEmpty) {
      vCard.writeln('TEL;TYPE=WORK,VOICE:$tel');
    }
    
    if (email.isNotEmpty) {
      vCard.writeln('EMAIL;TYPE=INTERNET,WORK:$email');
    }
    
    if (address.isNotEmpty) {
      vCard.writeln('ADR;TYPE=WORK:;;$address;;;;');
    }
    
    if (website.isNotEmpty) {
      vCard.writeln('URL:$website');
    }
    
    vCard.writeln('NOTE:Contacto compartido desde Facturo');
    vCard.writeln('END:VCARD');

    // Save to temporary file and share
    try {
      final directory = await getTemporaryDirectory();
      final fileName = businessName.isNotEmpty 
          ? '${businessName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.vcf'
          : 'contacto.vcf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(vCard.toString());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: businessName.isNotEmpty 
            ? 'Contacto - $businessName' 
            : 'Contacto',
        text: 'Tarjeta de contacto',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 10, 10),
      );
    } catch (e) {
      // Fallback to text if vCard fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToCreateContactFile),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _shareAsText(profile, context);
      }
    }
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
