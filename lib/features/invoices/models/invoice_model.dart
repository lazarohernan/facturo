import 'package:facturo/features/invoices/models/invoice_item_model.dart';
import 'package:uuid/uuid.dart';

class Invoice {
  final String id;
  final DateTime createdAt;
  final String? userId;
  final String? documentNumber;
  final DateTime? documentDate;
  final String? poNumber;
  final String? clientId;
  final double? generalDiscount;
  final String? generalDiscountType;
  final double? generalTax;
  final String? generalTaxType;
  final String? photoUrl;
  final String? notes;
  final bool status;
  final bool paid;
  final List<InvoiceItem>? details;

  Invoice({
    String? id,
    DateTime? createdAt,
    this.userId,
    this.documentNumber,
    this.documentDate,
    this.poNumber,
    this.clientId,
    this.generalDiscount,
    this.generalDiscountType,
    this.generalTax,
    this.generalTaxType,
    this.photoUrl,
    this.notes,
    this.status = true,
    this.paid = false,
    this.details,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Calculate total amount
  double get total {
    if (details == null || details!.isEmpty) return 0.0;

    double subtotal = details!.fold(
      0.0,
      (sum, detail) => sum + (detail.lineTotal),
    );

    // Apply general discount if applicable
    if (generalDiscount != null && generalDiscount! > 0) {
      if (generalDiscountType == 'percentage') {
        subtotal = subtotal - (subtotal * (generalDiscount! / 100));
      } else {
        subtotal = subtotal - generalDiscount!;
      }
    }

    // Apply general tax if applicable
    if (generalTax != null && generalTax! > 0) {
      if (generalTaxType == 'percentage') {
        subtotal = subtotal + (subtotal * (generalTax! / 100));
      } else {
        subtotal = subtotal + generalTax!;
      }
    }

    return subtotal;
  }

  // Create a copy of the invoice with updated fields
  Invoice copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? documentNumber,
    DateTime? documentDate,
    String? poNumber,
    String? clientId,
    double? generalDiscount,
    String? generalDiscountType,
    double? generalTax,
    String? generalTaxType,
    String? photoUrl,
    String? notes,
    bool? status,
    bool? paid,
    List<InvoiceItem>? details,
  }) {
    return Invoice(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      documentNumber: documentNumber ?? this.documentNumber,
      documentDate: documentDate ?? this.documentDate,
      poNumber: poNumber ?? this.poNumber,
      clientId: clientId ?? this.clientId,
      generalDiscount: generalDiscount ?? this.generalDiscount,
      generalDiscountType: generalDiscountType ?? this.generalDiscountType,
      generalTax: generalTax ?? this.generalTax,
      generalTaxType: generalTaxType ?? this.generalTaxType,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      paid: paid ?? this.paid,
      details: details ?? this.details,
    );
  }

  // Convert from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    List<InvoiceItem>? detailsList;
    if (json['details'] != null) {
      detailsList = (json['details'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();
    }
    
    return Invoice(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      documentNumber: json['document_number'],
      documentDate:
          json['document_date'] != null
              ? DateTime.parse(json['document_date'])
              : null,
      poNumber: json['po_number'],
      clientId: json['client_id'],
      generalDiscount:
          json['general_discount'] != null
              ? double.parse(json['general_discount'].toString())
              : null,
      generalDiscountType: json['general_discount_type'],
      generalTax:
          json['general_tax'] != null
              ? double.parse(json['general_tax'].toString())
              : null,
      generalTaxType: json['general_tax_type'],
      photoUrl: json['photo_url'],
      notes: json['notes'],
      status: json['status'] ?? true,
      paid: json['paid'] ?? false,
      details: detailsList,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'document_number': documentNumber,
      'document_date': documentDate?.toIso8601String(),
      'po_number': poNumber,
      'client_id': clientId,
      'general_discount': generalDiscount,
      'general_discount_type': generalDiscountType,
      'general_tax': generalTax,
      'general_tax_type': generalTaxType,
      'photo_url': photoUrl,
      'notes': notes,
      'status': status,
      'paid': paid,
    };
    

    
    return data;
  }
}
