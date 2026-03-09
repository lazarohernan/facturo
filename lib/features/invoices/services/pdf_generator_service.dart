import 'package:facturo/core/services/storage_service.dart';
import 'package:facturo/features/invoices/models/invoice_attachment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../clients/models/client_model.dart';
import '../../../core/services/currency_service.dart';
import 'pdf_labels.dart';
import 'pdf_styles/executive_style.dart';
import 'pdf_styles/corporate_style.dart';
import 'pdf_styles/elegant_style.dart';
import 'pdf_styles/tech_style.dart';
import 'pdf_styles/creative_style.dart';
import 'pdf_styles/professional_style.dart';
import 'pdf_styles/boutique_style.dart';
import 'pdf_styles/bold_style.dart';

enum PDFStyle {
  executive,
  corporate,
  elegant,
  tech,
  creative,
  professional,
  boutique,
  bold,
}

class PDFGeneratorService {
  static const Map<PDFStyle, String> styleNames = {
    PDFStyle.executive: 'Executive',
    PDFStyle.corporate: 'Corporate',
    PDFStyle.elegant: 'Elegant',
    PDFStyle.tech: 'Tech',
    PDFStyle.creative: 'Creative',
    PDFStyle.professional: 'Professional',
    PDFStyle.boutique: 'Boutique',
    PDFStyle.bold: 'Bold',
  };

  static const Map<PDFStyle, String> styleDescriptions = {
    PDFStyle.executive: 'Premium design for high-end businesses',
    PDFStyle.corporate: 'Professional corporate identity',
    PDFStyle.elegant: 'Sophisticated and refined',
    PDFStyle.tech: 'Modern tech-inspired layout',
    PDFStyle.creative: 'Artistic and unique design',
    PDFStyle.professional: 'Clean business standard',
    PDFStyle.boutique: 'Luxury boutique style',
    PDFStyle.bold: 'Strong and impactful',
  };

  /// Generate PDF with selected style
  static Future<Uint8List> generatePDF({
    Invoice? invoice,
    required UserProfile userProfile,
    required PDFStyle style,
    Client? client,
    String currencyCode = 'USD',
    List<InvoiceAttachment>? attachments,
    required PdfLabels labels,
  }) async {
    debugPrint('🎨 Generating PDF with style: ${styleNames[style]}, currency: $currencyCode');

    final pdf = pw.Document();

    // Get currency format
    final currency = CurrencyService.getCurrency(currencyCode) ?? CurrencyService.defaultCurrency;
    final currencyFormat = NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );

