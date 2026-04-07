import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shows a minimal bottom sheet to quickly add a client.
/// Returns the newly created client as a [Map] matching the format used
/// in invoice/estimate forms, or null if the user cancelled.
Future<Map<String, dynamic>?> showAddClientSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _AddClientSheet(),
  );
}

class _AddClientSheet extends ConsumerStatefulWidget {
  const _AddClientSheet();

  @override
  ConsumerState<_AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends ConsumerState<_AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _secondaryEmailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _secondaryEmailController.dispose();
    _mobileController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final service = ref.read(clientServiceProvider);
      final client = Client(
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        secondaryEmailClient: _secondaryEmailController.text.trim().isEmpty ? null : _secondaryEmailController.text.trim(),
        clientMobile: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        clientPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        clientAddress1: _address1Controller.text.trim().isEmpty ? null : _address1Controller.text.trim(),
        clientAddress2: _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
      );

      final created = await service.createClient(client, userId);

      if (mounted) {
        Navigator.pop(context, {
          'clients_id': created.clientsId,
          'client_name': created.clientName,
          'client_email': created.clientEmail,
          'secondary_email_client': created.secondaryEmailClient,
          'client_mobile': created.clientMobile,
          'client_phone': created.clientPhone,
          'client_address_1': created.clientAddress1,
          'client_address_2': created.clientAddress2,
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                l10n.addClient,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Nombre *
              _field(
                controller: _nameController,
                label: l10n.clientName,
                hint: l10n.enterClientName,
                icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.pleaseEnterClientName : null,
              ),
              const SizedBox(height: 14),

              // Email
              _field(
                controller: _emailController,
                label: l10n.clientEmail,
                hint: l10n.enterClientEmail,
                icon: PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Email secundario
              _field(
                controller: _secondaryEmailController,
                label: l10n.secondaryEmail,
                hint: l10n.enterSecondaryEmail,
                icon: PhosphorIcons.at(PhosphorIconsStyle.regular),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Móvil
              _field(
                controller: _mobileController,
                label: l10n.mobile,
                hint: l10n.enterMobileNumber,
                icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.regular),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Teléfono fijo
              _field(
                controller: _phoneController,
                label: l10n.phone,
                hint: l10n.enterPhoneNumber,
                icon: PhosphorIcons.phone(PhosphorIconsStyle.regular),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Dirección 1
              _field(
                controller: _address1Controller,
                label: l10n.addressLine1,
                hint: l10n.enterAddressLine1,
                icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),

              // Dirección 2
              _field(
                controller: _address2Controller,
                label: l10n.addressLine2,
                hint: l10n.enterAddressLine2,
                icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
