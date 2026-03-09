import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/features/ocr/services/ocr_receipt_service.dart';
import 'package:facturo/features/ocr/models/ocr_scan.dart';
import 'package:facturo/features/ocr/widgets/ocr_conversion_bottom_sheet.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Vista para revisar y editar datos extraídos del OCR antes de guardar
class OCRReviewView extends ConsumerStatefulWidget {
  final File imageFile;
  final Map<String, dynamic> extractedData;

  const OCRReviewView({
    super.key,
    required this.imageFile,
    required this.extractedData,
  });

  @override
  ConsumerState<OCRReviewView> createState() => _OCRReviewViewState();
}

class _OCRReviewViewState extends ConsumerState<OCRReviewView>
    with FreemiumMixin {
  final OCRReceiptService _receiptService = OCRReceiptService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _companyController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _dateController;
  late TextEditingController _subtotalController;
  late TextEditingController _taxController;
  late TextEditingController _totalController;
  
  List<Map<String, dynamic>> _items = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadItems();
  }

  void _initializeControllers() {
    _companyController = TextEditingController(
      text: widget.extractedData['company']?.toString() ?? '',
    );
    _invoiceNumberController = TextEditingController(
      text: widget.extractedData['invoiceNumber']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.extractedData['date']?.toString() ?? '',
    );
    _subtotalController = TextEditingController(
      text: widget.extractedData['subtotal']?.toString() ?? '',
    );
    _taxController = TextEditingController(
      text: widget.extractedData['tax']?.toString() ?? '',
    );
    _totalController = TextEditingController(
      text: widget.extractedData['total']?.toString() ?? '',
    );
  }

  void _loadItems() {
    final items = widget.extractedData['items'] as List?;
    if (items != null) {
      _items = List<Map<String, dynamic>>.from(
        items.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    }
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
        title: Text(localizations.ocrReviewTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              
              // Botones de acción
              _buildActionButtons(localizations, theme),
            ],
          ),
        ),
      ),
    );
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
                Text(
                  localizations.scannedImage,
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
              child: Image.file(
                widget.imageFile,
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
                          localizations.imageNotAvailable,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildBasicInfoSection(
      AppLocalizations localizations, ThemeData theme) {
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
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: localizations.companyName,
                prefixIcon: Icon(PhosphorIcons.buildings(PhosphorIconsStyle.regular)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(
                labelText: localizations.invoiceNumber,
                prefixIcon: Icon(PhosphorIcons.hash(PhosphorIconsStyle.regular)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: localizations.dateWithFormat,
                prefixIcon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSection(
      AppLocalizations localizations, ThemeData theme) {
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
            TextFormField(
              controller: _subtotalController,
              decoration: InputDecoration(
                labelText: localizations.ocrSubtotal,
                prefixIcon: Icon(PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taxController,
              decoration: InputDecoration(
                labelText: localizations.ocrTax,
                prefixIcon: Icon(PhosphorIcons.percent(PhosphorIconsStyle.regular)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalController,
              decoration: InputDecoration(
                labelText: localizations.ocrTotal,
                prefixIcon: Icon(PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular)),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(
      AppLocalizations localizations, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.ocrItems,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
                  label: Text(AppLocalizations.of(context).addItem),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(AppLocalizations.of(context).noItemsFound),
              )
            else
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemRow(index, item, theme);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, Map<String, dynamic> item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item['description']?.toString() ?? AppLocalizations.of(context).itemNumberLabel(index + 1)),
        subtitle: Text(
          AppLocalizations.of(context).qtyTimesPrice((item['quantity'] ?? 1).toString(), item['unitPrice']?.toStringAsFixed(2) ?? '0.00'),
        ),
        trailing: Text(
          '\$${item['total']?.toStringAsFixed(2) ?? '0.00'}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _editItem(index),
      ),
    );
  }

  Widget _buildActionButtons(
      AppLocalizations localizations, ThemeData theme) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _showSaveOptions,
          icon: Icon(PhosphorIcons.floppyDisk(PhosphorIconsStyle.regular)),
          label: Text(localizations.saveScannedReceipt),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _rescan,
          icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular)),
          label: Text(AppLocalizations.of(context).rescan),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _addItem() {
    setState(() {
      _items.add({
        'quantity': 1,
        'description': '',
        'unitPrice': 0.0,
        'total': 0.0,
      });
    });
    _editItem(_items.length - 1);
  }

  void _editItem(int index) {
    final item = _items[index];
    showDialog(
      context: context,
      builder: (context) => _ItemEditDialog(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            _items[index] = updatedItem;
          });
        },
      ),
    );
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

  void _showSaveOptions() {
    if (!_formKey.currentState!.validate()) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OCRConversionBottomSheet(
        onSaveOnly: () {
          Navigator.pop(context);
          _saveReceiptOnly();
        },
        onConvertToExpense: () {
          Navigator.pop(context);
          _saveAndConvertToExpense();
        },
        onConvertToInvoice: () {
          Navigator.pop(context);
          _saveAndConvertToInvoice();
        },
      ),
    );
  }

  Future<void> _saveReceiptOnly() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos actualizados
      final updatedData = Map<String, dynamic>.from(widget.extractedData);
      updatedData['company'] = _companyController.text;
      updatedData['invoiceNumber'] = _invoiceNumberController.text;
      updatedData['date'] = _dateController.text;
      updatedData['subtotal'] = _subtotalController.text;
      updatedData['tax'] = _taxController.text;
      updatedData['total'] = _totalController.text;
      updatedData['items'] = _items;

      // Guardar en Supabase
      var receiptId = await _receiptService.saveOCRReceipt(
        extractedData: updatedData,
        imagePath: widget.imageFile.path,
      );

      // Manejar duplicados
      if (receiptId != null && receiptId.startsWith('DUPLICATE:') && mounted) {
        final shouldSave = await _showDuplicateDialog();
        if (shouldSave != true) {
          return;
        }
        // Forzar guardado ignorando duplicado
        updatedData['_forceSave'] = true;
        receiptId = await _receiptService.saveOCRReceipt(
          extractedData: updatedData,
          imagePath: widget.imageFile.path,
        );
      }

      if (receiptId != null && !receiptId.startsWith('DUPLICATE:') && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).receiptSavedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // Navegar al dashboard
        context.go('/dashboard');
      } else {
        throw Exception('Failed to save receipt');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSavingReceipt}: ${e.toString()}'),
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

  Future<void> _saveAndConvertToExpense() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos actualizados
      final updatedData = Map<String, dynamic>.from(widget.extractedData);
      updatedData['company'] = _companyController.text;
      updatedData['invoiceNumber'] = _invoiceNumberController.text;
      updatedData['date'] = _dateController.text;
      updatedData['subtotal'] = _subtotalController.text;
      updatedData['tax'] = _taxController.text;
      updatedData['total'] = _totalController.text;
      updatedData['items'] = _items;

      // Guardar en Supabase
      var receiptId = await _receiptService.saveOCRReceipt(
        extractedData: updatedData,
        imagePath: widget.imageFile.path,
      );

      // Manejar duplicados
      if (receiptId != null && receiptId.startsWith('DUPLICATE:') && mounted) {
        final shouldSave = await _showDuplicateDialog();
        if (shouldSave != true) {
          return;
        }
        updatedData['_forceSave'] = true;
        receiptId = await _receiptService.saveOCRReceipt(
          extractedData: updatedData,
          imagePath: widget.imageFile.path,
        );
      }

      if (receiptId != null && !receiptId.startsWith('DUPLICATE:') && mounted) {
        final receipt = await _receiptService.getOCRReceiptById(receiptId);
        if (receipt != null && mounted) {
          await _convertToExpense(receipt);
        }
      } else {
        throw Exception('Failed to save receipt');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSavingReceipt}: ${e.toString()}'),
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

  Future<void> _saveAndConvertToInvoice() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar datos actualizados
      final updatedData = Map<String, dynamic>.from(widget.extractedData);
      updatedData['company'] = _companyController.text;
      updatedData['invoiceNumber'] = _invoiceNumberController.text;
      updatedData['date'] = _dateController.text;
      updatedData['subtotal'] = _subtotalController.text;
      updatedData['tax'] = _taxController.text;
      updatedData['total'] = _totalController.text;
      updatedData['items'] = _items;

      // Guardar en Supabase
      var receiptId = await _receiptService.saveOCRReceipt(
        extractedData: updatedData,
        imagePath: widget.imageFile.path,
      );

      // Manejar duplicados
      if (receiptId != null && receiptId.startsWith('DUPLICATE:') && mounted) {
        final shouldSave = await _showDuplicateDialog();
        if (shouldSave != true) {
          return;
        }
        updatedData['_forceSave'] = true;
        receiptId = await _receiptService.saveOCRReceipt(
          extractedData: updatedData,
          imagePath: widget.imageFile.path,
        );
      }

      if (receiptId != null && !receiptId.startsWith('DUPLICATE:') && mounted) {
        final receipt = await _receiptService.getOCRReceiptById(receiptId);
        if (receipt != null && mounted) {
          await _convertToInvoice(receipt);
        }
      } else {
        throw Exception('Failed to save receipt');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorSavingReceipt}: ${e.toString()}'),
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

  Future<bool?> _showDuplicateDialog() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(localizations.duplicateReceiptTitle)),
          ],
        ),
        content: Text(localizations.duplicateReceiptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.saveAnyway),
          ),
        ],
      ),
    );
  }

  void _rescan() {
    context.pop();
  }

  Future<void> _convertToExpense(OCRScan receipt) async {
    try {
      final extractedData = receipt.extractedData ?? {};
      final total = receipt.totalAmount ?? 
          double.tryParse(extractedData['total']?.toString() ?? '0.0') ?? 0.0;
      final tax = extractedData['tax'] != null 
          ? (extractedData['tax'] is num 
              ? (extractedData['tax'] as num).toDouble() 
              : double.tryParse(extractedData['tax'].toString()))
          : null;

      // Parsear fecha si está disponible
      DateTime? expenseDate;
      try {
        if (receipt.date != null) {
          final dateStr = receipt.date!;
          for (var format in ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd.MM.yyyy']) {
            try {
              expenseDate = _parseDate(dateStr, format);
              break;
            } catch (e) {
              continue;
            }
          }
        }
      } catch (e) {
        expenseDate = null;
      }
      expenseDate ??= DateTime.now();

      // Obtener userId del usuario autenticado
      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        throw Exception('User not authenticated');
      }

      // Crear el gasto
      final expense = Expense(
        userId: authState.user!.id,
        merchant: receipt.companyName ?? AppLocalizations.of(context).unknownCompany,
        category: null,
        expenseDate: expenseDate,
        total: total,
        tax: tax,
        description: AppLocalizations.of(context).createdFromOcrReceipt(receipt.invoiceNumber ?? ""),
        receiptUrl: receipt.imageUrl,
      );

      // Guardar gasto en Supabase usando el provider
      final expenseNotifier = ref.read(expenseDetailProvider.notifier);
      final createdExpense = await expenseNotifier.createExpense(expense);

      if (createdExpense == null) {
        throw Exception('Failed to create expense');
      }

      // Vincular el OCR con el gasto
      await _receiptService.markAsUsedForExpense(receipt.id, createdExpense.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).expenseCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        // Navegar a la vista de gastos
        context.go('/expenses');
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
    }
  }

  Future<void> _convertToInvoice(OCRScan receipt) async {
    try {
      final extractedData = receipt.extractedData ?? {};
      final items = extractedData['items'] as List? ?? [];
      
      // Convertir items del OCR a InvoiceItem
      final invoiceItems = items.map((item) {
        final quantity = item['quantity'] ?? 1;
        final unitPrice = item['unitPrice'] ?? 0.0;
        return InvoiceItem(
          description: item['description']?.toString() ?? '',
          quantity: quantity is num ? quantity.toDouble() : double.tryParse(quantity.toString()) ?? 1.0,
          unitCost: unitPrice is num ? unitPrice.toDouble() : double.tryParse(unitPrice.toString()) ?? 0.0,
        );
      }).toList();

      final tax = extractedData['tax'] != null 
          ? (extractedData['tax'] is num 
              ? (extractedData['tax'] as num).toDouble() 
              : double.tryParse(extractedData['tax'].toString()))
          : null;

      // Parsear fecha si está disponible
      DateTime? invoiceDate;
      try {
        if (receipt.date != null) {
          final dateStr = receipt.date!;
          for (var format in ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd.MM.yyyy']) {
            try {
              invoiceDate = _parseDate(dateStr, format);
              break;
            } catch (e) {
              continue;
            }
          }
        }
      } catch (e) {
        invoiceDate = null;
      }
      invoiceDate ??= DateTime.now();

      // Crear la factura
      final invoice = Invoice(
        documentNumber: receipt.invoiceNumber ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
        documentDate: invoiceDate,
        notes: AppLocalizations.of(context).createdFromOcrScan(receipt.companyName ?? AppLocalizations.of(context).unknownCompany),
        photoUrl: receipt.imageUrl,
        details: invoiceItems,
        generalTax: tax,
      );

      // Guardar factura en Supabase usando el provider con SubscriptionService
      final invoiceService = ref.read(invoiceServiceProvider);
      final createdInvoice = await invoiceService.createInvoice(invoice);

      // Vincular el OCR con la factura
      await _receiptService.markAsUsedForInvoice(receipt.id, createdInvoice.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).invoiceCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        // Navegar a la vista de facturas
        context.go('/invoices');
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
    }
  }

  void _showImageDialog() {
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.scannedImage,
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
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
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
}

class _ItemEditDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;

  const _ItemEditDialog({
    required this.item,
    required this.onSave,
  });

  @override
  State<_ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<_ItemEditDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.item['description']?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item['quantity']?.toString() ?? '1',
    );
    _unitPriceController = TextEditingController(
      text: widget.item['unitPrice']?.toString() ?? '0.00',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).editItem),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).quantity,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _unitPriceController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).unitPrice,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }

  void _save() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    final total = quantity * unitPrice;

    widget.onSave({
      'quantity': quantity,
      'description': _descriptionController.text,
      'unitPrice': unitPrice,
      'total': total,
    });

    Navigator.pop(context);
  }
}

