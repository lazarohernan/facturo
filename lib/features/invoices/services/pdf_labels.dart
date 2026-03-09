import 'package:facturo/generated/l10n/app_localizations.dart';

/// Holds all translated PDF label strings.
/// Built from AppLocalizations so the PDF respects the user's locale.
class PdfLabels {
  final String invoice;
  final String billTo;
  final String from;
  final String date;
  final String due;
  final String onReceipt;
  final String poNumber;
  final String description;
  final String rate;
  final String qty;
  final String amount;
  final String subtotal;
  final String totalDue;
  final String total;
  final String balanceDue;
  final String na;
  final String off;
  final String invoiceDetails;
  final String invoiceDate;
  final String dueDate;
  final String details;
  final String dateSigned;
  final String payableTo;
  final String attachments;
  final String fallbackBusiness;
  final String fallbackClient;
  final String tel;
  final String email;

  /// Builds labels from [AppLocalizations.of(context)].
  final AppLocalizations _l10n;

  PdfLabels._(this._l10n)
      : invoice = _l10n.pdfInvoice,
        billTo = _l10n.pdfBillTo,
        from = _l10n.pdfFrom,
        date = _l10n.pdfDate,
        due = _l10n.pdfDue,
        onReceipt = _l10n.pdfOnReceipt,
        poNumber = _l10n.pdfPoNumber,
        description = _l10n.pdfDescription,
        rate = _l10n.pdfRate,
        qty = _l10n.pdfQty,
        amount = _l10n.pdfAmount,
        subtotal = _l10n.pdfSubtotal,
        totalDue = _l10n.pdfTotalDue,
        total = _l10n.pdfTotal,
        balanceDue = _l10n.pdfBalanceDue,
        na = _l10n.pdfNA,
        off = _l10n.pdfOff,
        invoiceDetails = _l10n.pdfInvoiceDetails,
        invoiceDate = _l10n.pdfInvoiceDate,
        dueDate = _l10n.pdfDueDate,
        details = _l10n.pdfDetails,
        dateSigned = _l10n.pdfDateSigned,
        payableTo = _l10n.pdfPayableTo,
        attachments = _l10n.pdfAttachments,
        fallbackBusiness = _l10n.pdfFallbackBusiness,
        fallbackClient = _l10n.pdfFallbackClient,
        tel = _l10n.pdfTel,
        email = _l10n.pdfEmail;

  factory PdfLabels.from(AppLocalizations l10n) => PdfLabels._(l10n);

  String pageOf(int current, int total) => _l10n.pdfPageOf(current, total);
  String imageCount(int count) => _l10n.pdfImageCount(count);
}
