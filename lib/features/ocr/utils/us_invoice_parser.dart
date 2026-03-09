import 'package:flutter/foundation.dart';

/// Parser bilingüe (español/inglés) para facturas y recibos
/// Extrae información estructurada del texto OCR
class USInvoiceParser {
  // Símbolos de moneda unicode (1 carácter)
  // $, €, £, ¥, ₹, ₩, ₱, ₫, ₺, ₽, ₴, ₦, ₪, ₡, ₲, ฿, ៛, ₨, ৳, ƒ, ﷼
  static const String _currencySymbols = r'\$€£¥₹₩₱₫₺₽₴₦₪₡₲฿៛₨৳ƒ﷼';
  // Prefijos/sufijos multi-carácter de todas las regiones en currency_service.dart
  // Américas: R$, MX$, CA$, CO$, CL$, AR$, BZ$, C$, RD$, J$, TT$, Bds$, EC$, GY$, SR$, S$, \$U, B/., Afl., NAƒ, S/
  // Europa: CHF, kr, zł, Kč, Ft, lei, kn, лв, дін.
  // Asia: Rp, RM, HK$, NT$, Rs
  // Oceanía: A$, NZ$, FJ$
  // África: KSh, GH₵, CFA, FCFA, E£
  // Medio Oriente: د.م., د.ت, د.إ, ر.ق, د.ك, د.ب, ر.ع., د.ا, ل.ل
  static final RegExp _multiCharPrefix = RegExp(
    r'(?:'
    // Américas
    r'R\$|MX\$|CA\$|CO\$|CL\$|AR\$|BZ\$|RD\$|GY\$|SR\$|'
    r'C\$|J\$|TT\$|Bds\$|EC\$|\$U|'
    r'S/|B/\.|Afl\.|NAƒ|Bs\.|'
    // Centroamérica/Caribe: Lempira (L), Quetzal (Q), Gourde (G)
    r'L\s(?=\d)|Q\s(?=\d)|G\s(?=\d)|'
    // Europa
    r'CHF|kr|zł|Kč|Ft|lei|kn|лв|дін\.|'
    // Asia
    r'Rp|RM|Rs|HK\$|NT\$|S\$|'
    // Oceanía
    r'A\$|NZ\$|FJ\$|'
    // África
    r'KSh|GH₵|CFA|FCFA|E£|'
    // Medio Oriente (árabe)
    r'د\.م\.|د\.ت|د\.إ|ر\.ق|د\.ك|د\.ب|ر\.ع\.|د\.ا|ل\.ل'
    r')\s*',
  );
  static final RegExp _decimalAmountPattern = RegExp(
    '(?:$_multiCharPrefix)?[$_currencySymbols]?\\s*-?(?:\\d{1,3}(?:[\\.,]\\d{3})+|\\d+)[\\.,]\\d{2}',
  );
  static final RegExp _integerCurrencyAmountPattern = RegExp(
    '(?:(?:$_multiCharPrefix)|[$_currencySymbols])\\s*-?(?:\\d{1,3}(?:[\\.,]\\d{3})+|\\d+)',
  );

  // Patrones para números que NO son montos (teléfonos, códigos postales, etc.)
  static final RegExp _phonePattern = RegExp(
    r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b',
  );
  static final RegExp _zipCodePattern = RegExp(r'\b\d{5}(?:-\d{4})?\b');
  static final RegExp _dateNumberPattern = RegExp(
    r'\b\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}\b',
  );

