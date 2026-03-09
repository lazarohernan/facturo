import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/core/constants/app_sizes.dart';
import 'package:facturo/core/constants/profile_colors.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/core/design_system/design_system.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/features/profile/widgets/profile_completion_indicator.dart';
import 'package:facturo/features/clients/services/client_service.dart';
import 'package:facturo/features/expenses/services/expense_service.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/views/invoice_detail_view.dart';
import 'package:facturo/features/estimates/providers/estimate_provider.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/views/estimate_detail_view.dart';
import 'package:facturo/features/dashboard/widgets/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facturo/features/notifications/widgets/notification_icon_button.dart';
import 'package:facturo/features/settings/providers/app_settings_provider.dart';
import 'package:facturo/core/services/currency_service.dart';

// Modelo de datos para Syncfusion Charts
class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _isLoading = true;
  DateTime? _lastRefreshTime;
  static const Duration _refreshCooldown = Duration(
    seconds: 30,
  ); // 30 seconds cooldown

  // Number format without currency symbol for cards
  final numberFormat = NumberFormat('#,##0.00');

  // Dynamic currency format based on settings
  NumberFormat get currencyFormat {
    final settings = ref.watch(appSettingsProvider);
    final currency =
        CurrencyService.getCurrency(settings.currency) ??
        CurrencyService.defaultCurrency;
    return NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );
  }

  // Get current currency code for display
  String get currencyCode {
    final settings = ref.watch(appSettingsProvider);
    return settings.currency;
  }

  // Local state to store data
  List<dynamic> _invoices = [];
  List<dynamic> _estimates = [];
  List<dynamic> _expenses = [];
  List<dynamic> _clients = [];

  @override
  void initState() {
    super.initState();
    // Cargar el perfil del usuario automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).loadUserProfile();
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    // Check cooldown
    if (_lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _refreshCooldown) {
        final remainingSeconds =
            (_refreshCooldown - timeSinceLastRefresh).inSeconds;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).waitBeforeRefresh(remainingSeconds),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      if (!_isLoading) _isLoading = true;
    });

    try {
      // Get the user ID
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Use the service providers to fetch data
      final invoiceService = ref.read(invoiceServiceProvider);
      final estimateService = ref.read(estimateServiceProvider);
      final expenseService = ref.read(expenseServiceProvider);
      final clientService = ref.read(clientServiceProvider);

      // Fetch all data
      final invoicesData = await invoiceService.getInvoices();
      final estimatesData = await estimateService.getEstimates();
      final expensesData = await expenseService.getExpenses(userId);
      final clientsData = await clientService.getClients(userId);

      if (mounted) {
        setState(() {
          _invoices = invoicesData;
          _estimates = estimatesData;
          _expenses = expensesData;
          _clients = clientsData;
          _isLoading = false;
          _lastRefreshTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).errorRefreshingData}: $e',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateTo(String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);
    final localizations = AppLocalizations.of(context);

    // Calculate financial metrics from fetched data
    final totalPaidInvoices = _invoices
        .where((inv) => inv.paid == true)
        .fold(0.0, (sum, inv) => sum + (inv.total ?? 0));

    final totalPendingInvoices = _invoices
        .where((inv) => inv.paid != true)
        .fold(0.0, (sum, inv) => sum + (inv.total ?? 0));

    final totalExpenses = _expenses.fold(
      0.0,
      (sum, exp) => sum + (exp.total ?? 0),
    );

    // Recent activities - sort by most recent date and take top 5
    final recentInvoices = (() {
      final list = _invoices.whereType<Invoice>().toList();
      list.sort((a, b) {
        final aDate = a.documentDate ?? a.createdAt;
        final bDate = b.documentDate ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
      return list.take(5).toList();
    })();

    final recentEstimates = (() {
      final list = _estimates.whereType<Estimate>().toList();
      list.sort((a, b) {
        final aDate = a.documentDate ?? a.createdAt;
        final bDate = b.documentDate ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
      return list.take(5).toList();
    })();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboard),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(DesignTokens.spacingXl),
          ),
        ),
        actions: [
          const NotificationIconButton(),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.user),
            tooltip: localizations.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 50,
          right: DesignTokens.spacingSm,
        ),
        child: Semantics(
          label: localizations.scanReceipt,
          hint: localizations.doubleTapToScanReceipt,
          button: true,
          child: Container(
            width: DesignTokens.iconSize5xl,
            height: DesignTokens.iconSize5xl,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A), // Azul profundo primario
                  Color(0xFF2563EB), // Azul medio
                  Color(0xFF4F7AC7), // Azul más claro
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/receipt-uploader'),
                borderRadius: DesignTokens.radius(DesignTokens.spacingXl),
                child: Center(
                  child: Icon(
                    PhosphorIcons.scan(PhosphorIconsStyle.light),
                    size: DesignTokens.iconSize2xl,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Contenido principal del dashboard
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.all(
                            LayoutSystem.isMobile(context)
                                ? DesignTokens.spacingMd
                                : DesignTokens.spacingLg,
                          ).copyWith(
                            bottom: LayoutSystem.isMobile(context)
                                ? 120
                                : 140, // Espacio extra para FAB
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome card with business info
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                elevation: 0,
                                color: theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: DesignTokens.radius(
                                    DesignTokens.spacingLg,
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.08),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    LayoutSystem.isMobile(context)
                                        ? DesignTokens.spacingMd
                                        : DesignTokens.spacingLg,
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar/Logo
                                      Container(
                                        width: LayoutSystem.isMobile(context)
                                            ? DesignTokens.iconSize4xl
                                            : DesignTokens.iconSize5xl - 4,
                                        height: LayoutSystem.isMobile(context)
                                            ? DesignTokens.iconSize4xl
                                            : DesignTokens.iconSize5xl - 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.2),
                                            width: 2,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child:
                                            profileState.businessLogoUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: profileState
                                                    .businessLogoUrl!,
                                                width:
                                                    LayoutSystem.isMobile(
                                                      context,
                                                    )
                                                    ? DesignTokens.iconSize4xl
                                                    : DesignTokens.iconSize5xl -
                                                          4,
                                                height:
                                                    LayoutSystem.isMobile(
                                                      context,
                                                    )
                                                    ? DesignTokens.iconSize4xl
                                                    : DesignTokens.iconSize5xl -
                                                          4,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Icon(
                                                      PhosphorIcons.buildings(
                                                        PhosphorIconsStyle
                                                            .regular,
                                                      ),
                                                      size:
                                                          LayoutSystem.isMobile(
                                                            context,
                                                          )
                                                          ? DesignTokens
                                                                .iconSizeLg
                                                          : DesignTokens
                                                                    .iconSize2xl -
                                                                2,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                fadeInDuration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                              )
                                            : Icon(
                                                PhosphorIcons.buildings(
                                                  PhosphorIconsStyle.regular,
                                                ),
                                                size:
                                                    LayoutSystem.isMobile(
                                                      context,
                                                    )
                                                    ? DesignTokens.iconSizeLg
                                                    : DesignTokens.iconSize2xl -
                                                          2,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                      ),
                                      SizedBox(
                                        width: LayoutSystem.isMobile(context)
                                            ? DesignTokens.spacingMd
                                            : ResponsiveUtils.w(16),
                                      ),
                                      // Business info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  PhosphorIcons.thumbsUp(
                                                    PhosphorIconsStyle.regular,
                                                  ),
                                                  size:
                                                      LayoutSystem.isMobile(
                                                        context,
                                                      )
                                                      ? DesignTokens.fontSizeLg
                                                      : DesignTokens.fontSizeXl,
                                                  color: Colors.amber,
                                                ),
                                                DesignTokens.gapSm,
                                                Text(
                                                  '${localizations.welcome}!',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                            DesignTokens.gapXs,
                                            Text(
                                              profileState.businessName ??
                                                  localizations.yourBusiness,
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Indicador de completado en la esquina
                              Positioned(
                                top: ResponsiveUtils.h(16),
                                right: ResponsiveUtils.w(16),
                                child: const ProfileCompletionIndicator(),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile ? 16 : 20),

                          // Financial overview
                          _buildFinancialOverview(
                            context,
                            theme,
                            localizations,
                            totalPaidInvoices,
                            totalPendingInvoices,
                            totalExpenses,
                          ),

                          SizedBox(height: ResponsiveUtils.isMobile ? 8 : 12),

                          // Quick Actions
                          _buildQuickActions(context, theme, localizations),
                          SizedBox(height: ResponsiveUtils.isMobile ? 16 : 20),

                          // Responsive Example - Solo mostrar en pantallas grandes
                          if (!ResponsiveUtils.isMobile) ...[
                            _buildResponsiveExample(
                              context,
                              theme,
                              localizations,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Income vs Expenses Chart
                          _buildChart(context, theme, localizations),
                          SizedBox(height: ResponsiveUtils.isMobile ? 16 : 20),

                          // Recent Activity
                          _buildRecentActivity(
                            context,
                            theme,
                            localizations,
                            recentInvoices,
                            recentEstimates,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Welcome card flotante (al final para que aparezca encima)
                const WelcomeCard(),
              ],
            ),
    );
  }

  // Helper widget for financial overview
  Widget _buildFinancialOverview(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    double paid,
    double pending,
    double expenses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.financialOverview,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.responsiveH(8)),
        SizedBox(
          height: 260,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: DesignTokens.spacingMd,
            mainAxisSpacing: DesignTokens.spacingMd,
            childAspectRatio: 1.7,
            children: [
              _FinancialCard(
                title: localizations.paidInvoices,
                amount: numberFormat.format(paid),
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                color: theme.colorScheme.primary,
                currencyCode: currencyCode,
              ),
              _FinancialCard(
                title: localizations.pendingInvoices,
                amount: numberFormat.format(pending),
                icon: PhosphorIcons.timer(PhosphorIconsStyle.regular),
                color: theme.colorScheme.primary,
                currencyCode: currencyCode,
              ),
              _FinancialCard(
                title: localizations.expenses,
                amount: numberFormat.format(expenses),
                icon: PhosphorIcons.trendDown(PhosphorIconsStyle.regular),
                color: theme.colorScheme.primary,
                currencyCode: currencyCode,
              ),
              _FinancialCard(
                title: localizations.netIncome,
                amount: numberFormat.format(paid - expenses),
                icon: PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
                color: theme.colorScheme.primary,
                currencyCode: currencyCode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for quick actions
  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final quickActions = <Widget>[
      _QuickActionButton(
        icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
        label: localizations.invoices,
        color: ProfileColors.business,
        onTap: () => _navigateTo(AppConstants.invoicesRoute),
      ),
      _QuickActionButton(
        icon: PhosphorIcons.calculator(PhosphorIconsStyle.regular),
        label: localizations.estimates,
        color: ProfileColors.edit,
        onTap: () => _navigateTo(AppConstants.estimatesRoute),
      ),
      _QuickActionButton(
        icon: PhosphorIcons.wallet(PhosphorIconsStyle.regular),
        label: localizations.expenses,
        color: ProfileColors.warning,
        onTap: () => _navigateTo(AppConstants.expensesRoute),
      ),
      _QuickActionButton(
        icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
        label: localizations.clients,
        color: ProfileColors.language,
        onTap: () => _navigateTo(AppConstants.clientsRoute),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.quickActions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.responsiveH(8)),
        SizedBox(
          height: LayoutSystem.isMobile(context) ? 90 : 100,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: LayoutSystem.isMobile(context)
                ? DesignTokens.spacingSm
                : DesignTokens.spacingMd,
            mainAxisSpacing: LayoutSystem.isMobile(context)
                ? DesignTokens.spacingXs
                : DesignTokens.spacingSm,
            childAspectRatio: LayoutSystem.isMobile(context) ? 0.75 : 0.85,
            children: quickActions,
          ),
        ),
      ],
    );
  }

  // Helper widget for responsive example
  Widget _buildResponsiveExample(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.responsiveDesign,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.testResponsiveDesign,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DesignTokens.gapSm,
                Text(
                  localizations.howAppAdapts,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                DesignTokens.gapLg,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/responsive-example'),
                    icon: Icon(PhosphorIcons.phone(PhosphorIconsStyle.regular)),
                    label: Text(localizations.viewResponsiveExample),
                    style: ElevatedButton.styleFrom(
                      padding: DesignTokens.paddingSymmetric(
                        vertical: DesignTokens.spacingMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for the chart
  Widget _buildChart(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    // Calculate total income, expenses and net income
    final totalPaidInvoices = _invoices
        .where((inv) => inv.paid == true)
        .fold(0.0, (sum, inv) => sum + (inv.total ?? 0));

    final totalExpenses = _expenses.fold(
      0.0,
      (sum, exp) => sum + (exp.total ?? 0),
    );

    final netIncome = totalPaidInvoices - totalExpenses;

    // Check if there's any data to show
    final hasData = totalPaidInvoices > 0 || totalExpenses > 0;

    // Prepare chart data
    final List<ChartData> chartData = [
      ChartData(localizations.income, totalPaidInvoices, Colors.green),
      ChartData(localizations.expenses, totalExpenses, Colors.red),
      ChartData(
        localizations.netIncome,
        netIncome.abs(),
        netIncome >= 0 ? theme.colorScheme.primary : Colors.orange,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.incomeVsExpenses,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: theme.colorScheme.shadow,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              height: ResponsiveUtils.isMobile ? 280 : 320,
              padding: ResponsiveUtils.isMobile
                  ? DesignTokens.paddingAll(DesignTokens.spacingMd)
                  : DesignTokens.paddingAll(DesignTokens.spacingLg),
              child: hasData
                  ? _buildSyncfusionChart(theme, localizations, chartData)
                  : _buildEmptyState(theme, localizations),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
            size: DesignTokens.iconSize4xl - 8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          DesignTokens.gapMd,
          Text(
            localizations.noDataToShow,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Nueva implementación con Syncfusion Charts
  Widget _buildSyncfusionChart(
    ThemeData theme,
    AppLocalizations localizations,
    List<ChartData> chartData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: chartData
              .map(
                (data) => Padding(
                  padding: const EdgeInsets.only(right: DesignTokens.spacingLg),
                  child: _buildLegendItem(theme, data.color, data.category),
                ),
              )
              .toList(),
        ),
        DesignTokens.gapXl,
        // Chart
        Expanded(
          child: charts.SfCartesianChart(
            plotAreaBorderWidth: 0,
            isTransposed: true,
            // Eje X: Categorías (Ingresos, Gastos, Net Income)
            primaryXAxis: charts.CategoryAxis(
              majorGridLines: const charts.MajorGridLines(width: 0),
              majorTickLines: const charts.MajorTickLines(size: 0),
              axisLine: const charts.AxisLine(width: 0),
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            // Eje Y: Valores numéricos (horizontal al estar transposed)
            primaryYAxis: const charts.NumericAxis(
              minimum: 0, // Asegurar que las barras empiecen desde cero
              isVisible: false,
              majorGridLines: charts.MajorGridLines(width: 0),
              majorTickLines: charts.MajorTickLines(size: 0),
              axisLine: charts.AxisLine(width: 0),
            ),
            series: <charts.BarSeries<ChartData, String>>[
              charts.BarSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) =>
                    data.category, // Categorías en eje X (horizontal)
                yValueMapper: (ChartData data, _) =>
                    data.value, // Valores en eje Y (vertical)
                pointColorMapper: (ChartData data, _) => data.color,
                isTrackVisible: true, // ¡Barras de fondo!
                trackColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                trackBorderWidth: 0,
                trackPadding: 4,
                width: 0.7, // Altura de las barras
                spacing: 0.2,
                borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
                dataLabelSettings: const charts.DataLabelSettings(
                  isVisible: false,
                ),
                animationDuration: 800, // Animación suave
              ),
            ],
            tooltipBehavior: charts.TooltipBehavior(
              enable: true,
              activationMode: charts.ActivationMode.singleTap,
              header: '',
              builder:
                  (
                    dynamic data,
                    dynamic point,
                    dynamic series,
                    int pointIndex,
                    int seriesIndex,
                  ) {
                    final chartPoint = data as ChartData;
                    final formattedValue = numberFormat.format(
                      chartPoint.value,
                    );
                    return Container(
                      padding: DesignTokens.paddingSymmetric(
                        horizontal: DesignTokens.spacingMd,
                        vertical: DesignTokens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: DesignTokens.radius(
                          DesignTokens.borderRadiusSm,
                        ),
                      ),
                      child: Text(
                        '${chartPoint.category}: $formattedValue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      children: [
        Container(
          width: DesignTokens.spacingMd,
          height: DesignTokens.spacingMd,
          decoration: BoxDecoration(
            color: color,
            borderRadius: DesignTokens.radius(DesignTokens.borderRadiusXs - 1),
          ),
        ),
        DesignTokens.gapXs,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // Helper widget for recent activity
  Widget _buildRecentActivity(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    List<dynamic> recentInvoices,
    List<dynamic> recentEstimates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.recentActivity,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _navigateTo(AppConstants.invoicesRoute),
              icon: Icon(
                PhosphorIcons.arrowRight(PhosphorIconsStyle.regular),
                size: DesignTokens.iconSizeSm,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                localizations.seeAll,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: DesignTokens.fontSizeSm,
                ),
              ),
              style: TextButton.styleFrom(
                padding: DesignTokens.paddingSymmetric(
                  horizontal: DesignTokens.spacingSm,
                ),
                minimumSize: const Size(0, 0),
              ),
            ),
          ],
        ),
        DesignTokens.gapMd,
        _buildActivitySection(
          context,
          theme,
          localizations,
          localizations.recentInvoices,
          recentInvoices,
          PhosphorIcons.receipt(PhosphorIconsStyle.regular),
          AppConstants.invoicesRoute,
        ),
        DesignTokens.gapLg,
        _buildActivitySection(
          context,
          theme,
          localizations,
          localizations.recentEstimates,
          recentEstimates,
          PhosphorIcons.fileText(PhosphorIconsStyle.regular),
          AppConstants.estimatesRoute,
        ),
        DesignTokens.gap2xl,
        _buildSummarySection(context, theme, localizations),
      ],
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    // Definimos una paleta de colores azules atractivos
    const Color invoiceColor = Color(0xFF3B82F6); // Azul brillante
    const Color estimateColor = Color(0xFF0EA5E9); // Azul cielo
    const Color clientColor = Color(0xFF6366F1); // Azul índigo

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.summary,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: theme.colorScheme.shadow,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Padding(
              padding: DesignTokens.paddingAll(DesignTokens.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    theme,
                    PhosphorIcons.fileText(PhosphorIconsStyle.regular),
                    _invoices.length.toString(),
                    localizations.invoices,
                    invoiceColor,
                  ),
                  _buildVerticalDivider(theme),
                  _buildSummaryItem(
                    context,
                    theme,
                    PhosphorIcons.calculator(PhosphorIconsStyle.regular),
                    _estimates.length.toString(),
                    localizations.estimates,
                    estimateColor,
                  ),
                  _buildVerticalDivider(theme),
                  _buildSummaryItem(
                    context,
                    theme,
                    PhosphorIcons.users(PhosphorIconsStyle.regular),
                    _clients.length.toString(),
                    localizations.clients,
                    clientColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String count,
    String label,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: DesignTokens.paddingAll(DesignTokens.spacingSm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: DesignTokens.iconSizeLg - 2,
          ),
        ),
        DesignTokens.gapSm,
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        DesignTokens.gapXs,
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // Helper widget for recent activity
  Widget _buildActivitySection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    String title,
    List<dynamic> items,
    IconData icon,
    String viewAllRoute,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: theme.colorScheme.shadow,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 3),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Padding(
          padding: DesignTokens.paddingAll(DesignTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: DesignTokens.paddingAll(
                      DesignTokens.spacingXs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: DesignTokens.radius(
                        DesignTokens.borderRadiusSm,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: DesignTokens.fontSizeXl,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingSm + 2),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              DesignTokens.gapLg,
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.spacing2xl + 6,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: DesignTokens.iconSize4xl - 8,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      DesignTokens.gapMd,
                      Text(
                        title == localizations.recentInvoices
                            ? localizations.noRecentInvoices
                            : localizations.noRecentEstimates,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...items.map(
                  (item) => _buildActivityItem(context, item, localizations),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    dynamic item,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final isInvoice = item is Invoice;

    String title = localizations.noDate;
    if (isInvoice) {
      title = item.documentNumber ?? localizations.noInvoiceNumber;
    } else if (item is Estimate) {
      title = item.documentNumber ?? localizations.noEstimateNumber;
    }

    String subtitle = localizations.noDate;
    if (isInvoice) {
      subtitle = currencyFormat.format(item.total);
    } else if (item is Estimate) {
      subtitle = currencyFormat.format(item.total);
    }

    final DateTime? date = isInvoice
        ? item.documentDate
        : (item is Estimate ? item.documentDate : null);
    final bool isPaid = isInvoice ? (item.paid == true) : false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
        ),
        shadowColor: theme.colorScheme.shadow,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (isInvoice) {
                context.push(InvoiceDetailView.routePath, extra: item);
              } else if (item is Estimate) {
                context.push(EstimateDetailView.routePath, extra: item);
              }
            },
            borderRadius: DesignTokens.radius(DesignTokens.borderRadiusSm),
            child: Padding(
              padding: DesignTokens.paddingAll(DesignTokens.spacingMd),
              child: Row(
                children: [
                  SizedBox(
                    width: DesignTokens.iconSize4xl - 8,
                    height: DesignTokens.iconSize4xl - 8,
                    child: Center(
                      child: Icon(
                        isInvoice
                            ? (isPaid
                                  ? PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.regular,
                                    )
                                  : PhosphorIcons.timer(
                                      PhosphorIconsStyle.regular,
                                    ))
                            : PhosphorIcons.fileText(
                                PhosphorIconsStyle.regular,
                              ),
                        color: theme.colorScheme.primary,
                        size: DesignTokens.iconSizeLg - 2,
                      ),
                    ),
                  ),
                  DesignTokens.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DesignTokens.spacingXs / 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DesignTokens.gapSm,
                  Container(
                    padding: DesignTokens.paddingSymmetric(
                      horizontal: DesignTokens.spacingSm,
                      vertical: DesignTokens.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        width: 1.0,
                      ),
                      borderRadius: DesignTokens.radius(
                        DesignTokens.spacingXs + 2,
                      ),
                      color: theme.colorScheme.surface,
                    ),
                    child: Text(
                      date != null
                          ? DateFormat('MMM d').format(date)
                          : localizations.noDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: DesignTokens
                            .fontSizeSm, // Apple HIG: minimum 11pt, recommended 12pt+
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for financial cards in the overview
class _FinancialCard extends StatelessWidget {
  const _FinancialCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currencyCode,
  });

  final String title;
  final String amount;
  final dynamic icon; // Puede ser IconData o LucideIconData
  final Color color;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: $amount $currencyCode',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: theme.colorScheme.shadow,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 3),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Padding(
            padding: AppSizes.responsivePaddingAll(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with icon and currency
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon as IconData,
                      size: AppSizes.responsiveSp(18),
                      color: color,
                    ),
                    Text(
                      currencyCode,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: AppSizes.responsiveSp(11),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.responsiveH(8)),
                // Amount - Hacer flexible
                Flexible(
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.responsiveSp(14),
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: AppSizes.responsiveH(4)),
                // Title - Hacer flexible
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: AppSizes.responsiveSp(11),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Quick action button widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: label,
      hint: 'Double tap to navigate to $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radius(DesignTokens.borderRadiusMd),
        child: Padding(
          padding: DesignTokens.paddingSymmetric(
            vertical: DesignTokens.spacingXs,
            horizontal: DesignTokens.spacingXs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: LayoutSystem.isMobile(context)
                      ? DesignTokens.iconSize4xl
                      : DesignTokens.iconSize5xl - 8,
                  height: LayoutSystem.isMobile(context)
                      ? DesignTokens.iconSize4xl
                      : DesignTokens.iconSize5xl - 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: DesignTokens.radius(
                      DesignTokens.borderRadiusMd,
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: LayoutSystem.isMobile(context)
                        ? DesignTokens.iconSizeLg
                        : DesignTokens.iconSize2xl - 4,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXs),
              ExcludeSemantics(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
