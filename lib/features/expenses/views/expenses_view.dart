import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/features/expenses/views/expense_category_list_view.dart';
import 'package:facturo/features/expenses/views/expense_list_view.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: localizations.expenses,
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: localizations.expenses), Tab(text: localizations.categories)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [ExpenseListView(), ExpenseCategoryListView()],
      ),
    );
  }
}
