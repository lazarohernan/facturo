import 'dart:io';
import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/invoices/models/invoice_attachment_model.dart';
import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import '../widgets/invoice_items_list.dart';
import '../widgets/invoice_item_form.dart';
import 'package:facturo/core/design_system/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';

class InvoiceForm extends ConsumerStatefulWidget {
  final Invoice? invoice;
  final Function(Invoice) onSubmit;
  final Map<String, dynamic>? ocrData; // Datos del OCR para prellenar

  const InvoiceForm({
    super.key,
    this.invoice,
    required this.onSubmit,
    this.ocrData,
  });

  @override
  ConsumerState<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends ConsumerState<InvoiceForm>
    with FreemiumMixin, AutomaticKeepAliveClientMixin {
  static const List<String> _documentPrefixes = ['INV', 'FAC'];

  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _documentDate;
  String? _clientId;
  double? _generalDiscount;
  String _generalDiscountType = 'percentage';
  double? _generalTax;
  String _generalTaxType = 'percentage';

  // Multi-attachment state (new system)
  final List<File> _newAttachmentFiles = [];
  List<InvoiceAttachment> _existingAttachments = [];
  bool _isUploading = false;
  bool _isPickingImages = false;
  bool _isLoadingAttachments = false;

  // Legacy single-image (backward compat for old invoices with photo_url only)
  String? _legacyPhotoUrl;
  bool _isGeneratingDocumentNumber = false;
  bool _isLoadingClients = false;
  List<Map<String, dynamic>> _clients = [];

  final List<InvoiceItem> _invoiceItems = [];

  String? _clientError;

  bool _isPaid = false;

  // Modo lectura/edición para facturas existentes
  bool _isReadOnly = true;
  String _selectedDocumentPrefix = _documentPrefixes.first;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _documentDate = widget.invoice?.documentDate ?? DateTime.now();
    // Set default values for discount and tax
    _generalDiscount = widget.invoice?.generalDiscount ?? 0.00;
    _generalTax = widget.invoice?.generalTax ?? 0.00;
    // Set paid status
    _isPaid = widget.invoice?.paid ?? false;
    // Load clients
    _loadClients();
    _initializeForm();
    _selectedDocumentPrefix = _extractDocumentPrefix(
      _documentNumberController.text,
    );

    // Si es factura nueva, iniciar en modo edición
    // Si es factura existente, iniciar en modo lectura
    _isReadOnly = widget.invoice != null;

    if (widget.invoice == null && widget.ocrData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateDocumentNumberIfNeeded();
      });
    }

    if (widget.invoice != null) {
      // Use Future.microtask to avoid conflicting with GoRouter's Navigator
      // rebuild cycle (known _elements.contains(element) assertion bug).
      Future.microtask(() {
        if (mounted) _loadExistingAttachments(widget.invoice!.id);
      });
    }
  }

  Future<void> _loadExistingAttachments(String invoiceId) async {
    setState(() => _isLoadingAttachments = true);
    try {
      final attachments = await ref
          .read(invoiceServiceProvider)
          .getInvoiceAttachments(invoiceId);

      // Resolve signed URLs for display
      final storage = StorageService(Supabase.instance.client);
      final resolved = <InvoiceAttachment>[];
      for (final a in attachments) {
        final url = await storage.getSignedUrl(a.storagePath);
        resolved.add(url != null ? a.copyWith(storagePath: url) : a);
      }

      if (mounted) setState(() => _existingAttachments = resolved);
    } catch (_) {
      // Silently fall back — legacy photoUrl still shows
    } finally {
      if (mounted) setState(() => _isLoadingAttachments = false);
    }
  }

  void _initializeForm() {
    // Prioridad: 1. Invoice existente, 2. Datos OCR, 3. Valores por defecto
    if (widget.invoice != null) {
      // Inicializar con factura existente (modo edición)
      _documentNumberController.text = widget.invoice!.documentNumber ?? '';
      _poNumberController.text = widget.invoice!.poNumber ?? '';
      _clientId = widget.invoice!.clientId;
      _generalDiscountType =
          widget.invoice!.generalDiscountType ?? 'percentage';
      _generalTaxType = widget.invoice!.generalTaxType ?? 'percentage';
      _legacyPhotoUrl = widget.invoice!.photoUrl;
      _notesController.text = widget.invoice!.notes ?? '';

      if (widget.invoice!.details != null) {
        _invoiceItems.addAll(widget.invoice!.details!);
      }
    } else if (widget.ocrData != null) {
      // Inicializar con datos del OCR (modo creación desde OCR)
      _initializeFromOCR();
    }
  }

  /// Inicializa el formulario con datos del OCR
  void _initializeFromOCR() {
    final ocrData = widget.ocrData!;

    debugPrint('🧾 Inicializando formulario con datos OCR: $ocrData');

    try {
      // Número de factura del OCR
      if (ocrData['invoiceNumber'] != null) {
        _documentNumberController.text = ocrData['invoiceNumber'].toString();
      }

      // Fecha del OCR (convertir formato US a DateTime)
      if (ocrData['date'] != null) {
        _documentDate =
            _parseOCRDate(ocrData['date'].toString()) ?? DateTime.now();
      }

      // Notas con información del OCR
      final ocrNotes = <String>[];
      if (ocrData['description'] != null) {
        ocrNotes.add('Description: ${ocrData['description']}');
      }
      if (ocrData['billingAddress'] != null) {
        ocrNotes.add('Billing Address: ${ocrData['billingAddress']}');
      }
      if (ocrData['paymentTerms'] != null) {
        ocrNotes.add('Payment Terms: ${ocrData['paymentTerms']}');
      }
      if (ocrNotes.isNotEmpty) {
        _notesController.text = ocrNotes.join('\n\n');
      }

      // Impuestos y descuentos del OCR
      if (ocrData['tax'] != null) {
        final taxAmount = _parseAmount(ocrData['tax']);
        if (taxAmount > 0) {
          _generalTax = taxAmount;
          _generalTaxType = 'fixed'; // Usar monto fijo del OCR
        }
      }

      // Items del OCR
      if (ocrData['items'] != null && ocrData['items'] is List) {
        final ocrItems = ocrData['items'] as List;
        for (final itemData in ocrItems) {
          if (itemData is Map<String, dynamic>) {
            final quantity = (itemData['quantity'] as num?)?.toDouble() ?? 1.0;
            double unitCost = _parseAmount(itemData['unitPrice']);
            if (unitCost <= 0) {
              unitCost = _parseAmount(itemData['amount']);
            }
            if (unitCost <= 0) {
              final total = _parseAmount(itemData['total']);
              if (total > 0 && quantity > 0) {
                unitCost = total / quantity;
              }
            }

            final rawDescription = itemData['description']?.toString() ?? '';
            final description = rawDescription.trim().isNotEmpty
                ? rawDescription.trim()
                : AppLocalizations.of(context).ocrItem;

            final item = InvoiceItem(
              id: const Uuid().v4(),
              description: description,
              quantity: quantity,
              unitCost: unitCost,
            );
            _invoiceItems.add(item);
          }
        }
      }

      // Si no hay items del OCR, crear uno basico con la información disponible
      if (_invoiceItems.isEmpty) {
        final description =
            ocrData['description']?.toString() ?? 'Services from OCR scan';
        final total = _parseAmount(ocrData['total']);
        final subtotal = _parseAmount(ocrData['subtotal']);
        final amount = subtotal > 0 ? subtotal : total;

        if (amount > 0) {
          final item = InvoiceItem(
            id: const Uuid().v4(),
            description: description,
            quantity: 1.0,
            unitCost: amount,
          );
          _invoiceItems.add(item);
        }
      }

      debugPrint(
        '✅ Formulario inicializado con ${_invoiceItems.length} items del OCR',
      );
    } catch (e) {
      debugPrint('❌ Error inicializando desde OCR: $e');
      // En caso de error, mostrar notificación pero continuar
      if (mounted) {
        SnackbarService.showWarning(
          context,
          message:
              '${AppLocalizations.of(context).warningOcrDataNotLoaded}: ${e.toString()}',
        );
      }
    }
  }

  /// Parsea fechas del OCR en formato estadounidense
  DateTime? _parseOCRDate(String dateStr) {
    try {
      // Intentar varios formatos de fecha estadounidenses
      final formats = [
        'MM/dd/yyyy',
        'M/d/yyyy',
        'MM-dd-yyyy',
        'M-d-yyyy',
        'MMMM d, yyyy',
        'MMM d, yyyy',
      ];

      for (final format in formats) {
        try {
          final formatter = DateFormat(format);
          return formatter.parse(dateStr);
        } catch (_) {
          continue;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing OCR date: $e');
      return null;
    }
  }

  /// Parsea cantidades monetarias del OCR
  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;

    final amountStr = amount
        .toString()
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(amountStr) ?? 0.0;
  }

  /// Construye el indicador visual de que la factura se está creando desde OCR
  Widget _buildOCRIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.cyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 Invoice created from OCR scan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data has been automatically extracted and pre-filled. Please review and adjust as needed.',
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome, color: Colors.blue[600], size: 20),
        ],
      ),
    );
  }

  // Load clients from the database
  Future<void> _loadClients() async {
    if (!mounted) return;

    setState(() {
      _isLoadingClients = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        debugPrint('❌ Usuario no autenticado');
        setState(() {
          _isLoadingClients = false;
        });
        return;
      }

      final response = await supabase
          .from('clients')
          .select('clients_id, client_name')
          .eq('user_id', userId)
          .eq('status', true)
          .order('client_name');

      if (!mounted) return;

      setState(() {
        _clients = List<Map<String, dynamic>>.from(response);
        _isLoadingClients = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingClients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).errorLoadingClients}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _poNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    setState(() => _isPickingImages = true);
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (images.isNotEmpty && mounted) {
        setState(() {
          _newAttachmentFiles.addAll(images.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).errorPickingImage}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  Future<void> _generateDocumentNumberIfNeeded({bool force = false}) async {
    if (widget.invoice != null) return;
    if (_isGeneratingDocumentNumber) return;
    if (!force && _documentNumberController.text.trim().isNotEmpty) return;

    setState(() {
      _isGeneratingDocumentNumber = true;
    });

    try {
      final nextNumber = await ref
          .read(invoiceServiceProvider)
          .generateNextDocumentNumber(prefix: _selectedDocumentPrefix);

      if (!mounted) return;

      _documentNumberController.text = nextNumber;
    } catch (e) {
      if (!mounted) return;
      SnackbarService.showWarning(
        context,
        message:
            '${AppLocalizations.of(context).errorLoadingData}: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingDocumentNumber = false;
        });
      }
    }
  }

  String _extractDocumentPrefix(String? documentNumber) {
    final normalizedValue = documentNumber?.trim() ?? '';
    if (normalizedValue.isEmpty) {
      return _documentPrefixes.first;
    }

    final match = RegExp(r'^([A-Za-z]+)[-\s]?\d+$').firstMatch(normalizedValue);
    return _normalizeDocumentPrefix(match?.group(1));
  }

  String _normalizeDocumentPrefix(String? prefix) {
    final normalizedPrefix = _sanitizeDocumentPrefixInput(prefix);

    if (normalizedPrefix.isEmpty) {
      return _documentPrefixes.first;
    }

    return normalizedPrefix;
  }

  String _sanitizeDocumentPrefixInput(String? prefix) {
    return (prefix ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
  }

  Future<void> _onDocumentPrefixSelected(String prefix) async {
    final normalizedPrefix = _normalizeDocumentPrefix(prefix);
    if (_selectedDocumentPrefix == normalizedPrefix) return;

    setState(() {
      _selectedDocumentPrefix = normalizedPrefix;
    });

    if (widget.invoice == null) {
      await _generateDocumentNumberIfNeeded(force: true);
      return;
    }

    final currentNumber = _documentNumberController.text.trim();
    final sequenceMatch = RegExp(r'(\d+)$').firstMatch(currentNumber);
    final sequence = sequenceMatch?.group(1);

    _documentNumberController.text = sequence == null || sequence.isEmpty
        ? '$normalizedPrefix-'
        : '$normalizedPrefix-$sequence';
  }

  Future<void> _openDocumentPrefixModal(AppLocalizations localizations) async {
    if (_isReadOnly) return;

    final selectedPrefix = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (context) {
        return _DocumentPrefixSheet(
          initialPrefix: _selectedDocumentPrefix,
          suggestions: _documentPrefixes,
          localizations: localizations,
          normalizePrefix: _normalizeDocumentPrefix,
          sanitizePrefix: _sanitizeDocumentPrefixInput,
        );
      },
    );

    if (!mounted || selectedPrefix == null) return;

    await _onDocumentPrefixSelected(selectedPrefix);
  }

  Future<void> _uploadAttachments(String invoiceId) async {
    if (_newAttachmentFiles.isEmpty) return;
    if (!mounted) return;

    setState(() => _isUploading = true);
    try {
      final startOrder = _existingAttachments.length;
      await ref
          .read(invoiceServiceProvider)
          .saveInvoiceAttachments(
            invoiceId: invoiceId,
            files: _newAttachmentFiles,
            startSortOrder: startOrder,
          );
      if (mounted) {
        setState(() => _newAttachmentFiles.clear());
        // Reload to get signed URLs for the newly uploaded files
        await _loadExistingAttachments(invoiceId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error uploading attachments: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).errorUploadingImage}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Si es una nueva factura, verificar límite freemium
    if (widget.invoice == null) {
      final canCreate = await executeIfAllowed(
        FreemiumAction.createInvoice,
        () async {
          await _createInvoice();
        },
      );

      // Si no se pudo crear por límite, executeIfAllowed ya mostró el paywall
      if (!canCreate) return;
    } else {
      // Si es edición, proceder normalmente
      await _createInvoice();
    }
  }

  Future<void> _createInvoice() async {
    try {
      _formKey.currentState!.save();

      final invoice = Invoice(
        id: widget.invoice?.id,
        documentNumber: _documentNumberController.text,
        documentDate: _documentDate,
        poNumber: _poNumberController.text,
        clientId: _clientId,
        generalDiscount: _generalDiscount,
        generalDiscountType: _generalDiscountType,
        generalTax: _generalTax,
        generalTaxType: _generalTaxType,
        // Preserve legacy photoUrl; new attachments go to invoice_attachments
        photoUrl: widget.invoice?.photoUrl,
        notes: _notesController.text,
        paid: _isPaid,
        details: _invoiceItems,
      );

      // Persist invoice in DB (onSubmit no longer pops the screen)
      await widget.onSubmit(invoice);

      // Upload any newly selected attachment files
      if (_newAttachmentFiles.isNotEmpty && mounted) {
        await _uploadAttachments(invoice.id);
      }

      // Now pop the screen after everything is saved
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        SnackbarService.showGenericError(context, error: e.toString());
      }
    }
  }

  // Método para editar un ítem de factura
  void _editInvoiceItem(InvoiceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return InvoiceItemForm(
          item: item,
          invoiceId: widget.invoice?.id,
          onSave: (updatedItem) {
            if (!mounted) return;
            setState(() {
              final index = _invoiceItems.indexWhere((i) => i.id == item.id);
              if (index != -1) {
                _invoiceItems[index] = updatedItem;
              }
            });
          },
        );
      },
    );
  }

  // Método para añadir un ítem de factura
  void _addInvoiceItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return InvoiceItemForm(
          invoiceId: widget.invoice?.id,
          onSave: (item) {
            setState(() {
              _invoiceItems.add(item);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final showPrefixEditor = widget.invoice == null || !_isReadOnly;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          LayoutSystem.isMobile(context)
              ? DesignTokens.spacingMd
              : DesignTokens.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de creación desde OCR
            if (widget.ocrData != null) _buildOCRIndicator(theme),

            // Estado de pago
            Container(
              margin: EdgeInsets.only(
                bottom: LayoutSystem.isMobile(context)
                    ? DesignTokens.spacingLg
                    : DesignTokens.spacingXl,
              ),
              padding: EdgeInsets.all(
                LayoutSystem.isMobile(context)
                    ? DesignTokens.spacingMd
                    : DesignTokens.spacingLg,
              ),
              decoration: BoxDecoration(
                color: _isPaid
                    ? Colors.green.withValues(alpha: isDark ? 0.2 : 0.1)
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                borderRadius: DesignTokens.radius(DesignTokens.borderRadiusLg),
                border: Border.all(
                  color: _isPaid
                      ? Colors.green.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      LayoutSystem.isMobile(context)
                          ? DesignTokens.spacingSm
                          : DesignTokens.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color: _isPaid
                          ? Colors.green.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaid ? Icons.check_circle : Icons.pending_actions,
                      color: _isPaid ? Colors.green : theme.colorScheme.primary,
                      size: LayoutSystem.isMobile(context)
                          ? DesignTokens.iconSizeLg
                          : DesignTokens.iconSizeXl,
                    ),
                  ),
                  SizedBox(
                    width: LayoutSystem.isMobile(context)
                        ? DesignTokens.spacingMd
                        : DesignTokens.spacingLg,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPaid ? localizations.paid : localizations.unpaid,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _isPaid
                                ? Colors.green
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPaid
                              ? AppLocalizations.of(
                                  context,
                                ).invoiceHasBeenMarkedAsPaid
                              : AppLocalizations.of(
                                  context,
                                ).invoiceIsPendingPayment,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: _isPaid ? localizations.paid : localizations.unpaid,
                    toggled: _isPaid,
                    child: Switch.adaptive(
                      value: _isPaid,
                      onChanged: _isReadOnly
                          ? null
                          : (value) {
                              setState(() {
                                _isPaid = value;
                              });
                            },
                      activeTrackColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Sección de información básica
            _buildSection(theme, localizations.invoiceDetails, [
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _documentNumberController,
                      style: theme.textTheme.bodyLarge,
                      readOnly: _isReadOnly,
                      decoration: InputDecoration(
                        labelText: '${localizations.invoiceNumber} *',
                        hintText: localizations.enterInvoiceNumber,
                        helperText: widget.invoice == null
                            ? localizations.invoiceNumberAutoGeneratedHelper
                            : null,
                        prefixIcon: Icon(
                          Icons.numbers,
                          size: LayoutSystem.isMobile(context)
                              ? DesignTokens.iconSizeSm
                              : DesignTokens.iconSizeMd,
                        ),
                        suffixIcon: _isGeneratingDocumentNumber
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: DesignTokens.radius(
                            DesignTokens.borderRadiusMd,
                          ),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: LayoutSystem.isMobile(context)
                              ? DesignTokens.spacingMd
                              : DesignTokens.spacingLg,
                          vertical: LayoutSystem.isMobile(context)
                              ? DesignTokens.spacingSm + 2
                              : DesignTokens.spacingMd + 2,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.pleaseEnterInvoiceNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                  if (showPrefixEditor) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 92,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () =>
                            _openDocumentPrefixModal(localizations),
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size(92, 56),
                          minimumSize: const Size(92, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedDocumentPrefix,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                label:
                    '${localizations.date}: ${_documentDate != null ? DateFormat('dd/MM/yyyy').format(_documentDate!) : localizations.selectDate}',
                button: true,
                child: InkWell(
                  onTap: _isReadOnly
                      ? null
                      : () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _documentDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: theme.colorScheme.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _documentDate = pickedDate;
                            });
                          }
                        },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: localizations.date,
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        size: LayoutSystem.isMobile(context)
                            ? DesignTokens.iconSizeSm
                            : DesignTokens.iconSizeMd,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: DesignTokens.radius(
                          DesignTokens.borderRadiusMd,
                        ),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: LayoutSystem.isMobile(context)
                            ? DesignTokens.spacingMd
                            : DesignTokens.spacingLg,
                        vertical: LayoutSystem.isMobile(context)
                            ? DesignTokens.spacingSm + 2
                            : DesignTokens.spacingMd + 2,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _documentDate != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_documentDate!)
                                : localizations.selectDate,
                            style: theme.textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Número de orden de compra
              TextFormField(
                controller: _poNumberController,
                style: theme.textTheme.bodyLarge,
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                  labelText: localizations.poNumber,
                  hintText: localizations.enterPoNumber,
                  prefixIcon: const Icon(Icons.receipt_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
            ]),

            // Sección de cliente
            _buildSection(theme, localizations.client, [
              const SizedBox(height: 8),
              _buildClientSelector(theme, localizations),
            ]),

            // Sección de ítems
            _buildSection(theme, localizations.items, [
              const SizedBox(height: 8),
              InvoiceItemsList(
                items: _invoiceItems,
                onItemEdit: _isReadOnly ? null : _editInvoiceItem,
                onItemDelete: _isReadOnly
                    ? null
                    : (index) {
                        setState(() {
                          _invoiceItems.removeAt(index);
                        });
                      },
                onAddItem: _isReadOnly ? null : _addInvoiceItem,
                isReadOnly: _isReadOnly,
              ),
            ]),

            // Sección de descuentos e impuestos
            _buildSection(theme, localizations.discountsAndTaxes, [
              const SizedBox(height: 8),
              _buildDiscountAndTaxSection(theme, localizations),
            ]),

            // Sección de notas
            _buildSection(theme, localizations.notes, [
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                style: theme.textTheme.bodyLarge,
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                  hintText: localizations.enterNotes,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                maxLines: 4,
                minLines: 3,
              ),
            ]),

            // Sección de foto adjunta
            _buildSection(theme, localizations.attachImage, [
              const SizedBox(height: 8),
              _buildInvoiceImageUpload(theme, localizations),
            ]),

            // Botón de guardar/editar
            _buildActionButton(theme, localizations),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent sections
  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // Helper method to build client selector
  Widget _buildClientSelector(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: '${localizations.client} *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            errorText: _clientError,
          ),
          child: _isLoadingClients
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _clientId,
                    hint: Text(localizations.selectClient),
                    isExpanded: true,
                    onChanged: _isReadOnly
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _clientId = newValue;
                              _clientError = null;
                            });
                          },
                    items: _clients.isEmpty
                        ? [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(localizations.noClientsYet),
                            ),
                          ]
                        : [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(localizations.selectClient),
                            ),
                            ..._clients.map((client) {
                              return DropdownMenuItem<String>(
                                value: client['clients_id'],
                                child: Text(client['client_name']),
                              );
                            }),
                          ],
                  ),
                ),
        ),
      ],
    );
  }

  // Helper method to build discount and tax section
  Widget _buildDiscountAndTaxSection(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Column(
      children: [
        // Descuento
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _generalDiscount?.toString() ?? '0',
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                  labelText: localizations.discount,
                  prefixIcon: const Icon(Icons.discount_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: _isReadOnly
                    ? null
                    : (value) {
                        setState(() {
                          _generalDiscount = double.tryParse(value) ?? 0;
                        });
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: localizations.discountType,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _generalDiscountType,
                    isExpanded: true,
                    onChanged: _isReadOnly
                        ? null
                        : (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _generalDiscountType = newValue;
                              });
                            }
                          },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'percentage',
                        child: Text(localizations.percentage),
                      ),
                      DropdownMenuItem<String>(
                        value: 'fixed',
                        child: Text(localizations.fixedAmount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Impuesto
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _generalTax?.toString() ?? '0',
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                  labelText: localizations.tax,
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: _isReadOnly
                    ? null
                    : (value) {
                        setState(() {
                          _generalTax = double.tryParse(value) ?? 0;
                        });
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: localizations.taxType,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _generalTaxType,
                    isExpanded: true,
                    onChanged: _isReadOnly
                        ? null
                        : (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _generalTaxType = newValue;
                              });
                            }
                          },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'percentage',
                        child: Text(localizations.percentage),
                      ),
                      DropdownMenuItem<String>(
                        value: 'fixed',
                        child: Text(localizations.fixedAmount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build invoice image upload section (multi-attachment)
  Widget _buildInvoiceImageUpload(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    // Combine all items: existing attachments + new local files
    final existingCount = _existingAttachments.length;
    final newCount = _newAttachmentFiles.length;
    // Also include legacy photoUrl as a virtual "existing" entry if no new-style attachments yet
    final hasLegacy =
        _legacyPhotoUrl != null &&
        _legacyPhotoUrl!.isNotEmpty &&
        existingCount == 0;
    final totalCount = existingCount + newCount + (hasLegacy ? 1 : 0);
    final hasAny = totalCount > 0;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading/uploading indicator
          if (_isLoadingAttachments || _isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isUploading
                        ? localizations.uploadingImage
                        : localizations.loadingImage,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

          // Thumbnails grid
          if (hasAny) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Legacy single photo_url
                if (hasLegacy)
                  _buildThumbnail(
                    theme: theme,
                    child: Image.network(
                      _legacyPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () => _previewImageAt(source: 'legacy'),
                    onDelete: _isReadOnly
                        ? null
                        : () => setState(() => _legacyPhotoUrl = null),
                  ),
                // Existing attachments (signed URLs)
                for (var i = 0; i < existingCount; i++)
                  _buildThumbnail(
                    theme: theme,
                    child: Image.network(
                      _existingAttachments[i].storagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () => _previewImageAt(existingIndex: i),
                    onDelete: _isReadOnly
                        ? null
                        : () => _removeExistingAttachment(i),
                  ),
                // New local files (not yet uploaded)
                for (var i = 0; i < newCount; i++)
                  _buildThumbnail(
                    theme: theme,
                    badge: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    child: Image.file(
                      _newAttachmentFiles[i],
                      fit: BoxFit.cover,
                    ),
                    onTap: () => _previewImageAt(newIndex: i),
                    onDelete: () =>
                        setState(() => _newAttachmentFiles.removeAt(i)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ] else if (!_isLoadingAttachments)
            // Empty state placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isPickingImages
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.loadingImage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizations.noImageSelected,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

          // Add more button (edit mode only)
          if (!_isReadOnly)
            SizedBox(
              width: double.infinity,
              child: _isPickingImages
                  ? ElevatedButton.icon(
                      onPressed: null,
                      icon: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      label: Text(localizations.loadingImage),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 18,
                      ),
                      label: Text(localizations.uploadInvoiceImage),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail({
    required ThemeData theme,
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onDelete,
    Widget? badge,
  }) {
    const size = 90.0;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: size, height: size, child: child),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          if (badge != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: badge,
              ),
            ),
        ],
      ),
    );
  }

  void _previewImageAt({String? source, int? existingIndex, int? newIndex}) {
    Widget imageWidget;
    if (source == 'legacy' && _legacyPhotoUrl != null) {
      imageWidget = Image.network(
        _legacyPhotoUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, p) => p == null
            ? child
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      );
    } else if (existingIndex != null) {
      imageWidget = Image.network(
        _existingAttachments[existingIndex].storagePath,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, p) => p == null
            ? child
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      );
    } else if (newIndex != null) {
      imageWidget = Image.file(
        _newAttachmentFiles[newIndex],
        fit: BoxFit.contain,
      );
    } else {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: imageWidget,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context).close,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Pinch to zoom • Tap to close',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doDeleteExistingAttachment(int index) async {
    final attachment = _existingAttachments[index];
    try {
      await ref
          .read(invoiceServiceProvider)
          .deleteInvoiceAttachment(attachment);
      if (mounted) {
        setState(() => _existingAttachments.removeAt(index));
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showGenericError(context, error: e.toString());
      }
    }
  }

  void _removeExistingAttachment(int index) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(AppLocalizations.of(dlgCtx).deleteImage),
        content: Text(AppLocalizations.of(dlgCtx).deleteImageConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(AppLocalizations.of(dlgCtx).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              _doDeleteExistingAttachment(index);
            },
            child: Text(
              AppLocalizations.of(dlgCtx).delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de acción según el modo actual
  Widget _buildActionButton(ThemeData theme, AppLocalizations localizations) {
    final isExistingInvoice = widget.invoice != null;

    // Si es factura existente y está en modo lectura, mostrar botón "Editar"
    if (isExistingInvoice && _isReadOnly) {
      return FilledButton(
        onPressed: () {
          setState(() {
            _isReadOnly = false;
          });
        },
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: Size(
            double.infinity,
            LayoutSystem.isMobile(context) ? 48 : 56,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radius(DesignTokens.borderRadiusLg),
          ),
          padding: EdgeInsets.symmetric(
            vertical: LayoutSystem.isMobile(context)
                ? DesignTokens.spacingMd
                : DesignTokens.spacingLg,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_outlined,
              size: LayoutSystem.isMobile(context)
                  ? DesignTokens.iconSizeSm
                  : DesignTokens.iconSizeMd,
              color: theme.colorScheme.onPrimary,
            ),
            SizedBox(
              width: LayoutSystem.isMobile(context)
                  ? DesignTokens.spacingSm
                  : DesignTokens.spacingMd,
            ),
            Text(
              localizations.editInvoice,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    // Si es factura existente en modo edición, mostrar botones Cancelar y Actualizar
    if (isExistingInvoice && !_isReadOnly) {
      return Row(
        children: [
          // Botón Cancelar edición
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isReadOnly = true;
                  // Restaurar valores originales
                  _initializeForm();
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                localizations.cancelEdit,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: LayoutSystem.isMobile(context)
                ? DesignTokens.spacingSm
                : DesignTokens.spacingMd,
          ),
          // Botón Actualizar
          Expanded(
            child: FilledButton(
              onPressed: _submitForm,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: Size(
                  double.infinity,
                  LayoutSystem.isMobile(context) ? 48 : 56,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.radius(
                    DesignTokens.borderRadiusLg,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: LayoutSystem.isMobile(context)
                      ? DesignTokens.spacingMd
                      : DesignTokens.spacingLg,
                ),
              ),
              child: Text(
                localizations.updateInvoice,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    // Factura nueva - mostrar botón Guardar
    return FilledButton(
      onPressed: _submitForm,
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: Size(
          double.infinity,
          LayoutSystem.isMobile(context) ? 48 : 56,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius(DesignTokens.borderRadiusLg),
        ),
        padding: EdgeInsets.symmetric(
          vertical: LayoutSystem.isMobile(context)
              ? DesignTokens.spacingMd
              : DesignTokens.spacingLg,
        ),
      ),
      child: Text(
        _getButtonText(localizations),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  String _getButtonText(AppLocalizations localizations) {
    // Caso 1: Factura desde OCR (primera vez)
    if (widget.ocrData != null) {
      return localizations.saveInvoice;
    }

    // Caso 2: Factura nueva manual
    return localizations.saveInvoice;
  }
}

class _DocumentPrefixSheet extends StatefulWidget {
  const _DocumentPrefixSheet({
    required this.initialPrefix,
    required this.suggestions,
    required this.localizations,
    required this.normalizePrefix,
    required this.sanitizePrefix,
  });

  final String initialPrefix;
  final List<String> suggestions;
  final AppLocalizations localizations;
  final String Function(String?) normalizePrefix;
  final String Function(String?) sanitizePrefix;

  @override
  State<_DocumentPrefixSheet> createState() => _DocumentPrefixSheetState();
}

class _DocumentPrefixSheetState extends State<_DocumentPrefixSheet> {
  late String _currentPrefix;
  late String _fieldValue;

  @override
  void initState() {
    super.initState();
    _currentPrefix = widget.initialPrefix;
    _fieldValue = widget.initialPrefix;
  }

  void _applySuggestedPrefix(String prefix) {
    setState(() {
      _currentPrefix = prefix;
      _fieldValue = prefix;
    });
  }

  void _onPrefixChanged(String value) {
    final sanitizedPrefix = widget.sanitizePrefix(value);
    setState(() {
      _currentPrefix = sanitizedPrefix;
      _fieldValue = sanitizedPrefix;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.localizations.changeInvoicePrefix,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.localizations.invoicePrefixHelper,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.suggestions.map((prefix) {
                final isSelected = _currentPrefix == prefix;
                return ChoiceChip(
                  label: Text(prefix),
                  selected: isSelected,
                  onSelected: (_) => _applySuggestedPrefix(prefix),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey(_fieldValue),
              initialValue: _fieldValue,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: widget.localizations.customInvoicePrefix,
                hintText: 'INV',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onPrefixChanged,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.localizations.cancel),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: _currentPrefix.isEmpty
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop(widget.normalizePrefix(_currentPrefix)),
                    child: Text(widget.localizations.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
