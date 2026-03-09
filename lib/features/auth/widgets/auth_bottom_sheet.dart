import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart';
import 'package:facturo/features/auth/services/last_login_method_service.dart';
import 'package:facturo/features/profile/providers/user_profile_provider.dart';
import 'package:facturo/core/services/consent_service.dart';
import 'package:facturo/core/constants/app_constants.dart';

/// Shows the authentication bottom sheet
/// [isLogin] - true for login flow, false for account creation
/// [onSuccess] - callback when auth is successful
void showAuthBottomSheet(
  BuildContext context, {
  required bool isLogin,
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        AuthBottomSheet(isLogin: isLogin, onSuccess: onSuccess ?? () {}),
  );
}

/// Bottom sheet widget for authentication
class AuthBottomSheet extends ConsumerStatefulWidget {
  final bool isLogin;
  final VoidCallback onSuccess;

  const AuthBottomSheet({
    super.key,
    required this.isLogin,
    required this.onSuccess,
  });

  @override
  ConsumerState<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends ConsumerState<AuthBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _showEmailForm = false;
  bool _showOtpForm = false;
  bool _acceptTerms = false;
  int _resendCooldown = 0;
  OverlayEntry? _activeAlertEntry;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  final List<TextEditingController> _otpDigitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _focusListenersAdded = false;

  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonsAnimation;
  late Animation<double> _termsAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupFocusListeners() {
    if (_focusListenersAdded) return;
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      final focusNode = _otpFocusNodes[i];
      focusNode.addListener(() {
        if (mounted) setState(() {});
      });
      focusNode.onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _otpDigitControllers[i].text.isEmpty &&
            i > 0) {
          _otpFocusNodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
    _focusListenersAdded = true;
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );

