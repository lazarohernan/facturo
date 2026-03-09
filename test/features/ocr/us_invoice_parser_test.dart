import 'package:flutter_test/flutter_test.dart';
import 'package:facturo/features/ocr/utils/us_invoice_parser.dart';

void main() {
  group('USInvoiceParser', () {
    test('should parse company name from invoice text', () {
      const text = 'ACME CORPORATION\nInvoice #12345\nDate: 12/31/2024';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['company'], isNotNull);
      expect(result['company'], isNotEmpty);
    });

    test('should parse invoice number', () {
      const text = 'Invoice #INV-12345\nDate: 12/31/2024';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['invoiceNumber'], isNotNull);
      expect(result['invoiceNumber'], contains('12345'));
    });

    test('should parse date in MM/DD/YYYY format', () {
      const text = 'Date: 12/31/2024\nTotal: \$100.00';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['date'], isNotNull);
      expect(result['date'], contains('12/31/2024'));
      expect(result['subtotal'], isNull);
      expect(result['items'], isEmpty);
    });

    test('should parse total amount', () {
      const text = 'Subtotal: \$90.00\nTax: \$10.00\nTotal: \$100.00';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['total'], isNotNull);
      expect(result['total'], contains('100'));
    });

    test('should parse subtotal and tax', () {
      const text = 'Subtotal: \$90.00\nTax: \$10.00\nTotal: \$100.00';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['subtotal'], isNotNull);
      expect(result['tax'], isNotNull);
    });

    test('should parse items from invoice', () {
      const text = '''
Item 1: Product A - \$25.00
Item 2: Product B - \$30.00
Total: \$55.00
''';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result['items'], isNotNull);
      expect(result['items'], isA<List>());
    });

    test('should validate extracted data coherence', () {
      final data = {'subtotal': '90.00', 'tax': '10.00', 'total': '100.00'};

      final isValid = USInvoiceParser.validateExtractedData(data);
      expect(isValid, isTrue);
    });

    test('should detect incoherent totals', () {
      final data = {
        'subtotal': '90.00',
        'tax': '10.00',
        'total': '150.00', // Incorrecto
      };

      final isValid = USInvoiceParser.validateExtractedData(data);
      expect(isValid, isFalse);
    });

    test('should handle empty text gracefully', () {
      const text = '';
      final result = USInvoiceParser.parseInvoice(text);

      expect(result, isNotNull);
      expect(result['isUSFormat'], isTrue);
    });

    test('should parse complete US invoice format', () {
      const text = '''
ACME CORPORATION
123 Main Street, New York, NY 10001

Invoice #INV-2024-001
Date: 12/31/2024

Items:
1x Product A    \$25.00
2x Product B    \$60.00

Subtotal: \$85.00
Tax: \$8.50
Total: \$93.50

Payment Terms: Net 30
''';

      final result = USInvoiceParser.parseInvoice(text);

      expect(result['company'], isNotNull);
      expect(result['invoiceNumber'], isNotNull);
      expect(result['date'], isNotNull);
      expect(result['subtotal'], isNotNull);
      expect(result['tax'], isNotNull);
      expect(result['total'], isNotNull);
      expect(result['items'], isA<List>());
      expect((result['items'] as List).length, 2);
      expect(result['subtotal'], '85.00');
      expect(result['tax'], '8.50');
      expect(result['total'], '93.50');
      expect(result['isValid'], isTrue);
      expect(result['isUSFormat'], isTrue);
    });

    test(
      'should ignore invoice metadata when extracting items without header',
      () {
        const text = '''
ACME CORPORATION
Invoice #INV-2024-001
Date: 12/31/2024
Widget A \$25.00
Widget B \$30.00
Total: \$55.00
''';

        final result = USInvoiceParser.parseInvoice(text);

        expect((result['items'] as List).length, 2);
        expect(result['subtotal'], '55.00');
        expect(result['total'], '55.00');
        expect(result['isValid'], isTrue);
      },
    );
  });
}
