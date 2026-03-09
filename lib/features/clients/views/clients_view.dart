import 'package:facturo/common/widgets/empty_state_widget.dart';
import 'package:facturo/common/ui/ui.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/providers/client_provider.dart';
import 'package:facturo/features/clients/widgets/client_card.dart';
import 'package:facturo/features/clients/services/contacts_service.dart' as contacts;
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ClientsView extends ConsumerStatefulWidget {
  static const String routeName = '/clients';

  const ClientsView({super.key});

  @override
  ConsumerState<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends ConsumerState<ClientsView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _loadClients();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _loadClients();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Usamos el provider para cargar los clientes
      await ref.read(clientsProvider.notifier).loadClients();
      
      // También cargar facturas para los resúmenes si no están cargadas
      // Esto es necesario porque eliminamos la carga automática del provider derivado
      ref.read(invoiceListProvider.notifier).loadInvoices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).errorLoadingClients}: $e')),
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

  void _showDeleteConfirmation(BuildContext context, Client client) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteClient),
        content: Text(localizations.deleteClientConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClient(client);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(Client client) async {
    try {
      await ref.read(clientsProvider.notifier).deleteClient(client.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).clientDeletedSuccess),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context).errorDeletingClient}: $e'),
          ),
        );
      }
    }
  }

  void _navigateToClientDetail([Client? client]) {
    if (client != null) {
      context.push('/clients/${client.clientsId}');
    } else {
      context.push('/clients/new');
    }
  }

  Future<void> _importFromContacts() async {
    try {
      // Open native contact picker (no permissions required)
      final client = await contacts.ContactsImportService.pickContactAsClient();

      debugPrint('🔄 Cliente recibido en vista: ${client?.clientName}, ${client?.clientMobile}');

      if (client == null) {
        // User cancelled
        debugPrint('❌ No se seleccionó contacto');
        return;
      }

      // Store client in provider for ClientDetailView to pick up
      ref.read(prefilledClientProvider.notifier).setClient(client);
      
      // Navigate to client detail view with pre-filled data
      // User can review and edit before saving
      if (!mounted) return;
      
      debugPrint('🚀 Navegando a /clients/new con cliente: ${client.clientName}');
      context.push('/clients/new');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorImportingContact}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Client> _getFilteredClients(List<Client> clients) {
    if (_searchQuery.isEmpty) return clients;

    return ref.read(clientsProvider.notifier).searchClients(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final clients = ref.watch(clientsProvider);
    final filteredClients = _getFilteredClients(clients);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.clients),
        actions: [
          IconButton(
            onPressed: _importFromContacts,
            icon: Icon(PhosphorIcons.addressBook(PhosphorIconsStyle.regular)),
            tooltip: AppLocalizations.of(context).importFromContacts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.w(16),
              vertical: ResponsiveUtils.h(8),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchClients,
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.w(16),
                  vertical: ResponsiveUtils.h(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.regular), size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Clients list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : clients.isEmpty
                    ? EmptyStateWidget(
                        icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
                        title: localizations.noClientsYet,
                        message: localizations.addYourFirstClient,
                      )
                    : filteredClients.isEmpty
                        ? Center(
                            child: EmptyStateWidget(
                              icon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                              title: localizations.noClientsFound,
                              message: localizations.tryAnotherSearch,
                              buttonText: localizations.refresh,
                              onAction: _loadClients,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadClients,
                            child: ListView.builder(
                              padding: EdgeInsets.all(ResponsiveUtils.w(16)),
                              itemCount: filteredClients.length,
                              itemBuilder: (context, index) {
                                final client = filteredClients[index];
                                return ClientCard(
                                  client: client,
                                  onEdit: () => _navigateToClientDetail(client),
                                  onDelete: () =>
                                      _showDeleteConfirmation(context, client),
                                  onTap: () => _navigateToClientDetail(client),
                                );
                              },
                            ),
                          ),
          ),

          // Bottom add button
          _buildBottomAddButton(context, theme, localizations),
        ],
      ),
    );
  }

  Widget _buildBottomAddButton(
      BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(20),
        vertical: ResponsiveUtils.h(16),
      ),
      child: SafeArea(
        child: AddButton(
          text: localizations.newClient,
          onPressed: () => _navigateToClientDetail(),
        ),
      ),
    );
  }
}
