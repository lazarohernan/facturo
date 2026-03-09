import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/features/ocr/models/ocr_scan.dart';
import 'package:facturo/features/ocr/services/ocr_receipt_service.dart';
import 'package:facturo/features/ocr/services/gemini_ocr_service.dart';
import 'package:facturo/features/expenses/models/expense_model.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

/// Vista principal del OCR con tabs para recibos guardados y escaneo
class ReceiptUploaderPage extends ConsumerStatefulWidget {
  const ReceiptUploaderPage({super.key});

  @override
  ConsumerState<ReceiptUploaderPage> createState() =>
      _ReceiptUploaderPageState();
}

class _ReceiptUploaderPageState extends ConsumerState<ReceiptUploaderPage>
    with FreemiumMixin, WidgetsBindingObserver {
  final OCRReceiptService _receiptService = OCRReceiptService();
  final GeminiOCRService _geminiService = GeminiOCRService();
  final ImagePicker _imagePicker = ImagePicker();
  List<OCRScan> _savedReceipts = [];
  bool _isLoading = true;

  // Notificador de progreso para el escaneo
  final ValueNotifier<double> _scanProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<String> _scanStatus = ValueNotifier<String>('Preparing...');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedReceipts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanProgress.dispose();
    _scanStatus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refrescar cuando la app vuelve a primer plano
    if (state == AppLifecycleState.resumed && mounted) {
      _loadSavedReceipts();
    }
  }

  Future<void> _loadSavedReceipts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final receipts = await _receiptService.getUserOCRReceipts();
      if (mounted) {
        setState(() {
          _savedReceipts = receipts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.ocrScannerTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: localizations.goBack,
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: _buildSavedReceiptsTab(localizations, theme),
    );
  }

  Widget _buildSavedReceiptsTab(
      AppLocalizations localizations, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: _savedReceipts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.scan(PhosphorIconsStyle.regular),
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noSavedReceipts,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.scanFirstReceipt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedReceipts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedReceipts.length,
                    itemBuilder: (context, index) {
                      final receipt = _savedReceipts[index];
                      return _buildReceiptCard(receipt, theme, localizations);
                    },
                  ),
                ),
        ),
        _buildBottomSection(localizations, theme),
      ],
    );
  }

  Widget _buildBottomSection(AppLocalizations localizations, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showScanOptions,
                icon: Icon(PhosphorIcons.scan(PhosphorIconsStyle.regular), size: 20),
                label: Text(
                  localizations.scanReceipt,
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
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tapReceiptToViewOrScan,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(OCRScan receipt, ThemeData theme, AppLocalizations localizations) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final companyName = receipt.companyName ?? localizations.unknownCompany;
    final total = receipt.totalAmount ?? 0.0;
    final date = receipt.date ?? dateFormat.format(receipt.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewReceipt(receipt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del recibo
              GestureDetector(
                onTap: () => _showImageDialog(receipt.imageUrl),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: receipt.imageUrl != null
                        ? Image.network(
                            receipt.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  PhosphorIcons.receipt(PhosphorIconsStyle.regular),
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 24,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              PhosphorIcons.receipt(PhosphorIconsStyle.regular),
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Información del recibo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      companyName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    if (receipt.invoiceNumber != null)
                      Text(
                        '${localizations.invoiceNumber} ${receipt.invoiceNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Monto y acciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (receipt.invoiceId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        localizations.saved,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              // Menú de acciones (tres puntos)
              IconButton(
                icon: Icon(
                  PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: AppLocalizations.of(context).moreOptions,
                onPressed: () => _showOptionsBottomSheet(receipt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewReceipt(OCRScan receipt) {
    context.push('/receipt-detail', extra: receipt);
  }

  void _showOptionsBottomSheet(OCRScan receipt) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  PhosphorIcons.pencil(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.primary,
                ),
                title: Text(localizations.edit),
                onTap: () {
                  Navigator.pop(context);
                  _editReceipt(receipt);
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.fileText(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.primary,
                ),
                title: Text(localizations.saveExpense),
                onTap: () {
                  Navigator.pop(context);
                  _saveAsExpense(receipt);
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.invoice(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.primary,
                ),
                title: Text(localizations.saveInvoice),
                onTap: () {
                  Navigator.pop(context);
                  _saveAsInvoice(receipt);
                },
              ),
              ListTile(
                leading: Icon(
                  PhosphorIcons.trash(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.error,
                ),
                title: Text(localizations.delete),
                onTap: () {
                  Navigator.pop(context);
                  _deleteReceipt(receipt);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null) return;
    
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
                              localizations.scannedReceipt,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: localizations.close,
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
                              imageUrl,
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

  void _showScanOptions() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    localizations.scanReceipt,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    localizations.chooseHowToAddReceipt,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildScanOption(
                          icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                          iconColor: ProfileColors.business,
                          title: localizations.camera,
                          subtitle: localizations.takePhoto,
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToCapture(isCamera: true);
                          },
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScanOption(
                          icon: PhosphorIcons.image(PhosphorIconsStyle.regular),
                          iconColor: ProfileColors.language,
                          title: localizations.gallery,
                          subtitle: localizations.selectFromPhotos,
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToCapture(isCamera: false);
                          },
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCapture({required bool isCamera}) async {
    try {
      final localizations = AppLocalizations.of(context);
      
      // Verificar límite freemium antes de capturar
      final canProceed = await checkFreemiumAction(FreemiumAction.useOCR);
      if (!canProceed) return;

      final XFile? image = await _imagePicker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null || !mounted) return;

      // Resetear progreso
      _scanProgress.value = 0.0;
      _scanStatus.value = localizations.creatingInvoice;

      // Mostrar indicador de procesamiento
      _showProcessingDialog();

      try {
        final imageFile = File(image.path);
        
        // Etapa 1: Preparando imagen (10%)
        _scanProgress.value = 0.10;
        _scanStatus.value = localizations.loadingImage;
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Etapa 2: Inicializando AI (25%)
        _scanProgress.value = 0.25;
        _scanStatus.value = localizations.initializingAI;
        await _geminiService.initialize();
        
        // Etapa 3: Enviando a procesamiento (40%)
        _scanProgress.value = 0.40;
        _scanStatus.value = localizations.sendingToAI;
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Procesar imagen con Gemini OCR
        Map<String, dynamic>? extractedData;
        
        if (_geminiService.isAvailable) {
          // Etapa 4: Procesando con AI (60%)
          _scanProgress.value = 0.60;
          _scanStatus.value = localizations.extractingData;
          
          extractedData = await _geminiService.processInvoiceImage(imageFile);
          
          // Etapa 5: Datos extraídos (85%)
          _scanProgress.value = 0.85;
          _scanStatus.value = localizations.processingResults;
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        // Si Gemini no está disponible o falló, usar datos vacíos
        extractedData ??= {
          'company': null,
          'invoiceNumber': null,
          'date': null,
          'items': [],
          'subtotal': null,
          'tax': null,
          'total': null,
          'processedBy': 'manual',
        };

        // Etapa 6: Completado (100%)
        _scanProgress.value = 1.0;
        _scanStatus.value = localizations.complete;
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;
        
        // Cerrar diálogo de procesamiento
        Navigator.of(context).pop();

        // Navegar a vista de revisión
        final result = await context.push<bool>('/ocr/review', extra: {
          'imageFile': imageFile,
          'extractedData': extractedData,
        });
        
        // Refrescar la lista solo si el usuario guardó algo (result == true)
        if (mounted && result == true) {
          _loadSavedReceipts();
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar diálogo
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).errorProcessingImage}: ${e.toString()}'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      } finally {
        // Processing completed
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).errorPickingImage}: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _showProcessingDialog() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animación Lottie de escaneo más grande
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset(
                    'assets/animations/document_ocr_scan.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  localizations.processingReceipt,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Estado dinámico del proceso
                ValueListenableBuilder<String>(
                  valueListenable: _scanStatus,
                  builder: (context, status, child) {
                    return Text(
                      status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Barra de progreso real
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.scanningProgress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Porcentaje real
                        ValueListenableBuilder<double>(
                          valueListenable: _scanProgress,
                          builder: (context, progress, child) {
                            return Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Barra de progreso real
                    ValueListenableBuilder<double>(
                      valueListenable: _scanProgress,
                      builder: (context, progress, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editReceipt(OCRScan receipt) {
    // Navegar a la vista de edición del recibo
    context.push('/receipt-detail', extra: receipt);
  }

  void _saveAsInvoice(OCRScan receipt) async {
    try {
      final theme = Theme.of(context);
      
      final localizations = AppLocalizations.of(context);
      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.saveInvoice),
            content: Text(localizations.convertReceiptToInvoice),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  localizations.createInvoice,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        // Navegar al formulario de factura con datos prellenados
        final invoiceData = {
          'company_name': receipt.companyName,
          'total_amount': receipt.totalAmount,
          'invoice_number': receipt.invoiceNumber,
          'date': receipt.date,
          'source_ocr_scan_id': receipt.id,
        };

        context.push('/invoice-form', extra: invoiceData);
      }
    } catch (e) {
      if (!mounted) return;
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorCreatingInvoice}: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  void _saveAsExpense(OCRScan receipt) async {
    try {
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      
      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.saveExpense),
            content: Text(localizations.convertReceiptToExpense),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  localizations.createExpense,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Obtener datos del recibo
        final extractedData = receipt.extractedData ?? {};
        final total = receipt.totalAmount ?? 
            double.tryParse(extractedData['total']?.toString() ?? '0.0') ?? 0.0;
        final tax = extractedData['tax'] != null 
            ? double.tryParse(extractedData['tax'].toString()) 
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
          merchant: receipt.companyName ?? localizations.unknownCompany,
          category: null,
          expenseDate: expenseDate,
          total: total,
          tax: tax,
          description: localizations.createdFromOcrReceipt(receipt.invoiceNumber ?? ""),
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
              content: Text(localizations.expenseCreatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );

          // Refrescar la lista
          _loadSavedReceipts();
        }
      }
    } catch (e) {
      if (!mounted) return;
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorCreatingExpense}: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  DateTime _parseDate(String dateStr, String format) {
    final parts = dateStr.split(RegExp(r'[\/\-.]'));
    
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

  void _deleteReceipt(OCRScan receipt) async {
    try {
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      
      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              localizations.deleteReceipt,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.confirmDeleteReceipt),
                const SizedBox(height: 8),
                Text(
                  '${receipt.companyName ?? localizations.unknownCompany} - \$${receipt.totalAmount?.toStringAsFixed(2) ?? "0.00"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (receipt.invoiceId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.warning(PhosphorIconsStyle.regular),
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations.receiptLinkedToInvoice,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(localizations.delete),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Eliminar el recibo
        final success = await _receiptService.deleteOCRReceipt(receipt.id);
        if (!mounted) return;

        if (success) {
          // Refrescar la lista
          _loadSavedReceipts();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.receiptDeletedSuccessfully),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        } else {
          throw Exception(localizations.failedToDeleteReceipt);
        }
      }
    } catch (e) {
      if (!mounted) return;
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorDeletingReceipt}: ${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}

