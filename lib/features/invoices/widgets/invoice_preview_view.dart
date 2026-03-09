import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/clients/models/client_model.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:facturo/features/invoices/models/invoice_attachment_model.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/features/invoices/services/pdf_generator_service.dart';
import 'package:facturo/features/invoices/services/pdf_labels.dart';
import 'package:facturo/features/invoices/widgets/pdf_style_carousel.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class InvoicePreviewView extends ConsumerStatefulWidget {
  final Invoice invoice;

  const InvoicePreviewView({super.key, required this.invoice});

  @override
  ConsumerState<InvoicePreviewView> createState() => _InvoicePreviewViewState();
}

class _InvoicePreviewViewState extends ConsumerState<InvoicePreviewView> {
  Client? _client;
  List<InvoiceAttachment> _attachments = [];
  final TransformationController _transformationController =
      TransformationController();
  PDFStyle _selectedPdfStyle = PDFStyle.executive;
  String? _sharedInvoiceUrl;
  bool _showStyleSelector = true;
  bool _isChangingStyle = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid conflicting with GoRouter's Navigator
    // rebuild cycle (known _elements.contains(element) assertion bug).
    Future.microtask(() {
      if (mounted) _loadClient();
      if (mounted) _loadAttachments();
    });
  }

  Future<void> _loadAttachments() async {
    try {
      final attachments = await ref
          .read(invoiceServiceProvider)
          .getInvoiceAttachments(widget.invoice.id);
      if (mounted) setState(() => _attachments = attachments);
    } catch (_) {
      // Fallback to legacy photo_url handled by PDF generator
    }
  }

  Future<void> _loadClient() async {
    if (widget.invoice.clientId == null) return;

    try {
      final clientService = ref.read(clientServiceProvider);
      final client = await clientService.getClient(widget.invoice.clientId!);
      if (mounted) {
        setState(() {
          _client = client;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).errorLoadingClient}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PDF Preview - Shows the actual PDF that will be sent
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: PdfPreview(
                  build: (format) => _generatePdf(
                    context,
                    widget.invoice,
                    profileState,
                  ),
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  allowPrinting: false,
                  allowSharing: false,
                  pdfFileName: 'Invoice_${widget.invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch}.pdf',
                  scrollViewDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  pdfPreviewPageDecoration: BoxDecoration(
                    color: Colors.white, // PDF paper stays white
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  pageFormats: const {
                    'A4': PdfPageFormat.a4,
                  },
                  padding: EdgeInsets.zero,
                  shouldRepaint: true,
                  previewPageMargin: EdgeInsets.zero,
                ),
              ),
              // Loading overlay when changing style
              if (_isChangingStyle)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aplicando estilo ${PDFGeneratorService.styleNames[_selectedPdfStyle]}...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
                onStyleChanged: (style) async {
                  setState(() {
                    _isChangingStyle = true;
                    _selectedPdfStyle = style;
                  });
                  
                  // Small delay to allow PDF to regenerate
                  await Future.delayed(const Duration(milliseconds: 800));
                  
                  if (mounted) {
                    setState(() {
                      _isChangingStyle = false;
                    });
                  }
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showSendOptions,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: Text(AppLocalizations.of(context).sendInvoice),
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
      ],
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
                        AppLocalizations.of(context).sendInvoice,
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
                leading: Icon(
                  Iconsax.message_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).sendViaTextMessage),
                subtitle: Text(AppLocalizations.of(context).sendPdfViaTextMessage),
                onTap: () {
                  Navigator.pop(context);
                  _sendViaText();
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
                    if (_sharedInvoiceUrl != null && _sharedInvoiceUrl!.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Iconsax.tick_circle_bold,
                          color: Colors.green,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(AppLocalizations.of(context).sendViaLink),
                    if (_sharedInvoiceUrl != null && _sharedInvoiceUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
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
                  _sharedInvoiceUrl != null && _sharedInvoiceUrl!.isNotEmpty
                      ? AppLocalizations.of(context).linkReadyTapToShare
                      : AppLocalizations.of(context).generateAndShareOnlineLink,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sendViaLink();
                },
              ),
            ],
          ),
        );
      },
    );
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
                  _exportToPDF(context, widget.invoice, ref.read(userProfileProvider));
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.image_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).exportAsImage),
                subtitle: Text(AppLocalizations.of(context).downloadAsPngImage),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsImage();
                },
              ),
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
        widget.invoice,
        ref.read(userProfileProvider),
      );

      // Get temp directory to save PDF
      final tempDir = await getTemporaryDirectory();
      String invoiceFileName =
          'Invoice_${widget.invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
      final file = File('${tempDir.path}/$invoiceFileName');

      // Save PDF to temp file
      await file.writeAsBytes(pdfBytes);

      // Prepare email parameters
      final amountFormatted = NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(widget.invoice.total);
      String subject = l.invoiceEmailSubject(widget.invoice.documentNumber ?? '');
      String body = l.invoiceEmailBody;

      if (_client != null) {
        body += l.invoiceEmailThankYou(_client!.clientName);
      }

      body += l.invoiceEmailAmountDue(amountFormatted);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).emailAppOpenedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorOpeningEmailApp}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _generatePdf(
    BuildContext context,
    Invoice invoice,
    dynamic profileState,
  ) async {
    debugPrint('🎨 Generating PDF with style: ${PDFGeneratorService.styleNames[_selectedPdfStyle]} (${_selectedPdfStyle.name})');

    // Get currency from settings
    final settings = ref.read(appSettingsProvider);

    // Use the PDF generator service with the selected style
    final l10n = AppLocalizations.of(context);
    final pdfBytes = await PDFGeneratorService.generatePDF(
      invoice: invoice,
      userProfile: profileState,
      style: _selectedPdfStyle,
      client: _client,
      currencyCode: settings.currency,
      attachments: _attachments.isNotEmpty ? _attachments : null,
      labels: PdfLabels.from(l10n),
    );

    debugPrint('✅ PDF generated successfully with ${_selectedPdfStyle.name} style');
    return pdfBytes;
  }


  void _sendViaText() async {
    OverlayEntry? loadingOverlay;
    // Capture context-dependent values before async operations
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    try {
      // Show loading indicator
      loadingOverlay = _showLoadingOverlay();

      // Generate PDF
      final pdfBytes = await _generatePdf(
        context,
        widget.invoice,
        ref.read(userProfileProvider),
      );

      // Get temp directory to save PDF
      final tempDir = await getTemporaryDirectory();
      String invoiceFileName =
          'Invoice_${widget.invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
      final file = File('${tempDir.path}/$invoiceFileName');

      // Save PDF to temp file
      await file.writeAsBytes(pdfBytes);

      // Prepare message text
      String messageText = 'Please find your invoice';
      if (widget.invoice.documentNumber != null) {
        messageText += ' #${widget.invoice.documentNumber}';
      }
      messageText += ' attached.\n\n';

      if (_client != null) {
        messageText +=
            'Thank you for your business, ${_client!.clientName}!\n\n';
      }

      messageText +=
          'Amount due: ${NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(widget.invoice.total)}';

      // Hide loading indicator before sharing
      loadingOverlay.remove();
      loadingOverlay = null;

      // Share the PDF file with text apps (WhatsApp, SMS, etc.)
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: messageText,
        subject: 'Invoice ${widget.invoice.documentNumber ?? ""}',
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      // Make sure to remove loading overlay on error
      loadingOverlay?.remove();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorSharingInvoice}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendViaLink() async {
    try {
      // Check if link already exists - reuse it instead of regenerating
      if (_sharedInvoiceUrl != null && _sharedInvoiceUrl!.isNotEmpty) {
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
      final loadingOverlay = _showLoadingOverlay();

      // Generate PDF
      final pdfBytes = await _generatePdf(
        context,
        widget.invoice,
        ref.read(userProfileProvider),
      );

      // Upload PDF to Supabase Storage
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final invoiceNumber = widget.invoice.documentNumber ?? 'invoice';
      final fileName = '${userId}_${invoiceNumber}_$timestamp.pdf';
      final filePath = 'invoices/$fileName';

      // Upload file to Supabase Storage and get signed URL for sharing
      final storageService = StorageService(supabase);
      final storedPath = await storageService.uploadBinary(
        filePath: filePath,
        data: pdfBytes,
      );

      // Get signed URL with long expiry for sharing (30 days)
      final shareUrl = await storageService.getShareUrl(storedPath);

      // Store the URL for sharing
      setState(() {
        _sharedInvoiceUrl = shareUrl;
      });

      // Hide loading indicator
      loadingOverlay.remove();

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
        SnackBar(content: Text('${AppLocalizations.of(context).errorGeneratingLink}: $e')),
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
                subtitle: Text(AppLocalizations.of(context).copyLinkDescription),
                onTap: () {
                  Navigator.pop(context);
                  _copyInvoiceLink();
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.share_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).shareLink),
                subtitle: Text(AppLocalizations.of(context).shareLinkDescription),
                onTap: () {
                  Navigator.pop(context);
                  _shareInvoiceLink();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Iconsax.refresh_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context).generateNewLink),
                subtitle: Text(AppLocalizations.of(context).generateNewLinkDescription),
                onTap: () {
                  Navigator.pop(context);
                  _regenerateInvoiceLink();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _copyInvoiceLink() async {
    if (_sharedInvoiceUrl == null || _sharedInvoiceUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noLinkAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: _sharedInvoiceUrl!));

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
              'Link copied to clipboard!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        elevation: 0,
      ),
    );
  }

  void _shareInvoiceLink() async {
    if (_sharedInvoiceUrl == null || _sharedInvoiceUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noLinkAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String message = 'Please find your invoice: $_sharedInvoiceUrl';

    await Share.share(
      message,
      subject: 'Invoice ${widget.invoice.documentNumber ?? ""}',
    );
  }

  void _regenerateInvoiceLink() async {
    // Clear existing URL to force regeneration
    setState(() {
      _sharedInvoiceUrl = null;
    });

    // Show confirmation message
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
              Iconsax.refresh_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              'Generating new link...',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        elevation: 0,
      ),
    );

    // Generate new link
    await _sendViaLink();
  }

  OverlayEntry _showLoadingOverlay() {
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  Future<void> _exportToPDF(
    BuildContext context,
    Invoice invoice,
    dynamic profileState,
  ) async {
    try {
      // Show loading indicator
      final loadingOverlay = _showLoadingOverlay();

      // Generate PDF using the PDF generator service with selected style
      final pdfBytes = await _generatePdf(
        context,
        invoice,
        profileState,
      );

      // Hide loading
      loadingOverlay.remove();
      if (!mounted) return;

      // Save and share PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Invoice_${invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(this.context).errorExportingPdf}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _exportAsImage() async {
    // Capture context-dependent values before async operations
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    try {
      // Show loading indicator
      final loadingOverlay = _showLoadingOverlay();

      // Generate PDF first
      final pdfBytes = await _generatePdf(
        context,
        widget.invoice,
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
      File file;
      
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
        final finalPngBytes = img.encodePng(whiteBackground);
        
        // Save to temp directory
        final tempDir = await getTemporaryDirectory();
        file = File(
          '${tempDir.path}/Invoice_${widget.invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(finalPngBytes);
      } else {
        // Fallback: save original PNG if decoding fails
        final tempDir = await getTemporaryDirectory();
        file = File(
          '${tempDir.path}/Invoice_${widget.invoice.documentNumber ?? DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(pngBytes);
      }

      // Hide loading
      loadingOverlay.remove();

      // Share the PNG file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Invoice ${widget.invoice.documentNumber ?? ""}',
        sharePositionOrigin: shareOrigin,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pngExportedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).errorExportingPng}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}