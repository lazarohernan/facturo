import 'package:facturo/common/widgets/empty_state_widget.dart';
import 'package:facturo/common/widgets/error_state_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/clients/providers/client_provider.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/views/invoice_detail_view.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:facturo/core/services/snackbar_service.dart';

class InvoiceListView extends ConsumerStatefulWidget {
  static const String routeName = 'invoices';
  static const String routePath = '/invoices';

  const InvoiceListView({super.key});

  @override
  ConsumerState<InvoiceListView> createState() => _InvoiceListViewState();
}

class _InvoiceListViewState extends ConsumerState<InvoiceListView> {
  final TextEditingController _searchController = TextEditingController();
  static const String _kAllYears = 'ALL';
  String _selectedYear = _kAllYears; // Mostrar todas las facturas por defecto

  // Currency format from settings
  NumberFormat get currencyFormat {
    final settings = ref.watch(appSettingsProvider);
    final currency = CurrencyService.getCurrency(settings.currency) ??
        CurrencyService.defaultCurrency;
    return NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );
  }

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid conflicting with GoRouter's Navigator
    // rebuild cycle (known _elements.contains(element) assertion bug).
    Future.microtask(() {
      if (!mounted) return;
      ref.read(invoiceListProvider.notifier).loadInvoices();
      ref.read(clientListProvider.notifier).loadClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle search
  void _handleSearch(String query) {
    ref.read(invoiceListProvider.notifier).searchInvoices(query);
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Invoice invoice,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteInvoice),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '¿Estás seguro de que quieres eliminar la factura ${invoice.documentNumber ?? ""}?',
                ),
                const SizedBox(height: 10),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Eliminar',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteInvoice(invoice.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete invoice
  void _deleteInvoice(String invoiceId) {
    ref.read(invoiceListProvider.notifier).deleteInvoice(invoiceId);
    SnackbarService.showDeleteSuccess(context);
  }

  // Navigate to invoice detail view
  void _navigateToInvoiceDetail({Invoice? invoice}) async {
    final res = await context.push(InvoiceDetailView.routePath, extra: invoice);
    if (!mounted) return;
    if (res == true) {
      ref.read(invoiceListProvider.notifier).loadInvoices();
      if (!mounted) return;
      SnackbarService.hideAllSnackBars(context);
      SnackbarService.showSuccess(
        context,
        message: 'Invoices loaded successfully',
      );
    }
  }

  // Toggle invoice paid status
  void _togglePaidStatus(Invoice invoice) {
    ref
        .read(invoiceListProvider.notifier)
        .updateInvoicePaidStatus(invoice.id, !invoice.paid);
    SnackbarService.hideAllSnackBars(context);
    SnackbarService.showSuccess(
      context,
      message: invoice.paid 
          ? AppLocalizations.of(context).invoiceMarkedAsUnpaid
          : AppLocalizations.of(context).invoiceMarkedAsPaid,
    );
  }

  // Get available years from invoices
  List<String> _getAvailableYears(List<Invoice> invoices) {
    final years = <String>{_kAllYears}; // Agregar opción "Todos" al inicio
    for (final invoice in invoices) {
      if (invoice.documentDate != null) {
        years.add(invoice.documentDate!.year.toString());
      }
    }
    final sortedYears = years.toList()..sort((a, b) {
      // "Todos" siempre primero, luego los años en orden descendente
      if (a == _kAllYears) return -1;
      if (b == _kAllYears) return 1;
      return b.compareTo(a); // Años más grandes primero
    });
    return sortedYears;
  }

  // Filter invoices by selected year
  List<Invoice> _filterInvoicesByYear(List<Invoice> invoices) {
    if (_selectedYear.isEmpty || _selectedYear == _kAllYears) {
      // Mostrar todas las facturas, ordenadas por fecha descendente
      return invoices..sort((a, b) {
        // Sort by date descending (most recent first)
        if (a.documentDate == null) return 1;
        if (b.documentDate == null) return -1;
        return b.documentDate!.compareTo(a.documentDate!);
      });
    }
    
    return invoices.where((invoice) {
      if (invoice.documentDate == null) return false;
      return invoice.documentDate!.year.toString() == _selectedYear;
    }).toList()..sort((a, b) {
      // Sort by date descending (most recent first)
      if (a.documentDate == null) return 1;
      if (b.documentDate == null) return -1;
      return b.documentDate!.compareTo(a.documentDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceListData = ref.watch(invoiceListProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: localizations.searchInvoices,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _handleSearch,
          ),
        ),

        // Year selector - only show when not searching and has invoices
        if (invoiceListData.state == InvoiceState.loaded &&
            invoiceListData.invoices.isNotEmpty &&
            (invoiceListData.searchQuery == null || invoiceListData.searchQuery!.isEmpty))
          _buildYearSelector(invoiceListData.invoices, theme, localizations),

        // Invoice list
        Expanded(
          child: _buildInvoiceList(invoiceListData, theme, localizations),
        ),
      ],
    );
  }

  // Build year selector widget
  Widget _buildYearSelector(List<Invoice> invoices, ThemeData theme, AppLocalizations localizations) {
    final availableYears = _getAvailableYears(invoices);
    
    // If no years available, don't show the selector
    if (availableYears.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // If selected year is not in available years, select the first one
    if (!availableYears.contains(_selectedYear)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedYear = availableYears.first;
          });
        }
      });
      // Return early to avoid calculating with wrong year
      return const SizedBox.shrink();
    }
    
    final filteredInvoices = _filterInvoicesByYear(invoices);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Year dropdown expandido a lo largo
          Expanded(
            child: InkWell(
              onTap: () => _showYearPicker(availableYears, theme, localizations),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedYear == _kAllYears ? localizations.allYears : _selectedYear,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Counter integrado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredInvoices.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show year picker as bottom sheet
  void _showYearPicker(List<String> availableYears, ThemeData theme, AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.year,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableYears.map((year) {
              final yearCount = _filterInvoicesByYear(_getInvoicesForYear(year));
              return ListTile(
                title: Text(year == _kAllYears ? localizations.allYears : year),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${yearCount.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                selected: year == _selectedYear,
                onTap: () {
                  setState(() {
                    _selectedYear = year;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method to get invoices for a specific year
  List<Invoice> _getInvoicesForYear(String year) {
    final invoiceListData = ref.watch(invoiceListProvider);
    if (invoiceListData.state != InvoiceState.loaded) return [];
    
    if (year == _kAllYears) {
      return invoiceListData.invoices;
    }
    
    return invoiceListData.invoices.where((invoice) {
      if (invoice.documentDate == null) return false;
      return invoice.documentDate!.year.toString() == year;
    }).toList();
  }

  Widget _buildInvoiceList(InvoiceListData data, ThemeData theme, AppLocalizations localizations) {
    switch (data.state) {
      case InvoiceState.loading:
        return LoadingWidget(message: localizations.loadingInvoices);

      case InvoiceState.error:
        return ErrorStateWidget(
          message: data.errorMessage ?? localizations.anErrorOccurred,
          onRetry: () => ref.read(invoiceListProvider.notifier).loadInvoices(),
        );

      case InvoiceState.loaded:
        if (data.invoices.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
            title: localizations.noInvoicesFound,
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.noInvoicesMatchSearch
                : localizations.addYourFirstInvoice,
          );
        }

        // If there's a search query, don't filter by year
        List<Invoice> displayInvoices;
        if (data.searchQuery != null && data.searchQuery!.isNotEmpty) {
          displayInvoices = data.invoices..sort((a, b) {
            // Sort by date descending (most recent first)
            if (a.documentDate == null) return 1;
            if (b.documentDate == null) return -1;
            return b.documentDate!.compareTo(a.documentDate!);
          });
        } else {
          // Filter invoices by selected year only when not searching
          displayInvoices = _filterInvoicesByYear(data.invoices);
        }
        
        if (displayInvoices.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
            title: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.noInvoicesMatchSearch
                : '${localizations.noInvoicesFound} $_selectedYear',
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.tryAnotherSearch
                : localizations.tryAnotherSearch,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(invoiceListProvider.notifier).loadInvoices(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16), // Reduced padding since FAB is gone
            itemCount: displayInvoices.length,
            itemBuilder: (context, index) {
              final invoice = displayInvoices[index];
              return _buildInvoiceCard(invoice, theme, localizations);
            },
          ),
        );

      case InvoiceState.initial:
        return LoadingWidget(message: localizations.loadingInvoices);
    }
  }

  // Build invoice card to match the design from the image
  Widget _buildInvoiceCard(Invoice invoice, ThemeData theme, AppLocalizations localizations) {
    final isPaid = invoice.paid;
    final statusColor = isPaid ? Colors.green : Colors.orange;
    final statusText = isPaid ? localizations.paid : localizations.unpaid;
    final clientName = _getClientName(invoice.clientId, localizations);
    final amount = currencyFormat.format(_calculateTotal(invoice));

    return Semantics(
      label: '${localizations.invoice} ${invoice.documentNumber ?? "0000"}, $clientName, $amount, $statusText',
      hint: 'Double tap to view details',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToInvoiceDetail(invoice: invoice),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main row with icon, details and amount
                Row(
                  children: [
                    // Document icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        PhosphorIcons.fileText(PhosphorIconsStyle.regular),
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Invoice details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice number
                          Text(
                            invoice.documentNumber ?? '0000',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          
                          // Status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  statusText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Client name
                          ExcludeSemantics(
                            child: Text(
                              clientName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Amount and date column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Amount
                        Text(
                          currencyFormat.format(_calculateTotal(invoice)),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Text(
                          invoice.documentDate != null
                              ? DateFormat('MMM d, y', Localizations.localeOf(context).languageCode).format(invoice.documentDate!)
                              : localizations.noDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                
                // Action buttons row
                Row(
                  children: [
                    // Payment status button (always show)
                    Expanded(
                      child: _buildActionButton(
                        isPaid ? localizations.markAsUnpaid : localizations.markAsPaid,
                        isPaid ? Colors.orange : Colors.green,
                        () => _togglePaidStatus(invoice),
                        theme,
                        icon: isPaid ? PhosphorIcons.xCircle(PhosphorIconsStyle.regular) : PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                        isExpanded: true,
                      ),
                    ),
                    // Vertical divider
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    Expanded(
                      child: _buildActionButton(
                        localizations.delete,
                        Colors.red,
                        () => _showDeleteConfirmation(context, invoice),
                        theme,
                        icon: PhosphorIcons.trash(PhosphorIconsStyle.regular),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  // Build action button
  Widget _buildActionButton(
    String text,
    Color color,
    VoidCallback onPressed,
    ThemeData theme, {
    IconData? icon,
    bool isExpanded = false,
  }) {
    return Semantics(
      label: text,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isExpanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate total for an invoice
  double _calculateTotal(Invoice invoice) {
    // If we have details, use the total getter from the Invoice model
    if (invoice.details != null && invoice.details!.isNotEmpty) {
      return invoice.total;
    }

    // Otherwise, return 0 (or you could implement a simpler calculation here)
    return 0.0;
  }

  // Get client name by clientId
  String _getClientName(String? clientId, AppLocalizations localizations) {
    if (clientId == null || clientId.isEmpty) return localizations.noClientsYet;
    
    final clientListData = ref.read(clientListProvider);
    if (clientListData.state == ClientState.loaded) {
      try {
        final client = clientListData.clients.firstWhere(
          (client) => client.clientsId == clientId || client.id == clientId,
        );
        return client.clientName;
      } catch (e) {
        return localizations.clientNotFound;
      }
    }
    
    return localizations.loadingClients;
  }
}
