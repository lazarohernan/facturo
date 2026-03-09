import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:facturo/core/services/currency_service.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';

/// Provider for the current currency based on app settings
final currentCurrencyProvider = Provider<Currency>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return CurrencyService.getCurrency(settings.currency) ??
         CurrencyService.defaultCurrency;
});

/// Provider for currency NumberFormat
final currencyFormatProvider = Provider<NumberFormat>((ref) {
  final currency = ref.watch(currentCurrencyProvider);
  return NumberFormat.currency(
    symbol: '${currency.symbol} ',
    decimalDigits: currency.decimalDigits,
  );
});

/// Extension to easily format amounts with current currency
extension CurrencyFormatExtension on WidgetRef {
  /// Format a double amount with the current currency
  String formatCurrency(double amount) {
    final currency = watch(currentCurrencyProvider);
    final formatter = NumberFormat.currency(
      symbol: currency.symbolBefore ? '${currency.symbol} ' : '',
      decimalDigits: currency.decimalDigits,
    );
    final formatted = formatter.format(amount);
    return currency.symbolBefore ? formatted : '$formatted ${currency.symbol}';
  }

  /// Get current currency
  Currency get currency => watch(currentCurrencyProvider);

  /// Get current NumberFormat
  NumberFormat get currencyFormat => watch(currencyFormatProvider);
}

/// Helper class for formatting currency without Riverpod context
class CurrencyFormatter {
  final Currency currency;

  CurrencyFormatter(this.currency);

  /// Create from currency code
  factory CurrencyFormatter.fromCode(String code) {
    final currency = CurrencyService.getCurrency(code) ??
                     CurrencyService.defaultCurrency;
    return CurrencyFormatter(currency);
  }

  /// Get NumberFormat for this currency
  NumberFormat get numberFormat => NumberFormat.currency(
    symbol: '${currency.symbol} ',
    decimalDigits: currency.decimalDigits,
  );

  /// Format an amount
  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbolBefore ? '${currency.symbol} ' : '',
      decimalDigits: currency.decimalDigits,
    );
    final formatted = formatter.format(amount);
    return currency.symbolBefore ? formatted : '$formatted ${currency.symbol}';
  }

  /// Get just the symbol
  String get symbol => currency.symbol;

  /// Get the currency code
  String get code => currency.code;
}
