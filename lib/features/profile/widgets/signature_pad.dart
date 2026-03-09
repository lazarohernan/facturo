import 'dart:typed_data';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SignaturePad extends ConsumerStatefulWidget {
  final bool isEditing;
  final String? existingSignatureUrl;

  const SignaturePad({
    super.key,
    required this.isEditing,
    this.existingSignatureUrl,
  });

  @override
  ConsumerState<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends ConsumerState<SignaturePad> {
  late SignatureController _controller;

  bool _isSaving = false;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _hasSignature = widget.existingSignatureUrl != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar el controlador con colores del tema
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black, // Color negro para la firma
      exportBackgroundColor: Colors.transparent, // Fondo transparente para PNG
    );

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (!_controller.isNotEmpty) return;

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
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true, // Permitir sobrescribir archivos existentes
        ),
      );

      // Update the user profile with the signature URL
      await ref
          .read(userProfileProvider.notifier)
          .updateUserProfile(signatureUrl: signatureUrl);

      // Show success message
      if (mounted) {
        SnackbarService.showSaveSuccess(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        SnackbarService.showGenericError(
          context,
          error: '${AppLocalizations.of(context).errorSavingSignature}: $e',
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
    _controller.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).signature, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        // Signature display or pad
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.isEditing
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    width: double.infinity,
                    height: 200,
                  ),
                )
              : widget.existingSignatureUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.existingSignatureUrl!,
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
                      ),
                    )
                  : Center(child: Text(AppLocalizations.of(context).noSignatureAvailable)),
        ),

        // Signature controls (only in edit mode)
        if (widget.isEditing)
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear),
                    label: Text(AppLocalizations.of(context).clear),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 190, // Define un ancho fijo para evitar infinito
                    child: ElevatedButton.icon(
                      onPressed:
                          _hasSignature && !_isSaving ? _saveSignature : null,
                      icon: _isSaving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save, size: 16),
                      label: Text(AppLocalizations.of(context).saveSignature),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
