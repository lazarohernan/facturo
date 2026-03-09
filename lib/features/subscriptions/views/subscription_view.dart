import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:facturo/core/utils/responsive_utils.dart';
import 'package:facturo/common/widgets/loading_widget.dart';
import 'package:facturo/features/subscriptions/models/subscription_model.dart';
import 'package:facturo/features/subscriptions/services/subscription_service.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class SubscriptionView extends ConsumerStatefulWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final bool isFirstTimePaywall;
  final String? sourceRoute;
  final String? selectedPlan;
  final bool autoStartPurchase;

  const SubscriptionView({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.isFirstTimePaywall = false,
    this.sourceRoute,
    this.selectedPlan,
    this.autoStartPurchase = false,
  });

  @override
  ConsumerState<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends ConsumerState<SubscriptionView> {
  bool _isLoading = false;
  bool _isLoadingProducts = true;
  int _selectedPlanIndex = 0; // Default to monthly plan (most common choice)
  ScrollController? _scrollController;
  Timer? _timer;
  bool _isUserScrolling = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScrollStart);
    _startAutoScroll();
    
    // Si viene con un plan seleccionado, establecerlo
    if (widget.selectedPlan != null) {
      _selectedPlanIndex = widget.selectedPlan == 'monthly' ? 0 : 1;
    }
    
    // Inicializar productos cuando se muestra el paywall
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProducts();
    });
    
    // Si debe auto-iniciar la compra, hacerlo después del primer frame
    if (widget.autoStartPurchase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoStartPurchase();
      });
    }
  }
  
  Future<void> _initializeProducts() async {
    try {
      setState(() {
        _isLoadingProducts = true;
      });
      
      final subscriptionService = ref.read(subscriptionServiceProvider);
      await subscriptionService.initializeProducts();
      
      // Verificar si los productos se cargaron correctamente
      const plans = SubscriptionPlan.allPlans;
      bool hasProducts = true;
      for (final plan in plans) {
        final productDetails = subscriptionService.getProductDetails(plan.id);
        if (productDetails == null) {
          debugPrint('⚠️ Producto no disponible: ${plan.id}');
          hasProducts = false;
        }
      }
      
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
        
        if (!hasProducts && !widget.isFirstTimePaywall) {
          // Mostrar advertencia si los productos no están disponibles
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).localeName.startsWith('es')
                    ? 'Los productos aún se están cargando. Intenta de nuevo en un momento.'
                    : 'Products are still loading. Please try again in a moment.'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error inicializando productos: $e');
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }
  
  Future<void> _autoStartPurchase() async {
    const plans = SubscriptionPlan.allPlans;
    if (_selectedPlanIndex < plans.length) {
      final plan = plans[_selectedPlanIndex];
      await _handlePurchase(plan);
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _scrollController?.removeListener(_onScrollStart);
    _scrollController?.dispose();
    super.dispose();
  }
  
  void _onScrollStart() {
    if (!_isUserScrolling) {
      setState(() {
        _isUserScrolling = true;
      });
      _timer?.cancel();
      
      // Reanudar auto-scroll después de 5 segundos de inactividad
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isUserScrolling = false;
          });
          _startAutoScroll();
        }
      });
    }
  }
  
  
  void _startAutoScroll() {
    // Animación continua y suave
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController!.hasClients && !_isUserScrolling) {
        final maxScroll = _scrollController!.position.maxScrollExtent;
        final currentScroll = _scrollController!.offset;
        
        // Velocidad de scroll visible (pixels por frame)
        const scrollSpeed = 1.2;
        final targetScroll = currentScroll + scrollSpeed;
        
        if (targetScroll >= maxScroll) {
          // Reiniciar desde el principio instantáneamente
          _scrollController!.jumpTo(0);
        } else {
          // Scroll suave continuo
          _scrollController!.jumpTo(targetScroll);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    const subscriptionPlans = SubscriptionPlan.allPlans;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Contenido principal edge-to-edge
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: ResponsiveUtils.w(20),
              right: ResponsiveUtils.w(20),
              bottom: ResponsiveUtils.w(20),
              top: ResponsiveUtils.w(20), // Margen para notch/status bar
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveUtils.h(16)),
              
              // Hero Section Minimalista
              _buildHeroSection(context, theme, localizations),
              
              SizedBox(height: ResponsiveUtils.h(8)),
              
              // Planes de Precio
              Text(
                localizations.chooseYourPlan,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.h(16)),
              
              ...subscriptionPlans.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                final isSelected = index == _selectedPlanIndex;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveUtils.h(12)),
                  child: _buildPlanCard(context, theme, localizations, plan, index, isSelected),
                );
              }),
              
              SizedBox(height: ResponsiveUtils.h(24)),
              
              // Botón Principal
              _buildBottomSection(context, theme, localizations, subscriptionPlans),
              
              SizedBox(height: ResponsiveUtils.h(16)),
              
              // Restore purchases
              Center(
                child: TextButton(
                  onPressed: () async {
                    // Capture localized strings before async operation
                    final successMessage = localizations.purchasesRestoredSuccessfully;
                    final errorPrefix = localizations.errorRestoringPurchases;
                    try {
                      final subscriptionService = ref.read(subscriptionServiceProvider);
                      await subscriptionService.restorePurchases();
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(successMessage),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('$errorPrefix: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    localizations.restorePurchases,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.sp(14),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              
              // Terms text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(16)),
                child: Text(
                  localizations.subscriptionsRenewAutomatically,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveUtils.sp(12), // Apple HIG: minimum 11pt
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.h(12)),
              
              // Links to Terms of Use and Privacy Policy
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final isEnglish = localizations.localeName.startsWith('en');
                      final termsUrl = isEnglish 
                          ? 'https://facturoapp.com/terms-and-conditions-en.html'
                          : 'https://facturoapp.com/terms-and-conditions.html';
                      final uri = Uri.parse(termsUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      localizations.termsOfService,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(12),
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.sp(12),
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final isEnglish = localizations.localeName.startsWith('en');
                      final privacyUrl = isEnglish 
                          ? 'https://facturoapp.com/privacy-policy-en.html'
                          : 'https://facturoapp.com/privacy-policy.html';
                      final uri = Uri.parse(privacyUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      localizations.privacyPolicy,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(12),
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + ResponsiveUtils.h(20)),
            ],
          ),
        ),
          
          // Botón X flotante dinámico según el origen
          Positioned(
            top: MediaQuery.of(context).padding.top + ResponsiveUtils.w(16),
            right: _getCloseButtonPosition(context).right,
            left: _getCloseButtonPosition(context).left,
            child: GestureDetector(
              onTap: () {
                // Verificar si se puede hacer pop antes de intentarlo
                if (context.canPop()) {
                  context.pop();
                } else {
                  // Si no hay ruta anterior, navegar al dashboard o ruta inicial
                  context.go('/');
                }
              },
              child: Container(
                width: ResponsiveUtils.w(44),
                height: ResponsiveUtils.w(44),
                alignment: _getCloseButtonPosition(context).alignment,
                child: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  size: ResponsiveUtils.w(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para calcular posición dinámica del botón cerrar según el origen
  _CloseButtonPosition _getCloseButtonPosition(BuildContext context) {
    final source = widget.sourceRoute;
    
    // Si viene del dashboard o menú principal, poner en la esquina superior derecha
    if (source == 'dashboard' || source == 'home' || source == null) {
      return _CloseButtonPosition(
        right: ResponsiveUtils.w(20),
        left: null,
        alignment: Alignment.center,
      );
    }
    
    // Si viene de crear factura/cliente, poner en la esquina superior izquierda
    if (source == 'invoice' || source == 'client' || source == 'ocr') {
      return _CloseButtonPosition(
        left: ResponsiveUtils.w(20),
        right: null,
        alignment: Alignment.center,
      );
    }
    
    // Por defecto, esquina superior derecha
    return _CloseButtonPosition(
      right: ResponsiveUtils.w(20),
      left: null,
      alignment: Alignment.center,
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: ResponsiveUtils.h(40),
        bottom: ResponsiveUtils.h(32),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
      ),
      child: Column(
        children: [
          // Imagen del paywall - centrada sin padding horizontal
          Center(
            child: SizedBox(
              width: ResponsiveUtils.w(160),
              height: ResponsiveUtils.w(160),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.r(24)),
                child: Image.asset(
                  'assets/images/paywallimg.png',
                  width: ResponsiveUtils.w(160),
                  height: ResponsiveUtils.w(160),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.h(24)),
          
          // Título y Subtítulo - debajo de la imagen como parte del mensaje
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(24)),
            child: Column(
              children: [
                Text(
                  'FACTURO PRO',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: ResponsiveUtils.sp(24),
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.h(4)),
                Text(
                  widget.message ?? localizations.paywallDefaultMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveUtils.sp(16),
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.h(24)),
          
          // Carrusel de características principales - contenido dentro del container
          ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
            child: _buildFeaturesCarousel(theme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: ResponsiveUtils.w(44),
          height: ResponsiveUtils.w(44),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: ResponsiveUtils.w(22),
          ),
        ),
        SizedBox(height: ResponsiveUtils.h(8)),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: ResponsiveUtils.sp(12), // Apple HIG: minimum 11pt
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Carrusel de características principales (iconos) - completamente de lado a lado
  Widget _buildFeaturesCarousel(ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    final features = [
      {'icon': PhosphorIcons.fileText(PhosphorIconsStyle.regular), 'title': localizations.invoices},
      {'icon': PhosphorIcons.users(PhosphorIconsStyle.regular), 'title': localizations.clients},
      {'icon': PhosphorIcons.scan(PhosphorIconsStyle.regular), 'title': 'OCR'},
      {'icon': PhosphorIcons.clipboardText(PhosphorIconsStyle.regular), 'title': localizations.estimates},
      {'icon': PhosphorIcons.chartBar(PhosphorIconsStyle.regular), 'title': localizations.reports},
      {'icon': PhosphorIcons.pen(PhosphorIconsStyle.regular), 'title': localizations.digitalSignature},
      {'icon': PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular), 'title': localizations.share},
      {'icon': PhosphorIcons.cloud(PhosphorIconsStyle.regular), 'title': localizations.cloud},
    ];
    
    return SizedBox(
      height: ResponsiveUtils.h(100),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Container(
            width: ResponsiveUtils.w(80),
            margin: EdgeInsets.zero,
            child: _buildFeatureItem(
              theme, 
              feature['icon'] as IconData, 
              feature['title'] as String
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, ThemeData theme, AppLocalizations localizations, SubscriptionPlan plan, int index, bool isSelected) {
    final isRecommended = plan.id.contains('annual');
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final productDetails = subscriptionService.getProductDetails(plan.id);
    
    // Obtener precio real de StoreKit o usar precio por defecto
    final displayPrice = productDetails?.price ?? '\$${plan.price.toInt()}';
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.w(20)),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.localeName.startsWith('es') ? plan.titleEs : plan.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.sp(16),
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                  SizedBox(height: ResponsiveUtils.h(6)),
                  Text(
                    localizations.localeName.startsWith('es') ? plan.descriptionEs : plan.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: ResponsiveUtils.sp(13),
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (plan.type == SubscriptionType.annual) ...[
                    SizedBox(height: ResponsiveUtils.h(6)),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.piggyBank(PhosphorIconsStyle.regular),
                          size: ResponsiveUtils.w(14),
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: ResponsiveUtils.w(4)),
                        Text(
                          localizations.save17Percent,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: ResponsiveUtils.sp(12),
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: ResponsiveUtils.w(16)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayPrice,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveUtils.sp(24),
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(2)),
                Text(
                  plan.type == SubscriptionType.monthly 
                      ? localizations.perMonth
                      : localizations.perYear,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveUtils.sp(12),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
          // Badge "Popular" en la esquina superior derecha
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.w(8),
                  vertical: ResponsiveUtils.h(4),
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(ResponsiveUtils.r(12)),
                    bottomLeft: Radius.circular(ResponsiveUtils.r(4)),
                  ),
                ),
                child: Text(
                  localizations.popular,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.sp(12), // Apple HIG: minimum 11pt
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, ThemeData theme, AppLocalizations localizations, List<SubscriptionPlan> plans) {
    final selectedPlan = plans[_selectedPlanIndex];
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final productDetails = subscriptionService.getProductDetails(selectedPlan.id);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading || _isLoadingProducts)
          SizedBox(
            height: ResponsiveUtils.h(56),
            width: double.infinity,
            child: const LoadingWidget(),
          )
        else
          SizedBox(
            width: double.infinity,
            height: ResponsiveUtils.h(56),
            child: ElevatedButton(
              onPressed: () async {
                if (widget.isFirstTimePaywall) {
                  _handleStartFreeTrial();
                } else {
                  // Si los productos no están disponibles, intentar inicializarlos primero
                  if (productDetails == null) {
                    await _initializeProducts();
                    // Verificar nuevamente después de inicializar
                    final updatedProductDetails = subscriptionService.getProductDetails(selectedPlan.id);
                    if (updatedProductDetails == null) {
                      // Intentar comprar de todas formas - StoreKit puede manejar esto
                      debugPrint('⚠️ Producto no disponible, intentando compra directa...');
                      await _handlePurchase(selectedPlan);
                    } else {
                      await _handlePurchase(selectedPlan);
                    }
                  } else {
                    await _handlePurchase(selectedPlan);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.isFirstTimePaywall 
                          ? localizations.startFree
                          : localizations.subscribe,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(16),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleStartFreeTrial() async {
    try {
      final freemiumService = await ref.read(freemiumServiceProvider.future);
      await freemiumService.markFirstTimePaywallShown();
      
      if (mounted) {
        // Verificar si se puede hacer pop antes de intentarlo
        if (context.canPop()) {
          context.pop(true);
        } else {
          // Si no hay ruta anterior, navegar al dashboard
          context.go('/');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).localeName.startsWith('es')
                  ? '¡Bienvenido! Puedes usar Facturo con límites gratuitos.'
                  : 'Welcome! You can use Facturo with free limits.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al iniciar prueba gratuita: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).localeName.startsWith('es')
                  ? 'Error al iniciar prueba gratuita: $e'
                  : 'Error starting free trial: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handlePurchase(SubscriptionPlan plan) async {
    // Apple Guideline 5.1.1: Allow purchases without mandatory registration
    // The subscription is tied to Apple ID, not the app account
    // After purchase, we'll suggest (not require) creating an account
    final authState = ref.read(authControllerProvider);

    // Capture context-dependent values before async operations
    final localizations = AppLocalizations.of(context);
    final isSpanish = localizations.localeName.startsWith('es');
    final storeNotAvailableMessage = isSpanish
        ? 'La tienda no está disponible. Por favor, verifica tu conexión e intenta de nuevo.'
        : 'Store is not available. Please check your connection and try again.';

    // Proceed with purchase for ALL users (anonymous and authenticated)
    setState(() {
      _isLoading = true;
    });

    // Show loading overlay modal
    if (mounted) {
      _showPurchaseLoadingModal(context, localizations);
    }

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);

      // Asegurarse de que los productos estén inicializados antes de comprar
      final productDetails = subscriptionService.getProductDetails(plan.id);
      if (productDetails == null) {
        debugPrint('⚠️ Productos no disponibles, intentando inicializar...');
        await subscriptionService.initializeProducts(forceRefresh: true);

        // Verificar nuevamente después de inicializar
        final updatedProductDetails = subscriptionService.getProductDetails(plan.id);
        if (updatedProductDetails == null && !subscriptionService.isAvailable) {
          throw Exception(storeNotAvailableMessage);
        }
      }
      if (!mounted) return;

      // Dismiss loading modal before Apple dialog appears
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      final purchaseSuccess = await subscriptionService.buySubscription(plan, context: context);

      // Si la compra fue exitosa, navegar a pantalla de éxito
      // Pass isAnonymous to show account creation suggestion for anonymous users
      if (purchaseSuccess && mounted) {
        final subscriptionTypeString = plan.type == SubscriptionType.monthly ? 'monthly' : 'annual';

        // Apple Guideline 5.1.1: The paywall is now reachable without any session.
        // If the user arrived unauthenticated (came directly from onboarding "Ver Planes"
        // without pressing "Continuar gratis"), create the anonymous session NOW —
        // after the successful purchase — so the subscription can be saved to Supabase
        // and the account-prompt screen can offer them the option to link a real account.
        bool isAnonymousAfterPurchase = authState.isAnonymous;
        if (authState.state == AuthState.unauthenticated) {
          await ref.read(authControllerProvider.notifier).createAnonymousUser();
          isAnonymousAfterPurchase = true;
        }

        if (!mounted) return;
        context.go('/subscription-success?type=$subscriptionTypeString&isAnonymous=$isAnonymousAfterPurchase');
      } else if (!purchaseSuccess && mounted) {
        // La compra fue cancelada por el usuario - no mostrar mensaje de error
        // ya que es una acción intencional. El usuario simplemente permanece
        // en el paywall y puede intentar de nuevo cuando lo desee.
        debugPrint('ℹ️ Compra cancelada por el usuario - sin mensaje de error');
      }
    } catch (e) {
      // Dismiss loading modal if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      debugPrint('❌ Error al comprar: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        final errorMessage = e.toString();
        
        // Mensajes de error más específicos
        String userMessage;
        if (errorMessage.contains('not available') || errorMessage.contains('no disponible')) {
          userMessage = localizations.localeName.startsWith('es')
              ? 'El producto no está disponible en la tienda. Por favor, verifica tu conexión e intenta de nuevo.'
              : 'Product is not available in the store. Please check your connection and try again.';
        } else if (errorMessage.contains('already a purchase')) {
          userMessage = localizations.localeName.startsWith('es')
              ? 'Ya hay una compra en progreso. Por favor, espera.'
              : 'There is already a purchase in progress. Please wait.';
        } else {
          userMessage = localizations.localeName.startsWith('es')
              ? 'Error al iniciar la compra: $errorMessage'
              : 'Error starting purchase: $errorMessage';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPurchaseLoadingModal(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: theme.colorScheme.scrim.withValues(alpha: 0.4),
      builder: (context) {
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.w(40)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.w(28),
              vertical: ResponsiveUtils.h(28),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.w(14)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.storefront(PhosphorIconsStyle.fill),
                    color: theme.colorScheme.primary,
                    size: ResponsiveUtils.w(28),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.h(18)),
                Text(
                  localizations.purchaseLoadingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.sp(17),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.h(8)),
                Text(
                  localizations.purchaseLoadingMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.sp(14),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.h(20)),
                SizedBox(
                  width: ResponsiveUtils.w(24),
                  height: ResponsiveUtils.w(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Clase para representar la posición del botón cerrar
class _CloseButtonPosition {
  final double? right;
  final double? left;
  final Alignment alignment;

  const _CloseButtonPosition({
    this.right,
    this.left,
    required this.alignment,
  });
}
