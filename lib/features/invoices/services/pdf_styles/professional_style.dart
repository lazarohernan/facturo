import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Professional Style - Clean business standard
class ProfessionalStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#2c3e50'); // Dark blue-grey
    final accentColor = PdfColor.fromHex('#27ae60'); // Green

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Professional header
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: accentColor, width: 4),
              ),
            ),
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
                          width: 60,
                          height: 60,
                          margin: const pw.EdgeInsets.only(right: 15),
                          child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                        ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              userProfile.businessName ?? labels.fallbackBusiness,
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            if (userProfile.address != null)
                              pw.Text(userProfile.address!, style: const pw.TextStyle(fontSize: 10)),
                            pw.Row(
                              children: [
                                if (userProfile.tel != null)
                                  pw.Text('${labels.tel} ${userProfile.tel!}', style: const pw.TextStyle(fontSize: 10)),
                                if (userProfile.tel != null && userProfile.email != null)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                                    child: pw.Text('|', style: const pw.TextStyle(fontSize: 10)),
                                  ),
                                if (userProfile.email != null)
                                  pw.Text('${labels.email} ${userProfile.email!}', style: const pw.TextStyle(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      labels.invoice,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 5),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: accentColor,
                      ),
                      child: pw.Text(
                        '#${invoice.documentNumber ?? '0000'}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Invoice details and client info
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                        ),
                        child: pw.Text(
                          labels.billTo,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              client?.name ?? labels.fallbackClient,
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 5),
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
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: accentColor,
                        ),
                        child: pw.Text(
                          labels.details,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Column(
                          children: [
                            _buildDetailRow(labels.invoiceDate, PDFGeneratorService.formatDate(invoice.documentDate)),
                            pw.SizedBox(height: 8),
                            _buildDetailRow(labels.dueDate, labels.onReceipt),
                            pw.SizedBox(height: 8),
                            _buildDetailRow(labels.poNumber, invoice.poNumber ?? labels.na),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Items table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildItemsTable(invoice, primaryColor, accentColor, currencyFmt, labels),
          ),

          pw.Spacer(),

          // Totals
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildTotals(invoice, primaryColor, accentColor, currencyFmt, labels),
          ),
          
          pw.SizedBox(height: 25),
          
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: signatureSection,
          ),
          
          pw.SizedBox(height: 15),
          
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
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
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
            decoration: const pw.BoxDecoration(color: PdfColors.grey50),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
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
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey50,
              ),
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
                color: accentColor,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalDue,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(total),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
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
