import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facturo/features/subscriptions/services/freemium_service.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _staggeredController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _footerAnimation;
  int _currentPage = 0;
  bool _isCreatingAnonymousUser = false;
  bool _isOpeningPaywall = false;
  static const Color _primaryColor = Color(0xFF1E3A8A);
  static const Color _secondaryColor = Color(0xFF4F7AC7);
  static const Color _accentColor = Color(0xFF2563EB);

  List<OnboardingPageModel> _pages(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return [
      OnboardingPageModel(
        title: localizations.onboardingPage1Title,
        subtitle: localizations.onboardingPage1Subtitle,
        description: localizations.onboardingPage1Description,
        imagePath: 'assets/images/1.1.jpg',
        icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
        color: _primaryColor,
        gradientColors: [_primaryColor, _secondaryColor],
      ),
      OnboardingPageModel(
        title: localizations.onboardingPage2Title,
        subtitle: localizations.onboardingPage2Subtitle,
        description: localizations.onboardingPage2Description,
        imagePath: 'assets/images/1.2.jpg',
        icon: PhosphorIcons.scan(PhosphorIconsStyle.regular),
        color: _secondaryColor,
        gradientColors: [_secondaryColor, _accentColor],
      ),
      OnboardingPageModel(
        title: localizations.onboardingPage3Title,
        subtitle: localizations.onboardingPage3Subtitle,
        description: localizations.onboardingPage3Description,
        imagePath: 'assets/images/1.3.jpg',
        icon: PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
        color: _accentColor,
        gradientColors: [_accentColor, _primaryColor],
      ),
      // Página Freemium - última página (misma paleta de colores)
      OnboardingPageModel(
        title: localizations.onboardingPage4Title,
        subtitle: localizations.onboardingPage4Subtitle,
        description: localizations.onboardingPage4Description,
        imagePath: 'assets/images/1.1.jpg', // Reutilizamos imagen
        icon: PhosphorIcons.gift(PhosphorIconsStyle.regular),
        color: _primaryColor, // Mismo color primario azul
        gradientColors: [
          _primaryColor,
          _accentColor,
        ], // Gradiente azul consistente
        isFreemiumPage: true,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    // Inicializar PageController primero
    _pageController = PageController();

    // Configurar modo edge-to-edge para ocupar toda la pantalla
    _setEdgeToEdgeMode();

    // Inicializar animaciones
    _setupAnimations();

    // Inicializar usuario anónimo si es necesario
    _initializeAnonymousUser();
  }

  /// Configura todas las animaciones
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggeredController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animaciones Staggered
    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _footerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Iniciar animación inicial
    _animationController.forward();
    _staggeredController.forward();
  }

  /// Inicializa usuario anónimo si no existe
  Future<void> _initializeAnonymousUser() async {
    try {
      final authState = ref.read(authControllerProvider);

      // IMPORTANTE: Verificar si ya hay una sesión activa de Supabase
      // Esto previene crear múltiples usuarios anónimos y doble cobro
      if (authState.state == AuthState.authenticated) {
        debugPrint('⚠️ Usuario PERMANENTE detectado en onboarding');
        debugPrint('🔄 Redirigiendo al dashboard...');

        if (mounted) {
          // Usuario ya tiene cuenta permanente, redirigir al dashboard
          context.go('/dashboard');
        }
        return;
      }

      // Si ya hay un usuario anónimo activo, reutilizarlo
      if (authState.state == AuthState.anonymous) {
        debugPrint('✅ Usuario anónimo ya existe - reutilizando');
        return;
      }

      // NUEVO: NO crear usuario anónimo automáticamente aquí
      // El usuario anónimo solo se crea cuando el usuario llega a la última página
      // y hace clic en "Continuar gratis"
      // Esto previene crear múltiples usuarios anónimos si el usuario
      // navega por el onboarding múltiples veces
      debugPrint(
        'ℹ️ Onboarding iniciado - usuario anónimo se creará al final si es necesario',
      );
    } catch (e) {
      debugPrint('⚠️ Error en _initializeAnonymousUser: $e');
    }
  }

  void _setEdgeToEdgeMode() {
    // Configurar modo inmersivo edge-to-edge después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Para iOS: hacer el status bar transparente
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggeredController.dispose();
    _pageController.dispose();
    _restoreSystemUIMode();
    super.dispose();
  }

  void _restoreSystemUIMode() {
    // Restaurar modo normal del sistema UI al salir del onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      // Restaurar el estilo del status bar al normal
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: null, // Color por defecto del sistema
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: null, // Color por defecto del sistema
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  /// Asegura una sesión (anónima o autenticada) para flujos freemium/paywall
  Future<bool> _ensureSessionForFreemiumFlow() async {
    final authState = ref.read(authControllerProvider);

    if (authState.state == AuthState.authenticated ||
        authState.state == AuthState.anonymous) {
      return true;
    }

    if (authState.state == AuthState.unauthenticated ||
        authState.state == AuthState.loading) {
      debugPrint('🔄 Creando usuario anónimo para onboarding...');
      final authController = ref.read(authControllerProvider.notifier);
      final created = await authController.createAnonymousUser();

      if (!created || !mounted) return false;

      try {
        final freemiumService = await ref.read(freemiumServiceProvider.future);
        await freemiumService.markOnboardingCompleted();
      } catch (e) {
        debugPrint('⚠️ Error marcando onboarding completado: $e');
      }

      return true;
    }

    return false;
  }

  Future<void> _handleStartFree() async {
    setState(() {
      _isCreatingAnonymousUser = true;
    });

    try {
      final hasSession = await _ensureSessionForFreemiumFlow();
      if (!hasSession || !mounted) return;

      _restoreSystemUIMode();
      context.go('/dashboard');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAnonymousUser = false;
        });
      }
    }
  }

  Future<void> _handleOpenProPaywall() async {
    setState(() {
      _isOpeningPaywall = true;
    });

    try {
      // Apple Guideline 5.1.1: Show paywall immediately without creating any
      // session first. The anonymous user is created only if the user chooses
      // "Continue for Free" (_handleStartFree), or after a successful purchase
      // inside subscription_view.dart. The paywall must be reachable with zero
      // prerequisites — no network call, no spinner, no account creation.
      if (!mounted) return;

      final localizations = AppLocalizations.of(context);
      _restoreSystemUIMode();

      await context.push(
        '/subscriptions',
        extra: {
          'title': localizations.upgradeToFacturoPro,
          'message': localizations.unlockPremiumFeatures,
          'selectedPlan': 'annual',
          'sourceRoute': 'onboarding',
        },
      );

      if (mounted) {
        _setEdgeToEdgeMode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPaywall = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages(context).length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _restoreSystemUIMode();
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Azul profundo primario
              Color(0xFF2563EB), // Azul medio
              Color(0xFF4F7AC7), // Azul más claro
            ],
            stops: [0.0, 0.50, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // PageView con efecto parallax profesional
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages(context).length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageOffset = 0.0;
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      pageOffset = (_pageController.page ?? 0) - index;
                    }
                    return _buildParallaxPage(
                      _pages(context)[index],
                      pageOffset,
                    );
                  },
                );
              },
            ),

            // Header - posicionado en la parte superior
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),

            // Footer - posicionado en la parte inferior
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo simple - solo texto
              Text(
                AppLocalizations.of(context).appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: onPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _footerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _staggeredController,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
              ),
            ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicadores de página mejorados
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages(context).length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: _currentPage == index
                            ? LinearGradient(
                                colors: _pages(
                                  context,
                                )[_currentPage].gradientColors,
                              )
                            : null,
                        color: _currentPage == index
                            ? null
                            : Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: _pages(
                                    context,
                                  )[_currentPage].color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botones según el tipo de página
                if (_pages(context)[_currentPage].isFreemiumPage) ...[
                  // Página Freemium: dos botones
                  // Botón principal: Probar gratis (sin cuenta obligatoria)
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pages(context)[_currentPage].gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _pages(
                            context,
                          )[_currentPage].color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_isCreatingAnonymousUser || _isOpeningPaywall)
                          ? null
                          : _handleStartFree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isCreatingAnonymousUser
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.check(
                                    PhosphorIconsStyle.regular,
                                  ),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).continueForFree,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: (_isCreatingAnonymousUser || _isOpeningPaywall)
                          ? null
                          : _handleOpenProPaywall,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.85),
                          width: 1.4,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isOpeningPaywall
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.crown(
                                    PhosphorIconsStyle.regular,
                                  ),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).viewPlans,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ] else ...[
                  // Páginas normales: botón siguiente y omitir
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pages(context)[_currentPage].gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _pages(
                            context,
                          )[_currentPage].color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context).next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            PhosphorIcons.arrowRight(
                              PhosphorIconsStyle.regular,
                            ),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Botón "Omitir"
                  TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _pages(context).length -
                            1, // Ir a la última página (freemium)
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context).skip,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxPage(OnboardingPageModel page, double pageOffset) {
    // Si es la página freemium, usar diseño especial
    if (page.isFreemiumPage) {
      return _buildFreemiumPage(page);
    }

    // Efecto parallax profesional
    final scale = 1.0 - (pageOffset.abs() * 0.15).clamp(0.0, 0.3);
    final opacity = 1.0 - (pageOffset.abs() * 0.5).clamp(0.0, 0.5);
    final imageParallax = -pageOffset * 0.3;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            // Imagen con efecto parallax
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _imageAnimation,
                child: _buildImageSection(page, imageParallax),
              ),
            ),

            const SizedBox(height: 24),

            // Texto con efecto parallax sutil
            Expanded(
              flex: 2,
              child: FadeTransition(
                opacity: _textAnimation,
                child: Transform.translate(
                  offset: Offset(pageOffset * 50, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 180.0,
                    ),
                    child: SingleChildScrollView(
                      child: _buildTextSection(page),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Página especial Freemium con límites gratuitos
  Widget _buildFreemiumPage(OnboardingPageModel page) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Icono principal - imagen 3D del teléfono
            FadeTransition(
              opacity: _imageAnimation,
              child: Image.asset(
                'assets/images/4.png',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: page.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      PhosphorIcons.gift(PhosphorIconsStyle.regular),
                      size: 175,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ),
            // Título
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                page.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Subtítulo
            Text(
              page.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Descripci&oacute;n
            Text(
              page.description,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Tarjeta con límites gratuitos
            _buildFreemiumLimitsCard(page),
            const SizedBox(height: 200), // Espacio para el footer
          ],
        ),
      ),
    );
  }

  // Tarjeta con los límites del plan gratuito
  Widget _buildFreemiumLimitsCard(OnboardingPageModel page) {
    final l = AppLocalizations.of(context);
    final limits = [
      _FreemiumLimit(
        icon: PhosphorIcons.fileText(PhosphorIconsStyle.regular),
        title: l.freemiumLimitInvoicesTitle(FreemiumService.defaultFreeInvoiceLimit),
        subtitle: l.freemiumLimitInvoicesSubtitle(FreemiumService.defaultFreeInvoiceLimit),
      ),
      _FreemiumLimit(
        icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
        title: l.freemiumLimitClientsTitle(FreemiumService.defaultFreeClientLimit),
        subtitle: l.freemiumLimitClientsSubtitle(FreemiumService.defaultFreeClientLimit),
      ),
      _FreemiumLimit(
        icon: PhosphorIcons.clipboardText(PhosphorIconsStyle.regular),
        title: l.freemiumLimitEstimatesTitle(FreemiumService.defaultFreeEstimateLimit),
        subtitle: l.freemiumLimitEstimatesSubtitle(FreemiumService.defaultFreeEstimateLimit),
      ),
      _FreemiumLimit(
        icon: PhosphorIcons.scan(PhosphorIconsStyle.regular),
        title: l.freemiumLimitOcrTitle(FreemiumService.defaultFreeOCRLimit),
        subtitle: l.freemiumLimitOcrSubtitle(FreemiumService.defaultFreeOCRLimit),
      ),
      _FreemiumLimit(
        icon: PhosphorIcons.chartBar(PhosphorIconsStyle.regular),
        title: l.freemiumLimitReportsTitle(FreemiumService.defaultFreeReportsLimit),
        subtitle: l.freemiumLimitReportsSubtitle(FreemiumService.defaultFreeReportsLimit),
      ),
    ];

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: page.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de la tarjeta
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.sparkle(PhosphorIconsStyle.regular),
                      size: 16,
                      color: page.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).freePlan,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: page.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '\$0',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
              ),
              Text(
                AppLocalizations.of(context).perMonth,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Lista de límites
          ...limits.map(
            (limit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: page.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(limit.icon, size: 20, color: page.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          limit.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          limit.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIcons.check(PhosphorIconsStyle.regular),
                    size: 20,
                    color: page.color,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    OnboardingPageModel page, [
    double parallaxOffset = 0.0,
  ]) {
    return Container(
      width: double.infinity,
      height: 360,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: page.color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Image.asset(
          page.imagePath,
          fit: BoxFit.cover,
          alignment: Alignment(parallaxOffset.clamp(-1.0, 1.0), 0),
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(page);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(OnboardingPageModel page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Patrón geométrico moderno
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(page.gradientColors[0]),
            ),
          ),
          // Contenido central sin fondo circular
          Center(
            child: Builder(
              builder: (context) {
                final onPrimary = Theme.of(context).colorScheme.onPrimary;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono sin fondo, integrado directamente
                    Icon(
                      page.icon,
                      size: 80,
                      color: onPrimary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Imagen',
                      style: TextStyle(
                        color: onPrimary.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Espacio para imagen',
                      style: TextStyle(
                        color: onPrimary.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(OnboardingPageModel page) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Column(
      children: [
        // Subtitulo
        Text(
          page.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),

        // Titulo principal
        Text(
          page.title,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: onPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),

        // Descripcion sin padding horizontal extra
        Text(
          page.description,
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: onPrimary.withValues(alpha: 0.7),
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final bool isFreemiumPage;

  const OnboardingPageModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
    required this.gradientColors,
    this.isFreemiumPage = false,
  });
}

// Modelo para los límites freemium
class _FreemiumLimit {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FreemiumLimit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// Custom Painter para patrón geométrico moderno
class _GeometricPatternPainter extends CustomPainter {
  final Color color;

  _GeometricPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Crear patrón de círculos y líneas geométricas
    const double spacing = 60;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Círculos decorativos
        canvas.drawCircle(Offset(x + 20, y + 20), 8, paint);

        // Líneas conectoras sutiles
        if (x + spacing < size.width) {
          canvas.drawLine(
            Offset(x + 28, y + 20),
            Offset(x + spacing + 12, y + 20),
            strokePaint,
          );
        }

        if (y + spacing < size.height) {
          canvas.drawLine(
            Offset(x + 20, y + 28),
            Offset(x + 20, y + spacing + 12),
            strokePaint,
          );
        }
      }
    }

    // Elementos triangulares en las esquinas
    final trianglePaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Triángulo superior izquierdo
    final topLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(100, 0)
      ..lineTo(0, 100)
      ..close();
    canvas.drawPath(topLeftPath, trianglePaint);

    // Triángulo inferior derecho
    final bottomRightPath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width - 100, size.height)
      ..lineTo(size.width, size.height - 100)
      ..close();
    canvas.drawPath(bottomRightPath, trianglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
