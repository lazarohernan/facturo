import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/services/invoice_service.dart';
import 'package:facturo/features/subscriptions/services/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the InvoiceService
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return InvoiceService(subscriptionService: subscriptionService);
});

// Invoice list state
enum InvoiceState { initial, loading, loaded, error }

class InvoiceListData {
  final InvoiceState state;
  final List<Invoice> invoices;
  final String? errorMessage;
  final String? searchQuery;

  InvoiceListData({
    this.state = InvoiceState.initial,
    this.invoices = const [],
    this.errorMessage,
    this.searchQuery,
  });

  InvoiceListData copyWith({
    InvoiceState? state,
    List<Invoice>? invoices,
    String? errorMessage,
    String? searchQuery,
  }) {
    return InvoiceListData(
      state: state ?? this.state,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Invoice list notifier
class InvoiceListNotifier extends StateNotifier<InvoiceListData> {
  final InvoiceService _invoiceService;

  InvoiceListNotifier(this._invoiceService) : super(InvoiceListData());

  // Load all invoices
  Future<void> loadInvoices() async {
    try {
      state = state.copyWith(state: InvoiceState.loading);
      final invoices = await _invoiceService.getInvoices();
      state = state.copyWith(
        state: InvoiceState.loaded,
        invoices: invoices,
        searchQuery: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: InvoiceState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Search invoices
  Future<void> searchInvoices(String query) async {
    if (query.isEmpty) {
      return loadInvoices();
    }

    try {
      state = state.copyWith(state: InvoiceState.loading, searchQuery: query);
      final invoices = await _invoiceService.searchInvoices(query);
      state = state.copyWith(state: InvoiceState.loaded, invoices: invoices);
    } catch (e) {
      state = state.copyWith(
        state: InvoiceState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Delete an invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _invoiceService.deleteInvoice(invoiceId);
      state = state.copyWith(
        invoices:
            state.invoices.where((invoice) => invoice.id != invoiceId).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        state: InvoiceState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update invoice paid status
  Future<void> updateInvoicePaidStatus(String invoiceId, bool paid) async {
    try {
      await _invoiceService.updateInvoicePaidStatus(invoiceId, paid);

      // Update the local state
      state = state.copyWith(
        invoices:
            state.invoices.map((invoice) {
              if (invoice.id == invoiceId) {
                return invoice.copyWith(paid: paid);
              }
              return invoice;
            }).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        state: InvoiceState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider for the invoice list
final invoiceListProvider =
    StateNotifierProvider<InvoiceListNotifier, InvoiceListData>((ref) {
      final invoiceService = ref.watch(invoiceServiceProvider);
      return InvoiceListNotifier(invoiceService);
    });

// Provider for a single invoice
final invoiceProvider = FutureProvider.family<Invoice, String>((
  ref,
  invoiceId,
) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  return invoiceService.getInvoice(invoiceId);
});
