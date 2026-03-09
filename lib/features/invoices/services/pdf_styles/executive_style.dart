import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Executive Style - Premium design for high-end businesses
class ExecutiveStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#1a1a2e');
    final accentColor = PdfColor.fromHex('#d4af37'); // Gold

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Premium header with gold accent line
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: accentColor, width: 3),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (businessLogo != null)
                        pw.Container(
                          width: 70,
                          height: 70,
                          margin: const pw.EdgeInsets.only(right: 15),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: accentColor, width: 2),
                          ),
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                          ),
                        ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              userProfile.businessName ?? labels.fallbackBusiness,
                              style: pw.TextStyle(
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            if (userProfile.address != null)
                              pw.Text(
                                userProfile.address!,
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                            if (userProfile.tel != null)
                              pw.Text(
                                userProfile.tel!,
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                            if (userProfile.email != null)
                              pw.Text(
                                userProfile.email!,
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        labels.invoice,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      pw.Text(
                        '#${invoice.documentNumber ?? '0000'}',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Client and date information
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border(
                      left: pw.BorderSide(color: accentColor, width: 3),
                    ),
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
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        client?.name ?? labels.fallbackClient,
                        style: pw.TextStyle(
                          fontSize: 14,
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
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(labels.date, PDFGeneratorService.formatDate(invoice.documentDate), accentColor),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(labels.due, labels.onReceipt, accentColor),
                    pw.SizedBox(height: 8),
                    _buildInfoRow(labels.poNumber, invoice.poNumber ?? labels.na, accentColor),
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
          
          PDFGeneratorService.buildPaymentNote(userProfile, labels: labels),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, PdfColor accentColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 1,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 11),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor accentColor, NumberFormat currencyFmt, PdfLabels labels) {
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: [
            _buildTableCell(labels.description, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.rate, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.qty, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.amount, isHeader: true, textColor: PdfColors.white),
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
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.description ?? '',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    if (hasDiscount)
                      pw.Text(
                        discountText,
                        style: pw.TextStyle(fontSize: 9, color: accentColor),
                      ),
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
  
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
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
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: accentColor, width: 2),
        ),
        child: pw.Column(
          children: [
            _buildTotalRow(labels.subtotal, currencyFmt.format(subtotal)),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              decoration: pw.BoxDecoration(color: primaryColor),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Text(
                      labels.totalDue,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 10),
                    child: pw.Text(
                      currencyFmt.format(total),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
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
