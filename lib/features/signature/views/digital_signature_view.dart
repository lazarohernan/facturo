import 'dart:typed_data';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/core/widgets/app_scaffold.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DigitalSignatureView extends ConsumerStatefulWidget {
  const DigitalSignatureView({super.key});

  @override
  ConsumerState<DigitalSignatureView> createState() => _DigitalSignatureViewState();
}

class _DigitalSignatureViewState extends ConsumerState<DigitalSignatureView> {
  late SignatureController _controller;

  bool _isSaving = false;
  bool _hasSignature = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador sin depender de Theme en initState
    _controller = SignatureController(
      penStrokeWidth: AppSizes.responsiveW(3),
      penColor: Colors.black, // Se actualizará en didChangeDependencies
      exportBackgroundColor: Colors.white, // Se actualizará en didChangeDependencies
    );
    _initializeSignature();

    // Listen for changes in the signature
    _controller.onDrawStart = () {
      if (!_hasSignature) {
        setState(() {
          _hasSignature = true;
        });
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-crear el controlador con colores del tema una vez disponibles
    final old = _controller;
    final wasNotEmpty = old.isNotEmpty;
    final theme = Theme.of(context);
    
    // Usar colores adaptativos según el tema
    _controller = SignatureController(
      penStrokeWidth: AppSizes.responsiveW(3),
      penColor: theme.colorScheme.onSurface, // Se adapta al tema
      exportBackgroundColor: theme.colorScheme.surface, // Se adapta al tema
    );
    _controller.onDrawStart = () {
      if (!_hasSignature) {
        setState(() {
          _hasSignature = true;
        });
      }
    };
    old.dispose();
    // Si había trazos previos se limpian al cambiar tema; es aceptable para evitar errores
    if (wasNotEmpty) {
      setState(() {});
    }
  }

  void _initializeSignature() async {
    final profileState = ref.read(userProfileProvider);
    setState(() {
      _hasSignature = profileState.signatureUrl != null;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    final localizations = AppLocalizations.of(context);
    
    if (!_controller.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseSignFirst,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Export the signature as PNG
      final Uint8List? signatureData = await _controller.toPngBytes();
      if (signatureData == null) {
        throw Exception('Failed to export signature');
      }

      // Get the current user ID
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Generate a unique filename
      final fileName = 'signature_${userId}_${const Uuid().v4()}.png';
      final filePath = 'signatures/$fileName';

      // Upload to Supabase and get stored path
      final storageService = StorageService(supabase);
      final signatureUrl = await storageService.uploadBinary(
        filePath: filePath,
        data: signatureData,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Update the user profile with the signature URL
      await ref
          .read(userProfileProvider.notifier)
          .updateUserProfile(signatureUrl: signatureUrl);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.signatureSaved,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSavingSignature}: $e',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearSignature() {
    final localizations = AppLocalizations.of(context);
    
    _controller.clear();
    setState(() {
      _hasSignature = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.signatureCleared,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final profileState = ref.watch(userProfileProvider);

    // Ajustar colores del controlador según el tema (modo claro/oscuro)
    // Nota: los colores del controller se establecen en initState usando el tema actual

    if (_isLoading) {
      return AppScaffold(
        title: localizations.digitalSignatureScreen,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: localizations.digitalSignatureScreen,
      body: SingleChildScrollView(
        padding: AppSizes.responsivePaddingAll(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Card(
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusL),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  width: AppSizes.cardBorderWidth,
                ),
              ),
              child: Padding(
                padding: AppSizes.responsivePaddingAll(AppSizes.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppSizes.responsivePaddingAll(AppSizes.s + 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusS + 4),
                          ),
                          child: Icon(
                            Icons.draw,
                            size: AppSizes.responsiveW(AppSizes.iconSizeM),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: AppSizes.responsiveW(AppSizes.m)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.digitalSignatureScreen,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.responsiveSp(AppSizes.fontSizeXxl),
                                ),
                              ),
                              SizedBox(height: AppSizes.responsiveH(4)),
                              Text(
                                localizations.signatureInstructions,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizes.responsiveH(AppSizes.l)),

            // Current signature display (if exists)
            if (profileState.signatureUrl != null) ...[
              Text(
                AppLocalizations.of(context).currentSignature,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.responsiveSp(AppSizes.fontSizeXl),
                ),
              ),
              SizedBox(height: AppSizes.responsiveH(AppSizes.s + 4)),
              Card(
                elevation: AppSizes.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusM),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    width: AppSizes.cardBorderWidth,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: AppSizes.responsiveH(150),
                  padding: AppSizes.responsivePaddingAll(AppSizes.m),
                  child: ClipRRect(
                    borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusS),
                    child: Image.network(
                      profileState.signatureUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.error_outline, 
                            size: AppSizes.responsiveW(AppSizes.iconSizeXl + 8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.responsiveH(AppSizes.l)),
            ],

            // Signature pad section
            Text(
              profileState.signatureUrl != null 
                  ? 'Update Signature' 
                  : localizations.addYourSignature,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.responsiveSp(AppSizes.fontSizeXl),
              ),
            ),
            SizedBox(height: AppSizes.responsiveH(AppSizes.s + 4)),

            // Signature pad
            Card(
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusM),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  width: AppSizes.cardBorderWidth,
                ),
              ),
              child: Container(
                padding: AppSizes.responsivePaddingAll(AppSizes.m),
                child: Column(
                  children: [
                    // Instructions
                    Container(
                      width: double.infinity,
                      padding: AppSizes.responsivePaddingAll(AppSizes.s + 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusS),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: AppSizes.responsiveW(AppSizes.iconSizeS + 4),
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: AppSizes.responsiveW(AppSizes.s)),
                          Expanded(
                            child: Text(
                              localizations.signHere,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.responsiveH(AppSizes.m)),

                    // Signature area
                    Container(
                      height: ResponsiveUtils.isMobile 
                          ? AppSizes.responsiveH(200) 
                          : AppSizes.responsiveH(250),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: AppSizes.responsiveW(2),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusM),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: AppSizes.responsiveRadius(AppSizes.borderRadiusS + 2),
                        child: Signature(
                          controller: _controller,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          width: double.infinity,
                          height: ResponsiveUtils.isMobile 
                              ? AppSizes.responsiveH(200) 
                              : AppSizes.responsiveH(250),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSizes.responsiveH(AppSizes.l)),

                    // Action buttons
                    ResponsiveUtils.isMobile
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: AppSizes.responsiveH(AppSizes.buttonHeight),
                                child: OutlinedButton.icon(
                                  onPressed: _clearSignature,
                                  icon: Icon(
                                    Icons.cleaning_services_outlined,
                                    size: AppSizes.responsiveW(AppSizes.iconSizeS + 2),
                                  ),
                                  label: Text(
                                    localizations.clearSignature,
                                    style: TextStyle(
                                      fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: AppSizes.responsivePaddingSymmetric(vertical: AppSizes.m),
                                    foregroundColor: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                    backgroundColor: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    side: BorderSide(color: theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSizes.responsiveH(AppSizes.s + 4)),
                              SizedBox(
                                width: double.infinity,
                                height: AppSizes.responsiveH(AppSizes.buttonHeight),
                                child: ElevatedButton.icon(
                                  onPressed: _hasSignature && !_isSaving ? _saveSignature : null,
                                  icon: _isSaving
                                      ? SizedBox(
                                          width: AppSizes.responsiveW(18),
                                          height: AppSizes.responsiveH(18),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        )
                                      : Icon(
                                          Icons.save,
                                          size: AppSizes.responsiveW(AppSizes.iconSizeS + 2),
                                        ),
                                  label: Text(
                                    localizations.saveSignature,
                                    style: TextStyle(
                                      fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: AppSizes.responsivePaddingSymmetric(vertical: AppSizes.m),
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: AppSizes.responsiveH(AppSizes.buttonHeight),
                                  child: OutlinedButton.icon(
                                    onPressed: _clearSignature,
                                    icon: Icon(
                                      Icons.cleaning_services_outlined,
                                      size: AppSizes.responsiveW(AppSizes.iconSizeS + 2),
                                    ),
                                    label: Text(
                                      localizations.clearSignature,
                                      style: TextStyle(
                                        fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: AppSizes.responsivePaddingSymmetric(vertical: AppSizes.m),
                                      foregroundColor: theme.brightness == Brightness.dark
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.primary,
                                      backgroundColor: theme.brightness == Brightness.dark
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      side: BorderSide(color: theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.responsiveW(AppSizes.m)),
                              Expanded(
                                child: SizedBox(
                                  height: AppSizes.responsiveH(AppSizes.buttonHeight),
                                  child: ElevatedButton.icon(
                                    onPressed: _hasSignature && !_isSaving ? _saveSignature : null,
                                    icon: _isSaving
                                        ? SizedBox(
                                            width: AppSizes.responsiveW(18),
                                            height: AppSizes.responsiveH(18),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                          )
                                        : Icon(
                                            Icons.save,
                                            size: AppSizes.responsiveW(AppSizes.iconSizeS + 2),
                                          ),
                                    label: Text(
                                      localizations.saveSignature,
                                      style: TextStyle(
                                        fontSize: AppSizes.responsiveSp(AppSizes.fontSizeM),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: AppSizes.responsivePaddingSymmetric(vertical: AppSizes.m),
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            
          ],
        ),
      ),
    );
  }
}
