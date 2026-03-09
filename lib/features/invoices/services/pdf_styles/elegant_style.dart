import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Elegant Style - Sophisticated and refined
class ElegantStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#4a4a4a');
    final accentColor = PdfColor.fromHex('#8b7355'); // Warm brown

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Elegant header with centered logo
          pw.Center(
            child: pw.Column(
              children: [
                if (businessLogo != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                  ),
                pw.Text(
                  userProfile.businessName ?? labels.fallbackBusiness,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 5),
                if (userProfile.address != null)
                  pw.Text(
                    userProfile.address!,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    textAlign: pw.TextAlign.center,
                  ),
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
                        child: pw.Text('•', style: const pw.TextStyle(color: PdfColors.grey700)),
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
          
          pw.SizedBox(height: 30),
          
          // Decorative line
          pw.Container(
            height: 1,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.white, accentColor, PdfColors.white],
              ),
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Invoice title and number
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labels.invoice,
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    '#${invoice.documentNumber ?? '0000'}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    PDFGeneratorService.formatDate(invoice.documentDate),
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 30),
          
          // Client and invoice details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      labels.billTo,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 5, bottom: 10),
                      height: 2,
                      width: 40,
                      color: accentColor,
                    ),
                    pw.Text(
                      client?.name ?? labels.fallbackClient,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (client?.company != null)
                      pw.Text(client!.company!, style: const pw.TextStyle(fontSize: 11)),
                    if (client?.address != null)
                      pw.Text(client!.address!, style: const pw.TextStyle(fontSize: 11)),
                    if (client?.email != null)
                      pw.Text(client!.email!, style: const pw.TextStyle(fontSize: 11)),
                    if (client?.phone != null)
                      pw.Text(client!.phone!, style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(width: 30),
              pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: accentColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(labels.invoiceDate, PDFGeneratorService.formatDate(invoice.documentDate)),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(labels.dueDate, labels.onReceipt),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(labels.poNumber, invoice.poNumber ?? labels.na),
                  ],
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 30),
          
          // Items table
          _buildItemsTable(invoice, primaryColor, accentColor, currencyFmt, labels),

          pw.Spacer(),

          // Totals
          _buildTotals(invoice, primaryColor, accentColor, currencyFmt, labels),
          
          pw.SizedBox(height: 25),
          
          signatureSection,
          
          pw.SizedBox(height: 15),
          
          // Decorative line
          pw.Container(
            height: 1,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.white, accentColor, PdfColors.white],
              ),
            ),
          ),
          
          pw.SizedBox(height: 10),
          
          PDFGeneratorService.buildPaymentNote(userProfile, labels: labels),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 11),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor accentColor, NumberFormat currencyFmt, PdfLabels labels) {
    return pw.Table(
      border: pw.TableBorder(
        top: pw.BorderSide(color: accentColor, width: 2),
        bottom: pw.BorderSide(color: accentColor, width: 2),
        horizontalInside: const pw.BorderSide(color: PdfColors.grey200),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            _buildTableCell(labels.description, isHeader: true),
            _buildTableCell(labels.rate, isHeader: true),
            _buildTableCell(labels.qty, isHeader: true),
            _buildTableCell(labels.amount, isHeader: true),
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
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.description ?? '', style: const pw.TextStyle(fontSize: 11)),
                    if (hasDiscount)
                      pw.Text(discountText, style: pw.TextStyle(fontSize: 9, color: accentColor)),
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
  
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  
  static pw.Widget _buildTotals(Invoice invoice, PdfColor primaryColor, PdfColor accentColor, NumberFormat currencyFmt, PdfLabels labels) {
    final subtotal = invoice.details?.fold<double>(0, (sum, item) => sum + item.lineTotal) ?? 0.0;
    final total = invoice.total;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        child: pw.Column(
          children: [
            _buildTotalRow(labels.subtotal, currencyFmt.format(subtotal)),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentColor, width: 2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalDue,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(total),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: accentColor,
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
  
  static pw.Widget _buildTotalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}
