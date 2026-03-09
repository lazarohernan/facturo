import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/common/ui/ui.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/views/invoice_list_view.dart';
import 'package:facturo/features/invoices/views/invoice_detail_view.dart';
import 'package:facturo/features/invoices/services/invoice_service.dart';
import 'package:facturo/features/subscriptions/services/subscription_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class InvoicesView extends ConsumerStatefulWidget {
  static const String routeName = 'invoices';
  static const String routePath = '/invoices';

  const InvoicesView({super.key});

  @override
  ConsumerState<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends ConsumerState<InvoicesView> {
  void _navigateToInvoiceDetail() async {
    // Check invoice limit before navigating
    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final currentCount = await invoiceService.getActiveInvoiceCount();
      if (!mounted) return;
      final localizations = AppLocalizations.of(context);

      final canProceed = await context.canPerformLimitedOperation(
        currentCount,
        InvoiceService.freeInvoiceLimit,
        title: localizations.limitReached,
        customMessage: localizations.usedAllFreeInvoices(
          InvoiceService.freeInvoiceLimit,
        ),
        icon: Icons.receipt_long,
      );

      if (!canProceed || !mounted) return;
    } catch (e) {
      debugPrint('Error verificando límite de facturas: $e');
      return;
    }
    if (!mounted) return;

    final bool? res = await context.push(InvoiceDetailView.routePath);

    if (res == true && mounted) {
      ref.read(invoiceListProvider.notifier).loadInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: localizations.invoices),
      body: Column(
        children: [
          const Expanded(child: InvoiceListView()),
          // Bottom button
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: AddButton(
                text: localizations.addInvoice,
                onPressed: _navigateToInvoiceDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
