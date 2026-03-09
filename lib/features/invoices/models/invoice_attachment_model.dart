class InvoiceAttachment {
  final String id;
  final String invoiceId;
  final String userId;
  final String storagePath;
  final String? mimeType;
  final String? fileName;
  final int sortOrder;
  final DateTime createdAt;

  const InvoiceAttachment({
    required this.id,
    required this.invoiceId,
    required this.userId,
    required this.storagePath,
    this.mimeType,
    this.fileName,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory InvoiceAttachment.fromJson(Map<String, dynamic> json) {
    return InvoiceAttachment(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      userId: json['user_id'] as String,
      storagePath: json['storage_path'] as String,
      mimeType: json['mime_type'] as String?,
      fileName: json['file_name'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'user_id': userId,
        'storage_path': storagePath,
        'mime_type': mimeType,
        'file_name': fileName,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
      };

  InvoiceAttachment copyWith({
    String? id,
    String? invoiceId,
    String? userId,
    String? storagePath,
    String? mimeType,
    String? fileName,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return InvoiceAttachment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      userId: userId ?? this.userId,
      storagePath: storagePath ?? this.storagePath,
      mimeType: mimeType ?? this.mimeType,
      fileName: fileName ?? this.fileName,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
