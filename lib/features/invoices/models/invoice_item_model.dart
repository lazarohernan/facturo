import 'package:uuid/uuid.dart';

class InvoiceItem {
  final String id;
  final String? invoiceId;
  final String? description;
  final double? quantity;
  final double? unitCost;
  final double? discountAmount;
  final String? discountType; // 'percentage' o 'fixed'
  final bool? taxable;
  final double? taxRate;
  final double lineTotal;

  InvoiceItem({
    String? id,
    this.invoiceId,
    this.description,
    this.quantity = 1,
    this.unitCost = 0,
    this.discountAmount = 0,
    this.discountType = 'percentage',
    this.taxable = false,
    this.taxRate = 0,
  })  : id = id ?? const Uuid().v4(),
        lineTotal = _calculateLineTotal(
          quantity ?? 1,
          unitCost ?? 0,
          discountAmount ?? 0,
          discountType ?? 'percentage',
          taxable ?? false,
          taxRate ?? 0,
        );

  static double _calculateLineTotal(
    double quantity,
    double unitCost,
    double discountAmount,
    String discountType,
    bool taxable,
    double taxRate,
  ) {
    final subtotal = quantity * unitCost;
    
    // Aplicar descuento
    double discountValue = 0;
    if (discountAmount > 0) {
      if (discountType == 'percentage') {
        discountValue = subtotal * (discountAmount / 100);
      } else {
        discountValue = discountAmount;
      }
    }
    
    final afterDiscount = subtotal - discountValue;
    
    // Aplicar impuesto
    double taxValue = 0;
    if (taxable && taxRate > 0) {
      taxValue = afterDiscount * (taxRate / 100);
    }
    
    return afterDiscount + taxValue;
  }

  // Crear una copia con campos actualizados
  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    double? quantity,
    double? unitCost,
    double? discountAmount,
    String? discountType,
    bool? taxable,
    double? taxRate,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      discountAmount: discountAmount ?? this.discountAmount,
      discountType: discountType ?? this.discountType,
      taxable: taxable ?? this.taxable,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'description': description,
      'quantity': quantity,
      'unit_cost': unitCost,
      'discount_amount': discountAmount,
      'discount_type': discountType,
      'taxable': taxable,
      'tax_rate': taxRate,
      'line_total': lineTotal,
    };
  }

  // Crear desde JSON
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id']?.toString(),
      invoiceId: json['invoice_id'],
      description: json['description'],
      quantity: json['quantity']?.toDouble(),
      unitCost: json['unit_cost']?.toDouble(),
      discountAmount: json['discount_amount']?.toDouble(),
      discountType: json['discount_type'],
      taxable: json['taxable'],
      taxRate: json['tax_rate']?.toDouble(),
    );
  }
} 