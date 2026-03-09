import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../providers/user_profile_provider.dart';

/// Paso 1: Información básica del usuario (nombre completo, email)
class ProfileOnboardingStep1 extends ConsumerStatefulWidget {
  const ProfileOnboardingStep1({super.key});

  @override
  ConsumerState<ProfileOnboardingStep1> createState() => _ProfileOnboardingStep1State();
}

class _ProfileOnboardingStep1State extends ConsumerState<ProfileOnboardingStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    // Cargar datos del perfil desde Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Primero cargar los datos desde la base de datos
      await ref.read(userProfileProvider.notifier).loadUserProfile();
      
      // Luego cargar los datos en el formulario
      final profile = ref.read(userProfileProvider);
      if (profile.fullName != null && profile.fullName!.isNotEmpty) {
        _nameController.text = profile.fullName!;
      }
      if (profile.email != null && profile.email!.isNotEmpty) {
        _emailController.text = profile.email!;
      }
      // Cargar imagen de perfil si existe (descargar desde URL)
      if (profile.profileImg != null && profile.profileImg!.isNotEmpty) {
        _loadProfileImage(profile.profileImg!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Obtener directorio temporal
        final tempDir = await getTemporaryDirectory();
        final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageFile = File('${tempDir.path}/$fileName');
        
        // Guardar imagen descargada
        await imageFile.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            _profileImage = imageFile;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      // No mostrar error al usuario, solo log
    }
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
          _profileImage = File(image.path);
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
      // Guardar datos temporalmente y navegar al paso 2
      context.push('/profile-onboarding/step2', extra: {
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImage': _profileImage?.path,
      });
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
                '1/3',
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
                  localizations.personalInformation,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(8)),
                
                // Subtítulo
                Text(
                  localizations.letsStartWithBasicInfo,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(32)),
                
                // Selector de imagen de perfil
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: ResponsiveUtils.w(120),
                      height: ResponsiveUtils.h(120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _profileImage != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: _profileImage != null ? 2 : 1,
                        ),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                                width: ResponsiveUtils.w(120),
                                height: ResponsiveUtils.h(120),
                              ),
                            )
                          : Icon(
                              Iconsax.camera_outline,
                              size: ResponsiveUtils.sp(40),
                              color: theme.colorScheme.primary,
                            ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(8)),
                
                Center(
                  child: Text(
                    localizations.tapToAddProfilePhoto,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.h(32)),
                
                // Campo de nombre completo
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.fullName,
                    hintText: localizations.exampleName,
                    prefixIcon: const Icon(Iconsax.user_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterFullName;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: ResponsiveUtils.h(20)),
                
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.email,
                    hintText: localizations.exampleEmail,
                    prefixIcon: const Icon(Iconsax.sms_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context).pleaseEnterValidEmailAddress;
                    }
                    return null;
                  },
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
