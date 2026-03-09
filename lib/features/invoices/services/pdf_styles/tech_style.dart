import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Tech Style - Modern tech-inspired layout
class TechStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#00d4ff'); // Cyan
    final secondaryColor = PdfColor.fromHex('#7b2cbf'); // Purple
    final darkColor = PdfColor.fromHex('#1a1a2e');
    
    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Tech-style header with gradient effect
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [darkColor, secondaryColor],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        if (businessLogo != null)
                          pw.Container(
                            width: 50,
                            height: 50,
                            margin: const pw.EdgeInsets.only(right: 12),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(25),
                            ),
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              userProfile.businessName ?? labels.fallbackBusiness,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            if (userProfile.website != null)
                              pw.Text(
                                userProfile.website!,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            labels.invoice,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          pw.Text(
                            '#${invoice.documentNumber ?? '0000'}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey800,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderInfo(labels.date, PDFGeneratorService.formatDate(invoice.documentDate), primaryColor),
                      pw.Container(width: 1, height: 30, color: PdfColors.grey600),
                      _buildHeaderInfo(labels.due, labels.onReceipt, primaryColor),
                      pw.Container(width: 1, height: 30, color: PdfColors.grey600),
                      _buildHeaderInfo(labels.amount, currencyFmt.format(invoice.total), primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Business and client info
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: primaryColor, width: 4),
                      ),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          labels.from,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        if (userProfile.address != null)
                          pw.Text(userProfile.address!, style: const pw.TextStyle(fontSize: 10)),
                        if (userProfile.tel != null)
                          pw.Text(userProfile.tel!, style: const pw.TextStyle(fontSize: 10)),
                        if (userProfile.email != null)
                          pw.Text(userProfile.email!, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: secondaryColor, width: 4),
                      ),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          labels.billTo,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          client?.name ?? labels.fallbackClient,
                          style: pw.TextStyle(
                            fontSize: 11,
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
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Items table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildItemsTable(invoice, primaryColor, secondaryColor, darkColor, currencyFmt, labels),
          ),

          pw.Spacer(),

          // Totals
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildTotals(invoice, primaryColor, secondaryColor, darkColor, currencyFmt, labels),
          ),
          
          pw.SizedBox(height: 20),
          
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
  
  static pw.Widget _buildHeaderInfo(String label, String value, PdfColor accentColor) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, PdfColor darkColor, NumberFormat currencyFmt, PdfLabels labels) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200),
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
            _buildTableCell(labels.description, isHeader: true, textColor: darkColor),
            _buildTableCell(labels.rate, isHeader: true, textColor: darkColor),
            _buildTableCell(labels.qty, isHeader: true, textColor: darkColor),
            _buildTableCell(labels.amount, isHeader: true, textColor: darkColor),
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

  static pw.Widget _buildTotals(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, PdfColor darkColor, NumberFormat currencyFmt, PdfLabels labels) {
    final subtotal = invoice.details?.fold<double>(0, (sum, item) => sum + item.lineTotal) ?? 0.0;
    final total = invoice.total;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        child: pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
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
                gradient: pw.LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalDue,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(total),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
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
