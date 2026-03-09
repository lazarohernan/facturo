import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/services/custom_email_service.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../services/anonymous_auth_service.dart';

/// Estado de autenticación simplificado
enum AuthState { authenticated, unauthenticated, loading, anonymous }

/// Datos de estado de autenticación
class AuthStateData {
  final AuthState state;
  final User? user;
  final String? errorMessage;
  final bool isAnonymous;

  AuthStateData({
    this.state = AuthState.authenticated,
    this.user,
    this.errorMessage,
    this.isAnonymous = false,
  });

  AuthStateData copyWith({
    AuthState? state,
    User? Function()? user,
    String? Function()? errorMessage,
    bool? isAnonymous,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      user: user != null ? user() : this.user,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

/// Controlador de autenticación con soporte para usuarios anónimos
class AuthController extends StateNotifier<AuthStateData> {
  late final AnonymousAuthService _anonymousAuthService;
  late final CustomEmailService _emailService;
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription? _authSubscription;

  AuthController(SharedPreferences prefs, Ref ref) : super(AuthStateData(
    state: AuthState.loading,
    user: null,
    isAnonymous: false,
  )) {
    _anonymousAuthService = AnonymousAuthService(_supabase, prefs);
    _emailService = ref.read(customEmailServiceProvider);
    _initializeAuth();
    _setupAuthListener();
  }

  /// Inicializa la autenticación (NO crea usuario anónimo automáticamente)
  /// El usuario anónimo solo se crea cuando el usuario presiona "Comenzar" en welcome
  Future<void> _initializeAuth() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser != null) {
        // Ya hay un usuario, verificar si es anónimo
        state = state.copyWith(
          state: currentUser.isAnonymous ? AuthState.anonymous : AuthState.authenticated,
          user: () => currentUser,
          isAnonymous: currentUser.isAnonymous,
        );
      } else {
        // No hay usuario - NO crear uno anónimo automáticamente
        // El usuario debe ver la pantalla de bienvenida primero
        // y presionar "Comenzar" para crear el usuario anónimo
        state = state.copyWith(state: AuthState.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
    }
  }

  User? get user => _supabase.auth.currentUser;
  bool get isAnonymous => _anonymousAuthService.isCurrentUserAnonymous();
  bool get isAuthenticated => user != null;

  /// Crea un usuario anónimo (llamado desde WelcomeView cuando el usuario presiona "Comenzar")
  Future<bool> createAnonymousUser() async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final anonymousUser = await _anonymousAuthService.getOrCreateAnonymousUser();
      if (anonymousUser != null) {
        state = state.copyWith(
          state: AuthState.anonymous,
          user: () => anonymousUser,
          isAnonymous: true,
        );
        return true;
      } else {
        state = state.copyWith(state: AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Envía un OTP (One-Time Password) por email para autenticación sin contraseña
  /// 
  /// Parámetros:
  /// - [email]: Email del usuario
  /// - [isLogin]: true si es login (solo usuarios existentes), false si es conversión/registro
  /// 
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> signInWithOtp({
    required String email,
    bool isLogin = false,
  }) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      // Si NO es login (es conversión de anónimo o registro), pre-aprobar el email
      // para que el hook before_user_created permita la creación
      if (!isLogin) {
        try {
          await _supabase.rpc('approve_signup', params: {
            'p_email': email.trim().toLowerCase(),
            'p_provider': 'email',
          });
          debugPrint('✅ Email pre-aprobado para OTP (conversión/registro)');
        } catch (e) {
          debugPrint('⚠️ Error pre-aprobando email para OTP: $e');
          // Continuar aunque falle
        }
      }
      
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'facturo://login-callback',
      );

      // OTP enviado exitosamente
      state = state.copyWith(state: AuthState.unauthenticated);
      return {
        'success': true,
        'message': 'Revisa tu email para el código de verificación',
      };
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verifica el OTP ingresado por el usuario
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String token,
    bool isLogin = false,
    String? password, // Para establecer contraseña después de verificación
  }) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      AuthResponse response;
      
      // Demo account bypass para App Store Review
      if (email.toLowerCase() == 'review@facturo.app' && token == '123456') {
        response = await _supabase.auth.signInWithPassword(
          email: email,
          password: 'Review2026!',
        );
      } else {
        // Para usuarios existentes (login), Supabase genera recovery_token (magiclink)
        // Para usuarios nuevos (registro), Supabase genera email OTP
        final otpType = isLogin ? OtpType.magiclink : OtpType.email;
        
        response = await _supabase.auth.verifyOTP(
          type: otpType,
          email: email,
          token: token,
        );
      }

      if (response.user != null) {
        // Si se proporcionó contraseña, establecerla
        if (password != null && password.isNotEmpty) {
          await _supabase.auth.updateUser(
            UserAttributes(password: password),
          );
        }
        
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => response.user,
          isAnonymous: false,
        );
        return {'success': true};
      } else {
        state = state.copyWith(state: AuthState.unauthenticated);
        return {
          'success': false,
          'error': 'Error al verificar el código',
        };
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      
      // Devolver código de error específico para manejo en la vista
      String errorCode = 'unknown_error';
      String errorMessage = e.toString();
      
      if (errorMessage.contains('expired') || errorMessage.contains('expir')) {
        errorCode = 'otp_expired';
      } else if (errorMessage.contains('invalid') || errorMessage.contains('inválido')) {
        errorCode = 'otp_invalid';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'errorCode': errorCode,
      };
    }
  }

  /// Verifica si un usuario existe en auth.users
  /// Retorna true si el usuario existe, false si no
  Future<bool> checkUserExists({required String email}) async {
    try {
      final result = await _supabase.rpc('check_user_exists', params: {
        'user_email': email.trim().toLowerCase(),
      });
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
      return false;
    }
  }

  /// Inicia sesión con email y contraseña (usuario existente)
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(state: AuthState.loading);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => response.user,
          isAnonymous: false,
        );
        return {'success': true};
      } else {
        state = state.copyWith(state: AuthState.unauthenticated);
        return {
          'success': false,
          'error': 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );

      String errorMessage = e.toString();
      // Traducir mensajes de error comunes
      if (errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Credenciales inválidas. Verifica tu email y contraseña.';
      } else if (errorMessage.contains('Email not confirmed')) {
        errorMessage = 'Email no confirmado. Revisa tu bandeja de entrada.';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  /// Registra un nuevo usuario con email y contraseña (flujo post-pago)
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Enviar email de confirmación personalizado usando send-custom-email
        final emailResult = await _emailService.sendSignupConfirmation(
          email: email,
          verificationLink: 'facturo://login-callback',
        );
        
        if (!emailResult['success']) {
          debugPrint('Error sending custom email: ${emailResult['error']}');
        }
        
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => response.user,
          isAnonymous: false,
        );
        return {'success': true};
      } else {
        state = state.copyWith(state: AuthState.unauthenticated);
        return {
          'success': false,
          'error': 'Error al crear la cuenta',
        };
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Convierte usuario anónimo a permanente con email
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> convertToPermanentUser({
    required String email,
    String? password,
  }) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final result = await _anonymousAuthService.convertToPermanentUser(
        email: email,
        password: password,
      );

      final success = result['success'] as bool? ?? false;

      if (success) {
        final currentUser = _supabase.auth.currentUser;
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => currentUser,
          isAnonymous: false,
        );
      } else {
        // Si la conversión falla, mantener estado anónimo si hay usuario anónimo activo
        final currentUser = _supabase.auth.currentUser;
        final hasAnonymousUser = currentUser != null && currentUser.isAnonymous;
        
        state = state.copyWith(
          state: hasAnonymousUser ? AuthState.anonymous : AuthState.unauthenticated,
          errorMessage: () => result['error'] as String?,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        state: state.isAnonymous ? AuthState.anonymous : AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Enlaza cuenta Apple a usuario anónimo (nativo iOS) o inicia sesión
  /// 
  /// Parámetros:
  /// - [isSignUp]: true para conversión/registro (permite crear cuenta), false para login (solo usuarios existentes)
  /// 
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> signInWithApple({bool isSignUp = true}) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final result = await _anonymousAuthService.signInWithAppleNative(isSignUp: isSignUp);

      final success = result['success'] as bool? ?? false;

      if (success) {
        final currentUser = _supabase.auth.currentUser;
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => currentUser,
          isAnonymous: false,
        );
      } else {
        // Si el login falla, mantener estado unauthenticated
        // Solo cambiar a anonymous si hay un usuario anónimo activo
        final currentUser = _supabase.auth.currentUser;
        final hasAnonymousUser = currentUser != null && currentUser.isAnonymous;
        
        state = state.copyWith(
          state: hasAnonymousUser ? AuthState.anonymous : AuthState.unauthenticated,
          errorMessage: () => result['error'] as String?,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        state: state.isAnonymous ? AuthState.anonymous : AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Enlaza cuenta Google a usuario anónimo (nativo) o inicia sesión
  /// 
  /// Parámetros:
  /// - [isSignUp]: true para conversión/registro (permite crear cuenta), false para login (solo usuarios existentes)
  /// 
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> signInWithGoogle({bool isSignUp = true}) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final result = await _anonymousAuthService.signInWithGoogleNative(isSignUp: isSignUp);

      final success = result['success'] as bool? ?? false;

      if (success) {
        final currentUser = _supabase.auth.currentUser;
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => currentUser,
          isAnonymous: false,
        );
      } else {
        // Si el login falla, mantener estado unauthenticated
        // Solo cambiar a anonymous si hay un usuario anónimo activo
        final currentUser = _supabase.auth.currentUser;
        final hasAnonymousUser = currentUser != null && currentUser.isAnonymous;
        
        state = state.copyWith(
          state: hasAnonymousUser ? AuthState.anonymous : AuthState.unauthenticated,
          errorMessage: () => result['error'] as String?,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        state: state.isAnonymous ? AuthState.anonymous : AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Enlaza cuenta OAuth a usuario anónimo (fallback para web)
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> linkOAuthIdentity(OAuthProvider provider) async {
    try {
      state = state.copyWith(state: AuthState.loading);
      
      final result = await _anonymousAuthService.linkOAuthIdentity(provider);

      final success = result['success'] as bool? ?? false;

      if (success) {
        final currentUser = _supabase.auth.currentUser;
        state = state.copyWith(
          state: AuthState.authenticated,
          user: () => currentUser,
          isAnonymous: false,
        );
      } else {
        // Si el enlace falla, mantener estado anónimo si hay usuario anónimo activo
        final currentUser = _supabase.auth.currentUser;
        final hasAnonymousUser = currentUser != null && currentUser.isAnonymous;
        
        state = state.copyWith(
          state: hasAnonymousUser ? AuthState.anonymous : AuthState.unauthenticated,
          errorMessage: () => result['error'] as String?,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        state: state.isAnonymous ? AuthState.anonymous : AuthState.unauthenticated,
        errorMessage: () => e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verifica si el usuario actual es anónimo (para mostrar advertencia antes de cerrar sesión)
  bool get isCurrentUserAnonymous => state.isAnonymous;

  /// Sign out con eliminación de datos si es usuario anónimo
  /// IMPORTANTE: Si el usuario es anónimo, sus datos serán eliminados permanentemente
  Future<void> signOut() async {
    await _anonymousAuthService.signOutAnonymousUser();
    await _supabase.auth.signOut();
    state = state.copyWith(
      state: AuthState.unauthenticated,
      user: () => null,
      isAnonymous: false,
      errorMessage: () => null,
    );
    debugPrint('🔐 User signed out');
  }

  /// Elimina la cuenta del usuario y todos sus datos asociados
  /// Retorna un Map con 'success' y opcionalmente 'error' con el mensaje
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'error': 'No user is currently logged in',
        };
      }

      // Eliminar todos los datos del usuario usando RPC
      try {
        await _supabase.rpc('delete_user_data', params: {
          'target_user_id': currentUser.id,
        });
        debugPrint('✅ User data deleted successfully');
      } catch (e) {
        debugPrint('⚠️ Error deleting user data: $e');
        // Continuar con la eliminación de la cuenta aunque falle la eliminación de datos
      }

      // Eliminar la cuenta de autenticación
      await _supabase.rpc('delete_user_account');
      
      // Cerrar sesión localmente
      await _supabase.auth.signOut();
      
      state = state.copyWith(
        state: AuthState.unauthenticated,
        user: () => null,
        isAnonymous: false,
        errorMessage: () => null,
      );
      
      debugPrint('🗑️ Account deleted successfully');
      return {'success': true};
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Configura el listener de cambios de autenticación
  void _setupAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      debugPrint('🔄 Auth state changed: $event, session: ${session?.user.id}');
      
      switch (event) {
        case AuthChangeEvent.initialSession:
          // La sesión inicial ya fue manejada en _initializeAuth
          break;
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            final user = session!.user;
            state = state.copyWith(
              state: user.isAnonymous ? AuthState.anonymous : AuthState.authenticated,
              user: () => user,
              isAnonymous: user.isAnonymous,
              errorMessage: () => null,
            );
          }
          break;
        case AuthChangeEvent.signedOut:
          state = state.copyWith(
            state: AuthState.unauthenticated,
            user: () => null,
            isAnonymous: false,
          );
          // NO crear usuario anónimo automáticamente
          // El usuario debe ir a welcome y presionar "Comenzar"
          break;
        case AuthChangeEvent.tokenRefreshed:
          // Actualizar el usuario si cambió
          if (session?.user != null) {
            final user = session!.user;
            state = state.copyWith(
              user: () => user,
              isAnonymous: user.isAnonymous,
            );
          }
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            final user = session!.user;
            state = state.copyWith(
              user: () => user,
              isAnonymous: user.isAnonymous,
            );
          }
          break;
        case AuthChangeEvent.passwordRecovery:
          // No necesitamos manejar esto para usuarios anónimos
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          // No aplicable para usuarios anónimos
          break;
        // ignore: deprecated_member_use
        case AuthChangeEvent.userDeleted:
          // Deprecated - no action needed
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider de autenticación
final authControllerProvider = StateNotifierProvider<AuthController, AuthStateData>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthController(prefs, ref);
});

/// Provider para SharedPreferences (necesario importar)
// Nota: Asegúrate de que este provider exista en tu app
// final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError('SharedPreferences provider not implemented');
// });
