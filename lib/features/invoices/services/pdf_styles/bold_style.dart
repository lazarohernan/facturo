import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Bold Style - Strong and impactful
class BoldStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#e63946'); // Bold red
    final secondaryColor = PdfColor.fromHex('#1d3557'); // Navy
    final accentColor = PdfColor.fromHex('#f1faee'); // Light cream
    
    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Bold header with strong colors
          pw.Container(
            color: secondaryColor,
            padding: const pw.EdgeInsets.all(25),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (businessLogo != null)
                            pw.Container(
                              width: 65,
                              height: 65,
                              margin: const pw.EdgeInsets.only(right: 15),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(5),
                              ),
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Image(businessLogo, fit: pw.BoxFit.contain),
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
                                    color: PdfColors.white,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                if (userProfile.address != null)
                                  pw.Text(
                                    userProfile.address!,
                                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                                  ),
                                if (userProfile.tel != null)
                                  pw.Text(
                                    userProfile.tel!,
                                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                                  ),
                                if (userProfile.email != null)
                                  pw.Text(
                                    userProfile.email!,
                                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            labels.invoice,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '#${invoice.documentNumber ?? '0000'}',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(labels.date, PDFGeneratorService.formatDate(invoice.documentDate)),
                      pw.Container(width: 2, height: 40, color: PdfColors.grey400),
                      _buildHeaderStat(labels.due, labels.onReceipt),
                      pw.Container(width: 2, height: 40, color: PdfColors.grey400),
                      _buildHeaderStat(labels.amount, currencyFmt.format(invoice.total)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Client information
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: primaryColor, width: 6),
                ),
                color: accentColor,
              ),
              child: pw.Row(
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
                            color: primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          client?.name ?? labels.fallbackClient,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
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
                  if (invoice.poNumber != null)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: primaryColor, width: 2),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            labels.poNumber,
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            invoice.poNumber!,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Items table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: _buildItemsTable(invoice, primaryColor, secondaryColor, currencyFmt, labels),
          ),

          pw.Spacer(),

          // Totals
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: _buildTotals(invoice, primaryColor, secondaryColor, currencyFmt, labels),
          ),
          
          pw.SizedBox(height: 20),
          
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 25),
            child: signatureSection,
          ),
          
          pw.SizedBox(height: 15),
          
          // Footer
          pw.Container(
            color: secondaryColor,
            padding: const pw.EdgeInsets.all(15),
            child: pw.Center(
              child: pw.Text(
                '${labels.payableTo} ${userProfile.businessName ?? "Business Name"}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildHeaderStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey300,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    return pw.Table(
      border: pw.TableBorder.all(color: secondaryColor, width: 2),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: secondaryColor),
          children: [
            _buildTableCell(labels.description, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.rate, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.qty, isHeader: true, textColor: PdfColors.white),
            _buildTableCell(labels.amount, isHeader: true, textColor: PdfColors.white),
          ],
        ),
        ...?invoice.details?.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final hasDiscount = (item.discountAmount ?? 0) > 0;
          final discountText = item.discountType == 'percentage'
              ? '${item.discountAmount}% ${labels.off}'
              : '${currencyFmt.format(item.discountAmount ?? 0)} ${labels.off}';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.description ?? '',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (hasDiscount)
                      pw.Text(
                        discountText,
                        style: pw.TextStyle(fontSize: 9, color: primaryColor),
                      ),
                  ],
                ),
              ),
              _buildTableCell(currencyFmt.format(item.unitCost ?? 0)),
              _buildTableCell(item.quantity.toString()),
              _buildTableCell(
                currencyFmt.format(item.lineTotal),
                textColor: secondaryColor,
                isBold: true,
              ),
            ],
          );
        }),
      ],
    );
  }
  
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? textColor, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
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
        width: 250,
        child: pw.Column(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: secondaryColor, width: 2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.subtotal,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(subtotal),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalDue,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.Text(
                    currencyFmt.format(total),
                    style: pw.TextStyle(
                      fontSize: 22,
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
