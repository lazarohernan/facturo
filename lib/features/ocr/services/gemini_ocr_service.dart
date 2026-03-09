import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

/// Servicio para procesar facturas usando Google Gemini AI
/// Proporciona extracción inteligente de datos de facturas con IA
class GeminiOCRService {
  static final GeminiOCRService _instance = GeminiOCRService._internal();
  factory GeminiOCRService() => _instance;
  GeminiOCRService._internal();

  bool _isInitialized = false;
  bool _isAvailable = false;

  /// Verifica si Gemini está disponible (API key configurada)
  bool get isAvailable => _isAvailable;

  /// Inicializa el servicio de Gemini
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('⚠️ GEMINI_API_KEY no configurada - usando solo ML Kit');
        _isAvailable = false;
        _isInitialized = true;
        return;
      }

      Gemini.init(
        apiKey: apiKey,
        enableDebugging: kDebugMode,
      );

      _isAvailable = true;
      _isInitialized = true;
      debugPrint('✅ Gemini AI inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando Gemini: $e');
      _isAvailable = false;
      _isInitialized = true;
    }
  }

  /// Procesa una imagen de factura y extrae datos estructurados usando Gemini
  /// Retorna un Map con los datos extraídos o null si falla
  Future<Map<String, dynamic>?> processInvoiceImage(File imageFile) async {
    if (!_isAvailable) {
      debugPrint('⚠️ Gemini no disponible');
      return null;
    }

    try {
      debugPrint('🤖 Procesando factura con Gemini AI...');

      final imageBytes = await imageFile.readAsBytes();
      final gemini = Gemini.instance;

      final response = await gemini.prompt(
        parts: [
          Part.text(_getInvoiceExtractionPrompt()),
          Part.inline(InlineData.fromUint8List(imageBytes)),
        ],
      );

      final outputText = response?.output;
      
      if (outputText == null || outputText.isEmpty) {
        debugPrint('⚠️ Gemini no retornó respuesta');
        return null;
      }

      debugPrint('📄 Respuesta de Gemini recibida');

      // Parsear la respuesta JSON
      final extractedData = _parseGeminiResponse(outputText);
      
      if (extractedData != null) {
        extractedData['processedBy'] = 'gemini';
        extractedData['processedAt'] = DateTime.now().toIso8601String();
        debugPrint('✅ Datos extraídos exitosamente con Gemini');
      }

      return extractedData;
    } catch (e) {
      debugPrint('❌ Error procesando con Gemini: $e');
      return null;
    }
  }

  /// Mejora los datos extraídos por ML Kit usando Gemini
  /// Toma el texto crudo del OCR y lo procesa con IA para mejor precisión
  Future<Map<String, dynamic>?> enhanceOCRData(String rawText) async {
    if (!_isAvailable) {
      debugPrint('⚠️ Gemini no disponible para mejora de datos');
      return null;
    }

    try {
      debugPrint('🤖 Mejorando datos OCR con Gemini AI...');

      final gemini = Gemini.instance;

      final response = await gemini.prompt(
        parts: [
          Part.text(_getTextEnhancementPrompt(rawText)),
        ],
      );

      final outputText = response?.output;
      
      if (outputText == null || outputText.isEmpty) {
        debugPrint('⚠️ Gemini no retornó respuesta para mejora');
        return null;
      }

      final extractedData = _parseGeminiResponse(outputText);
      
      if (extractedData != null) {
        extractedData['processedBy'] = 'gemini_enhanced';
        extractedData['processedAt'] = DateTime.now().toIso8601String();
        debugPrint('✅ Datos mejorados exitosamente con Gemini');
      }

      return extractedData;
    } catch (e) {
      debugPrint('❌ Error mejorando datos con Gemini: $e');
      return null;
    }
  }

  /// Prompt optimizado para extracción de datos de facturas desde imagen
  String _getInvoiceExtractionPrompt() {
    return '''
Analyze this invoice/receipt image and extract the following information.
Return ONLY a valid JSON object with these exact fields (use null for missing values):

{
  "company": "company or vendor name",
  "invoiceNumber": "invoice or receipt number",
  "date": "date in MM/DD/YYYY format",
  "billingAddress": "billing address if present",
  "items": [
    {
      "description": "item description",
      "quantity": 1,
      "unitPrice": 0.00,
      "total": 0.00
    }
  ],
  "subtotal": "subtotal amount as string with 2 decimals",
  "tax": "tax amount as string with 2 decimals",
  "total": "total amount as string with 2 decimals",
  "paymentTerms": "payment terms if present"
}

Important:
- Extract ALL line items you can identify
- For amounts, use numbers only (no currency symbols in the values)
- If you can't find a value, use null
- Return ONLY the JSON, no explanations
''';
  }

  /// Prompt para mejorar datos de texto OCR
  String _getTextEnhancementPrompt(String rawText) {
    return '''
I have the following text extracted from an invoice/receipt using OCR.
Please analyze it and extract structured data.

OCR TEXT:
$rawText

Return ONLY a valid JSON object with these exact fields (use null for missing values):

{
  "company": "company or vendor name",
  "invoiceNumber": "invoice or receipt number", 
  "date": "date in MM/DD/YYYY format",
  "billingAddress": "billing address if present",
  "items": [
    {
      "description": "item description",
      "quantity": 1,
      "unitPrice": 0.00,
      "total": 0.00
    }
  ],
  "subtotal": "subtotal amount as string with 2 decimals",
  "tax": "tax amount as string with 2 decimals",
  "total": "total amount as string with 2 decimals",
  "paymentTerms": "payment terms if present"
}

Important:
- Fix any OCR errors you detect in the text
- Extract ALL line items you can identify
- For amounts, use numbers only (no currency symbols)
- If you can't find a value, use null
- Return ONLY the JSON, no explanations
''';
  }

  /// Parsea la respuesta de Gemini a un Map
  Map<String, dynamic>? _parseGeminiResponse(String response) {
    try {
      // Limpiar la respuesta - remover markdown code blocks si existen
      String cleanedResponse = response.trim();
      
      // Remover ```json y ``` si están presentes
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();

      // Intentar parsear como JSON
      final Map<String, dynamic> data = json.decode(cleanedResponse);
      
      // Validar campos mínimos
      if (data.containsKey('total') || data.containsKey('items')) {
        // Asegurar que items sea una lista
        if (data['items'] != null && data['items'] is! List) {
          data['items'] = [];
        }
        
        // Convertir items a formato correcto
        if (data['items'] is List) {
          data['items'] = (data['items'] as List).map((item) {
            if (item is Map) {
              return {
                'description': item['description']?.toString() ?? '',
                'quantity': _parseNumber(item['quantity']) ?? 1,
                'unitPrice': _parseDouble(item['unitPrice']) ?? 0.0,
                'total': _parseDouble(item['total']) ?? 0.0,
              };
            }
            return item;
          }).toList();
        }
        
        // Validar rangos de valores numéricos
        final total = _parseDouble(data['total']);
        if (total != null && (total < 0 || total > 10000000)) {
          debugPrint('⚠️ Total fuera de rango: $total');
          data['isValid'] = false;
        }

        final subtotal = _parseDouble(data['subtotal']);
        if (subtotal != null && (subtotal < 0 || subtotal > 10000000)) {
          data['subtotal'] = null;
        }

        final tax = _parseDouble(data['tax']);
        if (tax != null && (tax < 0 || tax > 1000000)) {
          data['tax'] = null;
        }

        // Validar items: quantity > 0, unitPrice >= 0
        if (data['items'] is List) {
          data['items'] = (data['items'] as List).where((item) {
            if (item is Map) {
              final qty = _parseNumber(item['quantity']) ?? 1;
              final price = _parseDouble(item['unitPrice']) ?? 0.0;
              return qty > 0 && price >= 0;
            }
            return false;
          }).toList();
        }

        // Agregar campos adicionales
        data['isUSFormat'] = true;
        data['isValid'] = data['isValid'] ?? true;
        
        return data;
      }
      
      debugPrint('⚠️ Respuesta de Gemini no contiene campos válidos');
      return null;
    } catch (e) {
      debugPrint('❌ Error parseando respuesta de Gemini: $e');
      debugPrint('   Respuesta: ${response.substring(0, response.length.clamp(0, 200))}...');
      return null;
    }
  }

  int? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    final str = value.toString().replaceAll(RegExp(r'[^\d\.\-]'), '');
    return double.tryParse(str);
  }
}
