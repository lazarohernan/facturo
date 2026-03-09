import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../providers/user_profile_provider.dart';

/// Paso 2: Información del negocio (nombre, teléfono, dirección)
class ProfileOnboardingStep2 extends ConsumerStatefulWidget {
  final Map<String, dynamic>? previousData;
  
  const ProfileOnboardingStep2({super.key, this.previousData});

  @override
  ConsumerState<ProfileOnboardingStep2> createState() => _ProfileOnboardingStep2State();
}

class _ProfileOnboardingStep2State extends ConsumerState<ProfileOnboardingStep2> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _picker = ImagePicker();
  File? _businessLogo;

  @override
  void initState() {
    super.initState();
    // Cargar datos existentes si los hay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      if (profile.businessName != null && profile.businessName!.isNotEmpty) {
        _businessNameController.text = profile.businessName!;
      }
      if (profile.tel != null && profile.tel!.isNotEmpty) {
        _phoneController.text = profile.tel!;
      }
      if (profile.address != null && profile.address!.isNotEmpty) {
        _addressController.text = profile.address!;
      }
      if (profile.website != null && profile.website!.isNotEmpty) {
        _websiteController.text = profile.website!;
      }
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _businessLogo = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSelectingImage}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      // Combinar datos del paso anterior con los actuales
      final allData = {
        ...?widget.previousData,
        'businessName': _businessNameController.text.trim(),
        'tel': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        'businessLogo': _businessLogo?.path,
      };
      
      // Navegar al paso 3
      context.push('/profile-onboarding/step3', extra: allData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_outline, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.w(12),
                vertical: ResponsiveUtils.h(4),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
              ),
              child: Text(
                '2/3',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.close_circle_outline, color: theme.colorScheme.primary),
            onPressed: () => context.go('/dashboard'),
            tooltip: localizations.close,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtils.w(24)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveUtils.h(16)),
                
                // Título
                Text(
                  localizations.businessInfo,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(8)),
                
                // Subtítulo
                Text(
                  localizations.tellUsAboutYourBusiness,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(32)),
                
                // Selector de logo del negocio
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: ResponsiveUtils.w(120),
                      height: ResponsiveUtils.h(120),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _businessLogo != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: _businessLogo != null ? 2 : 1,
                        ),
                      ),
                      child: _businessLogo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
                              child: Image.file(
                                _businessLogo!,
                                fit: BoxFit.cover,
                                width: ResponsiveUtils.w(120),
                                height: ResponsiveUtils.h(120),
                              ),
                            )
                          : Icon(
                              Iconsax.building_outline,
                              size: ResponsiveUtils.sp(40),
                              color: theme.colorScheme.primary,
                            ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(8)),
                
                Center(
                  child: Text(
                    localizations.tapToAddBusinessLogo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(32)),
                
                // Campo de nombre del negocio
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: localizations.businessName,
                    hintText: localizations.exampleBusinessName,
                    prefixIcon: const Icon(Iconsax.building_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterBusinessName;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: ResponsiveUtils.h(20)),
                
                // Campo de teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: localizations.phone,
                    hintText: localizations.enterPhoneNumber,
                    prefixIcon: const Icon(Iconsax.call_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterPhone;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: ResponsiveUtils.h(20)),
                
                // Campo de dirección
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: localizations.address,
                    hintText: localizations.exampleAddress,
                    prefixIcon: const Icon(Iconsax.location_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterAddress;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: ResponsiveUtils.h(20)),
                
                // Campo de website (opcional)
                TextFormField(
                  controller: _websiteController,
                  decoration: InputDecoration(
                    labelText: localizations.website,
                    hintText: localizations.exampleWebsite,
                    prefixIcon: const Icon(Iconsax.global_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  // Website es opcional, no requiere validación
                ),
                
                SizedBox(height: ResponsiveUtils.h(40)),
                
                // Botón continuar
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.h(50),
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.continueButton,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.w(8)),
                        Icon(Iconsax.arrow_right_3_outline, size: ResponsiveUtils.sp(20)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
