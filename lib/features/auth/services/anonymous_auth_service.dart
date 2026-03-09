import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:facturo/features/auth/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar autenticación anónima con Supabase
/// 
/// IMPORTANTE - RLS Policies:
/// Los usuarios anónimos usan el rol `authenticated` igual que los usuarios permanentes.
/// Para diferenciar entre usuarios anónimos y permanentes en tus políticas RLS,
/// debes verificar el claim `is_anonymous` en el JWT:
/// 
/// ```sql
/// -- Ejemplo: Solo usuarios permanentes pueden insertar
/// CREATE POLICY "only_permanent_users_insert" ON your_table
/// AS RESTRICTIVE FOR INSERT
/// TO authenticated
/// WITH CHECK (
///   (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS FALSE
/// );
/// 
/// -- Ejemplo: Usuarios anónimos y permanentes pueden leer
/// CREATE POLICY "authenticated_users_read" ON your_table
/// FOR SELECT
/// TO authenticated
/// USING (true);
/// ```
/// 
/// Ver documentación: https://supabase.com/docs/guides/auth/auth-anonymous#access-control
class AnonymousAuthService {
  static const String _hasAnonymousUserKey = 'has_anonymous_user';
  static const String _anonymousUserIdKey = 'anonymous_user_id';
  
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  AnonymousAuthService(this._supabase, this._prefs);

  /// Verifica si ya hay un usuario anónimo creado
  bool get hasAnonymousUser => _prefs.getBool(_hasAnonymousUserKey) ?? false;

  /// Obtiene el ID del usuario anónimo actual
  String? get anonymousUserId => _prefs.getString(_anonymousUserIdKey);

