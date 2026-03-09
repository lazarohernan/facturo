import 'dart:math' as math;
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/main_navigation.dart';
import '../providers/profile_completion_provider.dart';

/// Clave para SharedPreferences
const String _kProfileTooltipShownKey = 'profile_completion_tooltip_shown';

/// Widget que muestra el indicador de completado del perfil
class ProfileCompletionIndicator extends ConsumerStatefulWidget {
  const ProfileCompletionIndicator({super.key});

  @override
  ConsumerState<ProfileCompletionIndicator> createState() =>
      _ProfileCompletionIndicatorState();
}

class _ProfileCompletionIndicatorState
    extends ConsumerState<ProfileCompletionIndicator> {
  bool _showTooltip = false;
  bool _isElementActive = false;
  int _tooltipRequestId = 0;
  final LayerLink _tooltipLink = LayerLink();
  OverlayEntry? _tooltipEntry;

  @override
  void initState() {
    super.initState();
    _isElementActive = true;
    // Esperar un poco más para que el perfil se cargue antes de verificar el tooltip
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeTooltip();
    });
  }

  @override
  void activate() {
    super.activate();
    _isElementActive = true;
  }

  @override
  void reassemble() {
    _tooltipRequestId++;
    _removeTooltipOverlay();
    _showTooltip = false;
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    _tooltipRequestId++;
    _isElementActive = false;
    _showTooltip = false;
    // Schedule overlay removal after the current frame to avoid
    // removing it during the layout phase (which crashes with
    // "schedulerPhase != SchedulerPhase.persistentCallbacks").
    final entry = _tooltipEntry;
    _tooltipEntry = null;
    if (entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        entry.remove();
      });
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _tooltipRequestId++;
    _isElementActive = false;
    _showTooltip = false;
    // _tooltipEntry already handled in deactivate (called before dispose)
    _removeTooltipOverlay();
    super.dispose();
  }

  bool _canShowTooltip() {
    if (!mounted || !_isElementActive) return false;
    return ref.read(currentNavigationIndexProvider) == 0;
  }

  Future<void> _checkFirstTimeTooltip() async {
    final requestId = ++_tooltipRequestId;
    // Esperar a que el widget esté montado y el perfil cargado
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_isElementActive || requestId != _tooltipRequestId) return;

    if (!_canShowTooltip()) {
      debugPrint('🔔 Tooltip no mostrado: no estamos en el dashboard');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final completion = ref.read(profileCompletionProvider);

    // Verificar si el modal de bienvenida ya fue cerrado
    final welcomeCardDismissed =
        prefs.getBool('welcome_card_dismissed') ?? false;
    final welcomeCardShown = prefs.getBool('welcome_card_shown') ?? false;

    // Mostrar tooltip solo si:
    // 1. Estamos en el dashboard
    // 2. El modal de bienvenida ya fue cerrado O nunca se mostró (usuarios existentes)
    // 3. El perfil no está completo
    // 4. El tooltip no ha sido aceptado antes
    final tooltipAccepted =
        prefs.getBool('${_kProfileTooltipShownKey}_accepted') ?? false;
    final shouldShowTooltip =
        _canShowTooltip() &&
        (welcomeCardDismissed || welcomeCardShown) &&
        completion.percentage < 100 &&
        !tooltipAccepted;

    debugPrint(
      '🔔 Tooltip check: isDashboard=${_canShowTooltip()}, welcomeDismissed=$welcomeCardDismissed, welcomeShown=$welcomeCardShown, percentage=${completion.percentage}, accepted=$tooltipAccepted, shouldShow=$shouldShowTooltip',
    );

    if (shouldShowTooltip && mounted && _canShowTooltip()) {
      // Si el modal no fue cerrado aún, esperar más tiempo
      if (!welcomeCardDismissed && welcomeCardShown) {
        // Esperar hasta que el modal sea cerrado
        await _waitForWelcomeCardDismissal(requestId);
      }

      // Verificar nuevamente que seguimos en el dashboard después del delay
      if (!_canShowTooltip() || requestId != _tooltipRequestId) {
        debugPrint('🔔 Tooltip cancelado: usuario navegó fuera del dashboard');
        return;
      }

      // Mostrar tooltip después de un delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted &&
          _isElementActive &&
          requestId == _tooltipRequestId &&
          _canShowTooltip()) {
        _setTooltipVisibility(true);
        debugPrint('🔔 Tooltip mostrado (esperando aceptación)');
      }
    }
  }

  Future<void> _waitForWelcomeCardDismissal(int requestId) async {
    final prefs = await SharedPreferences.getInstance();

    // Esperar hasta que el modal sea cerrado (máximo 30 segundos)
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted || !_isElementActive || requestId != _tooltipRequestId) {
        return;
      }

      final dismissed = prefs.getBool('welcome_card_dismissed') ?? false;
      if (dismissed) {
        debugPrint('🔔 Modal de bienvenida cerrado, continuando con tooltip');
        return;
      }
    }

    debugPrint('🔔 Timeout esperando cierre del modal de bienvenida');
  }

  Future<void> _acceptTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_kProfileTooltipShownKey}_accepted', true);
    debugPrint('🔔 Tooltip aceptado y guardado en SharedPreferences');
    _dismissTooltip();
  }

  void _setTooltipVisibility(bool visible) {
    if (!mounted) return;

    if (_showTooltip != visible) {
      setState(() {
        _showTooltip = visible;
      });
    }

    if (visible) {
      _showTooltipOverlay();
    } else {
      _removeTooltipOverlay();
    }
  }

  void _dismissTooltip() {
    _setTooltipVisibility(false);
  }

  void _showTooltipOverlay() {
    if (!_canShowTooltip()) return;

    final overlay = Overlay.of(context);
    if (_tooltipEntry == null) {
      _tooltipEntry = OverlayEntry(
        builder: (overlayContext) {
          if (!_showTooltip || !_canShowTooltip()) {
            return const SizedBox.shrink();
          }

          return CompositedTransformFollower(
            link: _tooltipLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: Offset(ResponsiveUtils.w(-10), ResponsiveUtils.h(4)),
            child: Material(
              color: Colors.transparent,
              child: _buildTooltip(overlayContext, Theme.of(overlayContext)),
            ),
          );
        },
      );
      overlay.insert(_tooltipEntry!);
      return;
    }

    _tooltipEntry!.markNeedsBuild();
  }

  void _removeTooltipOverlay() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final completion = ref.watch(profileCompletionProvider);
    final theme = Theme.of(context);

    // Escuchar cambios de pestaña de navegación para cerrar el tooltip
    final navIndex = ref.watch(currentNavigationIndexProvider);
    if (_showTooltip && navIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🔔 Tooltip eliminado: pestaña cambió a $navIndex');
          _dismissTooltip();
        }
      });
    }

    if (_showTooltip && navIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🔔 Tooltip eliminado: pestaña cambió a $navIndex');
          _dismissTooltip();
        }
      });
    }

    // Si el perfil está 100% completo, mostrar botón para ver perfil
    if (completion.percentage >= 100) {
      return GestureDetector(
        onTap: () => context.push('/business-profile'),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.w(12),
            vertical: ResponsiveUtils.h(6),
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: const Color(0xFF1F3A93).withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
          ),
          child: Icon(
            Iconsax.share_outline,
            size: ResponsiveUtils.sp(16),
            color: const Color(0xFF1F3A93).withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _tooltipLink,
      child: GestureDetector(
        onTap: () {
          _dismissTooltip();
          context.push('/profile-onboarding/step1');
        },
        // Minimum 44x44 touch target per Apple HIG - visual remains 36x36
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Container(
            width: ResponsiveUtils.w(36),
            height: ResponsiveUtils.h(36),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de fondo con gradiente gris para usuarios nuevos, verde para usuarios con progreso
                Container(
                  width: ResponsiveUtils.w(36),
                  height: ResponsiveUtils.h(36),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        completion.percentage == 0
                            ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              )
                            : const Color(0xFF2ECC71).withValues(alpha: 0.12),
                        completion.percentage == 0
                            ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.03,
                              )
                            : const Color(0xFF2ECC71).withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: completion.percentage == 0
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.10)
                          : const Color(0xFF2ECC71).withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                ),
                // Indicador de progreso circular
                CustomPaint(
                  size: Size(ResponsiveUtils.w(36), ResponsiveUtils.h(36)),
                  painter: _StepProgressPainter(
                    step1Complete: completion.step1Complete,
                    step2Complete: completion.step2Complete,
                    step3Complete: completion.step3Complete,
                    completedColor: const Color(
                      0xFF2ECC71,
                    ), // Verde esmeralda profesional
                    incompleteColor: theme.colorScheme.outline.withValues(
                      alpha: 0.10,
                    ),
                  ),
                ),
                // Porcentaje centrado
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.w(2)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${completion.percentage}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveUtils.sp(
                          12,
                        ), // Apple HIG: minimum 11pt
                        color: completion.percentage == 0
                            ? theme.colorScheme.onSurfaceVariant
                            : const Color(0xFF2ECC71),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext tooltipContext, ThemeData theme) {
    final localizations = AppLocalizations.of(tooltipContext);

    return AnimatedBuilder(
      animation: const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Flecha apuntando hacia arriba (hacia el indicador)
            Padding(
              padding: EdgeInsets.only(right: ResponsiveUtils.w(20)),
              child: CustomPaint(
                size: Size(ResponsiveUtils.w(16), ResponsiveUtils.h(10)),
                painter: _TooltipArrowPainter(
                  color: theme.colorScheme.primaryContainer,
                ),
              ),
            ),
            // Contenido del tooltip
            Container(
              width: ResponsiveUtils.w(200),
              padding: EdgeInsets.all(ResponsiveUtils.w(12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(ResponsiveUtils.r(12)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.info_circle_outline,
                        size: ResponsiveUtils.sp(16),
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: ResponsiveUtils.w(8)),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizations.completeYourProfileTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: ResponsiveUtils.sp(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.h(6)),
                  Text(
                    localizations.completeYourProfileTooltipBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.9,
                      ),
                      height: 1.3,
                      fontSize: ResponsiveUtils.sp(13),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.h(8)),
                  Text(
                    localizations.completeYourProfileTooltipCta,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Botón de aceptar pequeño
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: _acceptTooltip,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        side: BorderSide(
                          color: theme.colorScheme.onPrimaryContainer,
                          width: 1,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.w(12),
                          vertical: ResponsiveUtils.h(4),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.r(6),
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(tooltipContext).accept,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveUtils.sp(
                            12,
                          ), // Apple HIG: minimum 11pt
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painter para la flecha del tooltip
class _TooltipArrowPainter extends CustomPainter {
  final Color color;

  _TooltipArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter para dibujar los 3 pasos alrededor del círculo con estilo compacto
class _StepProgressPainter extends CustomPainter {
  final bool step1Complete;
  final bool step2Complete;
  final bool step3Complete;
  final Color completedColor;
  final Color incompleteColor;

  _StepProgressPainter({
    required this.step1Complete,
    required this.step2Complete,
    required this.step3Complete,
    required this.completedColor,
    required this.incompleteColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 1.5;
    const strokeWidth = 3.0; // Más delgado para diseño compacto

    // Ángulo de cada paso (120 grados cada uno = 360/3)
    const stepAngle = 2 * math.pi / 3;
    const gapAngle = 0.18; // Mayor espacio para diseño más limpio

    // Comenzar desde la parte superior (-90 grados)
    const startAngle = -math.pi / 2;

    final steps = [step1Complete, step2Complete, step3Complete];

    for (int i = 0; i < 3; i++) {
      final stepStartAngle = startAngle + (i * stepAngle) + gapAngle;
      const stepSweepAngle = stepAngle - (2 * gapAngle);

      // Crear gradiente para pasos completados
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (steps[i]) {
        // Gradiente para pasos completados
        final gradient = SweepGradient(
          startAngle: stepStartAngle,
          endAngle: stepStartAngle + stepSweepAngle,
          colors: [completedColor, completedColor.withValues(alpha: 0.85)],
        );
        paint.shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: outerRadius),
        );
      } else {
        // Color opaco para pasos incompletos
        paint.color = incompleteColor;
      }

      // Dibujar arco exterior
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        stepStartAngle,
        stepSweepAngle,
        false,
        paint,
      );

      // Añadir pequeño punto indicador para pasos completados (más pequeño)
      if (steps[i]) {
        final dotAngle = stepStartAngle + stepSweepAngle / 2;
        final dotX = center.dx + math.cos(dotAngle) * (outerRadius + 1.5);
        final dotY = center.dy + math.sin(dotAngle) * (outerRadius + 1.5);

        final dotPaint = Paint()
          ..color = completedColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(dotX, dotY), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_StepProgressPainter oldDelegate) {
    return oldDelegate.step1Complete != step1Complete ||
        oldDelegate.step2Complete != step2Complete ||
        oldDelegate.step3Complete != step3Complete;
  }
}

/// Widget expandido con más detalles (opcional para usar en modal)
class ProfileCompletionCard extends ConsumerWidget {
  const ProfileCompletionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(profileCompletionProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.w(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(16)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Iconsax.user_edit_outline,
                size: ResponsiveUtils.sp(20),
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: ResponsiveUtils.w(8)),
              Expanded(
                child: Text(
                  localizations.completeYourProfileTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${completion.percentage}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getColorForPercentage(completion.percentage),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.h(12)),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(8)),
            child: LinearProgressIndicator(
              value: completion.percentage / 100,
              minHeight: ResponsiveUtils.h(8),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForPercentage(completion.percentage),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.h(12)),

          // Información de campos
          Text(
            localizations.profileCompletionStatus(completion.percentage),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          if (!completion.isComplete) ...[
            SizedBox(height: ResponsiveUtils.h(12)),

            // Botón para completar
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(AppConstants.userProfileEditRoute);
                },
                icon: Icon(Iconsax.edit_outline, size: ResponsiveUtils.sp(16)),
                label: Text(localizations.completeProfile),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage >= 80) {
      return const Color(0xFF10B981);
    } else if (percentage >= 50) {
      return const Color(0xFFF59E0B);
    } else if (percentage == 0) {
      return const Color(0xFF9E9E9E); // Gris para información no completada
    } else {
      return const Color(0xFFEF4444);
    }
  }
}
