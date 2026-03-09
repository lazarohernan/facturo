import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/features/invoices/models/invoice_model.dart';
import 'package:facturo/features/invoices/providers/invoice_provider.dart';
import 'package:facturo/features/invoices/services/invoice_service.dart';
import 'package:facturo/features/invoices/widgets/invoice_form.dart';
import 'package:facturo/features/invoices/widgets/invoice_preview_view.dart';
import 'package:facturo/features/subscriptions/services/subscription_checker.dart';
import 'package:facturo/features/subscriptions/mixins/freemium_mixin.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/core/design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'invoice-detail';
  static const String routePath = '/invoices/detail';
  static const String createRoutePath = '/invoices/create';

  final Invoice? invoice;
  final Map<String, dynamic>? ocrData; // Datos del OCR para crear factura
  final bool autoStartOCR;

  const InvoiceDetailView({
    super.key, 
    this.invoice,
    this.ocrData,
    this.autoStartOCR = false,
  });

  @override
  ConsumerState<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends ConsumerState<InvoiceDetailView>
    with TickerProviderStateMixin, FreemiumMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _hasShownImprovementPopup = false;
  bool _hasCheckedFreemiumLimit = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for tab changes — schedule setState via addPostFrameCallback
    // to avoid "setState() called during build" when TabBarView fires
    // the listener during its layout phase.
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autoStartOCR) _startOCRFromInvoice();
      if (widget.invoice == null) _checkFreemiumLimitOnEntry();
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
    final newIndex = _tabController.index;
    if (newIndex == _currentTabIndex) return;
    // Schedule the rebuild after the current frame to avoid
    // calling setState during TabBarView's build/layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentTabIndex = newIndex);
      if (newIndex == 1) _checkAndShowImprovementPopup();
    });
  }

  /// Verifica el límite freemium al entrar a crear una nueva factura
  Future<void> _checkFreemiumLimitOnEntry() async {
    if (_hasCheckedFreemiumLimit) return;
    _hasCheckedFreemiumLimit = true;

    final canCreate = await checkFreemiumAction(
      FreemiumAction.createInvoice,
      showPaywallOnLimit: true,
    );

    if (!canCreate && mounted) {
      // Si no puede crear, volver atrás
      context.pop();
    }
  }

  Future<void> _checkAndShowImprovementPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownPopup = prefs.getBool('has_shown_improvement_popup') ?? false;
    
    // Si ya se mostró el popup antes, no volver a mostrarlo automáticamente
    if (hasShownPopup || _hasShownImprovementPopup) return;
    
    // Esperar a que el perfil cargue
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final profileState = ref.read(userProfileProvider);
    final missingLogo = profileState.businessLogoUrl == null || profileState.businessLogoUrl!.isEmpty;
    final missingSignature = profileState.signatureUrl == null || profileState.signatureUrl!.isEmpty;
    
    // Solo mostrar si falta algo y estamos en el tab de vista previa (index 1)
    if ((missingLogo || missingSignature) && _currentTabIndex == 1) {
      _hasShownImprovementPopup = true;
      
      // Marcar como mostrado para no volver a mostrar automáticamente
      await prefs.setBool('has_shown_improvement_popup', true);
      
      // Mostrar popup con un pequeño delay
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showDocumentImprovementDialog(context, missingLogo, missingSignature);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Persists the invoice (create or update) in the database.
  /// Does NOT pop the screen — the form handles popping after uploading
  /// attachments so that its state stays alive during the upload.
  Future<void> _handleSubmit(Invoice invoice) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final invoiceService = ref.read(invoiceServiceProvider);

      if (widget.invoice == null) {
        await invoiceService.createInvoice(invoice);
      } else {
        await invoiceService.updateInvoice(invoice);
      }
      // Don't pop here — the form's _createInvoice will pop after
      // uploading attachments. If we popped now, the form would be
      // unmounted and attachments would never be uploaded.
    } catch (e) {
      if (!mounted) return;
      final localizations = AppLocalizations.of(context);

      if (e is FreeTierLimitExceededException) {
        if (!mounted) return;
        final didUpgrade = await context.checkSubscriptionOrRedirect(
          title: localizations.limitReached,
          message: e.toString(),
          icon: Icons.receipt_long,
        );

        if (didUpgrade && mounted) {
          _handleSubmit(invoice);
        }
        return;
      } else {
        if (mounted) {
          SnackbarService.showError(
            context,
            message: '${localizations.errorLoadingData}: ${e.toString()}',
          );
        }
        return;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewInvoice = widget.invoice == null;
    final localizations = AppLocalizations.of(context);
    final profileState = ref.watch(userProfileProvider);
    
    // Verificar si faltan logo o firma
    final missingLogo = profileState.businessLogoUrl == null || profileState.businessLogoUrl!.isEmpty;
    final missingSignature = profileState.signatureUrl == null || profileState.signatureUrl!.isEmpty;
    final showWarning = missingLogo || missingSignature;

    return Scaffold(
      appBar: AppBarWidget(
        title: isNewInvoice ? localizations.newInvoice : localizations.invoiceDetails,
        actions: [
          if (showWarning && _currentTabIndex == 1) // Solo mostrar en tab de preview
            FadeTransition(
              opacity: _pulseAnimation,
              child: IconButton(
                icon: Icon(
                  PhosphorIcons.info(PhosphorIconsStyle.regular),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                tooltip: localizations.improveYourDocumentTooltip,
                onPressed: () => _showDocumentImprovementDialog(context, missingLogo, missingSignature),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Semantics(
                    label: '${localizations.invoiceDetails}, tab 1 of 2',
                    selected: _currentTabIndex == 0,
                    child: Text(localizations.invoiceDetails),
                  ),
                ),
                Tab(
                  child: Semantics(
                    label: '${localizations.invoicePreview}, tab 2 of 2',
                    selected: _currentTabIndex == 1,
                    child: Text(localizations.invoicePreview),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Use Stack instead of ternary so the form stays mounted while
      // _isLoading is true. This allows _createInvoice to continue
      // uploading attachments after the DB operation completes.
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: Opacity(
              opacity: _isLoading ? 0.0 : 1.0,
              child: Container(
                color: theme.colorScheme.surface,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildInvoiceDetailsTab(theme),
                    _buildPreviewTab(theme, localizations),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Semantics(
              label: isNewInvoice ? localizations.creatingInvoice : localizations.updatingInvoice,
              liveRegion: true,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isNewInvoice ? localizations.creatingInvoice : localizations.updatingInvoice,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InvoiceForm(
        invoice: widget.invoice, 
        onSubmit: _handleSubmit,
        ocrData: widget.ocrData ?? _ocrData, // Pasar datos del OCR al formulario
      ),
    );
  }

  Map<String, dynamic>? _ocrData;

  Future<void> _startOCRFromInvoice() async {
    if (!mounted) return;
    try {
      await context.push('/receipt-uploader');
    } catch (e) {
      if (!mounted) return;
      SnackbarService.showGenericError(
        context,
        error: '${AppLocalizations.of(context).errorInitiatingOcr}: $e',
      );
    }
  }

  void _showDocumentImprovementDialog(BuildContext context, bool missingLogo, bool missingSignature) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              PhosphorIcons.lightbulb(PhosphorIconsStyle.fill),
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.improveYourDocument,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.makeInvoicesMoreProfessional,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (missingLogo)
              _buildImprovementItem(
                icon: PhosphorIcons.image(PhosphorIconsStyle.regular),
                title: localizations.addBusinessLogo,
                description: localizations.addBusinessLogoDescription,
              ),
            if (missingLogo && missingSignature) const SizedBox(height: 12),
            if (missingSignature)
              _buildImprovementItem(
                icon: PhosphorIcons.signature(PhosphorIconsStyle.regular),
                title: localizations.addDigitalSignature,
                description: localizations.addDigitalSignatureDescription,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  PhosphorIcons.info(PhosphorIconsStyle.regular),
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.elementsOptionalButImprove,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.laterButton),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/profile/business-info');
            },
            icon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.regular), size: 18),
            label: Text(localizations.configureButton),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.orange.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTab(ThemeData theme, AppLocalizations localizations) {
    if (widget.invoice == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.fileText(PhosphorIconsStyle.regular),
              size: DesignTokens.iconSize4xl,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            DesignTokens.gapLg,
            Text(
              localizations.fillInvoiceDetails,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return InvoicePreviewView(invoice: widget.invoice!);
  }
}
