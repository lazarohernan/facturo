import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_bottom_sheet.dart';

/// Vista wrapper que muestra el AuthBottomSheet sobre un fondo
/// Unifica la experiencia de login/registro con My Account
class AuthWrapperView extends ConsumerStatefulWidget {
  /// Si es true, es login (solo usuarios existentes)
  /// Si es false, es registro (crear cuenta nueva)
  final bool isLogin;

  /// Si viene del flujo de suscripción
  final bool fromSubscription;

  /// Plan seleccionado antes de crear cuenta
  final String? selectedPlan;

  const AuthWrapperView({
    super.key,
    this.isLogin = false,
    this.fromSubscription = false,
    this.selectedPlan,
  });

  @override
  ConsumerState<AuthWrapperView> createState() => _AuthWrapperViewState();
}

class _AuthWrapperViewState extends ConsumerState<AuthWrapperView> {
  bool _bottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    // Mostrar el bottom sheet después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAuthSheet();
    });
  }

  void _showAuthSheet() {
    if (_bottomSheetShown) return;
    _bottomSheetShown = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthBottomSheet(
        isLogin: widget.isLogin,
        onSuccess: () {
          // Navegar según el flujo
          if (widget.fromSubscription && widget.selectedPlan != null) {
            context.go('/subscriptions', extra: {
              'selectedPlan': widget.selectedPlan,
              'autoStartPurchase': true,
            });
          } else {
            context.go('/dashboard');
          }
        },
      ),
    ).then((_) {
      // Si el usuario cierra el bottom sheet sin autenticarse, volver atrás
      if (mounted) {
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.surfaceContainerHighest,
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceContainerLow,
                      theme.colorScheme.surfaceContainerHighest,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/facturo_logo_with_text.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant,
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