  /// Crea o recupera un usuario anónimo
  /// 
  /// Si ya existe un usuario anónimo guardado localmente y coincide con el
  /// usuario actual de Supabase, lo reutiliza. De lo contrario, crea uno nuevo.
  Future<User?> getOrCreateAnonymousUser() async {
    try {
      // PRIMERO: Esperar a que Supabase restaure la sesión (si existe)
      // Esto es CRÍTICO para evitar crear usuarios duplicados
      await _waitForSessionRestoration();
      
      // SEGUNDO: Verificar si ya tenemos un usuario autenticado en la sesión actual
      // Esto puede ser una sesión restaurada por Supabase
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        debugPrint('✅ Usuario existente detectado: ${currentUser.id}');
        debugPrint('   - Es anónimo: ${currentUser.isAnonymous}');
        debugPrint('   - Email: ${currentUser.email ?? "sin email"}');
        
        // Si el usuario actual es anónimo, siempre reutilizarlo (sesión restaurada o nueva)
        if (currentUser.isAnonymous) {
          // Guardar info del usuario anónimo actual para futuras referencias
          await _saveAnonymousUserInfo(currentUser);
          return currentUser;
        }
        
        // Si el usuario actual NO es anónimo (tiene cuenta permanente), retornarlo
        // NO crear un usuario anónimo nuevo - esto previene pérdida de datos
        debugPrint('⚠️ Usuario permanente detectado - NO creando usuario anónimo');
        return currentUser;
      }

      // TERCERO: No hay usuario en la sesión actual
      // Verificar si hay un usuario anónimo guardado localmente pero no está en sesión
      // 
      // IMPORTANTE: Según la documentación de Supabase:
      // - Los usuarios anónimos NO pueden volver a iniciar sesión después de hacer logout
      // - Supabase restaura automáticamente la sesión al inicializar el cliente si los tokens están guardados
      // - Si currentUser es null después de la inicialización, significa que NO hay sesión restaurada
      // - Los datos permanecen en la BD asociados al user_id anterior pero NO son accesibles sin sesión activa
      // - Si el usuario crea un nuevo usuario anónimo, tendrá un nuevo user_id y los datos anteriores quedarán huérfanos
      if (hasAnonymousUser && anonymousUserId != null) {
        debugPrint('⚠️ Había usuario anónimo guardado pero no hay sesión activa');
        debugPrint('   - ID guardado: $anonymousUserId');
        // Limpiar el flag ya que no podemos recuperar la sesión
        await _clearAnonymousFlags();
      }

      // CUARTO: No hay usuario autenticado ni guardado, crear uno anónimo nuevo
      // Esto solo debería pasar cuando el usuario presiona "Comenzar" por primera vez
      debugPrint('🔄 Creando nuevo usuario anónimo...');
      final response = await _supabase.auth.signInAnonymously();
      
      if (response.user != null) {
        await _saveAnonymousUserInfo(response.user!);
        return response.user;
      } else {
        debugPrint('❌ signInAnonymously no devolvió usuario');
        return null;
      }
    } on AuthException catch (e) {
      // Manejar errores específicos de Supabase Auth
      String errorType = 'unknown';
      
      // Detectar tipo de error por código de estado o mensaje
      if (e.statusCode == '429' || e.message.contains('rate limit') || e.message.contains('too many')) {
        errorType = 'rate_limit';
      } else if (e.statusCode == '400' || e.message.contains('invalid')) {
        errorType = 'invalid_request';
      } else if (e.message.contains('network') || e.message.contains('connection') || e.message.contains('timeout')) {
        errorType = 'network_error';
      }
      
      debugPrint('❌ Error de autenticación creando usuario anónimo: ${e.statusCode} - ${e.message}');
      debugPrint('❌ Tipo de error: $errorType');
      return null;
    } catch (e) {
      debugPrint('❌ Error inesperado creando usuario anónimo: $e');
      return null;
    }
  }

  /// Espera a que Supabase restaure la sesión (si existe)
  /// Esto es CRÍTICO para evitar crear usuarios duplicados cuando la app se reinicia
  Future<void> _waitForSessionRestoration() async {
    // Si ya hay un usuario, no necesitamos esperar
    if (_supabase.auth.currentUser != null) {
      debugPrint('✅ Sesión ya disponible, no es necesario esperar');
      return;
    }
    
    // Esperar un poco para que Supabase restaure la sesión desde el almacenamiento local
    // Supabase guarda los tokens en el almacenamiento seguro del dispositivo
    debugPrint('⏳ Esperando restauración de sesión de Supabase...');
    
    // Intentar hasta 3 veces con delays incrementales
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        debugPrint('✅ Sesión restaurada después de ${300 * (i + 1)}ms');
        debugPrint('   - Usuario: ${currentUser.id}');
        debugPrint('   - Es anónimo: ${currentUser.isAnonymous}');
        return;
      }
    }
    
    debugPrint('⚠️ No se encontró sesión después de esperar');
  }

  /// Guarda información del usuario anónimo en SharedPreferences
  Future<void> _saveAnonymousUserInfo(User user) async {
    await _prefs.setBool(_hasAnonymousUserKey, true);
    await _prefs.setString(_anonymousUserIdKey, user.id);
  }

  /// Verifica si el usuario actual es anónimo
  bool isCurrentUserAnonymous() {
    final user = _supabase.auth.currentUser;
    return user?.isAnonymous ?? false;
  }

  /// Convierte usuario anónimo a permanente con email
  /// 
  /// Nota: Según la documentación de Supabase, el email debe ser verificado
  /// antes de poder establecer una contraseña. Si se proporciona password,
  /// se guardará pero el usuario deberá verificar su email primero.
  /// 
  /// Retorna un Map con:
  /// - 'success': bool indicando si la operación fue exitosa
  /// - 'requiresEmailVerification': bool indicando si se requiere verificación
  /// - 'error': String con el mensaje de error si hubo alguno
  /// - 'errorCode': String con el código de error si hubo alguno
  Future<Map<String, dynamic>> convertToPermanentUser({
    required String email,
    String? password,
  }) async {
    try {
      // Validar formato de email básico antes de intentar conversión
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(email.trim())) {
        return {
          'success': false,
          'error': 'Por favor, ingresa un email válido.',
          'errorCode': 'invalid_email_format',
        };
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        return {
          'success': false,
          'error': 'No anonymous user to convert',
          'errorCode': 'no_anonymous_user',
        };
      }

      // Validar que password no sea null
      if (password == null || password.isEmpty) {
        return {
          'success': false,
          'error': 'La contraseña es requerida',
          'errorCode': 'password_required',
        };
      }

      try {
        // Pre-aprobar el email para que el hook before_user_created permita la conversión
        try {
          await _supabase.rpc('approve_signup', params: {
            'p_email': email.trim().toLowerCase(),
            'p_provider': 'email',
          });
          debugPrint('✅ Email pre-aprobado para conversión de usuario anónimo');
        } catch (e) {
          debugPrint('⚠️ Error pre-aprobando email: $e');
          // Continuar aunque falle - el hook puede permitirlo de todas formas
        }
        
        // MÉTODO CORRECTO según documentación oficial de Supabase:
        // Para usuarios anónimos, usar signUp() con email y password
        // Esto crea una nueva cuenta y la vincula automáticamente al usuario anónimo
        final response = await _supabase.auth.signUp(
          email: email.trim(),
          password: password,
          emailRedirectTo: 'facturo://login-callback',
        );

        if (response.user != null) {
          debugPrint('✅ Usuario anónimo (${currentUser.id}) convertido a permanente');
          debugPrint('📧 Se enviará email de confirmación manualmente');
          
          // NOTA: El email de confirmación se enviará automáticamente por Supabase
          // Si necesitas personalizarlo, usa el Auth Hook o send-custom-email separadamente
          
          // Actualizar anonymous_user_tracking
          try {
            await _supabase.from('anonymous_user_tracking').update({
              'is_anonymous': false,
              'converted_at': DateTime.now().toIso8601String(),
              'conversion_time_hours': DateTime.now().difference(
                DateTime.parse(currentUser.createdAt)
              ).inHours,
              'user_email': email.trim(),
              'status': 'converted',
            }).eq('user_id', currentUser.id);
          } catch (e) {
            debugPrint('⚠️ Error actualizando anonymous_user_tracking: $e');
          }
          
          // Limpiar flags de usuario anónimo
          await _clearAnonymousFlags();
          
          return {
            'success': true,
            'requiresEmailVerification': true,
            'user': response.user,
            'message': 'Cuenta creada. Revisa tu email para verificar.',
          };
        }
        
        return {
          'success': false,
          'error': 'No se pudo actualizar el usuario',
          'errorCode': 'update_failed',
        };
      } on AuthException catch (e) {
        // Manejar errores específicos de Supabase Auth
        String errorCode = 'unknown';
        String errorMessage = e.message;
        
        debugPrint('❌ AuthException durante conversión: ${e.message} (${e.statusCode})');
        
        if (e.message.contains('already registered') || 
            e.message.contains('already exists') ||
            e.message.contains('email address is already') ||
            e.statusCode == '422') {
          errorCode = 'email_already_exists';
          errorMessage = 'Este email ya está registrado. Por favor, inicia sesión con ese email.';
        } else if (e.statusCode == '429' || e.message.contains('rate limit')) {
          errorCode = 'rate_limit';
          errorMessage = 'Demasiados intentos. Por favor, espera unos minutos e intenta nuevamente.';
        } else if (e.message.contains('network') || e.message.contains('connection')) {
          errorCode = 'network_error';
          errorMessage = 'Error de conexión. Verifica tu internet e intenta nuevamente.';
        } else if (e.message.contains('Password should be at least')) {
          errorCode = 'weak_password';
          errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
        } else if (e.statusCode == '400') {
          errorCode = 'invalid_request';
          errorMessage = 'Solicitud inválida. Por favor, verifica los datos e intenta nuevamente.';
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'errorCode': errorCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Error inesperado durante conversión: $e');
      return {
        'success': false,
        'error': 'Error inesperado. Por favor, intenta nuevamente.',
        'errorCode': 'unexpected_error',
      };
    }
  }

  /// Convierte usuario anónimo a permanente con Apple Sign In nativo (iOS)
  ///
  /// Parámetros:
  /// - [isSignUp]: true si es conversión/registro (permite crear cuenta), false si es login (solo permite usuarios existentes)
  ///
  /// Retorna un Map con:
  /// - 'success': bool indicando si la operación fue exitosa
  /// - 'error': String con el mensaje de error si hubo alguno
  Future<Map<String, dynamic>> signInWithAppleNative({bool isSignUp = true}) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      // IMPORTANTE: Verificar si hay usuario anónimo para enlazar
      final isAnonymousUser = currentUser != null && currentUser.isAnonymous;

      // Generar nonce para seguridad (usar el método de Supabase recomendado)
      final rawNonce = _supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Solicitar credenciales de Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return {
          'success': false,
          'error': 'No se pudo obtener el token de Apple',
        };
      }

      // Extraer nombre del usuario desde las credenciales de Apple
      // IMPORTANTE: Apple solo proporciona el nombre en el PRIMER login
      String? fullName;
      final givenName = credential.givenName;
      final familyName = credential.familyName;

      if (givenName != null && familyName != null) {
        fullName = '$givenName $familyName'.trim();
      } else if (givenName != null) {
        fullName = givenName.trim();
      } else if (familyName != null) {
        fullName = familyName.trim();
      }

      User? resultUser;

      // Si hay usuario anónimo, usar linkIdentityWithIdToken para vincular la cuenta
      // Este método vincula la identidad OAuth al usuario anónimo existente
      if (isAnonymousUser) {
        debugPrint('🍎 Usuario anónimo detectado - usando linkIdentityWithIdToken');

        // Si es LOGIN (isSignUp=false), verificar que el usuario existe ANTES de vincular
        if (!isSignUp) {
          // Intentar obtener el email del token de Apple para verificar
          String? emailToCheck = credential.email;

          // Si no tenemos email de las credenciales, intentar decodificar del idToken
          if (emailToCheck == null) {
            try {
              final parts = idToken.split('.');
              if (parts.length == 3) {
                final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
                final Map<String, dynamic> tokenData = json.decode(payload);
                emailToCheck = tokenData['email'] as String?;
              }
            } catch (e) {
              debugPrint('⚠️ Error decodificando email del token Apple: $e');
            }
          }

          if (emailToCheck != null) {
            try {
              final userExists = await _supabase.rpc('check_user_exists', params: {
                'user_email': emailToCheck.trim().toLowerCase(),
              }) as bool? ?? false;

              if (!userExists) {
                debugPrint('❌ Usuario anónimo intenta login con Apple pero no existe cuenta - rechazando');
                return {
                  'success': false,
                  'error': 'No account found. Please sign up first.',
                  'errorCode': 'account_not_found',
                };
              }
              debugPrint('✅ Usuario existe - continuando con vinculación Apple');
            } catch (e) {
              debugPrint('⚠️ Error verificando si usuario existe: $e');
            }
          } else {
            debugPrint('⚠️ No se pudo obtener email de Apple para verificar - rechazando login por seguridad');
            return {
              'success': false,
              'error': 'No account found. Please sign up first.',
              'errorCode': 'account_not_found',
            };
          }
        }

        // Si es registro (isSignUp=true), pre-aprobar el email para que el hook lo permita
        if (isSignUp && credential.email != null) {
          try {
            await _supabase.rpc('approve_signup', params: {
              'p_email': credential.email,
              'p_provider': 'apple',
            });
          } catch (e) {
            debugPrint('⚠️ Error pre-aprobando email para vinculación: $e');
          }
        }

        try {
          final response = await _supabase.auth.linkIdentityWithIdToken(
            provider: OAuthProvider.apple,
            idToken: idToken,
            nonce: rawNonce,
          );
          resultUser = response.user;
          
          debugPrint('🍎 linkIdentityWithIdToken resultado: user=${resultUser?.id}, email=${resultUser?.email}');
          
          if (resultUser != null) {
            // Actualizar perfil con la información de Apple
            try {
              final userProfileService = UserProfileService(_supabase);
              await userProfileService.updateUserProfile(
                userUuid: resultUser.id,
                fullName: fullName,
                email: resultUser.email,
              );
            } catch (e) {
              debugPrint('⚠️ Error actualizando perfil: $e');
            }

            // Actualizar anonymous_user_tracking
            try {
              await _supabase.from('anonymous_user_tracking').update({
                'is_anonymous': false,
                'converted_at': DateTime.now().toIso8601String(),
                'conversion_time_hours': DateTime.now().difference(
                  DateTime.parse(currentUser.createdAt)
                ).inHours,
                'user_email': resultUser.email,
                'status': 'converted',
              }).eq('user_id', currentUser.id);
            } catch (e) {
              debugPrint('⚠️ Error actualizando anonymous_user_tracking: $e');
            }

            await _clearAnonymousFlags();
            return {
              'success': true,
              'user': resultUser,
            };
          } else {
            return {
              'success': false,
              'error': 'No se pudo vincular la cuenta de Apple',
            };
          }
        } on AuthException catch (e) {
          debugPrint('❌ Error vinculando identidad Apple: ${e.message}');

          if (e.message.contains('already linked') ||
              e.message.contains('already exists')) {
            return {
              'success': false,
              'error': 'Esta cuenta de Apple ya está vinculada a otro usuario',
              'errorCode': 'identity_already_linked',
            };
          }

          return {
            'success': false,
            'error': e.message,
            'errorCode': e.statusCode,
          };
        }
      }

      // Si NO hay usuario anónimo, usar signInWithIdToken para login o registro
      debugPrint('🍎 Iniciando sesión con Apple (sin usuario anónimo)...');

      // Si es LOGIN (isSignUp=false), verificar que el usuario existe ANTES de autenticar
      // NOTA: Apple solo proporciona el email en el primer login
      if (!isSignUp && credential.email != null) {
        try {
          final userExists = await _supabase.rpc('check_user_exists', params: {
            'user_email': credential.email!.trim().toLowerCase(),
          }) as bool? ?? false;

          if (!userExists) {
            debugPrint('❌ Usuario no existe y es login - rechazando');
            return {
              'success': false,
              'error': 'No account found. Please sign up first.',
              'errorCode': 'account_not_found',
            };
          }
          debugPrint('✅ Usuario existe - continuando con login');
        } catch (e) {
          debugPrint('⚠️ Error verificando si usuario existe: $e');
          // Continuar y dejar que el hook lo maneje
        }
      }

      // Si es registro (isSignUp=true), pre-aprobar el email para que el hook lo permita
      if (isSignUp && credential.email != null) {
        try {
          await _supabase.rpc('approve_signup', params: {
            'p_email': credential.email,
            'p_provider': 'apple',
          });
        } catch (e) {
          debugPrint('⚠️ Error pre-aprobando email: $e');
        }
      }

      // Usar signInWithIdToken para login o registro normal
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      resultUser = response.user;

      debugPrint('🍎 Apple Sign In resultado: user=${resultUser?.id}, email=${resultUser?.email}');

      if (resultUser != null) {
        // Actualizar perfil con la información de Apple
        try {
          final userProfileService = UserProfileService(_supabase);
          await userProfileService.updateUserProfile(
            userUuid: resultUser.id,
            fullName: fullName,
            email: resultUser.email,
          );
        } catch (e) {
          debugPrint('⚠️ Error actualizando perfil: $e');
        }

        return {
          'success': true,
          'user': resultUser,
        };
      } else {
        return {
          'success': false,
          'error': 'No se pudo completar el inicio de sesión con Apple',
        };
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('❌ Error de autorización Apple: ${e.code} - ${e.message}');

      if (e.code == AuthorizationErrorCode.unknown &&
          e.message.contains('error 1000')) {
        debugPrint('⚠️ Error 1000: Verificar Apple Developer Console y configuración de Sign In with Apple');
        return {
          'success': false,
          'error': 'Error 1000 en dispositivo físico.\n\n'
              'Verificar Apple Developer Console y configuración de Sign In with Apple',
          'errorCode': 'error_1000',
        };
      }

      if (e.code == AuthorizationErrorCode.canceled) {
        return {
          'success': false,
          'error': 'Inicio de sesión cancelado',
          'errorCode': 'canceled',
        };
      }

      return {
        'success': false,
        'error': 'Error de autorización: ${e.message}',
        'errorCode': e.code.toString(),
      };
    } on AuthException catch (e) {
      debugPrint('❌ Error de Supabase Auth con Apple: ${e.message}');

      if (e.statusCode == '403' || e.message.contains('No account found') || e.message.contains('sign up first')) {
        return {
          'success': false,
          'error': e.message,
          'errorCode': 'account_not_found',
        };
      }

      if (e.message.contains('already linked') ||
          e.message.contains('already exists')) {
        return {
          'success': false,
          'error': 'Esta cuenta de Apple ya está vinculada a otro usuario',
          'errorCode': 'identity_already_linked',
        };
      }

      return {
        'success': false,
        'error': e.message,
        'errorCode': e.statusCode,
      };
    } catch (e) {
      debugPrint('❌ Error inesperado con Apple Sign In: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Convierte usuario anónimo a permanente con Google Sign In nativo
  ///
  /// Parámetros:
  /// - [isSignUp]: true si es conversión/registro (permite crear cuenta), false si es login (solo permite usuarios existentes)
  ///
  /// Retorna un Map con:
  /// - 'success': bool indicando si la operación fue exitosa
  /// - 'error': String con el mensaje de error si hubo alguno
  Future<Map<String, dynamic>> signInWithGoogleNative({bool isSignUp = true}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      debugPrint('🔵 Iniciando Google Sign-In nativo...');
      debugPrint('🔵 isSignUp: $isSignUp');

      // 1. Iniciar sesión con Google nativo
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Usuario canceló el inicio de sesión con Google');
        return {
          'success': false,
          'error': 'Inicio de sesión cancelado',
          'errorCode': 'user_cancelled',
        };
      }

      debugPrint('✅ Usuario de Google obtenido: ${googleUser.email}');

      // 2. Obtener tokens de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        debugPrint('❌ No se pudo obtener el ID token de Google');
        return {
          'success': false,
          'error': 'No se pudo obtener el token de autenticación',
          'errorCode': 'no_id_token',
        };
      }

      debugPrint('✅ Tokens obtenidos de Google');

      // 3. Verificar si hay un usuario anónimo actual
      final currentUser = _supabase.auth.currentUser;
      final isCurrentlyAnonymous = currentUser?.isAnonymous ?? false;

      debugPrint('🔍 Usuario actual: ${currentUser?.id}');
      debugPrint('🔍 Es anónimo: $isCurrentlyAnonymous');

      // Si hay usuario anónimo, usar linkIdentityWithIdToken para vincular la cuenta
      // Este método vincula la identidad OAuth al usuario anónimo existente
      if (isCurrentlyAnonymous && currentUser != null) {
        debugPrint('🔵 Usuario anónimo detectado - usando linkIdentityWithIdToken');

        // Si es LOGIN (isSignUp=false), verificar que el usuario existe ANTES de vincular
        if (!isSignUp) {
          try {
            final userExists = await _supabase.rpc('check_user_exists', params: {
              'user_email': googleUser.email.trim().toLowerCase(),
            }) as bool? ?? false;

            if (!userExists) {
              debugPrint('❌ Usuario anónimo intenta login con Google pero no existe cuenta - rechazando');
              await googleSignIn.signOut();
              return {
                'success': false,
                'error': 'No account found. Please sign up first.',
                'errorCode': 'account_not_found',
              };
            }
            debugPrint('✅ Usuario existe - continuando con vinculación Google');
          } catch (e) {
            debugPrint('⚠️ Error verificando si usuario existe: $e');
          }
        }

        // Si es registro (isSignUp=true), pre-aprobar el email para que el hook lo permita
        if (isSignUp) {
          try {
            await _supabase.rpc('approve_signup', params: {
              'p_email': googleUser.email,
              'p_provider': 'google',
            });
          } catch (e) {
            debugPrint('⚠️ Error pre-aprobando email para vinculación: $e');
          }
        }

        try {
          final response = await _supabase.auth.linkIdentityWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
          final resultUser = response.user;
          
          debugPrint('🔵 linkIdentityWithIdToken resultado: user=${resultUser?.id}, email=${resultUser?.email}');
          
          if (resultUser != null) {
            // Actualizar perfil con datos de Google
            await _updateUserProfileFromGoogle(googleUser);

            // Actualizar anonymous_user_tracking
            try {
              await _supabase.from('anonymous_user_tracking').update({
                'is_anonymous': false,
                'converted_at': DateTime.now().toIso8601String(),
                'conversion_time_hours': DateTime.now().difference(
                  DateTime.parse(currentUser.createdAt)
                ).inHours,
                'user_email': resultUser.email,
                'status': 'converted',
              }).eq('user_id', currentUser.id);
            } catch (e) {
              debugPrint('⚠️ Error actualizando anonymous_user_tracking: $e');
            }

            await _clearAnonymousFlags();
            return {
              'success': true,
              'user': resultUser,
            };
          } else {
            return {
              'success': false,
              'error': 'No se pudo vincular la cuenta de Google',
            };
          }
        } on AuthException catch (e) {
          debugPrint('❌ Error vinculando identidad Google: ${e.message}');

          if (e.message.contains('already linked') ||
              e.message.contains('already exists')) {
            return {
              'success': false,
              'error': 'Esta cuenta de Google ya está vinculada a otro usuario',
              'errorCode': 'identity_already_linked',
            };
          }

          return {
            'success': false,
            'error': e.message,
            'errorCode': e.statusCode,
          };
        }
      }

      // Si NO hay usuario anónimo, usar signInWithIdToken para login o registro
      debugPrint('🔵 Iniciando sesión con Google (sin usuario anónimo)...');

      // Si es LOGIN (isSignUp=false), verificar que el usuario existe ANTES de autenticar
      if (!isSignUp) {
        try {
          final userExists = await _supabase.rpc('check_user_exists', params: {
            'user_email': googleUser.email.trim().toLowerCase(),
          }) as bool? ?? false;

          if (!userExists) {
            debugPrint('❌ Usuario no existe y es login - rechazando');
            await GoogleSignIn().signOut(); // Cerrar sesión de Google
            return {
              'success': false,
              'error': 'No account found. Please sign up first.',
              'errorCode': 'account_not_found',
            };
          }
          debugPrint('✅ Usuario existe - continuando con login');
        } catch (e) {
          debugPrint('⚠️ Error verificando si usuario existe: $e');
          // Continuar y dejar que el hook lo maneje
        }
      }

      // Si es registro (isSignUp=true), pre-aprobar el email para que el hook lo permita
      if (isSignUp) {
        try {
          await _supabase.rpc('approve_signup', params: {
            'p_email': googleUser.email,
            'p_provider': 'google',
          });
        } catch (e) {
          debugPrint('⚠️ Error pre-aprobando email: $e');
        }
      }

      // Autenticar con Supabase usando el token de Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Verificar resultado
      if (response.user != null) {
        debugPrint('✅ Autenticación con Google exitosa');
        debugPrint('   - User ID: ${response.user!.id}');
        debugPrint('   - Email: ${response.user!.email}');
        debugPrint('   - Es anónimo: ${response.user!.isAnonymous}');

        // Actualizar perfil con datos de Google
        await _updateUserProfileFromGoogle(googleUser);

        return {
          'success': true,
          'user': response.user,
        };
      } else {
        debugPrint('❌ No se obtuvo usuario después de la autenticación');
        return {
          'success': false,
          'error': 'No se pudo completar la autenticación',
          'errorCode': 'no_user',
        };
      }

    } on AuthException catch (e) {
      debugPrint('❌ Error de Supabase Auth con Google: ${e.message}');

      // Error del hook before_user_created: usuario no existe y no está pre-aprobado
      if (e.statusCode == '403' || e.message.contains('No account found') || e.message.contains('sign up first')) {
        return {
          'success': false,
          'error': e.message,
          'errorCode': 'account_not_found',
        };
      }

      if (e.message.contains('already linked') ||
          e.message.contains('already exists')) {
        return {
          'success': false,
          'error': 'Esta cuenta de Google ya está vinculada a otro usuario',
          'errorCode': 'identity_already_linked',
        };
      }

      return {
        'success': false,
        'error': e.message,
        'errorCode': e.statusCode,
      };
    } catch (e) {
      debugPrint('❌ Error inesperado con Google Sign In: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Actualiza el perfil del usuario con datos de Google
  Future<void> _updateUserProfileFromGoogle(GoogleSignInAccount googleUser) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      debugPrint('🔄 Actualizando perfil con datos de Google...');
      debugPrint('📝 Datos de Google:');
      debugPrint('   - displayName: "${googleUser.displayName}"');
      debugPrint('   - email: "${googleUser.email}"');
      debugPrint('   - photoUrl: "${googleUser.photoUrl}"');

      // Extraer nombre con fallbacks
      String fullName = googleUser.displayName ?? '';
      if (fullName.isEmpty) {
        // Si no hay displayName, intentar extraer del email
        final emailParts = googleUser.email.split('@');
        fullName = emailParts[0];
        // Capitalizar primera letra
        if (fullName.isNotEmpty) {
          fullName = fullName[0].toUpperCase() + fullName.substring(1);
        }
            }

      debugPrint('👤 Nombre final a guardar: "$fullName"');

      // Actualizar en la tabla users_public_info (tabla correcta)
      await _supabase.from('users_public_info').upsert({
        'user_uuid': userId,
        'full_name': fullName,
        'email': googleUser.email,
        'profile_img': googleUser.photoUrl, // Campo correcto para la foto de perfil
      }, onConflict: 'user_uuid');

      debugPrint('✅ Perfil actualizado con datos de Google');
    } catch (e) {
      debugPrint('⚠️ Error al actualizar perfil con datos de Google: $e');
      // No fallar el flujo si no se puede actualizar el perfil
    }
  }

  /// Convierte usuario anónimo a permanente con OAuth (fallback para web)
  /// 
  /// Retorna un Map con:
  /// - 'success': bool indicando si la operación fue exitosa
  /// - 'error': String con el mensaje de error si hubo alguno
  Future<Map<String, dynamic>> linkOAuthIdentity(OAuthProvider provider) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        return {
          'success': false,
          'error': 'No anonymous user to link',
        };
      }

      // linkIdentity devuelve bool en Supabase Flutter
      final success = await _supabase.auth.linkIdentity(provider);
      
      if (success) {
        await _clearAnonymousFlags();
        return {
          'success': true,
          'user': _supabase.auth.currentUser,
        };
      } else {
        return {
          'success': false,
          'error': 'No se pudo enlazar la identidad OAuth',
        };
      }
    } on AuthException catch (e) {
      debugPrint('❌ Error enlazando identity OAuth: ${e.message}');
      
      // Manejar errores específicos
      if (e.message.contains('already linked') || 
          e.message.contains('already exists')) {
        return {
          'success': false,
          'error': 'Esta cuenta ya está vinculada a otro usuario',
          'errorCode': 'identity_already_linked',
        };
      }
      
      return {
        'success': false,
        'error': e.message,
        'errorCode': e.statusCode,
      };
    } catch (e) {
      debugPrint('❌ Error enlazando identity OAuth: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Limpia las flags de usuario anónimo después de convertir
  Future<void> _clearAnonymousFlags() async {
    await _prefs.remove(_hasAnonymousUserKey);
    await _prefs.remove(_anonymousUserIdKey);
  }

  /// Elimina todos los datos de un usuario anónimo antes de cerrar sesión
  /// Retorna true si se eliminaron los datos correctamente
  Future<bool> deleteAnonymousUserData(String userId) async {
    try {
      debugPrint('🗑️ Eliminando datos del usuario anónimo: $userId');
      final response = await _supabase.rpc('delete_anonymous_user_data', params: {
        'target_user_id': userId,
      });
      
      debugPrint('🗑️ Respuesta de RPC: $response');
      
      if (response != null && response['success'] == true) {
        debugPrint('✅ Datos del usuario anónimo eliminados correctamente');
        return true;
      } else {
        debugPrint('⚠️ Error al eliminar datos: ${response?['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Error al eliminar datos del usuario anónimo: $e');
      return false;
    }
  }

  /// Sign out del usuario anónimo
  /// 
  /// IMPORTANTE: Según la documentación de Supabase:
  /// - Los usuarios anónimos NO pueden volver a iniciar sesión después de hacer logout
  /// - Los datos creados por el usuario anónimo permanecen en la BD asociados al user_id
  /// - Sin sesión activa, los datos NO son accesibles debido a las políticas RLS
  /// - Si el usuario crea un nuevo usuario anónimo, tendrá un nuevo user_id
  /// - Los datos anteriores quedarán huérfanos en la BD (no accesibles)
  /// 
  /// Para evitar pérdida de datos, se recomienda:
  /// - Convertir el usuario anónimo a permanente antes de hacer logout
  /// - O advertir al usuario sobre la pérdida de acceso a sus datos
  Future<void> signOutAnonymousUser() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      final isAnonymous = _supabase.auth.currentUser?.isAnonymous ?? false;
      
      if (isAnonymous && currentUserId != null) {
        await deleteAnonymousUserData(currentUserId);
      }
      
      await _supabase.auth.signOut();
      await _clearAnonymousFlags();
    } catch (e) {
      debugPrint('❌ Error cerrando sesión anónima: $e');
    }
  }

  /// Obtiene estadísticas del usuario anónimo
  Future<Map<String, dynamic>> getAnonymousUserStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};

    return {
      'id': user.id,
      'isAnonymous': user.isAnonymous,
      'createdAt': user.createdAt, // Ya es String
      'lastSignInAt': user.lastSignInAt, // Ya es String
      'hasLocalRecord': hasAnonymousUser,
    };
  }
}
