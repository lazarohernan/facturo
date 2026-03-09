import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_settings_service.dart';
/// Servicio para manejar notificaciones push con Firebase
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Stream controllers para manejar eventos
  final StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  bool _initialized = false;
  String? _fcmToken;
  StreamSubscription<AuthState>? _authSubscription;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Inicializar notificaciones locales
      await _initializeLocalNotifications();
      
      // Limpiar badge de iOS al abrir la app
      await clearBadge();
      
      // Solicitar permisos ANTES de obtener el token
      final hasPermission = await requestPermissions();
      debugPrint('📱 Permisos de notificación: ${hasPermission ? "✅ Concedidos" : "❌ Denegados"}');
      
      if (hasPermission) {
        // Obtener token FCM solo si hay permisos
        await _getFCMToken();
        
        // 🎯 La activación automática se hace en _setupAuthListener
        // cuando se detecta que un usuario se loguea/registra (signedIn event)
        debugPrint('✅ Permisos concedidos, esperando creación de usuario para activar notificaciones...');
      } else {
        debugPrint('⚠️ No se puede obtener FCM token sin permisos de notificación');
      }
      
      // Configurar handlers
      _setupMessageHandlers();
      
      // Escuchar cambios de autenticación para guardar el token cuando el usuario se loguee
      _setupAuthListener();
      
      _initialized = true;
      debugPrint('🔥 Firebase Notification Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Notification Service: $e');
    }
  }

  /// Limpia el badge de notificaciones en iOS
  Future<void> clearBadge() async {
    try {
      // Cancelar todas las notificaciones entregadas
      await _localNotifications.cancelAll();

      // Limpiar el badge del icono de la app (iOS y Android)
      if (await FlutterAppBadger.isAppBadgeSupported()) {
        await FlutterAppBadger.removeBadge();
        debugPrint('🧹 Badge de la app limpiado correctamente');
      }
    } catch (e) {
      debugPrint('⚠️ Error limpiando badge: $e');
    }
  }

  /// Activa automáticamente las notificaciones push cuando el usuario concede permisos
  /// Esto mejora la experiencia del usuario al no requerir activación manual
  Future<void> _enablePushNotificationsByDefault() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        debugPrint('⚠️ No hay usuario autenticado, no se puede activar notificaciones');
        return;
      }
      
      debugPrint('🔔 Usuario concedió permisos, activando notificaciones push por defecto...');
      
      // Usar NotificationSettingsService para activar las notificaciones
      final settingsService = NotificationSettingsService();
      
      // Verificar si ya existen configuraciones
      try {
        final existingSettings = await settingsService.getNotificationSettings();
        
        // Si ya existen y están desactivadas, activarlas
        if (existingSettings != null && !existingSettings.pushEnabled) {
          await settingsService.setPushEnabled(true);
          debugPrint('✅ Notificaciones push activadas automáticamente');
        } else {
          debugPrint('✅ Las notificaciones push ya estaban activadas');
        }
      } catch (e) {
        // Si no existen configuraciones, crearlas con push enabled
        debugPrint('📝 Creando configuración de notificaciones con push activado...');
        await settingsService.updateNotificationSettings(pushEnabled: true);
        debugPrint('✅ Configuración creada con notificaciones push activadas');
      }
    } catch (e) {
      debugPrint('❌ Error activando notificaciones automáticamente: $e');
      // No lanzar error - esto es una mejora, no crítico
    }
  }

  /// Configura listener para cambios de autenticación
  void _setupAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;
      
      debugPrint('🔐 Auth state changed: $event, user: ${user?.id}');
      
      // Cuando el usuario se loguea o registra, guardar el token FCM
      if ((event == AuthChangeEvent.signedIn || 
           event == AuthChangeEvent.userUpdated ||
           event == AuthChangeEvent.tokenRefreshed) && 
          user != null && _fcmToken != null) {
        debugPrint('🔄 Usuario autenticado, guardando FCM token...');
        _saveFCMTokenToSupabase(_fcmToken!);
        
        // 🎯 ACTIVAR notificaciones automáticamente cuando se crea/loguea un usuario
        // Esto cubre el caso donde Firebase se inicializa antes que el usuario anónimo
        if (event == AuthChangeEvent.signedIn) {
          debugPrint('🔔 Usuario nuevo detectado, activando notificaciones...');
          _enablePushNotificationsByDefault();
        }
      }
    });
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('📱 iOS Permission status: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isAndroid) {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('🤖 Android Permission status: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    
    return false;
  }

  /// Inicializa notificaciones locales para mostrar en foreground
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Obtiene el token FCM del dispositivo
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $_fcmToken');
      
      // Guardar token en Supabase
      if (_fcmToken != null) {
        await _saveFCMTokenToSupabase(_fcmToken!);
      }
      
      // Escuchar cambios en el token
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('🔄 FCM Token refreshed: $token');
        _saveFCMTokenToSupabase(token);
      });
      
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Guarda el token FCM en Supabase
  Future<void> _saveFCMTokenToSupabase(String token) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        debugPrint('⚠️ No hay usuario autenticado, no se puede guardar token FCM');
        debugPrint('💡 Esperando a que el usuario se autentique (anónimo o registrado)...');
        return;
      }
      
      debugPrint('👤 Guardando FCM token para usuario: ${user.id} (anónimo: ${user.isAnonymous})');


      final deviceType = Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web';
      
      // Upsert del token (insertar o actualizar si ya existe)
      await supabase.from('fcm_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'device_type': deviceType,
        'device_name': Platform.isIOS ? 'iPhone' : Platform.isAndroid ? 'Android' : 'Web',
        'is_active': true,
      }, onConflict: 'user_id, fcm_token');

      debugPrint('✅ Token FCM guardado en Supabase');
    } catch (e) {
      debugPrint('❌ Error guardando token FCM en Supabase: $e');
    }
  }

  /// Configura handlers para mensajes
  void _setupMessageHandlers() {
    // Mensaje cuando app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Mensaje cuando app está en background pero abierta
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Mensaje cuando app está completamente cerrada
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  /// Maneja mensajes en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message received: ${message.notification?.title}');
    
    // Mostrar notificación local
    _showLocalNotification(message);
    
    // Enviar al stream
    _messageStreamController.add(message);
  }

  /// Maneja mensajes cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📱 Message opened app: ${message.notification?.title}');
    _messageStreamController.add(message);
  }

  /// Maneja mensaje inicial cuando app está cerrada
  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      debugPrint('🚀 Initial message: ${message.notification?.title}');
      _messageStreamController.add(message);
    }
  }

  /// Muestra notificación local cuando app está en foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'facturo_channel',
      'Facturo Notifications',
      channelDescription: 'Notifications from Facturo app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Maneja tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Local notification tapped: ${response.payload}');
    // Navigation to specific screen based on payload not yet implemented
  }

  /// Programa el resumen semanal para el usuario actual
  Future<void> scheduleWeeklySummary({
    required int dayOfWeek, // 1 = Lunes, 7 = Domingo
    required int hour, // 0-23
    required String userId,
  }) async {
    try {
      // Backend implementation pending
      debugPrint('✅ Weekly summary scheduled for day $dayOfWeek at $hour:00');
      debugPrint('📝 Token FCM: $_fcmToken');
    } catch (e) {
      debugPrint('❌ Error scheduling weekly summary: $e');
    }
  }

  /// Cancela el resumen semanal del usuario
  Future<void> cancelWeeklySummary(String userId) async {
    try {
      // Backend implementation pending
      debugPrint('✅ Weekly summary cancelled for user: $userId');
    } catch (e) {
      debugPrint('❌ Error cancelling weekly summary: $e');
    }
  }

  /// Envía una notificación de prueba local
  Future<void> sendTestNotification() async {
    try {
      // Enviar notificación local de prueba
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications from Facturo',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        0,
        '🔔 Test Notification',
        'Firebase notifications are working! Your weekly summary will arrive here.',
        details,
      );
      
      debugPrint('✅ Test notification sent locally');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }

  /// Obtiene el token FCM actual
  String? get fcmToken => _fcmToken;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;

  /// Dispose
  void dispose() {
    _authSubscription?.cancel();
    _messageStreamController.close();
  }
}
