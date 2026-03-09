import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:facturo/features/ocr/models/ocr_scan.dart';
import 'package:facturo/core/services/storage_service.dart';
import 'package:path/path.dart' as path;

/// Servicio para manejar la persistencia de recibos OCR en Supabase
class OCRReceiptService {
  static final OCRReceiptService _instance = OCRReceiptService._internal();
  factory OCRReceiptService() => _instance;
  OCRReceiptService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sube una imagen OCR al bucket de Supabase Storage
  Future<String?> uploadOCRImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado para subir imagen OCR');
        return null;
      }

      debugPrint('📤 Subiendo imagen OCR al bucket...');

      // Generar nombre único para el archivo
      final fileExt = path.extension(imageFile.path);
      final randomId = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${userId}_$randomId$fileExt';
      final filePath = 'ocr/$fileName';

      // Subir imagen al bucket y obtener el path almacenado
      final storageService = StorageService(_supabase);
      final storedPath = await storageService.uploadFile(
        filePath: filePath,
        file: imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      debugPrint('✅ Imagen OCR subida exitosamente: $storedPath');
      return storedPath;
    } catch (e) {
      debugPrint('❌ Error subiendo imagen OCR: $e');
      return null;
    }
  }

  /// Guarda un recibo OCR en Supabase usando la tabla ocr_scans
  Future<String?> saveOCRReceipt({
    required Map<String, dynamic> extractedData,
    required String imagePath,
    String? imageUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado para guardar recibo OCR');
        return null;
      }

      debugPrint('💾 Guardando recibo OCR en tabla ocr_scans...');

      // Detección de duplicados (saltar si _forceSave está activo)
      final forceSave = extractedData.remove('_forceSave') == true;
      if (!forceSave) {
        final duplicateCheck = await checkForDuplicate(
          userId: userId,
          company: extractedData['company']?.toString(),
          total: _parseAmount(extractedData['total']),
          invoiceNumber: extractedData['invoiceNumber']?.toString(),
        );
        if (duplicateCheck != null) {
          debugPrint('⚠️ Posible duplicado detectado: $duplicateCheck');
          return 'DUPLICATE:$duplicateCheck';
        }
      }

      // Si no se proporciona imageUrl, subir la imagen al bucket
      if (imageUrl == null) {
        final imageFile = File(imagePath);
        imageUrl = await uploadOCRImage(imageFile);
        if (imageUrl == null) {
          debugPrint('❌ No se pudo subir la imagen OCR, usando path local');
          // Fallback: usar path local si falla el upload
          imageUrl = imagePath;
        }
      }

      final imageFile = File(imagePath);
      final fileSize = await imageFile.length();

      final scanData = {
        'user_id': userId,
        'image_url': imageUrl,
        'status': 'completed',
        'original_filename': imagePath.split('/').last,
        'file_size': fileSize,
        'mime_type': 'image/jpeg',
        'raw_text': extractedData['fullText'] ?? '',
        'json_data': {
          'extracted_data': extractedData,
          'processing_source': 'ml_kit',
          'is_us_format': extractedData['isUSFormat'] ?? true,
          'company_name': extractedData['company'],
          'total_amount': _parseAmount(extractedData['total']),
          'invoice_number': extractedData['invoiceNumber'],
          'billing_address': extractedData['billingAddress'],
          'payment_terms': extractedData['paymentTerms'],
          'items': extractedData['items'],
          'tax': _parseAmount(extractedData['tax']),
          'subtotal': _parseAmount(extractedData['subtotal']),
        },
      };

      final response = await _supabase
          .from('ocr_scans')
          .insert(scanData)
          .select('id')
          .single();

      final receiptId = response['id']?.toString();
      debugPrint('✅ Recibo OCR guardado con ID: $receiptId');
      return receiptId;
    } catch (e) {
      debugPrint('❌ Error guardando recibo OCR: $e');
      return null;
    }
  }

  /// Obtiene todos los recibos OCR del usuario actual
  Future<List<OCRScan>> getUserOCRReceipts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado');
        return [];
      }

      final response = await _supabase
          .from('ocr_scans')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((scan) => OCRScan.fromMap(scan as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo recibos OCR: $e');
      return [];
    }
  }

  /// Obtiene un recibo OCR por ID
  Future<OCRScan?> getOCRReceiptById(String receiptId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado');
        return null;
      }

      final response = await _supabase
          .from('ocr_scans')
          .select('*')
          .eq('id', receiptId)
          .eq('user_id', userId)
          .single();

      return OCRScan.fromMap(response);
    } catch (e) {
      debugPrint('❌ Error obteniendo recibo OCR: $e');
      return null;
    }
  }

  /// Actualiza un recibo OCR
  Future<bool> updateOCRReceipt(
      String receiptId, Map<String, dynamic> updates) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado para actualizar escaneo OCR');
        return false;
      }

      debugPrint('🔄 Actualizando escaneo OCR: $receiptId');

      final updateData = <String, dynamic>{};

      if (updates.containsKey('invoice_id')) {
        updateData['invoice_id'] = updates['invoice_id'];
      }

      if (updates.containsKey('expense_id')) {
        updateData['expense_id'] = updates['expense_id'];
      }

      // Actualizar datos extraídos (json_data)
      if (updates.containsKey('extracted_data')) {
        // Obtener el registro actual para mantener la estructura
        final currentRecord = await _supabase
            .from('ocr_scans')
            .select('json_data')
            .eq('id', receiptId)
            .eq('user_id', userId)
            .single();

        final currentJsonData =
            currentRecord['json_data'] as Map<String, dynamic>? ?? {};

        // Actualizar solo extracted_data dentro de json_data
        final updatedJsonData = Map<String, dynamic>.from(currentJsonData);
        updatedJsonData['extracted_data'] = updates['extracted_data'];

        // Mantener otros campos de json_data
        updateData['json_data'] = updatedJsonData;

        debugPrint('📝 Actualizando datos extraídos en json_data');
      }

      if (updateData.isNotEmpty) {
        await _supabase
            .from('ocr_scans')
            .update(updateData)
            .eq('id', receiptId)
            .eq('user_id', userId);

        debugPrint('✅ Escaneo OCR actualizado');
        return true;
      } else {
        debugPrint('⚠️ No hay campos válidos para actualizar');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error actualizando escaneo OCR: $e');
      return false;
    }
  }

  /// Elimina un recibo OCR
  Future<bool> deleteOCRReceipt(String receiptId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuario no autenticado');
        return false;
      }

      await _supabase
          .from('ocr_scans')
          .delete()
          .eq('id', receiptId)
          .eq('user_id', userId);

      debugPrint('✅ Recibo OCR eliminado: $receiptId');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando recibo OCR: $e');
      return false;
    }
  }

  /// Obtiene el conteo de uso OCR del usuario (para freemium)
  Future<int> getOCRUsageCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      // Contar escaneos completados del mes actual
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final response = await _supabase
          .from('ocr_scans')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gte('created_at', startOfMonth.toIso8601String());

      return (response as List).length;
    } catch (e) {
      debugPrint('❌ Error obteniendo conteo OCR: $e');
      return 0;
    }
  }

  /// Marca un recibo como usado para una factura
  Future<bool> markAsUsedForInvoice(String receiptId, String invoiceId) async {
    return await updateOCRReceipt(receiptId, {'invoice_id': invoiceId});
  }

  /// Marca un recibo como usado para un gasto
  Future<bool> markAsUsedForExpense(String receiptId, String expenseId) async {
    return await updateOCRReceipt(receiptId, {'expense_id': expenseId});
  }

  /// Verifica si ya existe un recibo similar (posible duplicado)
  /// Busca por mismo total + empresa o mismo número de factura en las últimas 24h
  Future<String?> checkForDuplicate({
    required String userId,
    String? company,
    double? total,
    String? invoiceNumber,
  }) async {
    try {
      final since = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();

      // Buscar por número de factura exacto (más confiable)
      if (invoiceNumber != null && invoiceNumber.isNotEmpty) {
        final byInvoice = await _supabase
            .from('ocr_scans')
            .select('id')
            .eq('user_id', userId)
            .eq('status', 'completed')
            .gte('created_at', since)
            .contains('json_data', {'invoice_number': invoiceNumber})
            .limit(1);

        if ((byInvoice as List).isNotEmpty) {
          return byInvoice[0]['id']?.toString();
        }
      }

      // Buscar por empresa + total (fuzzy match)
      if (company != null && company.isNotEmpty && total != null && total > 0) {
        final byAmount = await _supabase
            .from('ocr_scans')
            .select('id, json_data')
            .eq('user_id', userId)
            .eq('status', 'completed')
            .gte('created_at', since)
            .contains('json_data', {'company_name': company});

        for (final scan in (byAmount as List)) {
          final jsonData = scan['json_data'] as Map<String, dynamic>?;
          if (jsonData != null) {
            final existingTotal = _parseAmount(jsonData['total_amount']);
            if (existingTotal != null && (existingTotal - total).abs() < 0.01) {
              return scan['id']?.toString();
            }
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('⚠️ Error verificando duplicados: $e');
      return null; // En caso de error, permitir guardar
    }
  }

  /// Parsea un monto a double
  double? _parseAmount(dynamic value) {
    if (value == null) return null;
    final str = value.toString().replaceAll(RegExp(r'[^\d\.\-]'), '');
    return double.tryParse(str);
  }
}

