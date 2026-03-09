import 'package:facturo/common/widgets/empty_state_widget.dart';
import 'package:facturo/common/widgets/error_state_widget.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/clients/providers/client_provider.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/providers/estimate_provider.dart';
import 'package:facturo/features/estimates/views/estimate_detail_view.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:facturo/core/services/snackbar_service.dart';

class EstimateListView extends ConsumerStatefulWidget {
  static const String routeName = 'estimates';
  static const String routePath = '/estimates';

  const EstimateListView({super.key});

  @override
  ConsumerState<EstimateListView> createState() => _EstimateListViewState();
}

class _EstimateListViewState extends ConsumerState<EstimateListView> {
  final TextEditingController _searchController = TextEditingController();
  static const String _kAllYears = 'ALL';
  String _selectedYear = _kAllYears; // Mostrar todas las cotizaciones por defecto

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
    // Load estimates and clients when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(estimateListProvider.notifier).loadEstimates();
      // Also load clients to have client data available
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
    ref.read(estimateListProvider.notifier).searchEstimates(query);
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Estimate estimate,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteEstimate),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${AppLocalizations.of(context).deleteEstimateConfirmation} ${estimate.documentNumber ?? ""}?',
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).deleteEstimateWarning,
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
                AppLocalizations.of(context).deleteEstimate,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteEstimate(estimate.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Delete estimate
  void _deleteEstimate(String estimateId) {
    ref.read(estimateListProvider.notifier).deleteEstimate(estimateId);
    SnackbarService.showDeleteSuccess(context);
  }

  // Navigate to estimate detail view
  void _navigateToEstimateDetail({Estimate? estimate}) async {
    final res = await context.push(
      EstimateDetailView.routePath,
      extra: estimate,
    );
    if (res == true) {
      ref.read(estimateListProvider.notifier).loadEstimates();
      if (!mounted) return;
      SnackbarService.hideAllSnackBars(context);
      SnackbarService.showSuccess(
        context,
        message: 'Estimates loaded successfully',
      );
    }
  }

  // Get available years from estimates
  List<String> _getAvailableYears(List<Estimate> estimates) {
    final years = <String>{_kAllYears}; // Agregar opción "Todos" al inicio
    for (final estimate in estimates) {
      if (estimate.documentDate != null) {
        years.add(estimate.documentDate!.year.toString());
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

  // Filter estimates by selected year
  List<Estimate> _filterEstimatesByYear(List<Estimate> estimates) {
    if (_selectedYear.isEmpty || _selectedYear == _kAllYears) {
      // Mostrar todas las facturas, ordenadas por fecha descendente
      return estimates..sort((a, b) {
        // Sort by date descending (most recent first)
        if (a.documentDate == null) return 1;
        if (b.documentDate == null) return -1;
        return b.documentDate!.compareTo(a.documentDate!);
      });
    }
    
    return estimates.where((estimate) {
      if (estimate.documentDate == null) return false;
      return estimate.documentDate!.year.toString() == _selectedYear;
    }).toList()..sort((a, b) {
      // Sort by date descending (most recent first)
      if (a.documentDate == null) return 1;
      if (b.documentDate == null) return -1;
      return b.documentDate!.compareTo(a.documentDate!);
    });
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
              final yearCount = _filterEstimatesByYear(_getEstimatesForYear(year));
              return ListTile(
                title: Text(year == _kAllYears ? localizations.allYears : year),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  // Helper method to get estimates for a specific year
  List<Estimate> _getEstimatesForYear(String year) {
    final estimateListData = ref.watch(estimateListProvider);
    if (estimateListData.state != EstimateState.loaded) return [];

    if (year == _kAllYears) {
      return estimateListData.estimates;
    }

    return estimateListData.estimates.where((estimate) {
      if (estimate.documentDate == null) return false;
      return estimate.documentDate!.year.toString() == year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final estimateListData = ref.watch(estimateListProvider);
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
              hintText: localizations.searchEstimates,
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

        // Year selector - only show when not searching and has estimates
        if (estimateListData.state == EstimateState.loaded &&
            estimateListData.estimates.isNotEmpty &&
            (estimateListData.searchQuery == null ||
                estimateListData.searchQuery!.isEmpty))
          _buildYearSelector(estimateListData.estimates, theme, localizations),

        // Estimate list
        Expanded(child: _buildEstimateList(estimateListData, theme, localizations)),
      ],
    );
  }

  // Build year selector widget
  Widget _buildYearSelector(List<Estimate> estimates, ThemeData theme, AppLocalizations localizations) {
    final availableYears = _getAvailableYears(estimates);

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

    final filteredEstimates = _filterEstimatesByYear(estimates);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredEstimates.length}',
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

  Widget _buildEstimateList(EstimateListData data, ThemeData theme, AppLocalizations localizations) {
    switch (data.state) {
      case EstimateState.loading:
        return LoadingWidget(message: localizations.loadingEstimates);

      case EstimateState.error:
        return ErrorStateWidget(
          message: data.errorMessage ?? localizations.anErrorOccurred,
          onRetry: () =>
              ref.read(estimateListProvider.notifier).loadEstimates(),
        );

      case EstimateState.loaded:
        if (data.estimates.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
            title: localizations.noEstimatesFound,
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.noEstimatesMatchSearch
                : localizations.addYourFirstEstimate,
          );
        }

        // If there's a search query, don't filter by year
        List<Estimate> displayEstimates;
        if (data.searchQuery != null && data.searchQuery!.isNotEmpty) {
          displayEstimates = data.estimates
            ..sort((a, b) {
              // Sort by date descending (most recent first)
              if (a.documentDate == null) return 1;
              if (b.documentDate == null) return -1;
              return b.documentDate!.compareTo(a.documentDate!);
            });
        } else {
          // Filter estimates by selected year only when not searching
          displayEstimates = _filterEstimatesByYear(data.estimates);
        }

        if (displayEstimates.isEmpty) {
          return EmptyStateWidget(
            icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
            title: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.noEstimatesMatchSearch
                : '${localizations.noEstimatesFound} $_selectedYear',
            message: data.searchQuery != null && data.searchQuery!.isNotEmpty
                ? localizations.tryAnotherSearch
                : localizations.tryAnotherSearch,
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(estimateListProvider.notifier).loadEstimates(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: displayEstimates.length,
            itemBuilder: (context, index) {
              final estimate = displayEstimates[index];
              return _buildEstimateItem(estimate, theme);
            },
          ),
        );

      case EstimateState.initial:
        return LoadingWidget(message: localizations.loadingEstimates);
    }
  }

  // Build estimate card to match the modern design from invoices
  Widget _buildEstimateItem(Estimate estimate, ThemeData theme) {
    return Container(
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
          onTap: () => _navigateToEstimateDetail(estimate: estimate),
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
                    
                    // Estimate details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Estimate number
                          Text(
                            estimate.documentNumber ?? '0000',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          
                          // Status and client
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).estimate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getClientName(estimate.clientId),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
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
                          currencyFormat.format(estimate.total),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Text(
                          estimate.documentDate != null
                              ? DateFormat('MMM d, y', Localizations.localeOf(context).languageCode).format(estimate.documentDate!)
                              : AppLocalizations.of(context).noDate,
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
                    // Edit button
                    Expanded(
                      child: _buildActionButton(
                        AppLocalizations.of(context).edit,
                        theme.colorScheme.primary,
                        () => _navigateToEstimateDetail(estimate: estimate),
                        theme,
                        icon: PhosphorIcons.pencil(PhosphorIconsStyle.regular),
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
                        AppLocalizations.of(context).deleteEstimate,
                        Colors.red,
                        () => _showDeleteConfirmation(context, estimate),
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
    return InkWell(
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
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get client name by clientId
  String _getClientName(String? clientId) {
    if (clientId == null || clientId.isEmpty) return AppLocalizations.of(context).noClientsYet;

    final clientListData = ref.read(clientListProvider);
    if (clientListData.state == ClientState.loaded) {
      try {
        final client = clientListData.clients.firstWhere(
          (client) => client.clientsId == clientId || client.id == clientId,
        );
        return client.clientName;
      } catch (e) {
        return AppLocalizations.of(context).clientNotFound;
      }
    }

    return AppLocalizations.of(context).loadingClients;
  }
}
