import 'package:facturo/core/widgets/app_scaffold.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/estimates/providers/estimate_provider.dart';
import 'package:facturo/features/expenses/providers/expense_provider.dart';
import 'package:facturo/features/expenses/services/expense_service.dart';
import 'package:facturo/features/expenses/models/expense_category_model.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:share_plus/share_plus.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Enum para tipos de reportes
enum ReportType {
  invoices,
  estimates,
  expenses,
}

// Enum para formato de exportación
enum ExportFormat {
  xlsx,
  pdf,
}

// Enum para orientación del PDF
enum PdfOrientation {
  portrait,
  landscape,
}

/*
OPTIMIZACIONES IMPLEMENTADAS:
1. DRY Principle: Método genérico _generateReport elimina duplicación de código
2. Single Responsibility: Cada método tiene una responsabilidad clara
3. Error Handling: Manejo centralizado de errores con mensajes localizados
4. Validation: Validación de permisos y datos antes de procesar
5. Constants: Uso de mapas para configuración centralizada
6. Documentation: Comentarios explicativos para mejor mantenibilidad
7. Null Safety: Validaciones mejoradas para evitar crashes
8. Separation of Concerns: Lógica de UI separada de lógica de negocio
*/

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> with FreemiumMixin {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = false;
  final dateFormat = DateFormat('MMM d, yyyy');

  // Dynamic currency format based on settings
  NumberFormat get currencyFormat {
    final settings = ref.read(appSettingsProvider);
    final currency = CurrencyService.getCurrency(settings.currency) ??
        CurrencyService.defaultCurrency;
    return NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );
  }

  // Enums para mejor organización
  static const Map<ReportType, String> _reportHeaders = {
    ReportType.invoices: 'Invoices',
    ReportType.estimates: 'Estimates',
    ReportType.expenses: 'Expenses',
  };

  static const Map<ReportType, String> _filePrefixes = {
    ReportType.invoices: 'invoices_report',
    ReportType.estimates: 'estimates_report',
    ReportType.expenses: 'expenses_report',
  };

  static Map<ReportType, String> _getSubjectPrefixes(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return {
      ReportType.invoices: localizations.invoicesReport,
      ReportType.estimates: localizations.estimatesReport,
      ReportType.expenses: localizations.expensesReport,
    };
  }

  static List<String> _getInvoiceHeaders(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      'Invoice #',
      localizations.date,
      localizations.clientName,
      localizations.poNumber,
      localizations.amount,
      localizations.status,
    ];
  }

  static List<String> _getEstimateHeaders(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      'Estimate #',
      localizations.date,
      localizations.expiryDate,
      localizations.clientName,
      localizations.poNumber,
      localizations.amount,
      localizations.notes
    ];
  }

  /// Método genérico para generar reportes - DRY principle implementation
  /// Elimina duplicación de código y mejora mantenibilidad
  /// Soporte para diferentes tipos de datos y configuraciones personalizadas
  Future<void> _generateReport<T>({
    required ReportType reportType,
    required Future<List<T>> Function() getData,
    required DateTime? Function(T) getDate,
    required Function(T, Sheet, int) buildRow,
    List<String>? headers,
  }) async {
    if (!mounted) return;

    // Validar antes de procesar
    if (!_validateReportGeneration()) return;

    // Capture context-dependent values before async operations
    final defaultHeaders = headers ?? _getDefaultHeaders(reportType, context);

    setState(() => _isLoading = true);

    try {
      final data = await getData();
      final filteredData = data.where((item) {
        final date = getDate(item);
        if (date == null) return false;
        return date.isAfter(_dateRange.start) &&
            date.isBefore(_dateRange.end.add(const Duration(days: 1)));
      }).toList();

      if (filteredData.isEmpty) {
        if (!mounted) return;
        _showNoDataMessage(reportType);
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel[_reportHeaders[reportType]!];
      for (var i = 0; i < defaultHeaders.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(defaultHeaders[i]);
      }

      // Agregar datos
      for (var i = 0; i < filteredData.length; i++) {
        buildRow(filteredData[i], sheet, i + 1);
      }

      // Guardar y compartir archivo
      await _saveAndShareExcelFile(excel, reportType);
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(reportType, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _getDefaultHeaders(ReportType reportType, BuildContext context) {
    switch (reportType) {
      case ReportType.invoices:
        return _getInvoiceHeaders(context);
      case ReportType.estimates:
        return _getEstimateHeaders(context);
      case ReportType.expenses:
        return ['Date', 'Merchant', 'Category', 'Amount', 'Tax', 'Description'];
    }
  }

  /// Helper method to get client name from client ID
  Future<String> _getClientName(String? clientId) async {
    if (clientId == null || clientId.isEmpty) return 'N/A';
    try {
      final clientService = ref.read(clientServiceProvider);
      final client = await clientService.getClient(clientId);
      return client.clientName;
    } catch (e) {
      return 'N/A';
    }
  }

  /// Helper method to get category name from category ID or expense object
  Future<String> _getCategoryName(int? categoryId, {String? existingCategoryName}) async {
    // First check if category name is already available from the database join
    if (existingCategoryName != null && existingCategoryName.isNotEmpty) {
      return existingCategoryName;
    }

    if (categoryId == null) return 'N/A';
    // Capture localization before async operation
    final unknownCategory = AppLocalizations.of(context).unknownCategory;
    try {
      final expenseService = ref.read(expenseServiceProvider);
      final categories = await expenseService.getExpenseCategories(
        ref.read(authControllerProvider).user?.id ?? '',
      );
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => ExpenseCategory(
          id: categoryId,
          userId: '',
          categoryName: unknownCategory,
        ),
      );
      return category.categoryName;
    } catch (e) {
      return unknownCategory;
    }
  }

  void _showNoDataMessage(ReportType reportType) {
    final localizations = AppLocalizations.of(context);
    final message = switch (reportType) {
      ReportType.invoices => localizations.noInvoicesFoundInRange,
      ReportType.estimates => localizations.noEstimatesFoundInRange,
      ReportType.expenses => localizations.noExpensesFoundInRange,
    };

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(ReportType reportType, dynamic error) {
    final localizations = AppLocalizations.of(context);
    final message = switch (reportType) {
      ReportType.invoices => localizations.errorExportingInvoices,
      ReportType.estimates => localizations.errorExportingEstimates,
      ReportType.expenses => localizations.errorExportingExpenses,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message: $error')),
    );
  }

  /// Valida permisos y estado antes de generar reportes
  /// Mejora robustez del sistema de exportación
  bool _validateReportGeneration() {
    if (!mounted) return false;

    final user = ref.read(authControllerProvider).user;
    final localizations = AppLocalizations.of(context);

    if (user == null) {
      _showErrorMessage(ReportType.invoices, localizations.userNotAuthenticated);
      return false;
    }

    // Validar rango de fechas
    if (_dateRange.start.isAfter(_dateRange.end)) {
      _showErrorMessage(ReportType.invoices, localizations.invalidDateRange);
      return false;
    }

    return true;
  }

  Future<void> _saveAndShareExcelFile(
      Excel excel, ReportType reportType) async {
    // Capture context-dependent values before async operations
    final subjectPrefixes = _getSubjectPrefixes(context);
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    final directory = await getApplicationDocumentsDirectory();
    final dateRangeStr =
        '${dateFormat.format(_dateRange.start)}_to_${dateFormat.format(_dateRange.end)}';
    final fileName = '${_filePrefixes[reportType]}_$dateRangeStr.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    final bytes = excel.encode();

    if (bytes != null) {
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: '${subjectPrefixes[reportType]} ($dateRangeStr)',
        sharePositionOrigin: shareOrigin,
      );
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _dateRange = pickedRange;
      });
    }
  }

  /// Muestra diálogo para elegir formato y orientación de exportación
  Future<void> _showExportOptionsDialog(ReportType reportType) async {
    ExportFormat? selectedFormat;
    PdfOrientation? selectedOrientation;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.export(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context).exportOptions,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Formato de archivo
                    Text(
                      AppLocalizations.of(context).fileFormat,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormatOption(
                            context: context,
                            icon: PhosphorIcons.fileXls(),
                            label: AppLocalizations.of(context).excelXlsx,
                            isSelected: selectedFormat == ExportFormat.xlsx,
                            onTap: () {
                              setModalState(() {
                                selectedFormat = ExportFormat.xlsx;
                                selectedOrientation = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFormatOption(
                            context: context,
                            icon: PhosphorIcons.filePdf(),
                            label: AppLocalizations.of(context).pdfFormat,
                            isSelected: selectedFormat == ExportFormat.pdf,
                            onTap: () {
                              setModalState(() {
                                selectedFormat = ExportFormat.pdf;
                                selectedOrientation ??= PdfOrientation.portrait;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // Orientación del PDF (solo si se selecciona PDF)
                    if (selectedFormat == ExportFormat.pdf) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Orientación del PDF',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormatOption(
                              context: context,
                              icon: PhosphorIcons.arrowsOutLineVertical(),
                              label: AppLocalizations.of(context).vertical,
                              isSelected: selectedOrientation == PdfOrientation.portrait,
                              onTap: () {
                                setModalState(() {
                                  selectedOrientation = PdfOrientation.portrait;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFormatOption(
                              context: context,
                              icon: PhosphorIcons.arrowsOutLineHorizontal(),
                              label: AppLocalizations.of(context).horizontal,
                              isSelected: selectedOrientation == PdfOrientation.landscape,
                              onTap: () {
                                setModalState(() {
                                  selectedOrientation = PdfOrientation.landscape;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Botón de exportar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedFormat != null
                            ? () {
                                Navigator.pop(context, {
                                  'format': selectedFormat,
                                  'orientation': selectedOrientation,
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context).export),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      final format = result['format'] as ExportFormat;
      final orientation = result['orientation'] as PdfOrientation?;
      
      // Ejecutar exportación según el tipo de reporte
      switch (reportType) {
        case ReportType.invoices:
          await _executeInvoicesExport(format, orientation);
          break;
        case ReportType.estimates:
          await _executeEstimatesExport(format, orientation);
          break;
        case ReportType.expenses:
          await _executeExpensesExport(format, orientation);
          break;
      }
    }
  }

  Widget _buildFormatOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportInvoices() async {
    await _showExportOptionsDialog(ReportType.invoices);
  }

  Future<void> _executeInvoicesExport(ExportFormat format, PdfOrientation? orientation) async {
    // Verificar límite freemium antes de generar reporte
    final canGenerate = await executeAsyncIfAllowed(
      FreemiumAction.generateReport,
      () async {
        if (format == ExportFormat.xlsx) {
          await _generateInvoicesReport();
        } else {
          await _generateInvoicesPdfReport(orientation ?? PdfOrientation.portrait);
        }
      },
    );

    // Si no se pudo generar por límite, executeAsyncIfAllowed ya mostró el paywall
    if (!canGenerate) return;
  }

  Future<void> _generateInvoicesReport() async {
    // Capture localizations before async operations
    final paidText = AppLocalizations.of(context).paid;
    final unpaidText = AppLocalizations.of(context).unpaid;

    await _generateReport(
      reportType: ReportType.invoices,
      getData: () async {
        final invoiceService = ref.read(invoiceServiceProvider);
        return await invoiceService.getInvoices();
      },
      getDate: (item) => item.documentDate,
      buildRow: (item, sheet, rowIndex) async {
        final clientName = await _getClientName(item.clientId);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(item.documentNumber ?? 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(item.documentDate != null
            ? dateFormat.format(item.documentDate!)
            : 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(clientName);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(item.poNumber ?? 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = DoubleCellValue(item.total);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(item.paid ? paidText : unpaidText);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(item.notes ?? '');
      },
    );
  }

  Future<void> _exportEstimates() async {
    await _showExportOptionsDialog(ReportType.estimates);
  }

  Future<void> _executeEstimatesExport(ExportFormat format, PdfOrientation? orientation) async {
    // Verificar límite freemium antes de generar reporte
    final canGenerate = await executeAsyncIfAllowed(
      FreemiumAction.generateReport,
      () async {
        if (format == ExportFormat.xlsx) {
          await _generateEstimatesReport();
        } else {
          await _generateEstimatesPdfReport(orientation ?? PdfOrientation.portrait);
        }
      },
    );

    // Si no se pudo generar por límite, executeAsyncIfAllowed ya mostró el paywall
    if (!canGenerate) return;
  }

  Future<void> _generateEstimatesReport() async {
    await _generateReport(
      reportType: ReportType.estimates,
      getData: () async {
        final estimateService = ref.read(estimateServiceProvider);
        return await estimateService.getEstimates();
      },
      getDate: (item) => item.documentDate,
      buildRow: (item, sheet, rowIndex) async {
        final clientName = await _getClientName(item.clientId);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(item.documentNumber ?? 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(item.documentDate !=
                null
            ? dateFormat.format(item.documentDate!)
            : 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(item.expiryDate !=
                null
            ? dateFormat.format(item.expiryDate!)
            : 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(clientName);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(item.poNumber ?? 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = DoubleCellValue(item.total);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(item.notes ?? '');
      },
    );
  }

  Future<void> _exportExpenses() async {
    await _showExportOptionsDialog(ReportType.expenses);
  }

  Future<void> _executeExpensesExport(ExportFormat format, PdfOrientation? orientation) async {
    // Verificar límite freemium antes de generar reporte
    final canGenerate = await executeAsyncIfAllowed(
      FreemiumAction.generateReport,
      () async {
        if (format == ExportFormat.xlsx) {
          await _generateExpensesReport();
        } else {
          await _generateExpensesPdfReport(orientation ?? PdfOrientation.portrait);
        }
      },
    );

    // Si no se pudo generar por límite, executeAsyncIfAllowed ya mostró el paywall
    if (!canGenerate) return;
  }

  Future<void> _generateExpensesReport() async {
    // Verificar autenticación
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) {
      _showErrorMessage(ReportType.expenses, 'User not authenticated');
      return;
    }

    await _generateReport(
      reportType: ReportType.expenses,
      getData: () async {
        final expenseListNotifier = ref.read(expenseListProvider.notifier);
        await expenseListNotifier.loadExpenses();
        return ref.read(expenseListProvider).expenses;
      },
      getDate: (item) => item.expenseDate,
      buildRow: (item, sheet, rowIndex) async {
        final categoryName = await _getCategoryName(item.category, existingCategoryName: item.categoryName);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(item.expenseDate !=
                null
            ? dateFormat.format(item.expenseDate!)
            : 'N/A');
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(item.merchant);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(categoryName);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = DoubleCellValue(item.total ?? 0.0);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = DoubleCellValue(item.tax ?? 0.0);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(item.description ?? '');
      },
    );
  }

  /// Genera reporte de facturas en PDF
  Future<void> _generateInvoicesPdfReport(PdfOrientation orientation) async {
    if (!mounted) return;
    if (!_validateReportGeneration()) return;

    // Capture localizations before async operations
    final localizations = AppLocalizations.of(context);
    final paidText = localizations.paid;
    final unpaidText = localizations.unpaid;

    setState(() => _isLoading = true);

    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final invoices = await invoiceService.getInvoices();
      
      final filteredInvoices = invoices.where((item) {
        final date = item.documentDate;
        if (date == null) return false;
        return date.isAfter(_dateRange.start) &&
            date.isBefore(_dateRange.end.add(const Duration(days: 1)));
      }).toList();

      if (filteredInvoices.isEmpty) {
        _showNoDataMessage(ReportType.invoices);
        return;
      }

      // Get client names for all invoices
      final clientNames = <String, String>{};
      for (final invoice in filteredInvoices) {
        if (invoice.clientId != null && !clientNames.containsKey(invoice.clientId)) {
          clientNames[invoice.clientId!] = await _getClientName(invoice.clientId);
        }
      }

      final pdf = pw.Document();
      final pageFormat = orientation == PdfOrientation.landscape
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPdfHeader(localizations.invoicesReport, orientation),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: orientation == PdfOrientation.landscape
                  ? {
                      0: const pw.FlexColumnWidth(1.2),
                      1: const pw.FlexColumnWidth(1.2),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1.2),
                      5: const pw.FlexColumnWidth(1),
                      6: const pw.FlexColumnWidth(2),
                    }
                  : {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(0.8),
                    },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildPdfCell('Invoice #', isHeader: true),
                    _buildPdfCell('Date', isHeader: true),
                    _buildPdfCell('Client Name', isHeader: true),
                    _buildPdfCell('PO Number', isHeader: true),
                    _buildPdfCell('Amount', isHeader: true),
                    _buildPdfCell('Status', isHeader: true),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell('Notes', isHeader: true),
                  ],
                ),
                // Data rows
                ...filteredInvoices.map((invoice) => pw.TableRow(
                  children: [
                    _buildPdfCell(invoice.documentNumber ?? 'N/A'),
                    _buildPdfCell(invoice.documentDate != null 
                        ? dateFormat.format(invoice.documentDate!) 
                        : 'N/A'),
                    _buildPdfCell(clientNames[invoice.clientId] ?? 'N/A'),
                    _buildPdfCell(invoice.poNumber ?? 'N/A'),
                    _buildPdfCell(currencyFormat.format(invoice.total)),
                    _buildPdfCell(invoice.paid ? paidText : unpaidText),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell(invoice.notes ?? ''),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),
            _buildPdfSummary(filteredInvoices.length, 
                filteredInvoices.fold(0.0, (sum, i) => sum + i.total)),
          ],
        ),
      );

      await _sharePdfFile(pdf, 'invoices_report');
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(ReportType.invoices, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Genera reporte de cotizaciones en PDF
  Future<void> _generateEstimatesPdfReport(PdfOrientation orientation) async {
    if (!mounted) return;
    if (!_validateReportGeneration()) return;

    setState(() => _isLoading = true);

    try {
      final estimateService = ref.read(estimateServiceProvider);
      final estimates = await estimateService.getEstimates();
      
      final filteredEstimates = estimates.where((item) {
        final date = item.documentDate;
        if (date == null) return false;
        return date.isAfter(_dateRange.start) &&
            date.isBefore(_dateRange.end.add(const Duration(days: 1)));
      }).toList();

      if (filteredEstimates.isEmpty) {
        _showNoDataMessage(ReportType.estimates);
        return;
      }

      // Get client names for all estimates
      final clientNames = <String, String>{};
      for (final estimate in filteredEstimates) {
        if (estimate.clientId != null && !clientNames.containsKey(estimate.clientId)) {
          clientNames[estimate.clientId!] = await _getClientName(estimate.clientId);
        }
      }

      final pdf = pw.Document();
      final pageFormat = orientation == PdfOrientation.landscape
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPdfHeader('Estimates Report', orientation),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: orientation == PdfOrientation.landscape
                  ? {
                      0: const pw.FlexColumnWidth(1.2),
                      1: const pw.FlexColumnWidth(1.2),
                      2: const pw.FlexColumnWidth(1.2),
                      3: const pw.FlexColumnWidth(1.5),
                      4: const pw.FlexColumnWidth(1.2),
                      5: const pw.FlexColumnWidth(1.2),
                      6: const pw.FlexColumnWidth(2),
                    }
                  : {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(1),
                    },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildPdfCell('Estimate #', isHeader: true),
                    _buildPdfCell('Date', isHeader: true),
                    _buildPdfCell('Expiry', isHeader: true),
                    _buildPdfCell('Client Name', isHeader: true),
                    _buildPdfCell('PO Number', isHeader: true),
                    _buildPdfCell('Amount', isHeader: true),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell('Notes', isHeader: true),
                  ],
                ),
                // Data rows
                ...filteredEstimates.map((estimate) => pw.TableRow(
                  children: [
                    _buildPdfCell(estimate.documentNumber ?? 'N/A'),
                    _buildPdfCell(estimate.documentDate != null 
                        ? dateFormat.format(estimate.documentDate!) 
                        : 'N/A'),
                    _buildPdfCell(estimate.expiryDate != null 
                        ? dateFormat.format(estimate.expiryDate!) 
                        : 'N/A'),
                    _buildPdfCell(clientNames[estimate.clientId] ?? 'N/A'),
                    _buildPdfCell(estimate.poNumber ?? 'N/A'),
                    _buildPdfCell(currencyFormat.format(estimate.total)),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell(estimate.notes ?? ''),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),
            _buildPdfSummary(filteredEstimates.length, 
                filteredEstimates.fold(0.0, (sum, e) => sum + e.total)),
          ],
        ),
      );

      await _sharePdfFile(pdf, 'estimates_report');
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(ReportType.estimates, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Genera reporte de gastos en PDF
  Future<void> _generateExpensesPdfReport(PdfOrientation orientation) async {
    if (!mounted) return;
    if (!_validateReportGeneration()) return;

    setState(() => _isLoading = true);

    try {
      final expenseListNotifier = ref.read(expenseListProvider.notifier);
      await expenseListNotifier.loadExpenses();
      final expenses = ref.read(expenseListProvider).expenses;
      
      final filteredExpenses = expenses.where((item) {
        final date = item.expenseDate;
        if (date == null) return false;
        return date.isAfter(_dateRange.start) &&
            date.isBefore(_dateRange.end.add(const Duration(days: 1)));
      }).toList();

      if (filteredExpenses.isEmpty) {
        _showNoDataMessage(ReportType.expenses);
        return;
      }

      // Get category names for all expenses
      final categoryNames = <int, String>{};
      for (final expense in filteredExpenses) {
        if (expense.category != null && !categoryNames.containsKey(expense.category)) {
          categoryNames[expense.category!] = await _getCategoryName(expense.category, existingCategoryName: expense.categoryName);
        }
      }

      final pdf = pw.Document();
      final pageFormat = orientation == PdfOrientation.landscape
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPdfHeader('Expenses Report', orientation),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: orientation == PdfOrientation.landscape
                  ? {
                      0: const pw.FlexColumnWidth(1.2),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.2),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(2.5),
                    }
                  : {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1.2),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(0.8),
                    },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildPdfCell('Date', isHeader: true),
                    _buildPdfCell('Merchant', isHeader: true),
                    _buildPdfCell('Category', isHeader: true),
                    _buildPdfCell('Amount', isHeader: true),
                    _buildPdfCell('Tax', isHeader: true),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell('Description', isHeader: true),
                  ],
                ),
                // Data rows
                ...filteredExpenses.map((expense) => pw.TableRow(
                  children: [
                    _buildPdfCell(expense.expenseDate != null 
                        ? dateFormat.format(expense.expenseDate!) 
                        : 'N/A'),
                    _buildPdfCell(expense.merchant),
                    _buildPdfCell(categoryNames[expense.category] ?? 'N/A'),
                    _buildPdfCell(currencyFormat.format(expense.total ?? 0)),
                    _buildPdfCell(currencyFormat.format(expense.tax ?? 0)),
                    if (orientation == PdfOrientation.landscape)
                      _buildPdfCell(expense.description ?? ''),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),
            _buildPdfSummary(filteredExpenses.length, 
                filteredExpenses.fold(0.0, (sum, e) => sum + (e.total ?? 0))),
          ],
        ),
      );

      await _sharePdfFile(pdf, 'expenses_report');
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(ReportType.expenses, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Construye el header del PDF
  pw.Widget _buildPdfHeader(String title, PdfOrientation orientation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.Text(
              'Generated: ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Period: ${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// Construye el footer del PDF
  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
      ),
    );
  }

  /// Construye una celda del PDF
  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: isHeader ? PdfColors.blueGrey800 : PdfColors.grey800,
        ),
      ),
    );
  }

  /// Construye el resumen del PDF
  pw.Widget _buildPdfSummary(int count, double total) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total Records: $count',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Total Amount: ${currencyFormat.format(total)}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
        ],
      ),
    );
  }

  /// Guarda y comparte el archivo PDF
  Future<void> _sharePdfFile(pw.Document pdf, String filePrefix) async {
    // Capture context-dependent values before async operations
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    final directory = await getApplicationDocumentsDirectory();
    final dateRangeStr =
        '${dateFormat.format(_dateRange.start)}_to_${dateFormat.format(_dateRange.end)}';
    final fileName = '${filePrefix}_$dateRangeStr.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '${filePrefix.replaceAll('_', ' ').toUpperCase()} ($dateRangeStr)',
      sharePositionOrigin: shareOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.reports,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(context, theme, localizations),
                  _buildReportsSection(context, theme, localizations),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.generateReports,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: ResponsiveUtils.h(16)),
            Text(
              localizations.selectDateRangeAndReportType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: ResponsiveUtils.h(24)),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.w(16),
                  vertical: ResponsiveUtils.h(16),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.w(12)),
                      decoration: BoxDecoration(
                        color: ProfileColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(ResponsiveUtils.r(8)),
                      ),
                      child: Icon(
                        PhosphorIcons.calendar(),
                        size: ResponsiveUtils.sp(20),
                        color: ProfileColors.primaryBlue,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.w(16)),
                    Expanded(
                      child: Text(
                        '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      PhosphorIcons.caretDown(),
                      size: ResponsiveUtils.sp(20),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.w(16),
        vertical: ResponsiveUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(16),
              ResponsiveUtils.w(20),
              ResponsiveUtils.h(8),
            ),
            child: Text(
              localizations.availableReports,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.sp(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildReportCard(
            context,
            title: localizations.invoicesReport,
            description: localizations.invoicesReportDescription,
            icon: PhosphorIcons.receipt(),
            color: ProfileColors.business,
            onTap: _exportInvoices,
          ),
          _buildReportCard(
            context,
            title: localizations.estimatesReport,
            description: localizations.estimatesReportDescription,
            icon: PhosphorIcons.fileText(),
            color: ProfileColors.edit,
            onTap: _exportEstimates,
          ),
          _buildReportCard(
            context,
            title: localizations.expensesReport,
            description: localizations.expensesReportDescription,
            icon: PhosphorIcons.shoppingBag(),
            color: ProfileColors.notifications,
            onTap: _exportExpenses,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.w(20),
          vertical: ResponsiveUtils.h(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.w(12)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
              ),
              child: Icon(
                icon,
                size: ResponsiveUtils.sp(24),
                color: color,
              ),
            ),
            SizedBox(width: ResponsiveUtils.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: ResponsiveUtils.sp(16),
                      color: color,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.h(2)),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: ResponsiveUtils.sp(14),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              size: ResponsiveUtils.sp(20),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
