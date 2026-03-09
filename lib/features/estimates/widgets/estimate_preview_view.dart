import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/invoices/services/pdf_generator_service.dart';
import 'package:facturo/features/invoices/widgets/pdf_style_carousel.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import '../../../core/services/snackbar_service.dart';

class EstimatePreviewView extends ConsumerStatefulWidget {
  final Estimate estimate;

  const EstimatePreviewView({super.key, required this.estimate});

  @override
  ConsumerState<EstimatePreviewView> createState() =>
      _EstimatePreviewViewState();
}

class _EstimatePreviewViewState extends ConsumerState<EstimatePreviewView> {
  Client? _client;
  bool _isLoadingClient = false;
  final TransformationController _transformationController =
      TransformationController();
  PDFStyle _selectedPdfStyle = PDFStyle.executive;
  bool _showStyleSelector = true;
  final _expiryDateController = TextEditingController();
  DateTime? _selectedExpiryDate;
  String? _sharedEstimateUrl;

  // Get primary color based on selected PDF style
  Color _getStylePrimaryColor() {
    switch (_selectedPdfStyle) {
      case PDFStyle.executive:
        return const Color(0xFF1a1a2e);
      case PDFStyle.corporate:
        return const Color(0xFF003d82);
      case PDFStyle.elegant:
        return const Color(0xFF4a4a4a);
      case PDFStyle.tech:
        return const Color(0xFF00d4ff);
      case PDFStyle.creative:
        return const Color(0xFFff6b6b);
      case PDFStyle.professional:
        return const Color(0xFF2c3e50);
      case PDFStyle.boutique:
        return const Color(0xFFc9a959);
      case PDFStyle.bold:
        return const Color(0xFFe63946);
    }
  }

  // Get secondary color based on selected PDF style
  Color _getStyleSecondaryColor() {
    switch (_selectedPdfStyle) {
      case PDFStyle.executive:
        return const Color(0xFFd4af37);
      case PDFStyle.corporate:
        return const Color(0xFF0066cc);
      case PDFStyle.elegant:
        return const Color(0xFF8b7355);
      case PDFStyle.tech:
        return const Color(0xFF7b2cbf);
      case PDFStyle.creative:
        return const Color(0xFF4ecdc4);
      case PDFStyle.professional:
        return const Color(0xFF27ae60);
      case PDFStyle.boutique:
        return const Color(0xFF2d2d2d);
      case PDFStyle.bold:
        return const Color(0xFF1d3557);
    }
  }

  // Get background color for style
  Color _getStyleBackgroundColor() {
    switch (_selectedPdfStyle) {
      case PDFStyle.executive:
        return Colors.white;
      case PDFStyle.corporate:
        return Colors.white;
      case PDFStyle.elegant:
        return const Color(0xFFFAFAFA);
      case PDFStyle.tech:
        return Colors.white;
      case PDFStyle.creative:
        return Colors.white;
      case PDFStyle.professional:
        return Colors.white;
      case PDFStyle.boutique:
        return const Color(0xFFFAFAFA);
      case PDFStyle.bold:
        return Colors.white;
    }
  }

