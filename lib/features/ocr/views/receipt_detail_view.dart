import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/features/ocr/models/ocr_scan.dart';
import 'package:facturo/features/ocr/services/ocr_receipt_service.dart';
import 'package:facturo/features/ocr/widgets/ocr_conversion_bottom_sheet.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

/// Vista para mostrar y editar detalles de un recibo OCR guardado
class ReceiptDetailView extends ConsumerStatefulWidget {
  final OCRScan receipt;

  const ReceiptDetailView({
    super.key,
    required this.receipt,
  });

  @override
  ConsumerState<ReceiptDetailView> createState() =>
      _ReceiptDetailViewState();
}

class _ReceiptDetailViewState extends ConsumerState<ReceiptDetailView>
    with FreemiumMixin {
  final OCRReceiptService _receiptService = OCRReceiptService();
  late OCRScan _currentReceipt;
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers para edición
  late TextEditingController _companyController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _dateController;
  late TextEditingController _subtotalController;
  late TextEditingController _taxController;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _currentReceipt = widget.receipt;
    _initializeControllers();
  }

  void _initializeControllers() {
    final extractedData = _currentReceipt.extractedData ?? {};
    _companyController = TextEditingController(
      text: _currentReceipt.companyName ?? extractedData['company']?.toString() ?? '',
    );
    _invoiceNumberController = TextEditingController(
      text: _currentReceipt.invoiceNumber ?? extractedData['invoiceNumber']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: _currentReceipt.date ?? extractedData['date']?.toString() ?? '',
    );
    _subtotalController = TextEditingController(
      text: extractedData['subtotal']?.toString() ?? '',
    );
    _taxController = TextEditingController(
      text: extractedData['tax']?.toString() ?? '',
    );
    _totalController = TextEditingController(
      text: _currentReceipt.totalAmount?.toStringAsFixed(2) ??
          extractedData['total']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _invoiceNumberController.dispose();
    _dateController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentReceipt.companyName ?? localizations.receiptDetails),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(PhosphorIcons.floppyDisk(PhosphorIconsStyle.regular)),
              onPressed: _isSaving ? null : _saveChanges,
            )
          else
            IconButton(
              icon: Icon(PhosphorIcons.pencil(PhosphorIconsStyle.regular)),
              onPressed: _startEditing,
            ),
          IconButton(
            icon: Icon(PhosphorIcons.fileText(PhosphorIconsStyle.regular)),
            onPressed: _isSaving ? null : _showConversionOptions,
            tooltip: AppLocalizations.of(context).convertReceipt,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(PhosphorIcons.trash(PhosphorIconsStyle.regular)),
                  title: Text(AppLocalizations.of(context).delete),
                ),
                onTap: () => _deleteReceipt(),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vista previa de imagen
            _buildImagePreview(localizations, theme),
            const SizedBox(height: 24),
            
            // Información básica
            _buildBasicInfoSection(localizations, theme),
            const SizedBox(height: 24),

            // Información financiera
            _buildFinancialSection(localizations, theme),
            const SizedBox(height: 24),

            // Items
            _buildItemsSection(localizations, theme),
            const SizedBox(height: 24),

            // Información adicional
            _buildAdditionalInfoSection(localizations, theme),
            const SizedBox(height: 24),

            // Botón de acción principal
            _buildCreateInvoiceButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(AppLocalizations localizations, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.basicInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.companyName,
              controller: _companyController,
              icon: PhosphorIcons.buildings(PhosphorIconsStyle.regular),
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.invoiceNumber,
              controller: _invoiceNumberController,
              icon: PhosphorIcons.hash(PhosphorIconsStyle.regular),
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.date,
              controller: _dateController,
              icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(AppLocalizations localizations, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.financialInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.subtotal,
              controller: _subtotalController,
              icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular),
              theme: theme,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.tax,
              controller: _taxController,
              icon: PhosphorIcons.percent(PhosphorIconsStyle.regular),
              theme: theme,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: localizations.total,
              controller: _totalController,
              icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular),
              theme: theme,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(AppLocalizations localizations, ThemeData theme) {
    final items = _currentReceipt.extractedData?['items'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.items,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(AppLocalizations.of(context).noItemsFound),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value as Map<String, dynamic>;
                return _buildItemRow(index, item, theme, localizations);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, Map<String, dynamic> item, ThemeData theme, AppLocalizations localizations) {
    final quantity = item['quantity'] ?? 1;
    final unitPriceValue = item['unitPrice'] ?? 0.0;
    final totalValue = item['total'] ?? 0.0;
    final unitPrice = unitPriceValue is num ? unitPriceValue.toDouble() : double.tryParse(unitPriceValue.toString()) ?? 0.0;
    final total = totalValue is num ? totalValue.toDouble() : double.tryParse(totalValue.toString()) ?? 0.0;
    final description = item['description']?.toString() ?? '${localizations.item} ${index + 1}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(description),
        subtitle: Text('${AppLocalizations.of(context).qty}: $quantity × \$${unitPrice.toStringAsFixed(2)}'),
        trailing: Text(
          '\$${total.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(AppLocalizations localizations, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.additionalInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(localizations.status, _currentReceipt.status, theme),
            _buildInfoRow(
              localizations.created,
              dateFormat.format(_currentReceipt.createdAt),
              theme,
            ),
            if (_currentReceipt.invoiceId != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Saved as Invoice',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos actualizados
      final currentExtractedData =
          Map<String, dynamic>.from(_currentReceipt.extractedData ?? {});
      
      currentExtractedData['company'] = _companyController.text;
      currentExtractedData['invoiceNumber'] = _invoiceNumberController.text;
      currentExtractedData['date'] = _dateController.text;
      currentExtractedData['subtotal'] = _subtotalController.text;
      currentExtractedData['tax'] = _taxController.text;
      currentExtractedData['total'] = _totalController.text;

      // Actualizar en Supabase
      final success = await _receiptService.updateOCRReceipt(
        _currentReceipt.id,
        {'extracted_data': currentExtractedData},
      );

      if (success) {
        // Recargar el recibo actualizado
        final updatedReceipt =
            await _receiptService.getOCRReceiptById(_currentReceipt.id);
        if (updatedReceipt != null) {
          setState(() {
            _currentReceipt = updatedReceipt;
            _isEditing = false;
            _initializeControllers();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).receiptUpdatedSuccessfully),
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to update receipt');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorUpdatingReceipt}: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
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

  Future<void> _deleteReceipt() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteReceipt),
        content: Text(AppLocalizations.of(context).deleteReceiptConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _receiptService.deleteOCRReceipt(_currentReceipt.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).receiptDeletedSuccessfully),
          ),
        );
        context.pop();
      }
    }
  }

  Widget _buildImagePreview(AppLocalizations localizations, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.image(PhosphorIconsStyle.regular),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.scannedReceipt,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  localizations.tapToEnlarge,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showImageDialog(),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: _currentReceipt.imageUrl != null
                  ? Image.network(
                      _currentReceipt.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.imageSquare(PhosphorIconsStyle.regular),
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.imageSquare(PhosphorIconsStyle.regular),
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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

  void _showImageDialog() {
    if (_currentReceipt.imageUrl == null) return;
    
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Card(
                    elevation: 0,
                    child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.scannedReceipt,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: InteractiveViewer(
                            panEnabled: true,
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              _currentReceipt.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        PhosphorIcons.imageSquare(PhosphorIconsStyle.regular),
                                        size: 48,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateInvoiceButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _showConversionOptions,
        icon: _isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.swap_horiz),
        label: Text(
          AppLocalizations.of(context).convertReceipt,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showConversionOptions() async {
    // Mostrar modal bottom sheet para elegir conversión
    if (!mounted) return;
    
    await OCRConversionBottomSheet.show(
      context,
      onConvertToExpense: _convertToExpense,
      onConvertToInvoice: _convertToInvoice,
    );
  }

  Future<void> _convertToInvoice() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Verificar límite freemium
      final canCreate = await checkFreemiumAction(FreemiumAction.createInvoice);
      if (!canCreate) {
        if (!mounted) return;
        return;
      }

      // Convertir items del OCR a InvoiceItem
      final extractedData = _currentReceipt.extractedData ?? {};
      final items = extractedData['items'] as List? ?? [];
      
      final invoiceItems = items.map((item) {
        final itemData = item as Map<String, dynamic>;
        return InvoiceItem(
          description: itemData['description']?.toString() ?? 'Item',
          quantity: (itemData['quantity'] as num?)?.toDouble() ?? 1.0,
          unitCost: (itemData['unitPrice'] as num?)?.toDouble() ?? 0.0,
          taxable: true,
        );
      }).toList();

      // Parsear fecha
      DateTime? invoiceDate;
      try {
        final dateStr = _dateController.text.trim();
        if (dateStr.isNotEmpty) {
          final formats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd.MM.yyyy'];
          for (final format in formats) {
            try {
              invoiceDate = _parseDate(dateStr, format);
              break;
            } catch (e) {
              continue;
            }
          }
        }
        invoiceDate ??= DateTime.now();
      } catch (e) {
        invoiceDate = DateTime.now();
      }

      // Crear la factura
      final invoice = Invoice(
        documentNumber: _invoiceNumberController.text.trim().isEmpty 
            ? 'INV-${DateTime.now().millisecondsSinceEpoch}' 
            : _invoiceNumberController.text.trim(),
        documentDate: invoiceDate,
        notes: 'Created from OCR receipt\nCompany: ${_companyController.text}',
        photoUrl: _currentReceipt.imageUrl,
        details: invoiceItems,
        generalTax: _taxController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_taxController.text.replaceAll(RegExp(r'[^\d.]'), '')),
      );

      // Guardar factura en Supabase usando el provider con SubscriptionService
      final invoiceService = ref.read(invoiceServiceProvider);
      final createdInvoice = await invoiceService.createInvoice(invoice);

      // Vincular el OCR con la factura
      await _receiptService.markAsUsedForInvoice(_currentReceipt.id, createdInvoice.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).invoiceCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        // Navegar al dashboard
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorCreatingInvoice}: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
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

  Future<void> _convertToExpense() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final extractedData = _currentReceipt.extractedData ?? {};
      final total = double.tryParse(_totalController.text) ?? 
          double.tryParse(extractedData['total']?.toString() ?? '0.0') ?? 0.0;
      final tax = double.tryParse(_taxController.text) ?? 
          double.tryParse(extractedData['tax']?.toString() ?? '0.0') ?? 0.0;

      // Parsear fecha
      DateTime? expenseDate;
      try {
        final dateStr = _dateController.text.trim();
        if (dateStr.isNotEmpty) {
          final formats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd.MM.yyyy'];
          for (final format in formats) {
            try {
              expenseDate = _parseDate(dateStr, format);
              break;
            } catch (e) {
              continue;
            }
          }
        }
        expenseDate ??= DateTime.now();
      } catch (e) {
        expenseDate = DateTime.now();
      }

      // Obtener userId del usuario autenticado
      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      // Crear el gasto
      final expense = Expense(
        userId: authState.user!.id,
        merchant: _companyController.text.trim(),
        category: null, // El usuario puede editar esto después
        expenseDate: expenseDate,
        total: total,
        tax: tax,
        description: 'Created from OCR receipt\nInvoice #: ${_invoiceNumberController.text.trim()}',
        receiptUrl: _currentReceipt.imageUrl,
      );

      // Guardar gasto en Supabase usando el provider
      final expenseNotifier = ref.read(expenseDetailProvider.notifier);
      final createdExpense = await expenseNotifier.createExpense(expense);

      if (createdExpense == null) {
        throw Exception('Failed to create expense');
      }

      // Vincular el OCR con el gasto
      await _receiptService.markAsUsedForExpense(_currentReceipt.id, createdExpense.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).expenseCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        // Navegar al dashboard
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorCreatingExpense}: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
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

  DateTime _parseDate(String dateStr, String format) {
    final parts = dateStr.split(RegExp(r'[/\-.]'));
    
    switch (format) {
      case 'dd/MM/yyyy':
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      case 'MM/dd/yyyy':
        return DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
      case 'yyyy-MM-dd':
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      case 'dd.MM.yyyy':
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      default:
        throw FormatException('Unknown date format: $format');
    }
  }
}

