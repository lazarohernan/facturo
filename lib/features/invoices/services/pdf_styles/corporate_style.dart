import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Corporate Style - Professional corporate identity
class CorporateStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#003d82'); // Navy blue
    final secondaryColor = PdfColor.fromHex('#0066cc'); // Bright blue

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Corporate header with blue background
          pw.Container(
            color: primaryColor,
            padding: const pw.EdgeInsets.all(20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    if (businessLogo != null)
                      pw.Container(
                        width: 60,
                        height: 60,
                        margin: const pw.EdgeInsets.only(right: 15),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          userProfile.businessName ?? labels.fallbackBusiness,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      labels.invoice,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '#${invoice.documentNumber ?? '0000'}',
                      style: const pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Business info and Invoice details
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        labels.from,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        userProfile.businessName ?? labels.fallbackBusiness,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (userProfile.address != null)
                        pw.Text(userProfile.address!, style: const pw.TextStyle(fontSize: 10)),
                      if (userProfile.tel != null)
                        pw.Text('${labels.tel} ${userProfile.tel!}', style: const pw.TextStyle(fontSize: 10)),
                      if (userProfile.email != null)
                        pw.Text('${labels.email} ${userProfile.email!}', style: const pw.TextStyle(fontSize: 10)),
                      if (userProfile.website != null)
                        pw.Text(userProfile.website!, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        labels.invoiceDetails,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildDetailRow('${labels.date}:', PDFGeneratorService.formatDate(invoice.documentDate)),
                      pw.SizedBox(height: 3),
                      _buildDetailRow('${labels.due}:', labels.onReceipt),
                      pw.SizedBox(height: 3),
                      _buildDetailRow('${labels.poNumber}:', invoice.poNumber ?? labels.na),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Client information
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border(
                left: pw.BorderSide(color: secondaryColor, width: 3),
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
                  ),
                ),
                pw.SizedBox(height: 8),
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
          
          pw.SizedBox(height: 25),
          
          // Items table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildItemsTable(invoice, primaryColor, secondaryColor, currencyFmt, labels),
          ),

          pw.SizedBox(height: 30),

          // Totals
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildTotals(invoice, primaryColor, secondaryColor, currencyFmt, labels),
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
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 70,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    
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
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [primaryColor, secondaryColor],
            ),
          ),
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
                    pw.Text(item.description ?? '', style: const pw.TextStyle(fontSize: 11)),
                    if (hasDiscount)
                      pw.Text(discountText, style: pw.TextStyle(fontSize: 9, color: secondaryColor)),
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
  
  static pw.Widget _buildTotals(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    final subtotal = invoice.details?.fold<double>(0, (sum, item) => sum + item.lineTotal) ?? 0.0;
    final total = invoice.total;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          children: [
            _buildTotalRow(labels.subtotal, currencyFmt.format(subtotal)),
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: primaryColor,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.total,
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
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 5),
            _buildTotalRow(labels.balanceDue, currencyFmt.format(total)),
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
