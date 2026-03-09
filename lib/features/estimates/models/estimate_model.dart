import 'package:uuid/uuid.dart';

class Estimate {
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
  final String? signatureUrl;
  final bool status;
  final String? estimatePdfUrl;
  final List<EstimateDetail>? details;
  final DateTime? expiryDate;

  Estimate({
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
    this.signatureUrl,
    this.status = true,
    this.estimatePdfUrl,
    this.details,
    this.expiryDate,
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

  // Create a copy of the estimate with updated fields
  Estimate copyWith({
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
    String? signatureUrl,
    bool? status,
    String? estimatePdfUrl,
    List<EstimateDetail>? details,
    DateTime? expiryDate,
  }) {
    return Estimate(
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
      signatureUrl: signatureUrl ?? this.signatureUrl,
      status: status ?? this.status,
      estimatePdfUrl: estimatePdfUrl ?? this.estimatePdfUrl,
      details: details ?? this.details,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  // Convert from JSON
  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
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
      signatureUrl: json['signature_url'],
      status: json['status'] ?? true,
      estimatePdfUrl: json['estimate_pdf_url'],
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(json['expiry_date'])
              : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
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
      'signature_url': signatureUrl,
      'status': status,
      'estimate_pdf_url': estimatePdfUrl,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }
}

class EstimateDetail {
  final String estimateId;
  final DateTime createdAt;
  final String? description;
  final double? unitCost;
  final double? quantity;
  final String? discountType;
  final double? discountAmount;
  final bool? taxable;
  final String? additionalDetails;
  final String? userId;

  EstimateDetail({
    required this.estimateId,
    DateTime? createdAt,
    this.description,
    this.unitCost,
    this.quantity,
    this.discountType,
    this.discountAmount,
    this.taxable,
    this.additionalDetails,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate line total
  double get lineTotal {
    double total = (unitCost ?? 0) * (quantity ?? 0);

    // Apply discount if applicable
    if (discountAmount != null && discountAmount! > 0) {
      if (discountType == 'percentage') {
        total = total - (total * (discountAmount! / 100));
      } else {
        total = total - discountAmount!;
      }
    }

    return total;
  }

  // Create a copy of the estimate detail with updated fields
  EstimateDetail copyWith({
    String? estimateId,
    DateTime? createdAt,
    String? description,
    double? unitCost,
    double? quantity,
    String? discountType,
    double? discountAmount,
    bool? taxable,
    String? additionalDetails,
    String? userId,
  }) {
    return EstimateDetail(
      estimateId: estimateId ?? this.estimateId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      discountType: discountType ?? this.discountType,
      discountAmount: discountAmount ?? this.discountAmount,
      taxable: taxable ?? this.taxable,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      userId: userId ?? this.userId,
    );
  }

  // Convert from JSON
  factory EstimateDetail.fromJson(Map<String, dynamic> json) {
    return EstimateDetail(
      estimateId: json['estimate_id'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      unitCost:
          json['unit_cost'] != null
              ? double.parse(json['unit_cost'].toString())
              : null,
      quantity:
          json['quantity'] != null
              ? double.parse(json['quantity'].toString())
              : null,
      discountType: json['discount_type'],
      discountAmount:
          json['discount_amount'] != null
              ? double.parse(json['discount_amount'].toString())
              : null,
      taxable: json['taxable'],
      additionalDetails: json['additional_details'],
      userId: json['user_id'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'estimate_id': estimateId,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'unit_cost': unitCost,
      'quantity': quantity,
      'discount_type': discountType,
      'discount_amount': discountAmount,
      'taxable': taxable,
      'additional_details': additionalDetails,
      'user_id': userId,
    };
  }
}