    // Generate main invoice page based on style
    switch (style) {
      case PDFStyle.executive:
        pdf.addPage(await ExecutiveStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.corporate:
        pdf.addPage(await CorporateStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.elegant:
        pdf.addPage(await ElegantStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.tech:
        pdf.addPage(await TechStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.creative:
        pdf.addPage(await CreativeStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.professional:
        pdf.addPage(await ProfessionalStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.boutique:
        pdf.addPage(await BoutiqueStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
      case PDFStyle.bold:
        pdf.addPage(await BoldStyle.build(invoice!, userProfile, client, currencyFormat: currencyFormat, labels: labels));
        break;
    }

    // Collect all attachment image bytes
    final List<_AttachmentImage> loadedImages = [];
    final storageService = StorageService(Supabase.instance.client);

    // New multi-attachment system
    if (attachments != null && attachments.isNotEmpty) {
      for (final attachment in attachments) {
        final imageBytes = await _fetchAttachmentBytes(
          attachment.storagePath,
          storageService,
        );
        if (imageBytes != null) {
          loadedImages.add(_AttachmentImage(
            bytes: imageBytes,
            fileName: attachment.fileName,
          ));
        }
      }
    }

    // Backward compat: legacy single photo_url
    final legacyUrl = invoice.photoUrl;
    if (loadedImages.isEmpty &&
        legacyUrl != null &&
        legacyUrl.isNotEmpty) {
      final imageBytes = await _fetchAttachmentBytes(legacyUrl, storageService);
      if (imageBytes != null) {
        loadedImages.add(_AttachmentImage(bytes: imageBytes));
      }
    }

    // Build grid pages (4 images per page, 2×2 grid)
    if (loadedImages.isNotEmpty) {
      const imagesPerPage = 4;
      final totalPages = (loadedImages.length / imagesPerPage).ceil();
      for (var page = 0; page < totalPages; page++) {
        final start = page * imagesPerPage;
        final end = (start + imagesPerPage).clamp(0, loadedImages.length);
        final pageImages = loadedImages.sublist(start, end);
        pdf.addPage(_buildAttachmentGridPage(
          images: pageImages,
          pageIndex: page + 1,
          totalPages: totalPages,
          totalImages: loadedImages.length,
          invoiceNumber: invoice.documentNumber,
          labels: labels,
        ));
      }
    }

    debugPrint('✅ PDF generated successfully');
    return pdf.save();
  }

  /// Fetch image bytes from a storage path or legacy URL.
  static Future<Uint8List?> _fetchAttachmentBytes(
    String storedValue,
    StorageService storageService,
  ) async {
    try {
      String? url;
      if (storedValue.startsWith('http')) {
        url = storedValue;
      } else {
        url = await storageService.getSignedUrl(storedValue);
      }
      if (url == null) return null;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (e) {
      debugPrint('⚠️ Could not fetch attachment image: $e');
    }
    return null;
  }

  /// Build a grid page with up to 4 images (2×2) per page.
  static pw.Page _buildAttachmentGridPage({
    required List<_AttachmentImage> images,
    required int pageIndex,
    required int totalPages,
    required int totalImages,
    String? invoiceNumber,
    required PdfLabels labels,
  }) {
    final title = invoiceNumber != null
        ? '${labels.attachments} - #$invoiceNumber'
        : labels.attachments;
    final String pageCaption;
    if (totalPages > 1) {
      pageCaption = '${labels.pageOf(pageIndex, totalPages)} - ${labels.imageCount(totalImages)}';
    } else {
      pageCaption = labels.imageCount(totalImages);
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) {
        // Build rows of 2 images each
        final List<pw.Widget> rows = [];
        for (var i = 0; i < images.length; i += 2) {
          final left = images[i];
          final right = (i + 1 < images.length) ? images[i + 1] : null;
          rows.add(
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Expanded(child: _buildImageCell(left)),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: right != null
                        ? _buildImageCell(right)
                        : pw.SizedBox(),
                  ),
                ],
              ),
            ),
          );
          if (i + 2 < images.length) {
            rows.add(pw.SizedBox(height: 12));
          }
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.blueGrey200),
            pw.SizedBox(height: 12),
            // Image grid
            ...rows,
            // Footer
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.blueGrey200),
            pw.SizedBox(height: 4),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                pageCaption,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.blueGrey400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a single image cell with optional file name caption.
  static pw.Widget _buildImageCell(_AttachmentImage img) {
    final image = pw.MemoryImage(img.bytes);
    return pw.Column(
      children: [
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey100),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            padding: const pw.EdgeInsets.all(4),
            child: pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        ),
        if (img.fileName != null) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            img.fileName!,
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.blueGrey400,
            ),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
        ],
      ],
    );
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Load business logo image
  static Future<pw.MemoryImage?> loadBusinessLogo(UserProfile userProfile) async {
    if (userProfile.businessLogoUrl == null || userProfile.businessLogoUrl!.isEmpty) {
      return null;
    }
    
    try {
      final response = await http.get(Uri.parse(userProfile.businessLogoUrl!));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('Error loading business logo: $e');
    }
    return null;
  }

  /// Build signature section with digital signature
  static Future<pw.Widget> buildSignatureSection(Invoice invoice, UserProfile userProfile, {PdfLabels? labels}) async {
    pw.MemoryImage? signatureImage;
    
    // Load signature image if available
    if (userProfile.signatureUrl != null) {
      try {
        final response = await http.get(Uri.parse(userProfile.signatureUrl!));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error loading signature: $e');
      }
    }
    
    return pw.Center(
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            // Signature image or placeholder
            pw.Container(
              height: 60,
              alignment: pw.Alignment.bottomCenter,
              child: signatureImage != null
                  ? pw.Image(signatureImage, fit: pw.BoxFit.contain)
                  : pw.Container(),
            ),
            pw.Container(
              height: 1,
              color: PdfColors.grey800,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              labels?.dateSigned ?? 'DATE SIGNED',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              formatDate(invoice.documentDate),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment note
  static pw.Widget buildPaymentNote(UserProfile userProfile, {PdfLabels? labels}) {
    final businessName = userProfile.businessName ?? (labels?.fallbackBusiness ?? 'Business Name');
    final prefix = labels?.payableTo ?? 'Please Make Checks Payable to:';
    return pw.Center(
      child: pw.Text(
        '$prefix $businessName.',
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

/// Simple data class to hold fetched attachment image bytes and metadata.
class _AttachmentImage {
  final Uint8List bytes;
  final String? fileName;

  const _AttachmentImage({required this.bytes, this.fileName});
}