  /// Parsea una factura desde texto OCR (bilingüe español/inglés)
  static Map<String, dynamic> parseInvoice(String text) {
    final normalizedText = _normalizeText(text);

    // Detectar idioma predominante
    final isSpanish = _detectSpanish(normalizedText);
    debugPrint('🌐 Idioma detectado: ${isSpanish ? "Español" : "Inglés"}');

    final items = _extractItems(normalizedText, isSpanish: isSpanish);

    final subtotalRaw = _extractSubtotal(normalizedText, isSpanish: isSpanish);
    final taxRaw = _extractTax(normalizedText, isSpanish: isSpanish);
    final totalRaw = _extractTotal(normalizedText, isSpanish: isSpanish);

    final itemsTotal = _sumItemTotals(items);

    double? subtotalValue = _toDouble(subtotalRaw);
    if ((subtotalValue == null || subtotalValue == 0) && itemsTotal > 0) {
      subtotalValue = itemsTotal;
    }

    double? taxValue = _toDouble(taxRaw);
    double? totalValue = _toDouble(totalRaw);

    if (totalValue == null && subtotalValue != null && taxValue != null) {
      totalValue = subtotalValue + taxValue;
    } else if (totalValue == null && itemsTotal > 0) {
      totalValue = itemsTotal + (taxValue ?? 0);
    }

    if (taxValue == null &&
        subtotalValue != null &&
        totalValue != null &&
        totalValue >= subtotalValue) {
      final diff = totalValue - subtotalValue;
      if (diff >= 0 && diff <= totalValue * 0.3) {
        taxValue = diff;
      }
    }

    final parsed = {
      'company': _extractCompany(normalizedText, isSpanish: isSpanish),
      'invoiceNumber': _extractInvoiceNumber(
        normalizedText,
        isSpanish: isSpanish,
      ),
      'date': _extractDate(normalizedText, isSpanish: isSpanish),
      'subtotal': _formatAmount(subtotalValue, fallback: subtotalRaw),
      'tax': _formatAmount(taxValue, fallback: taxRaw),
      'total': _formatAmount(totalValue, fallback: totalRaw),
      'items': items,
      'itemsDetected': items.length,
      'itemsConfidence': _calculateItemsConfidence(items),
      'billingAddress': _extractBillingAddress(normalizedText),
      'paymentTerms': _extractPaymentTerms(normalizedText),
      'fullText': text,
      'isUSFormat': !isSpanish,
      'language': isSpanish ? 'es' : 'en',
      'processedAt': DateTime.now().toIso8601String(),
    };

    parsed['isValid'] = validateExtractedData(parsed);

    return parsed;
  }

  /// Detecta si el texto está predominantemente en español
  static bool _detectSpanish(String text) {
    final spanishWords = [
      'factura',
      'total',
      'subtotal',
      'fecha',
      'cliente',
      'enviar',
      'facturar',
      'importe',
      'cantidad',
      'precio',
      'unitario',
      'iva',
      'impuesto',
      'vencimiento',
      'pedido',
      'descripción',
      'condiciones',
      'pago',
      'banco',
      'gracias',
      'euros',
      '€',
    ];

    final lowerText = text.toLowerCase();
    int spanishCount = 0;

    for (final word in spanishWords) {
      if (lowerText.contains(word)) {
        spanishCount++;
      }
    }

    return spanishCount >= 3;
  }

  /// Normaliza el texto para mejor parsing
  /// Mantiene la estructura de líneas para mejor análisis
  static String _normalizeText(String text) {
    // Primero preservar saltos de línea importantes
    final lines = text.split('\n');
    final normalizedLines = lines
        .map((line) {
          return line
              .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
              .trim();
        })
        .where((line) => line.isNotEmpty)
        .toList();

    return normalizedLines.join('\n');
  }

  static List<RegExpMatch> _extractAmountMatches(String text) {
    final matches = <RegExpMatch>[
      ..._decimalAmountPattern.allMatches(text),
      ..._integerCurrencyAmountPattern.allMatches(text),
    ]..sort((a, b) => a.start.compareTo(b.start));

    final seen = <String>{};
    return matches.where((match) {
      final key = '${match.start}:${match.end}';
      return seen.add(key);
    }).toList();
  }

  static String? _formatAmount(double? value, {String? fallback}) {
    if (value == null) return fallback;
    return value.toStringAsFixed(2);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final normalized = value
        .toString()
        .replaceAll(RegExp(r'[^\d\-\.,]'), '')
        .replaceAll(',', '');
    if (normalized.isEmpty || normalized == '-' || normalized == '.') {
      return null;
    }
    return double.tryParse(normalized);
  }

  static double _sumItemTotals(List items) {
    double total = 0;
    for (final item in items) {
      if (item is Map) {
        final itemTotal = _toDouble(item['total']) ?? _toDouble(item['amount']);
        if (itemTotal != null) {
          total += itemTotal;
        }
      }
    }
    return total;
  }

  static double _calculateItemsConfidence(List items) {
    if (items.isEmpty) return 0.0;
    if (items.length == 1) return 0.55;
    if (items.length == 2) return 0.65;
    return 0.85;
  }

