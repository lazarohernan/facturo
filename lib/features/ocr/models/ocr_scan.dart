/// Modelo para representar un escaneo OCR
class OCRScan {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String? imageUrl;
  final String status; // 'pending', 'processing', 'completed', 'error'
  final String? originalFilename;
  final int? fileSize;
  final String? mimeType;
  final String? rawText;
  final Map<String, dynamic>? jsonData;
  final String? expenseId;
  final String? invoiceId;
  final String? errorMessage;

  OCRScan({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.imageUrl,
    required this.status,
    this.originalFilename,
    this.fileSize,
    this.mimeType,
    this.rawText,
    this.jsonData,
    this.expenseId,
    this.invoiceId,
    this.errorMessage,
  });

  /// Crea un OCRScan desde un mapa (típicamente de Supabase)
  factory OCRScan.fromMap(Map<String, dynamic> map) {
    return OCRScan(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      imageUrl: map['image_url']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      originalFilename: map['original_filename']?.toString(),
      fileSize: map['file_size'] as int?,
      mimeType: map['mime_type']?.toString(),
      rawText: map['raw_text']?.toString(),
      jsonData: map['json_data'] as Map<String, dynamic>?,
      expenseId: map['expense_id']?.toString(),
      invoiceId: map['invoice_id']?.toString(),
      errorMessage: map['error_message']?.toString(),
    );
  }

  /// Convierte el OCRScan a un mapa para Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'status': status,
      'original_filename': originalFilename,
      'file_size': fileSize,
      'mime_type': mimeType,
      'raw_text': rawText,
      'json_data': jsonData,
      'expense_id': expenseId,
      'invoice_id': invoiceId,
      'error_message': errorMessage,
    };
  }

  /// Obtiene los datos extraídos del json_data
  Map<String, dynamic>? get extractedData {
    return jsonData?['extracted_data'] as Map<String, dynamic>?;
  }

  /// Obtiene el nombre de la empresa desde los datos extraídos
  String? get companyName {
    return extractedData?['company']?.toString() ??
        jsonData?['company_name']?.toString();
  }

  /// Obtiene el total desde los datos extraídos
  double? get totalAmount {
    final totalStr = extractedData?['total']?.toString() ??
        jsonData?['total_amount']?.toString();
    return double.tryParse(totalStr ?? '');
  }

  /// Obtiene el número de factura desde los datos extraídos
  String? get invoiceNumber {
    return extractedData?['invoiceNumber']?.toString() ??
        jsonData?['invoice_number']?.toString();
  }

  /// Obtiene la fecha desde los datos extraídos
  String? get date {
    return extractedData?['date']?.toString();
  }

  /// Crea una copia del OCRScan con campos actualizados
  OCRScan copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    String? imageUrl,
    String? status,
    String? originalFilename,
    int? fileSize,
    String? mimeType,
    String? rawText,
    Map<String, dynamic>? jsonData,
    String? expenseId,
    String? invoiceId,
    String? errorMessage,
  }) {
    return OCRScan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      originalFilename: originalFilename ?? this.originalFilename,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      rawText: rawText ?? this.rawText,
      jsonData: jsonData ?? this.jsonData,
      expenseId: expenseId ?? this.expenseId,
      invoiceId: invoiceId ?? this.invoiceId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'OCRScan(id: $id, status: $status, companyName: $companyName, totalAmount: $totalAmount)';
  }
}

