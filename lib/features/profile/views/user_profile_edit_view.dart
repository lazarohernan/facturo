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

class UserProfileEditView extends ConsumerStatefulWidget {
  const UserProfileEditView({super.key});

  @override
  ConsumerState<UserProfileEditView> createState() =>
      _UserProfileEditViewState();
}

class _UserProfileEditViewState extends ConsumerState<UserProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _profileImageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Load user data when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateControllersFromProfile(UserProfile profileState) {
    // Solo actualizar controladores si no estamos editando
    if (!_isEditing) {
      if (profileState.fullName != null) {
        _fullNameController.text = profileState.fullName!;
      }
      if (profileState.email != null) {
        _emailController.text = profileState.email!;
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values
        final profileState = ref.read(userProfileProvider);
        _updateControllersFromProfile(profileState);
      }
    });
  }

  Future<void> _pickProfileImage(AppLocalizations localizations) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Mayor resolución para mejor recorte
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        // Recortar la imagen seleccionada
        final File? croppedImage = await ImageCropService.cropProfileImage(
          context,
          File(image.path),
        );

        if (croppedImage != null) {
          setState(() {
            _profileImageFile = croppedImage;
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

  Future<void> _saveUserProfile(AppLocalizations localizations) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Si hay una imagen seleccionada, subirla primero
      if (_profileImageFile != null) {
        await ref
            .read(userProfileProvider.notifier)
            .uploadProfileImage(_profileImageFile!);
      }

      // Guardar información personal del usuario usando el provider
      await ref.read(userProfileProvider.notifier).updateUserProfile(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
          );

      if (mounted) {
        // Cambiar a modo visualización después de guardar
        setState(() {
          _isEditing = false;
          _profileImageFile = null; // Limpiar el archivo después de subir
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorUpdating}: $e'),
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
            localizations.editProfile,
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
              localizations.editProfile,
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
                // Foto de perfil
                _buildProfileImageSection(theme, localizations),

                SizedBox(height: ResponsiveUtils.h(32)),

                // Información personal
                _buildPersonalInfoSection(theme, localizations),

                SizedBox(height: ResponsiveUtils.h(40)),

                // Botones de acción
                _buildSaveButton(theme, localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(
      ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.profilePhoto,
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
              // Avatar principal
              GestureDetector(
                onTap:
                    _isEditing ? () => _pickProfileImage(localizations) : null,
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
                  child: _buildProfileImageContent(theme, localizations),
                ),
              ),

              // Icono de acción traslapado en la esquina inferior derecha, estilo Facebook
              if (_isEditing)
                Positioned(
                  bottom: ResponsiveUtils.h(-12),
                  right: ResponsiveUtils.w(-12),
                  child: _buildActionIcon(theme, localizations),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageContent(
      ThemeData theme, AppLocalizations localizations) {
    // Si hay una imagen seleccionada localmente, mostrarla
    if (_profileImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        child: Image.file(
          _profileImageFile!,
          fit: BoxFit.cover,
        ),
      );
    }

    // Si hay una imagen del perfil en el bucket, mostrarla
    final profileState = ref.read(userProfileProvider);
    if (profileState.profileImg != null &&
        profileState.profileImg!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        child: Image.network(
          profileState.profileImg!,
          width: ResponsiveUtils.w(120),
          height: ResponsiveUtils.h(120),
          fit: BoxFit.cover,
          cacheWidth: 240,
          cacheHeight: 240,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            );
          },
          errorBuilder: (context, url, error) {
            return _buildDefaultProfileContent(theme, localizations);
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
        ),
      );
    }

    // Si no hay imagen, mostrar el contenido por defecto
    return _buildDefaultProfileContent(theme, localizations);
  }

  Widget _buildDefaultProfileContent(
      ThemeData theme, AppLocalizations localizations) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.camera_outline,
          size: ResponsiveUtils.sp(32),
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: ResponsiveUtils.h(8)),
        Text(
          _isEditing
              ? localizations.selectProfilePhoto
              : localizations.profilePhoto,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionIcon(ThemeData theme, AppLocalizations localizations) {
    final profileState = ref.read(userProfileProvider);
    final hasExistingImage =
        profileState.profileImg != null && profileState.profileImg!.isNotEmpty;
    final hasLocalImage = _profileImageFile != null;

    // Si hay imagen local o existente, mostrar icono de limpiar
    if (hasLocalImage || hasExistingImage) {
      return GestureDetector(
        onTap: () => _clearProfileImage(localizations),
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

    // Si no hay imagen, mostrar icono de agregar
    return GestureDetector(
      onTap: () => _pickProfileImage(localizations),
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

  Future<void> _clearProfileImage(AppLocalizations localizations) async {
    try {
      setState(() {
        _profileImageFile = null;
      });

      // Si hay una imagen existente en el bucket, también la eliminamos
      final profileState = ref.read(userProfileProvider);
      if (profileState.profileImg != null &&
          profileState.profileImg!.isNotEmpty) {
        await ref.read(userProfileProvider.notifier).deleteProfileImage();
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
            content: Text('${AppLocalizations.of(context).errorClearingImage}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildPersonalInfoSection(
      ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.personalInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.h(16)),

        // Nombre completo
        _buildTextField(
          controller: _fullNameController,
          label: localizations.fullName,
          hint: localizations.fullName,
          icon: Iconsax.user_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations.fullNameRequired;
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.h(16)),

        // Email
        _buildTextField(
          controller: _emailController,
          label: localizations.email,
          hint: localizations.email,
          icon: Iconsax.sms_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations.emailRequired;
            }
            if (!value.contains('@')) {
              return localizations.invalidEmail;
            }
            return null;
          },
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
                    ? () => _saveUserProfile(localizations)
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
              onPressed: _toggleEditMode,
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
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      enabled: enabled && _isEditing,
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