    _subtitleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );

    _buttonsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    _termsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _activeAlertEntry?.remove();
    _activeAlertEntry = null;
    _animationController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    for (final controller in _otpDigitControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpDigitControllers.map((c) => c.text).join();
  }

  void _clearOtpFields() {
    for (final controller in _otpDigitControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  void _showFloatingAlert({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return;

    _activeAlertEntry?.remove();
    _activeAlertEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final mediaQuery = MediaQuery.of(overlayContext);

        return Positioned(
          left: 16,
          right: 16,
          bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _activeAlertEntry = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (!mounted) return;
      if (_activeAlertEntry == overlayEntry) {
        overlayEntry.remove();
        _activeAlertEntry = null;
      }
    });
  }

  void _showErrorMessage(String message) {
    _showFloatingAlert(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccessMessage(String message) {
    _showFloatingAlert(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildAnimatedElement({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Muestra un diálogo de error cuando la cuenta no existe
  Future<void> _showAccountNotFoundDialog() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
          color: Colors.orange,
          size: 48,
        ),
        title: Text(
          localizations.error,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          localizations.accountNotFoundCreateFirst,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.accept),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.signInWithGoogle(
        isSignUp: !widget.isLogin,
      );

      final success = result['success'] as bool? ?? false;
      final errorMessage = result['error'] as String?;
      final errorCode = result['errorCode'] as String?;

      if (success && mounted) {
        await _handleSuccessfulAuth(LastLoginMethodService.google);
      } else if (mounted && errorMessage != 'Inicio de sesión cancelado') {
        // Mostrar diálogo si el usuario no existe
        if (errorCode == 'account_not_found') {
          await _showAccountNotFoundDialog();
        } else {
          _showErrorMessage(errorMessage ?? 'Error al conectar con Google');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.signInWithApple(
        isSignUp: !widget.isLogin,
      );

      final success = result['success'] as bool? ?? false;
      final errorMessage = result['error'] as String?;
      final errorCode = result['errorCode'] as String?;

      if (success && mounted) {
        await _handleSuccessfulAuth(LastLoginMethodService.apple);
      } else if (mounted && errorMessage != 'Inicio de sesión cancelado') {
        // Mostrar diálogo si el usuario no existe
        if (errorCode == 'account_not_found') {
          await _showAccountNotFoundDialog();
        } else {
          _showErrorMessage(errorMessage ?? 'Error al conectar con Apple');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isLogin && !_acceptTerms) {
      _showErrorMessage(AppLocalizations.of(context).mustAcceptTerms);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);

      // Si es login, verificar que el usuario existe antes de enviar OTP
      if (widget.isLogin) {
        final userExists = await authController.checkUserExists(
          email: _emailController.text.trim(),
        );

        if (!userExists && mounted) {
          setState(() => _isLoading = false);
          await _showAccountNotFoundDialog();
          return;
        }
      }

      final result = await authController.signInWithOtp(
        email: _emailController.text.trim(),
        isLogin: widget.isLogin,
      );

      final success = result['success'] as bool? ?? false;
      final errorMessage = result['error'] as String?;

      if (success && mounted) {
        setState(() {
          _showOtpForm = true;
        });
        _startResendCooldown();
        _showSuccessMessage(AppLocalizations.of(context).otpSentToEmail);
      } else if (mounted) {
        _showErrorMessage(
          errorMessage ?? AppLocalizations.of(context).errorSendingOtp,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      _showErrorMessage(AppLocalizations.of(context).invalidOtpCode);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);

      final result = await authController.verifyOtp(
        email: _emailController.text.trim(),
        token: otpCode,
        isLogin: widget.isLogin,
      );

      final success = result['success'] as bool? ?? false;
      final errorMessage = result['error'] as String?;
      final errorCode = result['errorCode'] as String?;

      if (success && mounted) {
        await _handleSuccessfulAuth(LastLoginMethodService.email);
      } else if (mounted) {
        String displayMessage;
        if (errorCode == 'otp_expired') {
          displayMessage = AppLocalizations.of(context).otpCodeExpired;
        } else if (errorCode == 'otp_invalid') {
          displayMessage = AppLocalizations.of(context).otpCodeInvalid;
        } else {
          displayMessage = errorMessage ?? 'Error al verificar el código';
        }
        _showErrorMessage(displayMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);

      final result = await authController.signInWithOtp(
        email: _emailController.text.trim(),
        isLogin: false,
      );

      final success = result['success'] as bool? ?? false;

      if (success && mounted) {
        _startResendCooldown();
        _showSuccessMessage(AppLocalizations.of(context).otpSentToEmail);
      } else if (mounted) {
        _showErrorMessage(
          result['error'] as String? ??
              AppLocalizations.of(context).errorSendingOtp,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSuccessfulAuth(String method) async {
    final consentService = ConsentService();
    final authState = ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId != null) {
      await consentService.acceptAllPolicies(
        userId: userId,
        platform: 'mobile',
        appVersion: AppConstants.appVersion,
      );
    }

    await LastLoginMethodService.saveLastLoginMethod(method);
    await ref.read(userProfileProvider.notifier).loadUserProfile();

    if (mounted) {
      final localizations = AppLocalizations.of(context);
      _showSuccessMessage(
        widget.isLogin
            ? localizations.loginSuccessful
            : localizations.accountCreatedSuccessfully,
      );
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = theme.colorScheme.surface;
    final gradientColors = isDark
        ? [
            Color.lerp(const Color(0xFF1a237e), surfaceColor, 0.7)!,
            Color.lerp(const Color(0xFF0d47a1), surfaceColor, 0.85)!,
            surfaceColor,
          ]
        : [
            Color.lerp(const Color(0xFF42a5f5), surfaceColor, 0.85)!,
            Color.lerp(const Color(0xFF1976d2), surfaceColor, 0.92)!,
            surfaceColor,
          ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                if (!_showEmailForm) ...[
                  const SizedBox(height: 24),

                  _buildAnimatedElement(
                    animation: _logoAnimation,
                    child: Image.asset(
                      'assets/images/facturo_logo_with_text.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        PhosphorIcons.invoice(PhosphorIconsStyle.fill),
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildAnimatedElement(
                    animation: _titleAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        localizations.welcomeToFacturo,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors
                              .white, // ShaderMask requires white base to apply gradient
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildAnimatedElement(
                    animation: _subtitleAnimation,
                    child: Text(
                      widget.isLogin
                          ? localizations.loginSubtitle
                          : localizations.createAccountSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),
                ] else ...[
                  const SizedBox(height: 16),
                ],

                _buildAnimatedElement(
                  animation: _buttonsAnimation,
                  child: _showEmailForm
                      ? _buildEmailForm(theme, localizations)
                      : _buildAuthButtons(theme, localizations),
                ),

                const SizedBox(height: 24),

                if (!_showEmailForm)
                  _buildAnimatedElement(
                    animation: _termsAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: '${localizations.termsAgreement} '),
                            TextSpan(
                              text: localizations.termsOfService,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' ${localizations.and} '),
                            TextSpan(
                              text: localizations.privacyPolicy,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildAuthButtons(ThemeData theme, AppLocalizations localizations) {
    return Column(
      children: [
        _buildAuthButton(
          theme: theme,
          icon: 'assets/images/apple_logo.png',
          fallbackIcon: PhosphorIcons.appleLogo(PhosphorIconsStyle.fill),
          label: localizations.continueWithApple,
          onPressed: _isLoading ? null : _signInWithApple,
        ),

        const SizedBox(height: 12),

        _buildAuthButton(
          theme: theme,
          icon: 'assets/images/google_logo.png',
          fallbackIcon: PhosphorIcons.googleLogo(PhosphorIconsStyle.fill),
          label: localizations.continueWithGoogle,
          onPressed: _isLoading ? null : _signInWithGoogle,
        ),

        const SizedBox(height: 12),

        _buildAuthButton(
          theme: theme,
          fallbackIcon: PhosphorIcons.at(PhosphorIconsStyle.bold),
          label: localizations.continueWithEmail,
          onPressed: _isLoading
              ? null
              : () => setState(() => _showEmailForm = true),
          iconColor: theme.colorScheme.primary,
        ),

        if (_isLoading) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildEmailForm(ThemeData theme, AppLocalizations localizations) {
    if (_showOtpForm) {
      return _buildOtpForm(theme, localizations);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => setState(() {
                      _showEmailForm = false;
                      _showOtpForm = false;
                    }),
              icon: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
                size: 20,
              ),
              label: Text(localizations.back),
            ),
          ),

          const SizedBox(height: 16),

          Icon(
            PhosphorIcons.envelopeSimple(PhosphorIconsStyle.fill),
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            localizations.willSendVerificationCode,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: localizations.email,
              hintText: localizations.emailHint,
              prefixIcon: Icon(
                PhosphorIcons.envelope(PhosphorIconsStyle.regular),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.enterYourEmail;
              }
              if (!value.contains('@')) {
                return localizations.enterValidEmail;
              }
              return null;
            },
          ),

          if (!widget.isLogin) ...[
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: _isLoading
                      ? null
                      : (value) =>
                            setState(() => _acceptTerms = value ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(text: '${localizations.termsAgreement} '),
                            TextSpan(
                              text: localizations.termsOfService,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: ' ${localizations.and} '),
                            TextSpan(
                              text: localizations.privacyPolicy,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      widget.isLogin
                          ? localizations.signIn
                          : localizations.sendCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(ThemeData theme, AppLocalizations localizations) {
    _setupFocusListeners();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isLoading
                ? null
                : () => setState(() {
                    _showOtpForm = false;
                    _clearOtpFields();
                  }),
            icon: Icon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
              size: 20,
            ),
            label: Text(localizations.back),
          ),
        ),

        const SizedBox(height: 16),

        Icon(
          PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
          size: 48,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(height: 16),

        Text(
          localizations.verifyCode,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          localizations.enterCodeSentToEmail,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          _emailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : (index == 3 ? 8 : 4),
                right: index == 5 ? 0 : (index == 2 ? 8 : 4),
              ),
              child: SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _otpDigitControllers[index],
                  focusNode: _otpFocusNodes[index],
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    } else if (value.isNotEmpty && index < 5) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                    if (_getOtpCode().length == 6) {
                      _verifyOtp();
                    }
                  },
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    localizations.verifyCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton(
            onPressed: (_isLoading || _resendCooldown > 0) ? null : _resendOtp,
            child: Text(
              _resendCooldown > 0
                  ? localizations.resendIn(_resendCooldown)
                  : localizations.resendCode,
              style: TextStyle(
                color: _resendCooldown > 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton({
    required ThemeData theme,
    String? icon,
    required IconData fallbackIcon,
    required String label,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(
            color: isDark
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(
                icon,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(fallbackIcon, size: 24, color: iconColor),
              )
            else
              Icon(fallbackIcon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
