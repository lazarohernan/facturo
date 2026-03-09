import 'package:facturo/core/widgets/app_scaffold.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/providers/client_provider.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ClientDetailView extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientDetailView({super.key, this.clientId});

  @override
  ConsumerState<ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends ConsumerState<ClientDetailView>
    with FreemiumMixin {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _secondaryEmailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _phoneController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _secondaryEmailController = TextEditingController();
    _mobileController = TextEditingController();
    _phoneController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();

    // Load prefilled client or existing client after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check for prefilled client from provider (imported from contacts)
      final prefilledClient = ref.read(prefilledClientProvider);
      
      if (prefilledClient != null) {
        debugPrint('📱 Contacto prellenado del provider: ${prefilledClient.clientName}, ${prefilledClient.clientMobile}');
        
        // Fill controllers with prefilled data
        _nameController.text = prefilledClient.clientName;
        _emailController.text = prefilledClient.clientEmail ?? '';
        _secondaryEmailController.text = prefilledClient.secondaryEmailClient ?? '';
        _mobileController.text = prefilledClient.clientMobile ?? '';
        _phoneController.text = prefilledClient.clientPhone ?? '';
        _address1Controller.text = prefilledClient.clientAddress1 ?? '';
        _address2Controller.text = prefilledClient.clientAddress2 ?? '';
        
        // Enable editing mode
        setState(() {
          _isEditing = true;
        });
        
        // Clear the provider after using it
        ref.read(prefilledClientProvider.notifier).clear();
      } else if (widget.clientId != null) {
        // Load existing client
        ref.read(clientDetailProvider.notifier).loadClient(widget.clientId!);
        ref.read(clientsProvider.notifier).loadClients();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load client data into controllers when available (for existing clients)
    if (widget.clientId != null) {
      final clientDetailState = ref.watch(clientDetailProvider);
      final client = clientDetailState.client;

      if (client != null && client.id == widget.clientId) {
        _nameController.text = client.clientName;
        _emailController.text = client.clientEmail ?? '';
        _secondaryEmailController.text = client.secondaryEmailClient ?? '';
        _mobileController.text = client.clientMobile ?? '';
        _phoneController.text = client.clientPhone ?? '';
        _address1Controller.text = client.clientAddress1 ?? '';
        _address2Controller.text = client.clientAddress2 ?? '';
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _secondaryEmailController.dispose();
    _mobileController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  // Toggle edit mode
  void _toggleEditMode() {
    final clientDetailState = ref.read(clientDetailProvider);
    final client = clientDetailState.client;

    if (!_isEditing && client != null) {
      // Al entrar en modo edición, cargar los datos del cliente en los controladores
      _nameController.text = client.clientName;
      _emailController.text = client.clientEmail ?? '';
      _secondaryEmailController.text = client.secondaryEmailClient ?? '';
      _mobileController.text = client.clientMobile ?? '';
      _phoneController.text = client.clientPhone ?? '';
      _address1Controller.text = client.clientAddress1 ?? '';
      _address2Controller.text = client.clientAddress2 ?? '';
    }

    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Si es un nuevo cliente, verificar límite freemium
      if (widget.clientId == null) {
        final canCreate = await executeIfAllowed(
          FreemiumAction.createClient,
          () async {
            await _createClient();
          },
        );

        // Si no se pudo crear por límite, executeIfAllowed ya mostró el paywall
        if (!canCreate) return;
      } else {
        // Si es edición, proceder normalmente
        await _createClient();
      }
    }
  }

  Future<void> _createClient() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final clientDetailNotifier = ref.read(clientDetailProvider.notifier);

      // Create client object from form data
      final client = Client(
        clientsId: widget
            .clientId, // null para clientes nuevos, se generará automáticamente
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        secondaryEmailClient: _secondaryEmailController.text.trim().isNotEmpty
            ? _secondaryEmailController.text.trim()
            : null,
        clientMobile: _mobileController.text.trim().isNotEmpty
            ? _mobileController.text.trim()
            : null,
        clientPhone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        clientAddress1: _address1Controller.text.trim().isNotEmpty
            ? _address1Controller.text.trim()
            : null,
        clientAddress2: _address2Controller.text.trim().isNotEmpty
            ? _address2Controller.text.trim()
            : null,
      );

      debugPrint('💾 Creando cliente: ${client.clientName}, ${client.clientMobile}');

      // Create or update client
      final result = widget.clientId == null
          ? await clientDetailNotifier.createClient(client)
          : await clientDetailNotifier.updateClient(client);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          if (result != null) {
            _isEditing = false;
          }
        });

        // Show success message
        final message = widget.clientId == null
            ? 'Client added successfully'
            : 'Client updated successfully';

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Handle navigation after successful operation
        if (result != null) {
          if (widget.clientId == null) {
            // New client created - go back after a short delay
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.pop();
              }
            });
          } else {
            // Existing client updated - go back after a short delay
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.pop();
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final clientDetailState = ref.watch(clientDetailProvider);
    final client = clientDetailState.client;
    final isLoading = clientDetailState.state == ClientState.loading;
    final hasError = clientDetailState.state == ClientState.error;

    // Determine if this is a new client or editing an existing one
    final isNewClient = widget.clientId == null;

    return AppScaffold(
      title: isNewClient
          ? localizations.addClient
          : (client?.clientName ?? localizations.clientDetails),
      actions: const [],
      body: isLoading
          ? Semantics(
              label: localizations.loadingClients,
              liveRegion: true,
              child: const Center(child: CircularProgressIndicator()),
            )
          : hasError
              ? Semantics(
                  label: '${localizations.error}: ${clientDetailState.errorMessage ?? localizations.anErrorOccurred}',
                  liveRegion: true,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          clientDetailState.errorMessage ??
                              localizations.anErrorOccurred,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: localizations.retry,
                          button: true,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.clientId != null) {
                                ref
                                    .read(clientDetailProvider.notifier)
                                    .loadClient(widget.clientId!);
                              } else {
                                context.pop();
                              }
                            },
                            child: Text(localizations.retry),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isEditing || isNewClient
                      ? _buildClientForm(localizations)
                      : _buildClientDetails(context, client, localizations),
                ),
    );
  }



  // Build client form
  Widget _buildClientForm(AppLocalizations localizations) {
    final isEditing = widget.clientId != null;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${localizations.clientName} *',
                    hintText: localizations.enterClientName,
                    prefixIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizations.pleaseEnterClientName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Contact information section
                Text(
                  localizations.contactInformation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.email,
                    hintText: localizations.enterClientEmail,
                    prefixIcon: Icon(PhosphorIcons.envelope(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      // Simple email validation
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value)) {
                        return localizations.pleaseEnterValidEmail;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Secondary Email
                TextFormField(
                  controller: _secondaryEmailController,
                  decoration: InputDecoration(
                    labelText: localizations.secondaryEmail,
                    hintText: localizations.enterSecondaryEmail,
                    prefixIcon: Icon(PhosphorIcons.at(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      // Simple email validation
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value)) {
                        return AppLocalizations.of(context).pleaseEnterValidEmail;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: localizations.mobile,
                    hintText: localizations.enterMobileNumber,
                    prefixIcon: Icon(PhosphorIcons.deviceMobile(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: localizations.phone,
                    hintText: localizations.enterPhoneNumber,
                    prefixIcon: Icon(PhosphorIcons.phone(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),

                // Address section
                Text(
                  localizations.address,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Address 1
                TextFormField(
                  controller: _address1Controller,
                  decoration: InputDecoration(
                    labelText: localizations.addressLine1,
                    hintText: localizations.enterAddressLine1,
                    prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Address 2
                TextFormField(
                  controller: _address2Controller,
                  decoration: InputDecoration(
                    labelText: localizations.addressLine2,
                    hintText: localizations.enterAddressLine2,
                    prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.regular), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing
                          ? localizations.updateClient
                          : localizations.addClient,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }


  // Build client details view
  Widget _buildClientDetails(
      BuildContext context, Client? client, AppLocalizations localizations) {
    if (client == null) {
      return Center(child: Text(localizations.clientNotFound));
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client header with avatar
        _buildClientHeader(context, theme, client),

        // Contact information section
        _buildContactSection(context, theme, client, localizations),

        // Address information section
        _buildAddressSection(context, theme, client, localizations),

        SizedBox(height: ResponsiveUtils.h(24)),

        // Edit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.h(16)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.editClient),
          ),
        ),
      ],
    );
  }

  // Build client header with avatar
  Widget _buildClientHeader(
      BuildContext context, ThemeData theme, Client client) {
    final localizations = AppLocalizations.of(context);
    return Semantics(
      label: '${localizations.client}: ${client.clientName}${client.clientEmail != null ? ', ${client.clientEmail}' : ''}',
      child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(14)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.w(16),
          vertical: ResponsiveUtils.h(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar cuadrado con bordes redondeados
            _buildSquareAvatar(theme, client),
            SizedBox(width: ResponsiveUtils.w(14)),
            // Client info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    client.clientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.sp(16),
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (client.clientEmail != null &&
                      client.clientEmail!.isNotEmpty) ...[
                    SizedBox(height: ResponsiveUtils.h(2)),
                    Text(
                      client.clientEmail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: ResponsiveUtils.sp(12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  // Método para crear un avatar cuadrado con bordes redondeados
  Widget _buildSquareAvatar(ThemeData theme, Client client) {
    final size = ResponsiveUtils.w(56); // 56x56 píxeles
    final borderRadius = ResponsiveUtils.r(12);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: ProfileColors.primaryBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Center(
            child: Text(
              client.clientName.isNotEmpty
                  ? client.clientName[0].toUpperCase()
                  : '?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build contact information section
  Widget _buildContactSection(BuildContext context, ThemeData theme,
      Client client, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.contactInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            theme,
            icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
            title: localizations.name,
            subtitle: client.clientName,
          ),
          if (client.clientEmail != null && client.clientEmail!.isNotEmpty)
            _buildMenuTile(
              context,
              theme,
              icon: PhosphorIcons.envelope(PhosphorIconsStyle.regular),
              title: localizations.email,
              subtitle: client.clientEmail!,
            ),
          if (client.secondaryEmailClient != null &&
              client.secondaryEmailClient!.isNotEmpty)
            _buildMenuTile(
              context,
              theme,
              icon: PhosphorIcons.at(PhosphorIconsStyle.regular),
              title: localizations.secondaryEmail,
              subtitle: client.secondaryEmailClient!,
            ),
          if (client.clientMobile != null && client.clientMobile!.isNotEmpty)
            _buildMenuTile(
              context,
              theme,
              icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.regular),
              title: localizations.mobile,
              subtitle: client.clientMobile!,
            ),
          if (client.clientPhone != null && client.clientPhone!.isNotEmpty)
            _buildMenuTile(
              context,
              theme,
              icon: PhosphorIcons.phone(PhosphorIconsStyle.regular),
              title: localizations.phone,
              subtitle: client.clientPhone!,
            ),
        ],
      ),
    );
  }

  // Build address information section
  Widget _buildAddressSection(BuildContext context, ThemeData theme,
      Client client, AppLocalizations localizations) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.address,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Address Line 1
          _buildMenuTile(
            context,
            theme,
            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
            title: localizations.addressLine1,
            subtitle: (client.clientAddress1 != null &&
                    client.clientAddress1!.isNotEmpty)
                ? client.clientAddress1!
                : localizations.noInformation,
          ),
          // Address Line 2
          _buildMenuTile(
            context,
            theme,
            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
            title: localizations.addressLine2,
            subtitle: (client.clientAddress2 != null &&
                    client.clientAddress2!.isNotEmpty)
                ? client.clientAddress2!
                : localizations.noInformation,
          ),
        ],
      ),
    );
  }

  // Build menu tile (same style as profile)
  Widget _buildMenuTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(20),
        vertical: ResponsiveUtils.h(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.w(24),
            color: textColor ?? theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ResponsiveUtils.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveUtils.sp(16),
                    color: textColor ?? theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ResponsiveUtils.h(2)),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: ResponsiveUtils.sp(14),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
