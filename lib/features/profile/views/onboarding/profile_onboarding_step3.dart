import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/business_category.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../auth/services/user_profile_service.dart';

/// Paso 3: Tipo de rubro/negocio
class ProfileOnboardingStep3 extends ConsumerStatefulWidget {
  final Map<String, dynamic>? previousData;
  
  const ProfileOnboardingStep3({super.key, this.previousData});

  @override
  ConsumerState<ProfileOnboardingStep3> createState() => _ProfileOnboardingStep3State();
}

class _ProfileOnboardingStep3State extends ConsumerState<ProfileOnboardingStep3> {
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar categoría existente si la hay (solo si no viene de pasos anteriores)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si no hay datos previos del flujo, cargar del perfil existente
      if (widget.previousData == null || 
          (widget.previousData!['fullName'] == null && widget.previousData!['businessName'] == null)) {
        final profile = ref.read(userProfileProvider);
        if (profile.businessNumber != null && profile.businessNumber!.isNotEmpty) {
          setState(() {
            _selectedCategory = profile.businessNumber;
          });
        }
      }
    });
  }

  Future<void> _finish() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectBusinessType),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final profileService = ref.read(userProfileServiceProvider);

      // 1. Subir imagen de perfil si existe
      if (widget.previousData?['profileImage'] != null) {
        final profileImagePath = widget.previousData!['profileImage'] as String;
        await profileService.uploadProfileImage(
          userUuid: userId,
          imageFile: File(profileImagePath),
        );
      }

      // 2. Subir logo del negocio si existe
      if (widget.previousData?['businessLogo'] != null) {
        final businessLogoPath = widget.previousData!['businessLogo'] as String;
        await profileService.uploadBusinessLogo(
          userUuid: userId,
          imageFile: File(businessLogoPath),
        );
      }

      // 3. Guardar todos los datos del perfil
      await ref.read(userProfileProvider.notifier).updateUserProfile(
        fullName: widget.previousData?['fullName'] as String?,
        email: widget.previousData?['email'] as String?,
        businessName: widget.previousData?['businessName'] as String?,
        tel: widget.previousData?['tel'] as String?,
        address: widget.previousData?['address'] as String?,
        website: widget.previousData?['website'] as String?,
        // Nota: businessNumber se usa para guardar la categoría del negocio
        businessNumber: _selectedCategory,
      );

      if (mounted) {
        // Mostrar mensaje de éxito
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.profileCompletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Volver al dashboard
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSaving}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories = getBusinessCategories(localizations);

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
                '3/3',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUtils.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveUtils.h(16)),
                    
                    // Título
                    Text(
                      localizations.whatDoesYourBusinessDo,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.h(8)),
                    
                    // Subtítulo
                    Text(
                      localizations.selectCategoryDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.h(24)),
                    
                    // Lista de categorías
                    ...categories.map((category) {
                      final isSelected = _selectedCategory == category.id;
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: ResponsiveUtils.h(12)),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUtils.w(16)),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Icono emoji
                                Text(
                                  category.icon,
                                  style: TextStyle(fontSize: ResponsiveUtils.sp(32)),
                                ),
                                
                                SizedBox(width: ResponsiveUtils.w(16)),
                                
                                // Información
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: ResponsiveUtils.h(4)),
                                      Text(
                                        category.description,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Checkmark
                                if (isSelected)
                                  Icon(
                                    Iconsax.tick_circle_bold,
                                    color: theme.colorScheme.primary,
                                    size: ResponsiveUtils.sp(24),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    SizedBox(height: ResponsiveUtils.h(24)),
                  ],
                ),
              ),
            ),
            
            // Botón finalizar (fijo en la parte inferior)
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.w(24)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.h(50),
                child: FilledButton(
                  onPressed: _isSaving ? null : _finish,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: ResponsiveUtils.sp(20),
                          height: ResponsiveUtils.sp(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.finishButton,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.w(8)),
                            Icon(Iconsax.tick_circle_outline, size: ResponsiveUtils.sp(20)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
