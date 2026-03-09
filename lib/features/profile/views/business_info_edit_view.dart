import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facturo/core/constants/app_sizes.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/features/profile/services/image_crop_service.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';

class BusinessInfoEditView extends ConsumerStatefulWidget {
  const BusinessInfoEditView({super.key});

  @override
  ConsumerState<BusinessInfoEditView> createState() =>
      _BusinessInfoEditViewState();
}

class _BusinessInfoEditViewState extends ConsumerState<BusinessInfoEditView> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _logoFile;
  final _picker = ImagePicker();
  bool _isLoading = false;
  bool _isEditing = false; // Nuevo estado para controlar la edición

  @override
  void initState() {
    super.initState();

    // Load profile data when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _updateControllersFromProfile(UserProfile profileState) {
    // Solo actualizar controladores si no estamos editando
    if (!_isEditing) {
      if (profileState.businessName != null) {
        _businessNameController.text = profileState.businessName!;
      }
      if (profileState.businessNumber != null) {
        _businessNumberController.text = profileState.businessNumber!;
      }
      if (profileState.address != null) {
        _addressController.text = profileState.address!;
      }
      if (profileState.tel != null) {
        _phoneController.text = profileState.tel!;
      }
      if (profileState.website != null) {
        _websiteController.text = profileState.website!;
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });

    // Recargar los datos originales del perfil
    final profileState = ref.read(userProfileProvider);
    _updateControllersFromProfile(profileState);
  }

  Future<void> _pickImage(AppLocalizations localizations) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600, // Mayor resolución para mejor recorte de logo
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        // Recortar la imagen seleccionada como logo de empresa
        final File? croppedImage = await ImageCropService.cropBusinessLogo(
          context,
          File(image.path),
        );

        if (croppedImage != null) {
          setState(() {
            _logoFile = croppedImage;
          });
        }
        // Si el usuario cancela el recorte, no hacemos nada
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.selectImageError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveBusinessInfo(AppLocalizations localizations) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Si hay un logo seleccionado, subirlo primero
      if (_logoFile != null) {
        await ref
            .read(userProfileProvider.notifier)
            .uploadBusinessLogo(_logoFile!);
      }

      // Guardar información del negocio usando el provider
      await ref.read(userProfileProvider.notifier).updateUserProfile(
            businessName: _businessNameController.text.trim(),
            businessNumber: _businessNumberController.text.trim(),
            address: _addressController.text.trim(),
            tel: _phoneController.text.trim(),
            website: _websiteController.text.trim(),
          );

      if (mounted) {
        // Cambiar a modo visualización después de guardar
        setState(() {
          _isEditing = false;
          _logoFile = null; // Limpiar el archivo local después de subir
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.businessInfoSaved),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.errorSavingBusinessInfo),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearBusinessLogo(AppLocalizations localizations) async {
    try {
      setState(() {
        _logoFile = null;
      });

      // Si hay un logo existente en el bucket, también eliminarlo
      final profileState = ref.read(userProfileProvider);
      if (profileState.businessLogoUrl != null &&
          profileState.businessLogoUrl!.isNotEmpty) {
        await ref.read(userProfileProvider.notifier).deleteBusinessLogo();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.profileImageCleared),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorClearingLogo}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Watch the profile state to get updates
    final profileState = ref.watch(userProfileProvider);

    // Update controllers when profile data changes
    if (profileState.state == UserProfileState.loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateControllersFromProfile(profileState);
      });
    }

    // Listen to auth state changes and reload profile when user authenticates
    ref.listen(authControllerProvider, (previous, next) {
      // Permitir tanto usuarios autenticados como anónimos
      if ((next.state == AuthState.authenticated || next.state == AuthState.anonymous) && next.user != null) {
        ref.read(userProfileProvider.notifier).loadUserProfile();
      }
    });

    // Show loading indicator while profile is loading
    if (profileState.state == UserProfileState.loading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left_outline,
              size: AppSizes.responsiveSp(18),
              color: ProfileColors.business,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            localizations.businessInfo,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: ProfileColors.business,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_outline,
            size: AppSizes.responsiveSp(18),
            color: ProfileColors.business,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.businessInfo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: ProfileColors.business,
              ),
            ),
            if (_isEditing)
              Text(
                localizations.editMode,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ProfileColors.business.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.responsivePaddingSymmetric(
            horizontal: ResponsiveUtils.isMobile ? 24.0 : 48.0,
            vertical: 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo del negocio
                _buildLogoSection(theme, localizations),

                SizedBox(height: ResponsiveUtils.h(32)),

                // Información del negocio
                _buildBusinessInfoSection(theme, localizations),

                SizedBox(height: ResponsiveUtils.h(40)),

                // Botón de guardar
                _buildSaveButton(theme, localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.businessLogo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.h(16)),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Logo principal
              GestureDetector(
                onTap: _isEditing ? () => _pickImage(localizations) : null,
                child: Container(
                  width: ResponsiveUtils.w(120),
                  height: ResponsiveUtils.h(120),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _buildLogoContent(theme, localizations),
                ),
              ),

              // Icono de acción traslapado en la esquina inferior derecha
              if (_isEditing)
                Positioned(
                  bottom: ResponsiveUtils.h(-12),
                  right: ResponsiveUtils.w(-12),
                  child: _buildLogoActionIcon(theme, localizations),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoContent(ThemeData theme, AppLocalizations localizations) {
    // Si hay una imagen seleccionada localmente, mostrarla
    if (_logoFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        child: Image.file(
          _logoFile!,
          fit: BoxFit.cover,
        ),
      );
    }

    // Si hay un logo del negocio en el bucket, mostrarlo
    final profileState = ref.read(userProfileProvider);
    if (profileState.businessLogoUrl != null &&
        profileState.businessLogoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        child: Image.network(
          profileState.businessLogoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultLogoContent(theme, localizations);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            );
          },
        ),
      );
    }

    // Si no hay logo, mostrar el contenido por defecto
    return _buildDefaultLogoContent(theme, localizations);
  }

  Widget _buildDefaultLogoContent(
      ThemeData theme, AppLocalizations localizations) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.building_outline,
          size: ResponsiveUtils.sp(32),
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: ResponsiveUtils.h(8)),
        Text(
          _isEditing ? localizations.selectLogo : localizations.businessLogo,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLogoActionIcon(ThemeData theme, AppLocalizations localizations) {
    final profileState = ref.read(userProfileProvider);
    final hasExistingLogo = profileState.businessLogoUrl != null &&
        profileState.businessLogoUrl!.isNotEmpty;
    final hasLocalLogo = _logoFile != null;

    // Si hay logo local o existente, mostrar icono de limpiar
    if (hasLocalLogo || hasExistingLogo) {
      return GestureDetector(
        onTap: () => _clearBusinessLogo(localizations),
        child: Container(
          width: ResponsiveUtils.w(40),
          height: ResponsiveUtils.h(40),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.surface,
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Iconsax.trash_outline,
            size: ResponsiveUtils.sp(16),
            color: Colors.white,
          ),
        ),
      );
    }

    // Si no hay logo, mostrar icono de agregar
    return GestureDetector(
      onTap: () => _pickImage(localizations),
      child: Container(
        width: ResponsiveUtils.w(40),
        height: ResponsiveUtils.h(40),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Iconsax.add_outline,
          size: ResponsiveUtils.sp(18),
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildBusinessInfoSection(
      ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.businessInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.h(16)),

        // Nombre del negocio
        _buildTextField(
          controller: _businessNameController,
          label: localizations.businessName,
          hint: localizations.businessName,
          icon: Iconsax.building_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations.businessNameRequired;
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.h(16)),

        // Número de empresa
        _buildTextField(
          controller: _businessNumberController,
          label: localizations.businessNumber,
          hint: localizations.businessNumber,
          icon: Iconsax.document_outline,
        ),

        SizedBox(height: ResponsiveUtils.h(16)),

        // Dirección
        _buildTextField(
          controller: _addressController,
          label: localizations.address,
          hint: localizations.address,
          icon: Iconsax.location_outline,
        ),

        SizedBox(height: ResponsiveUtils.h(16)),

        // Teléfono
        _buildTextField(
          controller: _phoneController,
          label: localizations.phoneNumber,
          hint: localizations.phoneNumber,
          icon: Iconsax.call_outline,
        ),

        SizedBox(height: ResponsiveUtils.h(16)),

        // Sitio web
        _buildTextField(
          controller: _websiteController,
          label: localizations.website,
          hint: localizations.website,
          icon: Iconsax.global_outline,
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations localizations) {
    return Column(
      children: [
        // Botón principal (Editar/Guardar)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_isEditing
                    ? () => _saveBusinessInfo(localizations)
                    : _toggleEditMode),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: AppSizes.responsivePaddingSymmetric(
                horizontal: ResponsiveUtils.isMobile ? 24.0 : 48.0,
                vertical: 16.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isEditing ? localizations.save : localizations.edit,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        // Botón de cancelar (solo visible en modo edición)
        if (_isEditing) ...[
          SizedBox(height: ResponsiveUtils.h(16)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: AppSizes.responsivePaddingSymmetric(
                  horizontal: ResponsiveUtils.isMobile ? 24.0 : 48.0,
                  vertical: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                ),
              ),
              child: Text(
                localizations.cancel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      enabled: _isEditing, // Habilitar solo cuando esté editando
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: validator,
    );
  }
}