  /// Extrae el nombre de la empresa (bilingüe)
  static String? _extractCompany(String text, {bool isSpanish = false}) {
    final lines = text.split('\n');

    // Palabras a excluir (no son nombres de empresa)
    final excludeWords = [
      'receipt',
      'invoice',
      'factura',
      'recibo',
      'bill to',
      'facturar a',
      'enviar a',
      'ship to',
      'date',
      'fecha',
      'total',
      'subtotal',
      'qty',
      'cantidad',
      'price',
      'precio',
      'description',
      'descripción',
    ];

    // Buscar en las primeras líneas (donde normalmente está el nombre)
    for (int i = 0; i < lines.length && i < 8; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.length < 3) continue;

      // Saltar líneas que son claramente direcciones o datos
      if (_phonePattern.hasMatch(line)) continue;
      if (_zipCodePattern.hasMatch(line) && line.length < 20) continue;
      if (_dateNumberPattern.hasMatch(line) && line.length < 15) continue;

      // Verificar si contiene palabras excluidas
      final lowerLine = line.toLowerCase();
      bool shouldExclude = false;
      for (final word in excludeWords) {
        if (lowerLine.contains(word)) {
          shouldExclude = true;
          break;
        }
      }
      if (shouldExclude) continue;

      // Patrones para nombres de empresa
      final patterns = [
        // Empresa con sufijos legales
        RegExp(
          r'^([A-Za-zÀ-ÿ][A-Za-zÀ-ÿ\s&\.\-]+?)(?:\s+(?:INC|LLC|CORP|S\.?L\.?|S\.?A\.?|GMBH|LTD)\.?)?$',
          caseSensitive: false,
        ),
        // Nombre con # (ej: Subway #12345)
        RegExp(
          r'^([A-Za-zÀ-ÿ][A-Za-zÀ-ÿ\s]+)(?:\s*#\s*[\d\-]+)?$',
          caseSensitive: false,
        ),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          var company = match.group(1)?.trim();
          if (company != null &&
              company.length >= 3 &&
              company.length < 50 &&
              !company.contains('@') &&
              !RegExp(r'^\d+').hasMatch(company)) {
            // Limpiar sufijos comunes
            company = company
                .replaceAll(
                  RegExp(
                    r'\s*(Inc|LLC|Corp|S\.?L\.?|S\.?A\.?)\.?\s*$',
                    caseSensitive: false,
                  ),
                  '',
                )
                .trim();
            return company;
          }
        }
      }
    }

    return null;
  }

  /// Extrae el número de factura (bilingüe)
  static String? _extractInvoiceNumber(String text, {bool isSpanish = false}) {
    final patterns = [
      // Español: N° DE FACTURA, Nº Factura, Factura Nº
      RegExp(
        r'(?:n[°º]?\s*(?:de\s*)?factura|factura\s*n[°º]?)[\s:]*([A-Z0-9\-]+)',
        caseSensitive: false,
      ),
      // Español: N° DE PEDIDO
      RegExp(
        r'(?:n[°º]?\s*(?:de\s*)?pedido|pedido\s*n[°º]?)[\s:]*([A-Z0-9\-/]+)',
        caseSensitive: false,
      ),
      // Inglés: Invoice #, Invoice:, Invoice No.
      RegExp(
        r'(?:invoice|inv)[\s:#\.]*(?:no\.?|number)?[\s:]*([A-Z0-9\-]+)',
        caseSensitive: false,
      ),
      // Transaction ID / Trans#
      RegExp(
        r'(?:trans(?:action)?\s*(?:#|id|no\.?))[\s:]*([A-Z0-9/\-]+)',
        caseSensitive: false,
      ),
      // Term ID-Trans# pattern
      RegExp(
        r'Term\s*ID[-\s]*Trans\s*#?\s*([0-9/A-Z]+)(?:\s*[-–]\s*(\d+))?',
        caseSensitive: false,
      ),
      // Receipt #
      RegExp(
        r'(?:receipt|order)[\s:#]*(?:no\.?|number)?[\s:]*([A-Z0-9\-]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      if (matches.isNotEmpty) {
        for (final match in matches) {
          // Algunos patrones sólo tienen un grupo de captura.
          final secondaryGroup = match.groupCount >= 2 ? match.group(2) : null;
          var result = secondaryGroup ?? match.group(1);
          result = result?.trim();

          // Validar que parece un número de factura válido
          if (result != null &&
              result.length >= 2 &&
              result.length <= 30 &&
              !result.toLowerCase().contains('invoice') &&
              !result.toLowerCase().contains('factura')) {
            return result;
          }
        }
      }
    }

    return null;
  }

  /// Extrae la fecha (soporta formatos US, EU y español)
  static String? _extractDate(String text, {bool isSpanish = false}) {
    // Patrones con contexto bilingüe
    final contextPatterns = [
      // Español: FECHA, Fecha de factura, Fecha vencimiento
      RegExp(
        r'(?:fecha(?:\s*(?:de)?\s*(?:factura|vencimiento|emisi[oó]n|pedido)?)?)[:\s]+([\d]{1,2})[\/\.\-]([\d]{1,2})[\/\.\-]([\d]{4})',
        caseSensitive: false,
      ),
      // Inglés: Date, Invoice Date, Due Date
      RegExp(
        r'(?:(?:invoice|due|bill)?\s*date)[:\s]+([\d]{1,2})[\/\.\-]([\d]{1,2})[\/\.\-]([\d]{4})',
        caseSensitive: false,
      ),
      // Formato europeo con punto: DD.MM.YYYY
      RegExp(
        r'(?:date|fecha)[:\s]+([\d]{1,2})\.([\d]{1,2})\.([\d]{4})',
        caseSensitive: false,
      ),
    ];

    // Buscar con contexto primero
    for (final pattern in contextPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final groups = match.groups([1, 2, 3]);
        if (groups[0] != null && groups[1] != null && groups[2] != null) {
          final first = int.tryParse(groups[0]!) ?? 0;
          final second = int.tryParse(groups[1]!) ?? 0;
          final year = int.tryParse(groups[2]!) ?? 0;

          if (year >= 2000 && year <= 2099) {
            // Detectar formato: si isSpanish o primer número > 12, es DD/MM/YYYY
            if (isSpanish || first > 12) {
              // Formato europeo: DD/MM/YYYY
              if (first >= 1 && first <= 31 && second >= 1 && second <= 12) {
                return '${groups[0]!.padLeft(2, '0')}/${groups[1]!.padLeft(2, '0')}/${groups[2]}';
              }
            } else {
              // Formato US: MM/DD/YYYY
              if (first >= 1 && first <= 12 && second >= 1 && second <= 31) {
                return '${groups[0]!.padLeft(2, '0')}/${groups[1]!.padLeft(2, '0')}/${groups[2]}';
              }
            }
          }
        }
      }
    }

    // Buscar fechas sin contexto
    final standalonePatterns = [
      // Con hora (más específico)
      RegExp(r'\b(\d{1,2})[\/\.](\d{1,2})[\/\.](\d{4})\s+\d{1,2}:\d{2}'),
      // Solo fecha
      RegExp(r'\b(\d{1,2})[\/\.](\d{1,2})[\/\.](\d{4})\b'),
    ];

    for (final pattern in standalonePatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final groups = match.groups([1, 2, 3]);
        if (groups[0] != null && groups[1] != null && groups[2] != null) {
          final first = int.tryParse(groups[0]!) ?? 0;
          final second = int.tryParse(groups[1]!) ?? 0;
          final year = int.tryParse(groups[2]!) ?? 0;

          if (year >= 2000 && year <= 2099) {
            // Detectar formato automáticamente
            if (isSpanish || first > 12) {
              if (first >= 1 && first <= 31 && second >= 1 && second <= 12) {
                return '${groups[0]!.padLeft(2, '0')}/${groups[1]!.padLeft(2, '0')}/${groups[2]}';
              }
            } else if (first >= 1 &&
                first <= 12 &&
                second >= 1 &&
                second <= 31) {
              return '${groups[0]!.padLeft(2, '0')}/${groups[1]!.padLeft(2, '0')}/${groups[2]}';
            }
          }
        }
      }
    }

    return null;
  }

  /// Normaliza un monto (soporta formato US y europeo)
  static String? _normalizeAmount(String? rawValue) {
    if (rawValue == null) return null;

    // Limpiar símbolos de moneda, prefijos multi-carácter y espacios
    var value = rawValue
        .replaceAll(_multiCharPrefix, '')
        .replaceAll(RegExp('[$_currencySymbols\\s]'), '');

    final hasComma = value.contains(',');
    final hasDot = value.contains('.');

    if (hasComma && hasDot) {
      final lastComma = value.lastIndexOf(',');
      final lastDot = value.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Formato europeo: 1.234,56 -> 1234.56
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Formato US: 1,234.56 -> 1234.56
        value = value.replaceAll(',', '');
      }
    } else if (hasComma) {
      if (RegExp(r',\d{2}$').hasMatch(value)) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (hasDot) {
      if (!RegExp(r'\.\d{2}$').hasMatch(value)) {
        value = value.replaceAll('.', '');
      }
    }

    return value;
  }

  /// Extrae el subtotal (bilingüe)
  static String? _extractSubtotal(String text, {bool isSpanish = false}) {
    final patterns = [
      // Español: Subtotal
      RegExp(
        r'(?:sub\s*-?\s*total(?:\s*(?:sin|without)?\s*(?:iva|vat)?)?)[:\s]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
      // Inglés: Sub Total, Subtotal
      RegExp(
        r'(?:sub\s*-?\s*total)[:\s]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      if (matches.isNotEmpty) {
        for (final match in matches) {
          final normalized = _normalizeAmount(match.group(1));
          if (normalized != null) {
            final doubleValue = double.tryParse(normalized);
            if (doubleValue != null &&
                doubleValue > 0 &&
                doubleValue < 1000000) {
              return normalized;
            }
          }
        }
      }
    }

    return null;
  }

  /// Extrae el impuesto (bilingüe: IVA, VAT, Tax, GST)
  static String? _extractTax(String text, {bool isSpanish = false}) {
    final patterns = [
      // Español: IVA con porcentaje
      RegExp(
        r'(?:iva|i\.v\.a\.?)\s*(?:\d+[%,.]?\d*\s*%?)?[\s:]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
      // Inglés: VAT con porcentaje
      RegExp(
        r'(?:vat|v\.a\.t\.?)\s*(?:\d+[%,.]?\d*\s*%?)?[\s:]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
      // GST (General Sales Tax) con porcentaje
      RegExp(
        r'(?:general\s*sales\s*tax|gst|sales\s*tax)[\s:]*\([^)]*\)[\s:]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
      // Tax simple
      RegExp(r'(?:tax|impuesto)[\s:]*[\$€]?\s*([\d.,]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      if (matches.isNotEmpty) {
        for (final match in matches) {
          final normalized = _normalizeAmount(match.group(1));
          if (normalized != null) {
            final doubleValue = double.tryParse(normalized);
            if (doubleValue != null &&
                doubleValue >= 0 &&
                doubleValue < 100000) {
              return normalized;
            }
          }
        }
      }
    }

    return null;
  }

  /// Extrae el total (bilingüe)
  static String? _extractTotal(String text, {bool isSpanish = false}) {
    final patterns = [
      // Español: Total Factura, Total EUR, Importe Total
      RegExp(
        r'(?:total\s*(?:factura|eur|euros?)?|importe\s*total|total\s*a\s*pagar|amount\s*due)[\s:]*[\$€]?\s*([\d.,]+)\s*[\$€]?',
        caseSensitive: false,
      ),
      // Total con contexto: "Total (Eat In): 60.02"
      RegExp(
        r'total\s*\([^)]+\)[\s:]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
      // Total simple con moneda al final
      RegExp(
        r'(?:total|grand\s*total|balance\s*due)[\s:]*([\d.,]+)\s*[€\$]',
        caseSensitive: false,
      ),
      // Total simple
      RegExp(
        r'(?:total|grand\s*total|balance\s*due)[\s:]*[\$€]?\s*([\d.,]+)',
        caseSensitive: false,
      ),
    ];

    // Buscar todos los matches y tomar el más relevante
    String? bestValue;
    double? bestAmount;

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final normalized = _normalizeAmount(match.group(1));
        if (normalized != null) {
          final amount = double.tryParse(normalized);
          if (amount != null && amount > 0 && amount < 1000000) {
            // Preferir el valor que aparece después de "Total" con contexto claro
            // y que sea razonable (no teléfonos, códigos postales, etc.)
            final currentBest = bestAmount ?? 0;

            // Si el monto actual es mayor que el mejor y menor que 10x el mejor
            // (para evitar números de teléfono que son muy grandes)
            if (amount > currentBest &&
                (currentBest == 0 || amount < currentBest * 10)) {
              bestAmount = amount;
              bestValue = normalized;
            }
          }
        }
      }
    }

    return bestValue;
  }

  /// Extrae los items de la factura (bilingüe)
  static List<Map<String, dynamic>> _extractItems(
    String text, {
    bool isSpanish = false,
  }) {
    final normalizedLines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final items = <Map<String, dynamic>>[];
    if (normalizedLines.isEmpty) {
      return items;
    }

    final startIndex = _findItemsSectionStart(normalizedLines);

    for (int i = startIndex; i < normalizedLines.length; i++) {
      final line = normalizedLines[i];
      final lowerLine = line.toLowerCase();

      if (_shouldStopItemScan(lowerLine)) {
        break;
      }

      Map<String, dynamic>? parsedItem = _parseItemLine(line);

      // Intentar combinar con la siguiente línea cuando falta información
      if (parsedItem == null &&
          i + 1 < normalizedLines.length &&
          !_isAdministrativeLine(line)) {
        final nextLine = normalizedLines[i + 1];
        if (_containsPriceCandidate(nextLine)) {
          final mergedLine = '$line ${nextLine.trim()}';
          final mergedItem = _parseItemLine(mergedLine);
          if (mergedItem != null) {
            parsedItem = mergedItem;
            i++; // Saltar la línea que ya se combinó
          }
        }
      }

      if (parsedItem != null) {
        items.add(parsedItem);
      }
    }

    return items;
  }

  static int _findItemsSectionStart(List<String> lines) {
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (_looksLikeStandaloneItemsLabel(lower) ||
          _looksLikeItemsHeader(lower)) {
        return i + 1;
      }
    }
    return 0;
  }

  static bool _looksLikeStandaloneItemsLabel(String lowerLine) {
    return RegExp(
      r'^(?:items?|products?|services?|details?|art[ií]culos?|productos?|detalles?|conceptos?)\s*:?\s*$',
      caseSensitive: false,
    ).hasMatch(lowerLine.trim());
  }

  static bool _looksLikeItemsHeader(String lowerLine) {
    // Palabras clave bilingües para encabezados de items
    const keywords = [
      // Inglés
      'qty', 'quantity', 'description', 'item', 'price', 'amount', 'unit',
      // Español
      'cantidad',
      'descripción',
      'descripcion',
      'concepto',
      'precio',
      'importe',
      'unidad',
    ];
    final hits = keywords
        .where((keyword) => lowerLine.contains(keyword))
        .length;
    return hits >= 2;
  }

  static bool _shouldStopItemScan(String lowerLine) {
    // Palabras clave bilingües que indican fin de sección de items
    const stopKeywords = [
      // Inglés
      'subtotal', 'sub total', 'tax', 'vat', 'gst', 'amount due', 'balance due',
      'payment terms', 'due date', 'total due', 'grand total', 'amount paid',
      'change', 'visa', 'mastercard', 'cash', 'card', 'payment',
      // Español
      'iva', 'i.v.a', 'impuesto', 'total factura', 'importe total', 'total eur',
      'forma de pago', 'fecha vencimiento', 'condiciones', 'banco', 'iban',
      'swift', 'cuenta', 'pagado', 'pendiente', 'vencimiento',
    ];

    // Detectar líneas de total (pero no si es parte de items)
    if (RegExp(
          r'^total(\b|:|\s+eur|\s+factura)',
          caseSensitive: false,
        ).hasMatch(lowerLine) &&
        !lowerLine.contains('qty') &&
        !lowerLine.contains('cantidad')) {
      return true;
    }

    return stopKeywords.any((keyword) => lowerLine.contains(keyword));
  }

  static bool _isAdministrativeLine(String line) {
    final lowerLine = line.toLowerCase().trim();

    if (lowerLine.isEmpty) return true;
    if (_looksLikeStandaloneItemsLabel(lowerLine)) return true;
    if (_looksLikeItemsHeader(lowerLine)) return true;

    final adminStartsWith = [
      'invoice',
      'inv ',
      'factura',
      'receipt',
      'recibo',
      'date',
      'fecha',
      'bill to',
      'ship to',
      'customer',
      'cliente',
      'payment terms',
      'terms',
      'due date',
      'vencimiento',
      'subtotal',
      'tax',
      'vat',
      'gst',
      'total',
      'importe',
      'pagado',
      'balance due',
      'amount due',
    ];

    for (final prefix in adminStartsWith) {
      if (lowerLine.startsWith(prefix)) {
        return true;
      }
    }

    if (line.contains('@') ||
        lowerLine.contains('http') ||
        lowerLine.contains('www.')) {
      return true;
    }

    if (_phonePattern.hasMatch(line)) return true;

    if (_dateNumberPattern.hasMatch(line) &&
        !_extractAmountMatches(line).isNotEmpty) {
      return true;
    }

    if (RegExp(
          r'(street|st\.|avenue|ave\.|road|rd\.|drive|dr\.|lane|ln\.|blvd|boulevard)',
          caseSensitive: false,
        ).hasMatch(line) &&
        _zipCodePattern.hasMatch(line)) {
      return true;
    }

    return false;
  }

  static bool _containsPriceCandidate(String line) {
    if (_extractAmountMatches(line).isNotEmpty) {
      return true;
    }
    return false;
  }

  static Map<String, dynamic>? _parseItemLine(String line) {
    final cleaned = line.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    if (cleaned.length < 4 || !_containsAlphabeticContent(cleaned)) {
      return null;
    }

    if (_isAdministrativeLine(cleaned)) {
      return null;
    }

    if (_looksLikeItemsHeader(cleaned.toLowerCase())) {
      return null;
    }

    final currencyMatches = _extractAmountMatches(cleaned);

    if (currencyMatches.isEmpty) {
      return null;
    }

    double? unitPrice;
    double? total;

    if (currencyMatches.length >= 2) {
      final unitPriceStr = _normalizeAmount(
        currencyMatches[currencyMatches.length - 2].group(0),
      );
      final totalStr = _normalizeAmount(currencyMatches.last.group(0));
      unitPrice = unitPriceStr != null ? double.tryParse(unitPriceStr) : null;
      total = totalStr != null ? double.tryParse(totalStr) : null;
    } else {
      final totalStr = _normalizeAmount(currencyMatches.last.group(0));
      total = totalStr != null ? double.tryParse(totalStr) : null;
    }

    int quantity = 1;
    final quantityPatterns = [
      // Inglés
      RegExp(r'(?:(?:qty|quantity)\s*[:\-]?\s*)(\d+)', caseSensitive: false),
      // Español
      RegExp(
        r'(?:(?:cant|cantidad|uds|unidades)\s*[:\-]?\s*)(\d+)',
        caseSensitive: false,
      ),
      // Formato "2x" o "2 x"
      RegExp(r'(\d+)\s*x\s', caseSensitive: false),
      // Número al inicio seguido de texto
      RegExp(r'^(\d+)\s+[A-Za-zÀ-ÿ]', caseSensitive: false),
    ];

    for (final pattern in quantityPatterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        final raw = match.group(1) ?? match.group(0);
        final parsedQty = int.tryParse(raw!.replaceAll(RegExp(r'[^\d]'), ''));
        if (parsedQty != null && parsedQty > 0 && parsedQty < 1000) {
          quantity = parsedQty;
          break;
        }
      }
    }

    final firstCurrencyIndex = currencyMatches.first.start;
    var description = cleaned.substring(0, firstCurrencyIndex).trim();
    description = description.replaceFirst(
      RegExp(
        r'^(?:items?|products?|services?|details?|art[ií]culos?|productos?|detalles?|conceptos?)\s*[:\-]?\s*',
        caseSensitive: false,
      ),
      '',
    );
    description = description.replaceFirst(
      RegExp(r'^(?:qty|quantity)\s*[:\-]?\s*\d+', caseSensitive: false),
      '',
    );
    description = description
        .replaceFirst(RegExp(r'^\d+\s*x?\s*', caseSensitive: false), '')
        .trim();

    if (description.isEmpty || description.length < 2) {
      return null;
    }

    // Excluir líneas que son datos financieros, no items
    final lowerDescription = description.toLowerCase();
    final financialKeywords = [
      // Inglés
      'subtotal', 'sub total', 'tax', 'total', 'amount due', 'balance due',
      'grand total', 'vat', 'gst', 'sales tax', 'change', 'cash', 'visa',
      'mastercard', 'payment', 'paid', 'due date', 'invoice date',
      // Español
      'iva', 'impuesto', 'importe total', 'total factura', 'pagado',
      'pendiente', 'forma de pago', 'fecha', 'vencimiento', 'banco',
      'subtotal sin', 'total eur', 'amount paid',
    ];

    for (final keyword in financialKeywords) {
      if (lowerDescription.contains(keyword)) {
        return null;
      }
    }

    // También excluir si la línea original parece ser un resumen financiero
    final lowerLine = line.toLowerCase();
    if (lowerLine.startsWith('sub') ||
        lowerLine.startsWith('total') ||
        lowerLine.startsWith('iva') ||
        lowerLine.startsWith('tax') ||
        lowerLine.startsWith('vat') ||
        lowerLine.startsWith('amount') ||
        lowerLine.startsWith('importe') ||
        lowerLine.startsWith('pagado')) {
      return null;
    }

    unitPrice ??= total != null && quantity > 0 ? total / quantity : null;
    total ??= unitPrice != null ? unitPrice * quantity : null;

    if (unitPrice == null || total == null) {
      return null;
    }

    unitPrice = double.parse(unitPrice.toStringAsFixed(2));
    total = double.parse(total.toStringAsFixed(2));

    return {
      'quantity': quantity,
      'description': description,
      'unitPrice': unitPrice,
      'amount': unitPrice,
      'total': total,
      'sourceLine': cleaned,
    };
  }

  static bool _containsAlphabeticContent(String value) {
    return RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value);
  }

  /// Extrae la dirección de facturación
  static String? _extractBillingAddress(String text) {
    // Buscar patrones de direcciones (número, calle, ciudad, estado, ZIP)
    final addressPattern = RegExp(
      r'(\d+\s+[A-Za-z0-9\s]+(?:Street|St|Avenue|Ave|Road|Rd|Drive|Dr|Lane|Ln|Boulevard|Blvd|Way|Circle|Ct)[\s,]+(?:[A-Za-z\s]+)[\s,]+(?:[A-Z]{2})[\s,]+(?:\d{5}(?:-\d{4})?))',
      caseSensitive: false,
    );

    final match = addressPattern.firstMatch(text);
    if (match != null) {
      return match.group(0)?.trim();
    }

    return null;
  }

  /// Extrae términos de pago
  static String? _extractPaymentTerms(String text) {
    final patterns = [
      RegExp(
        r'(?:payment\s*terms|terms|due\s*date)[\s:]+(.{5,50})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:net\s*)?(\d+)\s*(?:days?|d)\s*(?:net|due)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }

    return null;
  }

  /// Valida si los datos extraídos son coherentes
  static bool validateExtractedData(Map<String, dynamic> data) {
    final subtotal = _toDouble(data['subtotal']);
    final tax = _toDouble(data['tax']);
    final total = _toDouble(data['total']);
    final itemsConfidence = data['itemsConfidence'] is num
        ? (data['itemsConfidence'] as num).toDouble()
        : 0.0;

    if (total != null && subtotal != null) {
      final expectedTotal = subtotal + (tax ?? 0);
      final difference = (total - expectedTotal).abs();
      final tolerance = (expectedTotal * 0.02).abs();
      final allowedDifference = tolerance < 0.5 ? 0.5 : tolerance;

      if (difference > allowedDifference) {
        debugPrint(
          '⚠️ Validación fallida: total ($total) no coincide con subtotal '
          '($subtotal) + tax (${tax ?? 0})',
        );
        return false;
      }
    }

    if (subtotal != null && data['items'] is List) {
      final itemsSum = _sumItemTotals(data['items'] as List);
      if (itemsSum > 0 && itemsConfidence >= 0.65) {
        final difference = (subtotal - itemsSum).abs();
        final allowedDifference = subtotal * 0.05;
        if (difference > allowedDifference && difference > 1) {
          debugPrint(
            '⚠️ Validación fallida: subtotal ($subtotal) no coincide con suma '
            'de items ($itemsSum)',
          );
          return false;
        }
      }
    }

    return true;
  }
}
