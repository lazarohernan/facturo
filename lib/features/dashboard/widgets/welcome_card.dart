import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeCard extends ConsumerStatefulWidget {
  const WelcomeCard({super.key});

  @override
  ConsumerState<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends ConsumerState<WelcomeCard>
    with TickerProviderStateMixin {
  static const String _welcomeShownKey = 'welcome_card_shown';
  bool _isVisible = false;
  bool _isAnimationInitialized = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  void _initializeAnimations() {
    if (_isAnimationInitialized) return;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));

    _isAnimationInitialized = true;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasBeenShown = prefs.getBool(_welcomeShownKey) ?? false;
    
    debugPrint('🎉 WelcomeCard - hasBeenShown: $hasBeenShown');
    debugPrint('🎉 WelcomeCard - mounted: $mounted');
    
    if (!hasBeenShown && mounted) {
      debugPrint('🎉 WelcomeCard - Mostrando tarjeta de bienvenida');
      _initializeAnimations();
      setState(() {
        _isVisible = true;
      });
      // Pequeño delay para mejor experiencia
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _animationController != null) {
        _animationController!.forward();
      }
    } else {
      debugPrint('🎉 WelcomeCard - NO se muestra (ya fue mostrada antes)');
    }
  }

  Future<void> _dismiss() async {
    // Haptic feedback para mejor UX
    HapticFeedback.lightImpact();
    
    // Animar salida
    if (_animationController != null) {
      await _animationController!.reverse();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeShownKey, true);
    
    // Marcar que el modal se cerró para que el tooltip pueda aparecer
    await prefs.setBool('welcome_card_dismissed', true);
    
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _animationController == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) => _buildModalOverlay(context),
      ),
    );
  }

  Widget _buildModalOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final scaleValue = _scaleAnimation?.value ?? 1.0;
    final fadeValue = _fadeAnimation?.value ?? 1.0;
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Fondo oscuro
          Container(
            color: Colors.black.withValues(alpha: 0.4 * fadeValue),
          ),
          // Modal centrado
          Center(
            child: Transform.scale(
              scale: scaleValue,
              child: Opacity(
                opacity: fadeValue,
                child: _buildModalCard(context, theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalCard(BuildContext context, ThemeData theme) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          _buildContent(localizations, theme),
          _buildFooter(localizations, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: _dismiss,
            icon: Icon(
              PhosphorIcons.x(PhosphorIconsStyle.regular),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations localizations, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Icono principal
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              PhosphorIcons.handWaving(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          // Título
          Text(
            localizations.welcomeToFacturo,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Descripción
          Text(
            localizations.startCreatingInvoices,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations localizations, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _dismiss,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            localizations.start,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
