import 'package:facturo/core/constants/profile_colors.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Clase para el resumen de facturas
class ClientInvoiceSummary {
  final String clientId;
  final int invoiceCount;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;

  ClientInvoiceSummary({
    required this.clientId,
    this.invoiceCount = 0,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.pendingAmount = 0.0,
  });
}

// Proveedor para obtener el resumen de facturas por cliente usando el proveedor existente
final clientInvoiceSummaryProvider =
    FutureProvider.family<ClientInvoiceSummary, String>(
  (ref, clientId) async {
    final invoiceListData = ref.watch(invoiceListProvider);

    // No cargar facturas aquí para evitar modificar providers durante la construcción
    // La carga de facturas debe ser manejada por la vista principal
    if (invoiceListData.state == InvoiceState.initial) {
      // Retornar resumen vacío mientras se cargan los datos externamente
      return ClientInvoiceSummary(clientId: clientId);
    }

    // Filtrar facturas por cliente
    final clientInvoices = invoiceListData.invoices
        .where((invoice) => invoice.clientId == clientId)
        .toList();

    // Calcular totales
    final totalAmount =
        clientInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    final paidAmount = clientInvoices
        .where((invoice) => invoice.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
    final pendingAmount = totalAmount - paidAmount;

    return ClientInvoiceSummary(
      clientId: clientId,
      invoiceCount: clientInvoices.length,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
    );
  },
);

class ClientCard extends ConsumerWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final invoiceSummaryAsync =
        ref.watch(clientInvoiceSummaryProvider(client.id));

    return Semantics(
      label: '${localizations.client}: ${client.name}',
      hint: 'Double tap to view details',
      child: Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.h(12)),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with client info and actions
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.w(12)),
              child: Row(
                children: [
                  // Client avatar
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    radius: ResponsiveUtils.r(20),
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.w(12)),
                  // Client name
                  Expanded(
                    child: Text(
                      client.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.sp(16),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Actions menu
                  IconButton(
                    icon: Icon(
                      PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.regular),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: localizations.moreOptions,
                    onPressed: () => _showActionsMenu(context),
                  ),
                ],
              ),
            ),

            // Invoice summary section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.w(16),
                vertical: ResponsiveUtils.h(8),
              ),
              child: invoiceSummaryAsync.when(
                data: (summary) => _buildInvoiceSummary(context, summary),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildDefaultInvoiceSummary(context),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildInvoiceSummary(
      BuildContext context, ClientInvoiceSummary summary) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        // First row: Invoices count and Total amount
        Row(
          children: [
            // Invoices count
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
                value: summary.invoiceCount.toString(),
                label: localizations.invoices,
                iconColor: ProfileColors.primaryBlue,
              ),
            ),

            // Total amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular),
                value: '\$${summary.totalAmount.toStringAsFixed(2)}',
                label: localizations.total,
                iconColor: ProfileColors.primaryBlue,
              ),
            ),
          ],
        ),

        // Second row: Paid amount and Pending amount
        Row(
          children: [
            // Paid amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                value: '\$${summary.paidAmount.toStringAsFixed(2)}',
                label: localizations.paid,
                iconColor: Colors.green,
              ),
            ),

            // Pending amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
                value: '\$${summary.pendingAmount.toStringAsFixed(2)}',
                label: localizations.unpaid,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultInvoiceSummary(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        // First row: Invoices count and Total amount
        Row(
          children: [
            // Invoices count
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
                value: '0',
                label: localizations.invoices,
                iconColor: ProfileColors.primaryBlue,
              ),
            ),

            // Total amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular),
                value: '\$0.00',
                label: localizations.total,
                iconColor: ProfileColors.primaryBlue,
              ),
            ),
          ],
        ),

        // Second row: Paid amount and Pending amount
        Row(
          children: [
            // Paid amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                value: '\$0.00',
                label: localizations.paid,
                iconColor: Colors.green,
              ),
            ),

            // Pending amount
            Expanded(
              child: _buildSummaryItem(
                context,
                icon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
                value: '\$0.00',
                label: localizations.unpaid,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(4),
        vertical: ResponsiveUtils.h(4),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.h(12),
        horizontal: ResponsiveUtils.w(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.sp(20),
            color: iconColor,
          ),
          SizedBox(height: ResponsiveUtils.h(6)),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.sp(16),
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.sp(12),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(PhosphorIcons.pencil(PhosphorIconsStyle.regular), color: theme.colorScheme.primary),
              title: Text(localizations.edit),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading:
                  Icon(PhosphorIcons.trash(PhosphorIconsStyle.regular), color: theme.colorScheme.error),
              title: Text(localizations.delete),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
