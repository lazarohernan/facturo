import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/core/services/support_service.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:facturo/core/services/snackbar_service.dart';

class SupportModal extends ConsumerStatefulWidget {
  const SupportModal({super.key});

  @override
  ConsumerState<SupportModal> createState() => _SupportModalState();
}

class _SupportModalState extends ConsumerState<SupportModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authControllerProvider).user;
      final userEmail = user?.email ?? AppLocalizations.of(context).notAvailable;

      await SupportService.sendSupportRequest(
        problemTitle: _titleController.text.trim(),
        problemDescription: _descriptionController.text.trim(),
        userEmail: userEmail,
        platform: Theme.of(context).platform.name,
        appVersion: AppConstants.appVersion,
      );

      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        SnackbarService.showSuccess(
          context,
          message: AppLocalizations.of(context).supportRequestSent,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          message: AppLocalizations.of(context).supportRequestError,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
      ),
      child: Container(
        width: ResponsiveUtils.isMobile
            ? ResponsiveUtils.screenWidth * 0.9
            : ResponsiveUtils.w(400),
        padding: EdgeInsets.all(ResponsiveUtils.w(24)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del modal
              Row(
                children: [
                  Icon(
                    Iconsax.support_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: ResponsiveUtils.sp(24),
                  ),
                  SizedBox(width: ResponsiveUtils.w(12)),
                  Expanded(
                    child: Text(
                      localizations.contactSupport,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.sp(20),
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle_outline,
                      size: ResponsiveUtils.sp(20),
                    ),
                    tooltip: 'Close',
                    // Minimum 44x44 touch target per Apple HIG
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.h(24)),

              // Campo del título del problema
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: localizations.problemTitle,
                  hintText: localizations.problemTitleHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
                  ),
                  prefixIcon: Icon(
                    Iconsax.edit_outline,
                    size: ResponsiveUtils.sp(20),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.titleRequired;
                  }
                  if (value.trim().length < 5) {
                    return localizations.titleMinLength;
                  }
                  return null;
                },
                maxLength: 100,
              ),

              SizedBox(height: ResponsiveUtils.h(16)),

              // Campo de descripción del problema
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: localizations.problemDescription,
                  hintText: localizations.problemDescriptionHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
                  ),
                  prefixIcon: Icon(
                    Iconsax.document_text_outline,
                    size: ResponsiveUtils.sp(20),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.descriptionRequired;
                  }
                  if (value.trim().length < 20) {
                    return localizations.descriptionMinLength;
                  }
                  return null;
                },
                maxLines: 4,
                maxLength: 500,
              ),

              SizedBox(height: ResponsiveUtils.h(24)),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.h(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ResponsiveUtils.r(8)),
                        ),
                      ),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.w(12)),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submitSupportRequest,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.h(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ResponsiveUtils.r(8)),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: ResponsiveUtils.h(20),
                              width: ResponsiveUtils.w(20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              localizations.send,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(16),
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
    );
  }
}
