import 'package:facturo/common/widgets/app_bar_widget.dart';
import 'package:facturo/features/estimates/models/estimate_model.dart';
import 'package:facturo/features/estimates/providers/estimate_provider.dart';
import 'package:facturo/features/estimates/widgets/estimate_form.dart';
import 'package:facturo/features/estimates/widgets/estimate_preview_view.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/services/snackbar_service.dart';
import 'package:facturo/core/design_system/design_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstimateDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'estimate-detail';
  static const String routePath = '/estimates/detail';

  final Estimate? estimate;

  const EstimateDetailView({super.key, this.estimate});

  @override
  ConsumerState<EstimateDetailView> createState() => _EstimateDetailViewState();
}

class _EstimateDetailViewState extends ConsumerState<EstimateDetailView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _hasShownImprovementPopup = false;
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

    // Schedule setState via addPostFrameCallback to avoid
    // "setState() called during build" when TabBarView fires
    // the listener during its layout phase.
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!mounted) return;
    final newIndex = _tabController.index;
    if (newIndex == _currentTabIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentTabIndex = newIndex);
      if (newIndex == 1) _checkAndShowImprovementPopup();
    });
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

  Future<void> _handleSubmit(Estimate estimate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final estimateService = ref.read(estimateServiceProvider);

      if (widget.estimate == null) {
        // Create new estimate
        await estimateService.createEstimate(estimate);
        if (!mounted) return;
        
        // Los prompts de estimados ya no se muestran
        // Solo mantenemos prompts para primera factura y tiempo de uso
        
        if (!mounted) return;
        context.pop(true);
      } else {
        // Update existing estimate
        await estimateService.updateEstimate(estimate);
        if (!mounted) return;
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showGenericError(context, error: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewEstimate = widget.estimate == null;
    final localizations = AppLocalizations.of(context);
    final profileState = ref.watch(userProfileProvider);
    
    // Verificar si faltan logo o firma
    final missingLogo = profileState.businessLogoUrl == null || profileState.businessLogoUrl!.isEmpty;
    final missingSignature = profileState.signatureUrl == null || profileState.signatureUrl!.isEmpty;
    final showWarning = missingLogo || missingSignature;

    return Scaffold(
      appBar: AppBarWidget(
        title: isNewEstimate ? localizations.newEstimate : localizations.estimateDetails,
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
                Tab(text: localizations.estimateDetails),
                Tab(text: localizations.estimatePreview),
              ],
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Estimate Details Tab
                  _buildEstimateDetailsTab(theme),

                  // Preview Tab
                  _buildPreviewTab(theme),
                ],
              ),
    );
  }

  Widget _buildEstimateDetailsTab(ThemeData theme) {
    return EstimateForm(estimate: widget.estimate, onSubmit: _handleSubmit);
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
              localizations.makeEstimatesMoreProfessional,
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

  Widget _buildPreviewTab(ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    
    if (widget.estimate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.clipboardText(PhosphorIconsStyle.regular),
              size: DesignTokens.iconSize4xl,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            DesignTokens.gapLg,
            Text(
              localizations.fillEstimateDetails,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return EstimatePreviewView(estimate: widget.estimate!);
  }
}