  // Get header decoration based on style
  BoxDecoration? _getHeaderDecoration() {
    switch (_selectedPdfStyle) {
      case PDFStyle.executive:
        return BoxDecoration(
          border: Border(bottom: BorderSide(color: _getStyleSecondaryColor(), width: 3)),
        );
      case PDFStyle.corporate:
        return BoxDecoration(
          color: _getStylePrimaryColor(),
        );
      case PDFStyle.elegant:
        return null;
      case PDFStyle.tech:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [_getStylePrimaryColor().withValues(alpha: 0.1), _getStyleSecondaryColor().withValues(alpha: 0.1)],
          ),
        );
      case PDFStyle.creative:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [_getStylePrimaryColor().withValues(alpha: 0.1), _getStyleSecondaryColor().withValues(alpha: 0.1)],
          ),
        );
      case PDFStyle.professional:
        return BoxDecoration(
          border: Border(bottom: BorderSide(color: _getStyleSecondaryColor(), width: 4)),
        );
      case PDFStyle.boutique:
        return BoxDecoration(
          border: Border.all(color: _getStylePrimaryColor(), width: 2),
        );
      case PDFStyle.bold:
        return BoxDecoration(
          color: _getStyleSecondaryColor(),
        );
    }
  }

  // Get text color based on style (for dark backgrounds)
  Color _getTextColorForStyle() {
    switch (_selectedPdfStyle) {
      case PDFStyle.corporate:
      case PDFStyle.bold:
        return Colors.white;
      default:
        return Colors.black87;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadClient();
    if (widget.estimate.expiryDate != null) {
      _selectedExpiryDate = widget.estimate.expiryDate;
      _expiryDateController.text = DateFormat(
        'MM/dd/yyyy',
      ).format(_selectedExpiryDate!);
    }
  }

  Future<void> _loadClient() async {
    if (widget.estimate.clientId == null) return;

    setState(() {
      _isLoadingClient = true;
    });

    try {
      final clientService = ref.read(clientServiceProvider);
      final client = await clientService.getClient(widget.estimate.clientId!);
      if (mounted) {
        setState(() {
          _client = client;
          _isLoadingClient = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClient = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).errorLoadingClients}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: 'USD ',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Zoomable Preview
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    elevation: 0,
                    color: _getStyleBackgroundColor(),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with style decoration
                          Container(
                            padding: (_selectedPdfStyle == PDFStyle.corporate || _selectedPdfStyle == PDFStyle.bold) ? const EdgeInsets.all(12) : null,
                            decoration: _getHeaderDecoration(),
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo and Company Info
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo placeholder
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color:
                                            profileState.businessLogoUrl == null
                                                ? theme.colorScheme
                                                    .surfaceContainerHighest
                                                : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: profileState.businessLogoUrl !=
                                              null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                profileState.businessLogoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Center(
                                                    child: Icon(
                                                      Icons.business,
                                                      size: 36,
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.business,
                                                size: 36,
                                                color: (_selectedPdfStyle == PDFStyle.corporate || _selectedPdfStyle == PDFStyle.bold) ? Colors.white : _getStylePrimaryColor(),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Company Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profileState.businessName ??
                                                AppLocalizations.of(context).yourBusinessNameLabel,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: (_selectedPdfStyle == PDFStyle.corporate || _selectedPdfStyle == PDFStyle.bold) ? Colors.white : (_selectedPdfStyle == PDFStyle.executive ? _getStylePrimaryColor() : null),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${AppLocalizations.of(context).businessNumber} ${profileState.businessNumber ?? ''}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: _getTextColorForStyle(),
                                            ),
                                          ),
                                          Text(
                                            profileState.address ??
                                                AppLocalizations.of(context).businessAddressLabel,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: _getTextColorForStyle(),
                                            ),
                                          ),
                                          if (profileState.website != null)
                                            Text(
                                              profileState.website!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: _getTextColorForStyle(),
                                              ),
                                            ),
                                          Text(
                                            profileState.email ??
                                                AppLocalizations.of(context).emailLabel,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: _getTextColorForStyle(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Estimate Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).estimateLabel,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getStylePrimaryColor(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.estimate.documentNumber ??
                                        AppLocalizations.of(context).notAvailableLabel,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).dateLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.estimate.documentDate != null
                                        ? DateFormat(
                                            'MM/dd/yyyy',
                                          ).format(
                                            widget.estimate.documentDate!)
                                        : AppLocalizations.of(context).notAvailableLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context).validUntilLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.estimate.expiryDate != null
                                        ? DateFormat(
                                            'MM/dd/yyyy',
                                          ).format(widget.estimate.expiryDate!)
                                        : AppLocalizations.of(context).notAvailableLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context).totalLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(
                                      widget.estimate.total,
                                    ),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ),
                          const SizedBox(height: 20),

                          // Bill To
                          Text(
                            AppLocalizations.of(context).billToLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isLoadingClient)
                            const CircularProgressIndicator()
                          else if (_client != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _client!.clientName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: _getTextColorForStyle(),
                                  ),
                                ),
                                if (_client!.clientAddress1 != null)
                                  Text(
                                    _client!.clientAddress1!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                if (_client!.clientAddress2 != null)
                                  Text(
                                    _client!.clientAddress2!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                if (_client!.clientPhone != null)
                                  Text(
                                    '☎ ${_client!.clientPhone!}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                                if (_client!.clientEmail != null)
                                  Text(
                                    _client!.clientEmail!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getTextColorForStyle(),
                                    ),
                                  ),
                              ],
                            )
                          else
                            Text(
                              'Client ID: ${widget.estimate.clientId ?? AppLocalizations.of(context).notAvailableLabel}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getTextColorForStyle(),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Items Table
                          if (widget.estimate.details != null &&
                              widget.estimate.details!.isNotEmpty)
                            Table(
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: theme.dividerColor,
                                  width: 0.5,
                                ),
                                bottom: BorderSide(
                                  color: theme.dividerColor,
                                  width: 0.5,
                                ),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                // Header Row
                                TableRow(
                                  children: [
                                    _buildTableCell(
                                      AppLocalizations.of(context).descriptionLabel,
                                      theme,
                                      isHeader: true,
                                    ),
                                    _buildTableCell(
                                      AppLocalizations.of(context).rateLabel,
                                      theme,
                                      isHeader: true,
                                    ),
                                    _buildTableCell(
                                      AppLocalizations.of(context).qtyLabel,
                                      theme,
                                      isHeader: true,
                                    ),
                                    _buildTableCell(
                                      AppLocalizations.of(context).amountLabel,
                                      theme,
                                      isHeader: true,
                                    ),
                                  ],
                                ),
                                // Items
                                ...widget.estimate.details!.map(
                                  (item) => TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 6.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.description ?? '',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                              if (item.additionalDetails !=
                                                      null &&
                                                  item.additionalDetails!
                                                      .isNotEmpty)
                                                Text(
                                                  item.additionalDetails!,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 2),
                                              Wrap(
                                                spacing: 4.0,
                                                children: [
                                                  // Taxable badge
                                                  if (item.taxable == true)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .primaryContainer,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          2,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(context).taxable,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: theme
                                                              .colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  // Discount badge
                                                  if (item.discountAmount !=
                                                          null &&
                                                      item.discountAmount! > 0)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withValues(alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          2,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        item.discountType ==
                                                                'percentage'
                                                            ? '${item.discountAmount}% ${AppLocalizations.of(context).discountOff}'
                                                            : '\$${item.discountAmount?.toStringAsFixed(2)} ${AppLocalizations.of(context).discountOff}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      _buildTableCell(
                                        currencyFormat.format(
                                          item.unitCost ?? 0,
                                        ),
                                        theme,
                                      ),
                                      _buildTableCell(
                                        item.quantity?.toString() ?? '0',
                                        theme,
                                      ),
                                      _buildTableCell(
                                        currencyFormat.format(item.lineTotal),
                                        theme,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),

                          // Totals Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Totals
                              SizedBox(
                                width: 180,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildTotalRow(
                                      AppLocalizations.of(context).subtotalLabel,
                                      widget.estimate.total,
                                      theme,
                                    ),
                                    if (widget.estimate.generalTax != null &&
                                        widget.estimate.generalTax! > 0)
                                      _buildTotalRow(AppLocalizations.of(context).taxable, 0, theme),
                                    if (widget.estimate.generalTax != null &&
                                        widget.estimate.generalTax! > 0)
                                      _buildTotalRow(
                                        AppLocalizations.of(context).taxLabel,
                                        widget.estimate.generalTaxType ==
                                                'percentage'
                                            ? widget.estimate.total *
                                                (widget.estimate.generalTax! /
                                                    100)
                                            : widget.estimate.generalTax!,
                                        theme,
                                        showPrefix: true,
                                      ),
                                    const Divider(height: 8, thickness: 0.5),
                                    _buildTotalRow(
                                      AppLocalizations.of(context).totalLabel,
                                      widget.estimate.total,
                                      theme,
                                      isBold: true,
                                    ),
                                    const SizedBox(height: 4),
                                    _buildTotalRow(
                                      '${AppLocalizations.of(context).estimateLabel} ${AppLocalizations.of(context).totalLabel}',
                                      widget.estimate.total,
                                      theme,
                                      isBold: true,
                                      useLargeText: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Signature Section
                          if (profileState.signatureUrl != null) ...[
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.network(
                                        profileState.signatureUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'DATE SIGNED',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    widget.estimate.documentDate != null
                                        ? DateFormat(
                                            'MM/dd/yyyy',
                                          ).format(
                                            widget.estimate.documentDate!)
                                        : 'N/A',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Footer
                          Center(
                            child: Text(
                              'Thank you for considering our estimate.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // PDF Style Selector with toggle button
        Column(
          children: [
            // Toggle button for style selector (always visible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_showStyleSelector)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showStyleSelector = !_showStyleSelector;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Estilos',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Style selector (conditionally shown)
            if (_showStyleSelector)
              PDFStyleCarousel(
                selectedStyle: _selectedPdfStyle,
                onStyleChanged: (style) {
                  setState(() {
                    _selectedPdfStyle = style;
                  });
                },
                onToggleHide: () {
                  setState(() {
                    _showStyleSelector = !_showStyleSelector;
                  });
                },
                isShown: _showStyleSelector,
              ),
          ],
        ),

        // Action Buttons
        SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSendOptions,
                    icon:
                        const Icon(Iconsax.export_outline, color: Colors.white),
                    label: Text(AppLocalizations.of(context).sendEstimate),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showExportOptions,
                  icon: const Icon(Iconsax.document_download_outline),
                  tooltip: AppLocalizations.of(context).exportOptions,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(
    String text,
    ThemeData theme, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Text(
          text,
          style: isHeader
              ? theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                )
              : theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : null,
                ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isBold = false,
    bool showPrefix = false,
    bool useLargeText = false,
  }) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'USD ',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getTextColorForStyle(),
                fontWeight: isBold ? FontWeight.bold : null,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${showPrefix ? 'inc ' : ''}${currencyFormat.format(amount)}',
              style: useLargeText
                  ? theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isBold ? FontWeight.bold : null,
                      color: _getTextColorForStyle(),
                    )
                  : theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isBold ? FontWeight.bold : null,
                      color: _getTextColorForStyle(),
                      fontSize: 12,
                    ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showSendOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.export_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).sendEstimate,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Options
              ListTile(
                leading: Icon(
                  Iconsax.sms_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).sendViaEmail),
                subtitle: Text(AppLocalizations.of(context).sendPdfViaEmail),
                onTap: () {
                  Navigator.pop(context);
                  _sendViaEmail();
                },
              ),
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.link_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (_sharedEstimateUrl != null &&
                        _sharedEstimateUrl!.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Iconsax.tick_circle_outline,
                          color: Colors.green,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(AppLocalizations.of(context).sendViaLink),
                    if (_sharedEstimateUrl != null &&
                        _sharedEstimateUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            AppLocalizations.of(context).ready,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  _sharedEstimateUrl != null && _sharedEstimateUrl!.isNotEmpty
                      ? AppLocalizations.of(context).linkReadyTapToShare
                      : AppLocalizations.of(context).generateAndShareOnlineLink,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sendViaLink();
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.document_download_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).sendPdfFile),
                subtitle: Text(AppLocalizations.of(context).downloadAndSharePdf),
                onTap: () {
                  Navigator.pop(context);
                  _sendViaPDF();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _sendViaEmail() async {
    // Capture localizations before async gaps
    final l = AppLocalizations.of(context);
    try {
      final pdfBytes = await _generatePdf(
        context,
        widget.estimate,
        ref.read(userProfileProvider),
      );

      // Get temp directory to save PDF
      final tempDir = await getTemporaryDirectory();
      String estimateFileName =
          'Estimate_${widget.estimate.documentNumber ?? DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
      final file = File('${tempDir.path}/$estimateFileName');

      // Save PDF to temp file
      await file.writeAsBytes(pdfBytes);

      // Prepare email parameters
      final amountFormatted = NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(widget.estimate.total);
      String subject = l.estimateEmailSubject(widget.estimate.documentNumber ?? '');
      String body = l.estimateEmailBody;

      if (_client != null) {
        body += l.estimateEmailThankYou(_client!.clientName);
      }

      body += l.estimateEmailTotal(amountFormatted);
      body += l.invoiceEmailContact;

      // Recipient email
      String? recipientEmail = _client?.clientEmail;

      // Use flutter_email_sender to open email app directly with PDF attachment
      final Email email = Email(
        body: body,
        subject: subject,
        recipients: recipientEmail != null ? [recipientEmail] : [],
        attachmentPaths: [file.path],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      
      if (!mounted) return;
      SnackbarService.showSuccess(
        context,
        message: AppLocalizations.of(context).couldNotOpenEmailApp,
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarService.showGenericError(
        context,
        error: '${AppLocalizations.of(context).errorSendingEmail}: $e',
      );
    }
  }

  Future<Uint8List> _generatePdf(
    BuildContext context,
    Estimate estimate,
    dynamic profileState,
  ) async {
    // PDFGeneratorService with style will be used when estimates are supported
    // For now, use the old hardcoded method
    return await _generatePdfOld(context, estimate, profileState);
  }

  Future<Uint8List> _generatePdfOld(
    BuildContext context,
    Estimate estimate,
    dynamic profileState,
  ) async {
    final pdf = pw.Document();
    final settings = ref.read(appSettingsProvider);
    final currency = CurrencyService.getCurrency(settings.currency) ??
        CurrencyService.defaultCurrency;
    final currencyFormat = NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );

    // Calculate subtotal (without taxes or discounts)
    final double subtotal =
        estimate.details != null && estimate.details!.isNotEmpty
            ? estimate.details!.fold(
                0.0,
                (sum, detail) => sum + detail.lineTotal,
              )
            : 0.0;

    // Calculate tax amount if applicable
    final double taxAmount =
        (estimate.generalTax != null && estimate.generalTax! > 0)
            ? (estimate.generalTaxType == 'percentage'
                ? subtotal * (estimate.generalTax! / 100)
                : estimate.generalTax!)
            : 0.0;

    // Calculate discount amount if applicable
    final double discountAmount =
        (estimate.generalDiscount != null && estimate.generalDiscount! > 0)
            ? (estimate.generalDiscountType == 'percentage'
                ? subtotal * (estimate.generalDiscount! / 100)
                : estimate.generalDiscount!)
            : 0.0;

    // Logo image
    pw.MemoryImage? logoImage;
    if (profileState.businessLogoUrl != null) {
      try {
        final response = await NetworkAssetBundle(
          Uri.parse(profileState.businessLogoUrl!),
        ).load(profileState.businessLogoUrl!);
        final bytes = response.buffer.asUint8List();
        logoImage = pw.MemoryImage(bytes);
      } catch (e) {
        // Handle error silently, will use default icon
      }
    }

    // Signature image
    pw.MemoryImage? signatureImage;
    if (profileState.signatureUrl != null) {
      try {
        final response = await NetworkAssetBundle(
          Uri.parse(profileState.signatureUrl!),
        ).load(profileState.signatureUrl!);
        final bytes = response.buffer.asUint8List();
        signatureImage = pw.MemoryImage(bytes);
      } catch (e) {
        // Handle error silently
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo and Company Info
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Logo
                        logoImage != null
                            ? pw.Container(
                                width: 70,
                                height: 70,
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(8),
                                ),
                                child: pw.Image(
                                  logoImage,
                                  fit: pw.BoxFit.contain,
                                ),
                              )
                            : pw.Container(
                                width: 70,
                                height: 70,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey300,
                                  borderRadius: pw.BorderRadius.circular(8),
                                ),
                                child: pw.Center(
                                  child: pw.Text(
                                    'LOGO',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ),
                              ),
                        pw.SizedBox(width: 12),
                        // Company Info
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                profileState.businessName ??
                                    'Your Business Name',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Business Number ${profileState.businessNumber ?? ''}',
                                style: const pw.TextStyle(fontSize: 11),
                              ),
                              pw.Text(
                                profileState.address ?? 'Business Address',
                                style: const pw.TextStyle(fontSize: 11),
                              ),
                              if (profileState.website != null)
                                pw.Text(
                                  profileState.website!,
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.blue,
                                  ),
                                ),
                              pw.Text(
                                profileState.email ?? 'Email',
                                style: const pw.TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Estimate Info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'ESTIMATE',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        estimate.documentNumber ?? 'N/A',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'DATE',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        estimate.documentDate != null
                            ? DateFormat(
                                'MM/dd/yyyy',
                              ).format(estimate.documentDate!)
                            : 'N/A',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'VALID UNTIL',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        estimate.expiryDate != null
                            ? DateFormat(
                                'MM/dd/yyyy',
                              ).format(estimate.expiryDate!)
                            : 'N/A',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'TOTAL',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        currencyFormat.format(estimate.total),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Bill To
              pw.Text(
                'BILL TO',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (_client != null) ...[
                pw.Text(
                  _client!.clientName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (_client!.clientAddress1 != null)
                  pw.Text(
                    _client!.clientAddress1!,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                if (_client!.clientAddress2 != null)
                  pw.Text(
                    _client!.clientAddress2!,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                pw.SizedBox(height: 4),
                if (_client!.clientPhone != null)
                  pw.Text(
                    '☎ ${_client!.clientPhone!}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                if (_client!.clientEmail != null)
                  pw.Text(
                    _client!.clientEmail!,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
              ] else
                pw.Text(
                  'Client ID: ${estimate.clientId ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              pw.SizedBox(height: 20),

              // Items Table with reduced padding and font size
              if (estimate.details != null && estimate.details!.isNotEmpty)
                pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                    bottom: pw.BorderSide(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      children: [
                        _buildPdfTableCell(
                          'DESCRIPTION',
                          isHeader: true,
                          fontSize: 9,
                        ),
                        _buildPdfTableCell('RATE', isHeader: true, fontSize: 9),
                        _buildPdfTableCell('QTY', isHeader: true, fontSize: 9),
                        _buildPdfTableCell(
                          'AMOUNT',
                          isHeader: true,
                          fontSize: 9,
                        ),
                      ],
                    ),
                    // Items
                    ...estimate.details!.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 6.0,
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.description ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                                if (item.additionalDetails != null &&
                                    item.additionalDetails!.isNotEmpty)
                                  pw.Text(
                                    item.additionalDetails!,
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                pw.SizedBox(height: 2),
                                pw.Row(
                                  children: [
                                    // Taxable badge
                                    if (item.taxable == true)
                                      pw.Container(
                                        margin: const pw.EdgeInsets.only(
                                          right: 4,
                                        ),
                                        padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: pw.BoxDecoration(
                                          color: PdfColors.blue100,
                                          borderRadius:
                                              pw.BorderRadius.circular(2),
                                        ),
                                        child: pw.Text(
                                          'Taxable',
                                          style: const pw.TextStyle(
                                            fontSize: 6,
                                            color: PdfColors.blue800,
                                          ),
                                        ),
                                      ),
                                    // Discount badge
                                    if (item.discountAmount != null &&
                                        item.discountAmount! > 0)
                                      pw.Container(
                                        padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: pw.BoxDecoration(
                                          color: PdfColors.red100,
                                          borderRadius:
                                              pw.BorderRadius.circular(2),
                                        ),
                                        child: pw.Text(
                                          item.discountType == 'percentage'
                                              ? '${item.discountAmount}% off'
                                              : '\$${item.discountAmount?.toStringAsFixed(2)} off',
                                          style: const pw.TextStyle(
                                            fontSize: 6,
                                            color: PdfColors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildPdfTableCell(
                            currencyFormat.format(item.unitCost ?? 0),
                            fontSize: 11,
                          ),
                          _buildPdfTableCell(
                            item.quantity?.toString() ?? '0',
                            fontSize: 11,
                          ),
                          _buildPdfTableCell(
                            currencyFormat.format(item.lineTotal),
                            fontSize: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 12),

              // Totals Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  // Totals
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // Subtotal row
                        pw.SizedBox(height: 8),
                        _buildPdfTotalRow('SUBTOTAL', subtotal, currencyFormat),

                        // Show discount if applicable
                        if (estimate.generalDiscount != null &&
                            estimate.generalDiscount! > 0)
                          _buildPdfTotalRow(
                            estimate.generalDiscountType == 'percentage'
                                ? 'DISCOUNT (${estimate.generalDiscount}%)'
                                : 'DISCOUNT',
                            discountAmount,
                            currencyFormat,
                            isNegative: true,
                          ),

                        // Show tax if applicable
                        if (estimate.generalTax != null &&
                            estimate.generalTax! > 0) ...[
                          _buildPdfTotalRow(
                            'TAXABLE',
                            subtotal,
                            currencyFormat,
                          ),
                          _buildPdfTotalRow(
                            estimate.generalTaxType == 'percentage'
                                ? 'TAX (${estimate.generalTax}%)'
                                : 'TAX',
                            taxAmount,
                            currencyFormat,
                          ),
                        ],

                        pw.Divider(),
                        _buildPdfTotalRow(
                          'TOTAL',
                          estimate.total,
                          currencyFormat,
                          isBold: true,
                        ),
                        pw.SizedBox(height: 8),
                        _buildPdfTotalRow(
                          'ESTIMATE TOTAL',
                          estimate.total,
                          currencyFormat,
                          isBold: true,
                          useLargeText: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Signature Section
              if (signatureImage != null) ...[
                pw.Container(
                  width: double.infinity,
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 200,
                        height: 60,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey300),
                          ),
                        ),
                        child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'DATE SIGNED',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        estimate.documentDate != null
                            ? DateFormat(
                                'MM/dd/yyyy',
                              ).format(estimate.documentDate!)
                            : DateFormat('MM/dd/yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),
              ],

              // Notes
              if (estimate.notes != null && estimate.notes!.isNotEmpty) ...[
                pw.Text(
                  'Notes:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  estimate.notes!,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 24),
              ],

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for considering our estimate.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    double fontSize = 9,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold || isHeader ? pw.FontWeight.bold : null,
          color: isHeader ? PdfColors.grey700 : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    double amount,
    NumberFormat currencyFormat, {
    bool isBold = false,
    bool isNegative = false,
    bool useLargeText = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            isNegative
                ? '-${currencyFormat.format(amount)}'
                : currencyFormat.format(amount),
            style: pw.TextStyle(
              fontSize: useLargeText ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendViaLink() async {
    try {
      // Check if link already exists - reuse it instead of regenerating
      if (_sharedEstimateUrl != null && _sharedEstimateUrl!.isNotEmpty) {
        // Show message that we're using existing link
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            backgroundColor: Colors.blue,
            content: const Row(
              children: [
                Icon(
                  Iconsax.link_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Using existing link',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            elevation: 0,
          ),
        );

        // Show link sharing options directly
        _showLinkSharingOptions();
        return;
      }

      // Generate new link - PDF Generation
      final localizations = AppLocalizations.of(context);
      final loadingOverlay = _showLoadingOverlay(message: localizations.generatingPdf);

      // Generate PDF
      final pdfBytes = await _generatePdf(
        context,
        widget.estimate,
        ref.read(userProfileProvider),
      );

      // Update loading message - Upload to Cloud
      loadingOverlay.remove();
      final uploadOverlay =
          _showLoadingOverlay(message: localizations.uploadingToCloud);

      // Upload PDF to Supabase Storage
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final estimateNumber = widget.estimate.documentNumber ?? 'estimate';
      final fileName = '${userId}_${estimateNumber}_$timestamp.pdf';
      final filePath = 'estimates/$fileName';

      // Upload file to Supabase Storage and get signed URL for sharing
      final storageService = StorageService(supabase);
      final storedPath = await storageService.uploadBinary(
        filePath: filePath,
        data: pdfBytes,
      );

      // Get signed URL with long expiry for sharing (30 days)
      final shareUrl = await storageService.getShareUrl(storedPath);

      // Store the URL for sharing
      _sharedEstimateUrl = shareUrl;

      // Hide loading indicator
      uploadOverlay.remove();

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          backgroundColor: Colors.green,
          content: const Row(
            children: [
              Icon(
                Iconsax.tick_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Link generated successfully!',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );

      // Show link sharing options
      _showLinkSharingOptions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
      );
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.document_download_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).exportOptions,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Iconsax.document_download_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).exportAsPdf),
                subtitle: Text(AppLocalizations.of(context).downloadPdfFile),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPDF(
                      context, widget.estimate, ref.read(userProfileProvider));
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.image_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).exportAsPng),
                subtitle: Text(AppLocalizations.of(context).downloadAsImage),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPNG();
                },
              ),
              if (_sharedEstimateUrl != null && _sharedEstimateUrl!.isNotEmpty)
                ListTile(
                  leading: Icon(
                    Iconsax.trash_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(AppLocalizations.of(context).deleteOnlineLink),
                  subtitle: Text(AppLocalizations.of(context).removeSharedLink),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteOnlineLink();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _exportAsPNG() async {
    OverlayEntry? loadingOverlay;
    try {
      // Show loading indicator
      loadingOverlay = _showLoadingOverlay(message: AppLocalizations.of(context).generatingPngImage);

      // Generate PDF first
      final pdfBytes = await _generatePdf(
        context,
        widget.estimate,
        ref.read(userProfileProvider),
      );

      // Convert PDF to image using printing package
      final imageStream = Printing.raster(
        pdfBytes,
        dpi: 300, // High quality
        pages: [0], // Only first page
      );

      // Get the first page
      final firstPage = await imageStream.first;
      
      // Convert to PNG
      final pngBytes = await firstPage.toPng();

      // Add white background using image package
      final decodedImage = img.decodePng(pngBytes);
      Uint8List finalPngBytes;
      
      if (decodedImage != null) {
        // Create a white background image
        final whiteBackground = img.Image(
          width: decodedImage.width,
          height: decodedImage.height,
        );
        img.fill(whiteBackground, color: img.ColorRgb8(255, 255, 255));
        
        // Composite the original image over white background
        img.compositeImage(whiteBackground, decodedImage);
        
        // Encode back to PNG
        finalPngBytes = img.encodePng(whiteBackground);
      } else {
        // Fallback: use original PNG if decoding fails
        finalPngBytes = pngBytes;
      }

      // Hide loading indicator
      loadingOverlay.remove();
      loadingOverlay = null;

      // Save directly to gallery using image_gallery_saver
      final result = await ImageGallerySaver.saveImage(
        finalPngBytes,
        quality: 100,
        name: 'estimate_${widget.estimate.documentNumber ?? DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      
      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            backgroundColor: Colors.green,
            content: const Row(
              children: [
                Icon(
                  Iconsax.tick_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'PNG saved to Photos',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            elevation: 0,
          ),
        );
      } else {
        throw Exception('Failed to save image to gallery');
      }
    } catch (e) {
      // Make sure to remove loading overlay on error
      loadingOverlay?.remove();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorGeneratingPng}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteOnlineLink() async {
    if (_sharedEstimateUrl == null || _sharedEstimateUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noEstimateLinkAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteOnlineLink),
          content: const Text(
            'Are you sure you want to delete the online link? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      // Clear the URL
      _sharedEstimateUrl = null;

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          backgroundColor: Colors.green,
          content: const Row(
            children: [
              Icon(
                Iconsax.tick_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Online link deleted successfully',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          elevation: 0,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).errorDeletingLink}: $e')),
      );
    }
  }

  void _showLinkSharingOptions() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.link_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).shareOnlineLink,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Iconsax.copy_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).copyLink),
                subtitle: Text(AppLocalizations.of(context).copySecureLinkToClipboard),
                onTap: () {
                  Navigator.pop(context);
                  _copyEstimateLink();
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.share_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).shareLink),
                subtitle: Text(AppLocalizations.of(context).shareOnlineLinkViaApps),
                onTap: () {
                  Navigator.pop(context);
                  _shareEstimateLink();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Iconsax.refresh_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).generateNewLink),
                subtitle: Text(AppLocalizations.of(context).createFreshLink),
                onTap: () {
                  Navigator.pop(context);
                  _regenerateEstimateLink();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _sendViaPDF() async {
    try {
      // Show loading indicator
      final loadingOverlay =
          _showLoadingOverlay(message: AppLocalizations.of(context).generatingPdfFile);

      // Generate PDF
      final pdfBytes = await _generatePdf(
        context,
        widget.estimate,
        ref.read(userProfileProvider),
      );

      // Get temp directory to save PDF
      final tempDir = await getTemporaryDirectory();
      String estimateFileName =
          'Estimate_${widget.estimate.documentNumber ?? DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
      final file = File('${tempDir.path}/$estimateFileName');
      await file.writeAsBytes(pdfBytes);

      // Hide loading indicator
      loadingOverlay.remove();
      if (!mounted) return;

      // Show PDF sharing options
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.document_download_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).sharePdf,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Iconsax.share_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(AppLocalizations.of(context).sharePdfFile),
                  subtitle: Text(AppLocalizations.of(context).shareViaOtherApps),
                  onTap: () {
                    Navigator.pop(context);
                    _sharePDFFile(file);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Iconsax.folder_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(AppLocalizations.of(context).saveToDevice),
                  subtitle: Text(AppLocalizations.of(context).downloadToLocalStorage),
                  onTap: () {
                    Navigator.pop(context);
                    _savePDFToDevice(file);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).errorGeneratingPdf}: $e')),
      );
    }
  }

  void _copyEstimateLink() async {
    if (_sharedEstimateUrl == null || _sharedEstimateUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).noEstimateLinkAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: _sharedEstimateUrl!));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        backgroundColor: Colors.green,
        content: const Row(
          children: [
            Icon(
              Iconsax.tick_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              'Estimate link copied to clipboard',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }

  void _shareEstimateLink() async {
    if (_sharedEstimateUrl == null || _sharedEstimateUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).noEstimateLinkAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String message = 'Please find your estimate: $_sharedEstimateUrl';

    await Share.share(
      message,
      subject: 'Estimate ${widget.estimate.documentNumber ?? ""}',
    );
  }

  void _regenerateEstimateLink() async {
    // Clear existing URL to force regeneration
    _sharedEstimateUrl = null;

    // Show confirmation message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).generatingNewLink),
        backgroundColor: Colors.blue,
      ),
    );

    // Proceed with normal link generation
    await _sendViaLink();
  }

  void _sharePDFFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      text: 'Please find attached your estimate PDF',
      subject: 'Estimate ${widget.estimate.documentNumber ?? ""}',
    );
  }

  void _savePDFToDevice(File file) async {
    // Get the downloads directory
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final newFile = File('${downloadsDir.path}/${file.path.split('/').last}');
      await file.copy(newFile.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          backgroundColor: Colors.green,
          content: const Row(
            children: [
              Icon(
                Iconsax.tick_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'PDF saved to Downloads',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          elevation: 0,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotAccessDownloads)),
      );
    }
  }

  OverlayEntry _showLoadingOverlay({String message = 'Loading...'}) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  Future<void> _exportToPDF(
    BuildContext context,
    Estimate estimate,
    dynamic profileState,
  ) async {
    OverlayEntry? loadingOverlay;
    try {
      // Show loading indicator
      loadingOverlay = _showLoadingOverlay(message: AppLocalizations.of(context).generatingPdf);

      // Generate PDF using the PDF generator service
      final pdfBytes = await _generatePdf(
        context,
        estimate,
        profileState,
      );

      // Hide loading
      loadingOverlay.remove();
      loadingOverlay = null;

      // Save and share PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Estimate_${estimate.documentNumber ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      // Make sure to remove loading overlay on error
      loadingOverlay?.remove();

      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(this.context).errorExportingPdf}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
