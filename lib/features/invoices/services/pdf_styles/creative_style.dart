import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../../profile/providers/user_profile_provider.dart';
import '../../../clients/models/client_model.dart';
import '../pdf_generator_service.dart';
import '../pdf_labels.dart';

/// Creative Style - Artistic and unique design
class CreativeStyle {
  static Future<pw.Page> build(
    Invoice invoice,
    UserProfile userProfile,
    Client? client, {
    NumberFormat? currencyFormat,
    required PdfLabels labels,
  }) async {
    final currencyFmt = currencyFormat ?? NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);
    final primaryColor = PdfColor.fromHex('#ff6b6b'); // Coral red
    final secondaryColor = PdfColor.fromHex('#4ecdc4'); // Turquoise
    final accentColor = PdfColor.fromHex('#ffe66d'); // Yellow

    final signatureSection = await PDFGeneratorService.buildSignatureSection(invoice, userProfile, labels: labels);
    final businessLogo = await PDFGeneratorService.loadBusinessLogo(userProfile);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Creative header with colorful design
          pw.Stack(
            children: [
              // Background shapes
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 150,
                  height: 150,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(75),
                  ),
                ),
              ),
              pw.Positioned(
                top: 50,
                right: 100,
                child: pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.cyan100,
                    borderRadius: pw.BorderRadius.circular(40),
                  ),
                ),
              ),
              // Content
              pw.Padding(
                padding: const pw.EdgeInsets.all(20),
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
                              width: 65,
                              height: 65,
                              margin: const pw.EdgeInsets.only(right: 15),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: primaryColor, width: 3),
                              ),
                              padding: const pw.EdgeInsets.all(5),
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
                                if (userProfile.tel != null)
                                  pw.Text(userProfile.tel!, style: const pw.TextStyle(fontSize: 10)),
                                if (userProfile.email != null)
                                  pw.Text(userProfile.email!, style: const pw.TextStyle(fontSize: 10)),
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
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(20),
                          bottomRight: pw.Radius.circular(20),
                        ),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            labels.invoice,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            '#${invoice.documentNumber ?? '0000'}',
                            style: pw.TextStyle(
                              fontSize: 20,
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
            ],
          ),
          
          pw.SizedBox(height: 25),
          
          // Invoice info cards
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Row(
              children: [
                _buildInfoCard(labels.date, PDFGeneratorService.formatDate(invoice.documentDate), secondaryColor),
                pw.SizedBox(width: 10),
                _buildInfoCard(labels.due, labels.onReceipt, primaryColor),
                pw.SizedBox(width: 10),
                _buildInfoCard(labels.poNumber, invoice.poNumber ?? labels.na, accentColor),
              ],
            ),
          ),
          
          pw.SizedBox(height: 25),
          
          // Client information
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border(
                  left: pw.BorderSide(color: secondaryColor, width: 5),
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
          ),
          
          pw.SizedBox(height: 25),
          
          // Items table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildItemsTable(invoice, primaryColor, secondaryColor, currencyFmt, labels),
          ),

          pw.Spacer(),

          // Totals
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: _buildTotals(invoice, primaryColor, accentColor, currencyFmt, labels),
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
  
  static pw.Widget _buildInfoCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          border: pw.Border.all(color: color, width: 2),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  static pw.Widget _buildItemsTable(Invoice invoice, PdfColor primaryColor, PdfColor secondaryColor, NumberFormat currencyFmt, PdfLabels labels) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: primaryColor,
          ),
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
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey50,
            ),
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
  
  static pw.Widget _buildTotals(Invoice invoice, PdfColor primaryColor, PdfColor accentColor, NumberFormat currencyFmt, PdfLabels labels) {
    final subtotal = invoice.details?.fold<double>(0, (sum, item) => sum + item.lineTotal) ?? 0.0;
    final total = invoice.total;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primaryColor, width: 2),
        ),
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
                      fontSize: 18,
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
}
