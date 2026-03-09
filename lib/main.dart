import 'dart:async';
import 'package:facturo/features/ocr/services/gemini_ocr_service.dart';
import 'package:facturo/core/constants/app_constants.dart';
import 'package:facturo/core/providers/shared_preferences_provider.dart';
import 'package:facturo/core/theme/app_theme.dart';
import 'package:facturo/features/auth/controllers/auth_controller.dart' as auth;
import 'package:facturo/features/notifications/services/firebase_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/utils/router.dart';
import 'generated/l10n/app_localizations.dart';

void main() {
  runApp(const InitializationWrapper());
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  late final Future<SharedPreferences> _initialization;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 InitializationWrapper: initState()');
    _initialization = _initializeApp();
  }

  Future<SharedPreferences> _initializeApp() async {
    try {
      debugPrint('🔄 Inicializando WidgetsFlutterBinding...');
      WidgetsFlutterBinding.ensureInitialized();

      debugPrint('🔄 Cargando variables de entorno...');
      // Load environment variables from .env file
      await dotenv.load(fileName: ".env");

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      debugPrint('🔄 SUPABASE_URL: ${supabaseUrl?.substring(0, 20)}...');
      debugPrint(
          '🔄 SUPABASE_ANON_KEY: ${supabaseAnonKey?.substring(0, 20)}...');

      if (supabaseUrl == null ||
          supabaseAnonKey == null ||
          supabaseUrl.isEmpty ||
          supabaseAnonKey.isEmpty) {
        throw Exception(
            'SUPABASE_URL y SUPABASE_ANON_KEY deben estar definidos en tu archivo .env');
      }

      debugPrint('🔄 Inicializando Supabase...');
      // Initialize Supabase con persistencia de sesión (habilitada por defecto)
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // Flujo PKCE más seguro
          autoRefreshToken: true, // Auto-refresh de tokens
        ),
        // Configurar deep links para autenticación
        debug: kDebugMode,
      );
      debugPrint('✅ Supabase inicializado con persistencia de sesión y deep links');
      
      // Verificar sesión actual sin delay artificial
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        debugPrint('✅ Sesión restaurada: ${currentUser.id}');
        debugPrint('   - Es anónimo: ${currentUser.isAnonymous}');
      } else {
        debugPrint('ℹ️ No hay sesión previa para restaurar');
      }

      debugPrint('🔄 Inicializando SharedPreferences...');
      // Initialize SharedPreferences
      final sharedPreferences = await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences inicializado correctamente');

      // Inicializar servicios no críticos en background después del splash
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeBackgroundServices();
      });


      return sharedPreferences;
    } catch (e, stackTrace) {
      debugPrint('❌ Error en _initializeApp: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      // Rethrow to be caught by FutureBuilder
      rethrow;
    }
  }

  // Inicialización de servicios no críticos en background
  void _initializeBackgroundServices() async {
    debugPrint('🔄 Inicializando servicios en background...');
    
    // Inicializar Gemini AI (opcional, no bloquea si falla)
    debugPrint('🔄 Inicializando Gemini AI...');
    try {
      await GeminiOCRService().initialize();
      debugPrint('✅ Gemini AI inicializado');
    } catch (e) {
      debugPrint('⚠️ Gemini AI no disponible: $e');
    }

    // Firebase initialization - optional, won't block app if not configured
    debugPrint('🔄 Inicializando Firebase...');
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase inicializado');

      debugPrint('🔄 Inicializando Firebase Notifications...');
      final notificationService = FirebaseNotificationService();
      await notificationService.initialize();
      debugPrint('✅ Firebase Notifications inicializado');
    } catch (e) {
      debugPrint('⚠️ Firebase no configurado: $e');
      debugPrint('⚠️ Las notificaciones push no estarán disponibles hasta configurar Firebase');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 InitializationWrapper: build()');
    return FutureBuilder<SharedPreferences>(
      future: _initialization,
      builder: (context, snapshot) {
        debugPrint('🔄 FutureBuilder state: ${snapshot.connectionState}');

        if (snapshot.hasError) {
          debugPrint('❌ FutureBuilder error: ${snapshot.error}');
          return _buildErrorScreen(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          debugPrint('✅ Inicialización completa, creando ProviderScope');
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone X design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(snapshot.data!),
                ],
                child: const MyApp(),
              );
            },
          );
        }

        debugPrint('🔄 Mostrando pantalla de carga...');
        return _buildLoadingScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context).initializing,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).initializationErrorTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).initializationErrorHelp,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Reiniciar la aplicación
                        setState(() {
                          _initialization = _initializeApp();
                        });
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Agregar observador del ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Inicializar el AuthController para crear usuario anónimo si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Cuando la app vuelve al primer plano, limpiar el badge de iOS
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - limpiando badge de iOS...');
      FirebaseNotificationService().clearBadge();
    }
  }

  Future<void> _initializeAuth() async {
    try {
      // Leer el AuthController para que se inicialice
      final authState = ref.read(auth.authControllerProvider);
      debugPrint('🔐 AuthController inicializado: ${authState.state}');

      // Si está cargando, esperar a que termine
      if (authState.state == auth.AuthState.loading) {
        debugPrint('🔄 Esperando inicialización de auth...');
      }
    } catch (e) {
      debugPrint('❌ Error inicializando auth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 MyApp: build()');
    
    // Observar el estado de autenticación
    final authState = ref.watch(auth.authControllerProvider);
    debugPrint('🔐 Auth state: ${authState.state}, isAnonymous: ${authState.isAnonymous}');

    try {
      final themeMode = ref.watch(themeProvider);
      debugPrint('✅ themeProvider cargado');

      final locale = ref.watch(localeProvider);
      debugPrint('✅ localeProvider cargado');

      final router = ref.watch(routerProvider);
      debugPrint('✅ routerProvider cargado');

      debugPrint('🔄 Creando MaterialApp.router...');
      return MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        // Dynamic Type support with reasonable limits (Apple HIG compliance)
        // Allows system text scaling between 1.0x and 1.5x to prevent layout breakage
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final scale = mediaQuery.textScaler.scale(1.0).clamp(1.0, 1.5);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error en MyApp.build: $e');
      debugPrint('❌ StackTrace: $stackTrace');

      // Fallback app en caso de error
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).initializationErrorTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}
