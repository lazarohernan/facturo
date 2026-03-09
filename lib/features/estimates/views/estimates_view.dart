import 'package:facturo/common/ui/ui.dart';
import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/features/estimates/providers/estimate_provider.dart';
import 'package:facturo/features/estimates/views/estimate_list_view.dart';
import 'package:facturo/features/estimates/views/estimate_detail_view.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EstimatesView extends ConsumerStatefulWidget {
  static const String routeName = 'estimates';
  static const String routePath = '/estimates';

  const EstimatesView({super.key});

  @override
  ConsumerState<EstimatesView> createState() => _EstimatesViewState();
}

class _EstimatesViewState extends ConsumerState<EstimatesView> {
  void _navigateToEstimateDetail() async {
    // Navigate to the estimate detail view to create a new estimate
    final bool? res = await context.push(EstimateDetailView.routePath);

    // If the estimate was created, reload the estimates
    if (res != null && res == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(estimateListProvider.notifier).loadEstimates();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBarWidget(title: localizations.estimates),
      body: Column(
        children: [
          const Expanded(child: EstimateListView()),
          // Bottom button
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: AddButton(
                text: localizations.addEstimate,
                onPressed: _navigateToEstimateDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
