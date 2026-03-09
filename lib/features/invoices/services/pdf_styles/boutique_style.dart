import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Boutique Style - Luxury boutique style
class BoutiqueStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#c9a959'); // Gold
    final secondaryColor = PdfColor.fromHex('#2d2d2d'); // Charcoal
    final accentColor = PdfColor.fromHex('#f5f5f5'); // Off-white

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(35),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Luxury header with gold accents
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor, width: 2),
            ),
            child: pw.Column(
              children: [
                if (businessLogo != null)
                  pw.Container(
                    width: 70,
                    height: 70,
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 2),
                      shape: pw.BoxShape.circle,
                    ),
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                  ),
                pw.Text(
                  userProfile.businessName ?? labels.fallbackBusiness,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                if (userProfile.address != null)
                  pw.Text(
                    userProfile.address!,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    textAlign: pw.TextAlign.center,
                  ),
                if (userProfile.tel != null || userProfile.email != null)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      if (userProfile.tel != null)
                        pw.Text(
                          userProfile.tel!,
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      if (userProfile.tel != null && userProfile.email != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                          child: pw.Container(
                            width: 3,
                            height: 3,
                            decoration: pw.BoxDecoration(
                              color: primaryColor,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                        ),
                      if (userProfile.email != null)
                        pw.Text(
                          userProfile.email!,
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Invoice title with decorative elements
          pw.Center(
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(width: 60, height: 1, color: primaryColor),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                      child: pw.Text(
                        labels.invoice.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    pw.Container(width: 60, height: 1, color: primaryColor),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '#${invoice.documentNumber ?? '0000'}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Client and invoice details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: accentColor,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        labels.billTo,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 5, bottom: 8),
                        height: 1,
                        width: 40,
                        color: primaryColor,
                      ),
                      pw.Text(
                        client?.name ?? labels.fallbackClient,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (client?.company != null)
                        pw.Text(client!.company!, style: const pw.TextStyle(fontSize: 10)),
                      if (client?.address != null)
                        pw.Text(client!.address!, style: const pw.TextStyle(fontSize: 10)),
                      if (client?.email != null)
                        pw.Text(client!.email!, style: const pw.TextStyle(fontSize: 10)),
                      if (client?.phone != null)
                        pw.Text(client!.phone!, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: accentColor,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      labels.invoiceDetails,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 5, bottom: 8),
                      height: 1,
                      width: 40,
                      color: primaryColor,
                    ),
                    _buildDetailRow(labels.date, PDFGeneratorService.formatDate(invoice.documentDate)),
                    pw.SizedBox(height: 5),
                    _buildDetailRow(labels.due, labels.onReceipt),
                    pw.SizedBox(height: 5),
                    _buildDetailRow(labels.poNumber, invoice.poNumber ?? labels.na),
                  ],
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 25),
          
          // Items table
          _buildItemsTable(invoice, primaryColor, secondaryColor, currencyFmt, labels),

          pw.Spacer(),

          // Totals
          _buildTotals(invoice, primaryColor, secondaryColor, currencyFmt, labels),
          
          pw.SizedBox(height: 25),
          
          signatureSection,
          
          pw.SizedBox(height: 15),
          
          // Decorative footer
          pw.Center(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(width: 40, height: 1, color: primaryColor),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Container(
                    width: 5,
                    height: 5,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
                pw.Container(width: 40, height: 1, color: primaryColor),
              ],
            ),
          ),
          
          pw.SizedBox(height: 10),
          
          PDFGeneratorService.buildPaymentNote(userProfile, labels: labels),
        ],
      ),
    );
  }
  
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    return pw.Table(
      border: pw.TableBorder(
        top: pw.BorderSide(color: primaryColor, width: 2),
        bottom: pw.BorderSide(color: primaryColor, width: 2),
        horizontalInside: const pw.BorderSide(color: PdfColors.grey100),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          children: [
            _buildTableCell(labels.description, isHeader: true, color: secondaryColor),
            _buildTableCell(labels.rate, isHeader: true, color: secondaryColor),
            _buildTableCell(labels.qty, isHeader: true, color: secondaryColor),
            _buildTableCell(labels.amount, isHeader: true, color: secondaryColor),
          ],
        ),
        ...?invoice.details?.map((item) {
          final hasDiscount = (item.discountAmount ?? 0) > 0;
          final discountText = item.discountType == 'percentage'
              ? '${item.discountAmount}% ${labels.off}'
              : '${currencyFmt.format(item.discountAmount ?? 0)} ${labels.off}';

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.description ?? '', style: const pw.TextStyle(fontSize: 11)),
                    if (hasDiscount)
                      pw.Text(discountText, style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                  ],
                ),
              ),
              _buildTableCell(currencyFmt.format(item.unitCost ?? 0)),
              _buildTableCell(item.quantity.toString()),
              _buildTableCell(currencyFmt.format(item.lineTotal)),
            ],
          );
        }),
      ],
    );
  }
  
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
  
  static pw.Widget _buildTotals(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    final subtotal = invoice.details?.fold<double>(0, (sum, item) => sum + item.lineTotal) ?? 0.0;
    final total = invoice.total;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 230,
        child: pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(labels.subtotal, style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(currencyFmt.format(subtotal), style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalDue,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(total),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
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
