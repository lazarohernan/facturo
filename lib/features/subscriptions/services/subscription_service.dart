import 'dart:async';
import 'dart:io';

import 'package:facturo/generated/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:facturo/features/subscriptions/models/subscription_model.dart';
import 'package:facturo/core/providers/supabase_providers.dart';
import 'package:facturo/core/providers/shared_preferences_provider.dart';

// IDs de producto para iOS (deben coincidir con los configurados en App Store Connect)
const String _kMonthlyProductIdIOS = 'facturo_monthly_subscription';
const String _kAnnualProductIdIOS = 'facturo_annual_subscription';

// IDs de producto para Android (deben coincidir con los configurados en Google Play Console)
const String _kMonthlyProductIdAndroid = 'facturo.monthly.subscription';
const String _kAnnualProductIdAndroid = 'facturo.annual.subscription';

const String _kActiveSubscriptionKey = 'active_subscription';

class SubscriptionService {
  final SupabaseClient supabase;
  final SharedPreferences prefs;
  final InAppPurchase _inAppPurchase;
  
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _productsInitialized = false;
  bool _isExplicitRestoreRequest = false;
  
  final List<ProductDetails> _products = [];
  final Set<String> _processedTransactionIds = {};
  
  // Completer para esperar el resultado de la compra
  Completer<bool>? _purchaseCompleter;
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get purchasePending => _purchasePending;

  // Constructor
  SubscriptionService(this.supabase, this.prefs)
    : _inAppPurchase = InAppPurchase.instance {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    initializeProducts();
  }

  // Obtener ID de producto según la plataforma y el tipo de suscripción
  String _getProductId(SubscriptionType type) {
    final isMonthly = type == SubscriptionType.monthly;
    return Platform.isIOS
        ? isMonthly ? _kMonthlyProductIdIOS : _kAnnualProductIdIOS
        : isMonthly ? _kMonthlyProductIdAndroid : _kAnnualProductIdAndroid;
  }

  // Initialize store - método público para que pueda ser llamado desde la UI
  Future<void> initializeProducts({bool forceRefresh = false}) async {
    if (_productsInitialized && !forceRefresh) {
      debugPrint('ℹ️ Products already initialized, skipping');
      // Verificar si los productos siguen disponibles
      if (_products.isNotEmpty) {
        return;
      }
      // Si la lista está vacía, forzar recarga
      debugPrint('⚠️ Products list is empty, forcing refresh...');
      _productsInitialized = false;
    }
    
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        debugPrint('🔶 Store is not available - this is normal in simulator/development');
        // No marcar como inicializado si la tienda no está disponible
        _productsInitialized = false;
        return;
      }

      debugPrint('✅ Store is available, initializing products...');

      // Configurar IDs de producto según la plataforma
      final productIds = {
        if (Platform.isIOS) ...[_kMonthlyProductIdIOS, _kAnnualProductIdIOS],
        if (Platform.isAndroid) ...[_kMonthlyProductIdAndroid, _kAnnualProductIdAndroid],
      };
      
      debugPrint('🔍 Querying product IDs: $productIds');
      debugPrint('📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      
      ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails(productIds)
          .timeout(
            const Duration(seconds: 15), // Aumentar timeout a 15 segundos
            onTimeout: () {
              debugPrint('⏰ Product query timeout - this is normal in development');
              return ProductDetailsResponse(
                productDetails: [],
                notFoundIDs: productIds.toList(),
              );
            },
          );

      if (productDetailResponse.error != null) {
        final error = productDetailResponse.error!;
        if (error.code == 'storekit_no_response' || error.code == 'timeout') {
          debugPrint('🔶 StoreKit timeout/no response - normal in simulator: ${error.message}');
        } else {
          debugPrint('❌ Error querying products: ${error.code} - ${error.message}');
          debugPrint('❌ Error details: ${error.details}');
        }
        // No marcar como inicializado si hay error
        _productsInitialized = false;
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        debugPrint('🔶 No products found');
        if (productDetailResponse.notFoundIDs.isNotEmpty) {
          debugPrint('❌ Not found IDs: ${productDetailResponse.notFoundIDs}');
          debugPrint('⚠️ Verifica que los productos estén configurados en App Store Connect');
        }
        // No marcar como inicializado si no hay productos
        _productsInitialized = false;
        return;
      }

      _products.clear();
      _products.addAll(productDetailResponse.productDetails);
      debugPrint('✅ Available products: ${_products.length}');
      for (final product in _products) {
        debugPrint('💰 Product: ${product.id} - ${product.price} - ${product.title}');
      }
      _productsInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing products: $e');
      if (kDebugMode) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // No marcar como inicializado si hay excepción
      _productsInitialized = false;
    }
  }

  // Buy a subscription
  // Retorna true si la compra fue exitosa, false si fue cancelada o falló
  Future<bool> buySubscription(SubscriptionPlan plan, {BuildContext? context}) async {
    // Verificar si ya tiene suscripción activa
    try {
      debugPrint('🔍 Verificando suscripción actual antes de comprar...');
      final currentSub = await getCurrentSubscription();
      debugPrint('📊 Resultado: isActive=${currentSub.isActive}, type=${currentSub.type.name}');
      
      if (currentSub.isActive) {
        if (currentSub.type == plan.type) {
          // Mismo plan - NO permitir re-suscripción
          debugPrint('⚠️ User already has active ${plan.type.name} subscription');
          if (context != null && context.mounted) {
            final expiryDate = currentSub.expiryDate;
            final daysRemaining = expiryDate.difference(DateTime.now()).inDays;
            final l10n = AppLocalizations.of(context);
            final planName = plan.type == SubscriptionType.monthly ? l10n.monthlyPlan : l10n.annualPlan;
            
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Text(l10n.activePlan),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facturo Pro $planName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          l10n.renewingInDays(daysRemaining),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.autorenew, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          l10n.autoRenewalActive,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.manageSubscriptionHelp,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Abrir gestión de suscripciones en App Store
                      if (Platform.isIOS) {
                        final url = Uri.parse('https://apps.apple.com/account/subscriptions');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.manageInAppStore),
                  ),
                ],
              ),
            );
          }
          return false; // Ya tiene suscripción activa
        } else {
          // Usuario tiene otro plan - Mostrar que ya tiene suscripción activa
          debugPrint('⚠️ User has active ${currentSub.type.name} subscription, trying to get ${plan.type.name}');
          if (context != null && context.mounted) {
            final l10n = AppLocalizations.of(context);
            final currentPlanName = currentSub.type == SubscriptionType.monthly ? l10n.monthlyPlan : l10n.annualPlan;
            final newPlanName = plan.type == SubscriptionType.monthly ? l10n.monthlyPlan : l10n.annualPlan;
            final daysRemaining = currentSub.expiryDate.difference(DateTime.now()).inDays;
            
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Text(l10n.activePlan),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentPlanLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Facturo Pro $currentPlanName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          l10n.renewingInDays(daysRemaining),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.changePlanInstruction(newPlanName),
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Abrir gestión de suscripciones en App Store
                      if (Platform.isIOS) {
                        final url = Uri.parse('https://apps.apple.com/account/subscriptions');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.manageInAppStore),
                  ),
                ],
              ),
            );
          }
          return false; // Ya tiene suscripción activa
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not check current subscription: $e');
    }
    
    return await _executePurchase(plan);
  }

  
  // Método interno para ejecutar la compra
  // Retorna un Future<bool> que se completa cuando la compra termina (éxito o fallo)
  Future<bool> _executePurchase(SubscriptionPlan plan) async {
    // Verificar disponibilidad de la tienda
    if (!_isAvailable) {
      // Intentar verificar nuevamente
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        throw Exception('Store is not available');
      }
    }
    
    // Check if there's already a pending purchase
    if (_purchasePending) {
      debugPrint('⚠️ Ya hay una compra en progreso, esperando resultado...');
      if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
        return _purchaseCompleter!.future;
      }
      throw Exception('There is already a purchase in progress. Please wait.');
    }

    // Obtener ID de producto según la plataforma
    String productId = _getProductId(plan.type);

    // Buscar el producto en la lista de productos disponibles
    ProductDetails? productDetails;
    try {
      productDetails = _products.firstWhere(
        (element) => element.id == productId,
      );
    } catch (e) {
      // Si el producto no está en la lista, intentar inicializar productos nuevamente
      debugPrint('⚠️ Producto no encontrado en lista, intentando inicializar productos...');
      await initializeProducts();
      
      // Buscar nuevamente después de inicializar
      try {
        productDetails = _products.firstWhere(
          (element) => element.id == productId,
        );
      } catch (e2) {
        // Si aún no está disponible, crear un ProductDetails temporal con el ID
        // StoreKit puede manejar la compra incluso sin tener el producto precargado
        debugPrint('⚠️ Producto aún no disponible después de inicializar, intentando compra directa...');
        // Lanzar excepción para que el caller maneje el error
        throw Exception('Producto no disponible en la tienda: $productId. Por favor, verifica tu conexión e intenta de nuevo.');
      }
    }

    // Crear parámetros de compra
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    // Iniciar estado de compra ANTES de llamar a buyNonConsumable
    // para que los eventos de restore que lleguen sean procesados correctamente
    _purchasePending = true;
    _purchaseCompleter = Completer<bool>();
    try {
      debugPrint('💳 Iniciando compra: $productId');
      
      // Usar buyNonConsumable para suscripciones
      // Esto mostrará automáticamente el diálogo de confirmación de Apple/Google
      final bool purchaseInitiated = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!purchaseInitiated) {
        _completePurchase(false);
        throw Exception('No se pudo iniciar la compra. Por favor, inténtalo de nuevo.');
      }
      
      // Esperar a que la compra se complete (éxito o fallo)
      debugPrint('⏳ Esperando confirmación de compra...');
      return await _purchaseCompleter!.future;
    } catch (e) {
      debugPrint('❌ Error al iniciar compra: $e');
      _completePurchase(false);
      rethrow;
    }
  }
  
  // Completar el proceso de compra y notificar al caller
  void _completePurchase(bool success) {
    debugPrint('🏁 Completando compra: success=$success');
    _purchasePending = false;
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(success);
    }
    _purchaseCompleter = null;
  }

  // Process a successful purchase
  // La navegación ahora se maneja en el caller después de que buySubscription retorne
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      final transactionId = purchaseDetails.purchaseID ?? '';
      
      // Evitar procesar la misma transacción múltiples veces
      if (transactionId.isNotEmpty && _processedTransactionIds.contains(transactionId)) {
        debugPrint('⚠️ Transacción ya procesada: $transactionId');
        return;
      }
      
      // Apple Guideline 5.1.1: Process purchases for ALL users including anonymous
      // The subscription is tied to Apple ID (StoreKit), not the app account
      //
      // IMPORTANT: Supabase anonymous users DO have a valid user_id (UUID)
      // When they convert to a permanent account, the same user_id is preserved
      // So we should save to Supabase for ALL users (anonymous and authenticated)
      final currentUser = supabase.auth.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        debugPrint('📱 Processing purchase for anonymous user (user_id: ${currentUser.id})');
      }
      
      // Validar receipt antes de activar
      final isValid = await _verifyPurchase(purchaseDetails);
      if (!isValid) {
        debugPrint('❌ Receipt inválido');
        return;
      }
      
      // Marcar transacción como procesada
      if (transactionId.isNotEmpty) {
        _processedTransactionIds.add(transactionId);
      }
      
      // Determinar tipo de suscripción
      final isMonthlyProduct = Platform.isIOS
          ? purchaseDetails.productID == _kMonthlyProductIdIOS
          : purchaseDetails.productID == _kMonthlyProductIdAndroid;
      final type = isMonthlyProduct ? SubscriptionType.monthly : SubscriptionType.annual;

      debugPrint('💾 Guardando suscripción: type=$type');

      // Calculate expiry date (1 month or 1 year from now)
      final now = DateTime.now();
      final expiryDate = type == SubscriptionType.monthly
          ? DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year + 1, now.month, now.day);

      // Create subscription object
      SubscriptionInfo subscription = SubscriptionInfo(
        isActive: true,
        type: type,
        purchaseDate: now,
        expiryDate: expiryDate,
        transactionId: purchaseDetails.purchaseID,
        platform: Platform.isIOS ? 'ios' : 'android',
        productId: purchaseDetails.productID,
      );

      // Save locally (always - works for both anonymous and authenticated users)
      await _saveSubscriptionLocally(subscription);

      // Save to Supabase for ALL users (including anonymous)
      // Supabase anonymous users have a valid user_id that persists when they convert
      // This ensures subscription is already linked when they create a permanent account
      if (currentUser != null) {
        await _saveSubscriptionToSupabase(subscription);
        debugPrint('☁️ Subscription saved to Supabase (user_id: ${currentUser.id})');
      } else {
        debugPrint('📱 Subscription saved locally only (no user session)');
      }
      
      debugPrint('✅ Suscripción guardada exitosamente');
      
      // NOTA: La navegación se maneja en el caller después de que buySubscription() retorne true
    } catch (e) {
      debugPrint('❌ Error activating subscription: $e');
      rethrow;
    }
  }

  
  // Save subscription locally
  Future<void> _saveSubscriptionLocally(SubscriptionInfo subscription) async {
    try {
      await prefs.setString(_kActiveSubscriptionKey, subscription.toJson());
    } catch (e) {
      debugPrint('❌ Error saving subscription locally: $e');
      rethrow;
    }
  }

  // Verificar receipt con validación mejorada
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final purchaseId = purchaseDetails.purchaseID;
      if (purchaseId == null || purchaseId.isEmpty) {
        debugPrint('❌ Invalid purchase: no purchaseID');
        return false;
      }

      // Validación específica por plataforma
      if (Platform.isIOS) {
        // Para iOS, el plugin in_app_purchase ya valida automáticamente
        // la firma del receipt con StoreKit antes de entregar el PurchaseDetails
        // Si llegamos aquí con status=purchased, Apple ya validó el receipt
        
        // Validación adicional: verificar que el productID coincida
        final validProductIds = {_kMonthlyProductIdIOS, _kAnnualProductIdIOS};
        if (!validProductIds.contains(purchaseDetails.productID)) {
          debugPrint('❌ Invalid product ID: ${purchaseDetails.productID}');
          return false;
        }
        
        // Verificar que tenga verificationData (receipt)
        if (purchaseDetails.verificationData.serverVerificationData.isEmpty) {
          debugPrint('❌ No verification data (receipt) found');
          return false;
        }
        
        debugPrint('✅ iOS receipt validated by StoreKit');
        return true;
      } else if (Platform.isAndroid) {
        // Para Android, Google Play también valida automáticamente
        final validProductIds = {_kMonthlyProductIdAndroid, _kAnnualProductIdAndroid};
        if (!validProductIds.contains(purchaseDetails.productID)) {
          debugPrint('❌ Invalid product ID: ${purchaseDetails.productID}');
          return false;
        }
        
        // Verificar que tenga verificationData
        if (purchaseDetails.verificationData.serverVerificationData.isEmpty) {
          debugPrint('❌ No verification data found');
          return false;
        }
        
        debugPrint('✅ Android purchase validated by Google Play');
        return true;
      }
      
      // Plataforma no soportada
      debugPrint('⚠️ Unsupported platform for purchase verification');
      return false;
    } catch (e) {
      debugPrint('❌ Error verifying purchase: $e');
      return false;
    }
  }

  // Restaurar compras anteriores
  Future<void> restorePurchases({BuildContext? context}) async {
    try {
      _isExplicitRestoreRequest = true; // Marcar como restore explícito
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      _isExplicitRestoreRequest = false; // Resetear flag en caso de error
      if (context != null && context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorRestoringPurchasesWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }


  // Save subscription to Supabase using upsert to avoid race conditions
  Future<void> _saveSubscriptionToSupabase(
    SubscriptionInfo subscription,
  ) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ No user logged in, cannot save to Supabase');
        return;
      }

      // Usar upsert para evitar conflictos de clave duplicada
      final data = {
        'user_id': userId,
        'is_active': subscription.isActive,
        'type': subscription.type.name,
        'purchase_date': subscription.purchaseDate.toIso8601String(),
        'expiry_date': subscription.expiryDate.toIso8601String(),
        'transaction_id': subscription.transactionId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('subscriptions')
          .upsert(data, onConflict: 'user_id')
          .select();
    } catch (e) {
      debugPrint('❌ Error saving subscription to Supabase: $e');
      // No rethrow - solo log el error para evitar crashes
    }
  }

  // Fetch subscription from Supabase
  Future<SubscriptionInfo> _fetchSubscriptionFromSupabase() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ _fetchSubscriptionFromSupabase: No hay usuario');
        return SubscriptionInfo.inactive();
      }

      debugPrint('🔍 Consultando suscripciones en Supabase para user_id: $userId');
      
      final data = await supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1);
      
      debugPrint('📊 Datos recibidos de Supabase: ${data.length} registros');
      
      if (data.isEmpty) {
        debugPrint('✅ No hay suscripciones activas en Supabase');
        return SubscriptionInfo.inactive();
      }

      final subscriptionData = data.first;
      debugPrint('📋 Suscripción encontrada: $subscriptionData');
      
      final subscription = SubscriptionInfo.fromMap(subscriptionData);
      final now = DateTime.now();

      // Verificar si fue reembolsada
      if (subscription.refundDate != null) {
        debugPrint('💰 Subscription refunded, deactivating...');
        await _deactivateSubscription(subscription);
        return SubscriptionInfo.inactive();
      }

      // Verificar si el grace period expiró
      if (subscription.gracePeriodExpiresAt != null && 
          subscription.gracePeriodExpiresAt!.isBefore(now)) {
        debugPrint('⌛️ Grace period expired, deactivating...');
        await _deactivateSubscription(subscription);
        return SubscriptionInfo.inactive();
      }

      // Verificar expiración normal (solo si no hay grace period activo)
      if (subscription.expiryDate.isBefore(now) && 
          (subscription.gracePeriodExpiresAt == null || 
           subscription.gracePeriodExpiresAt!.isBefore(now))) {
        debugPrint('⌛️ Subscription expired, deactivating...');
        await _deactivateSubscription(subscription);
        return SubscriptionInfo.inactive();
      }

      // Mostrar información de estado
      if (subscription.cancellationDate != null && subscription.isActive) {
        final daysRemaining = subscription.expiryDate.difference(now).inDays;
        debugPrint('🔄 Subscription canceled but still active for $daysRemaining days');
      }

      if (subscription.gracePeriodExpiresAt != null && 
          subscription.gracePeriodExpiresAt!.isAfter(now)) {
        final graceDays = subscription.gracePeriodExpiresAt!.difference(now).inDays;
        debugPrint('⚠️ Subscription in grace period, expires in $graceDays days');
      }

      debugPrint('✅ Suscripción válida encontrada - Status: ${subscription.status.name}');
      // Guardar en caché local
      await _saveSubscriptionLocally(subscription);
      return subscription;
    } catch (e) {
      debugPrint('❌ Error fetching subscription from Supabase: $e');
      return SubscriptionInfo.inactive();
    }
  }

  // Get current subscription (ALWAYS from Supabase, never cache)
  Future<SubscriptionInfo> getCurrentSubscription() async {
    try {
      debugPrint('🔍 getCurrentSubscription: Iniciando consulta...');
      
      // SIEMPRE consultar Supabase directamente, ignorar cache local
      if (supabase.auth.currentUser != null) {
        debugPrint('👤 Usuario actual: ${supabase.auth.currentUser!.id}');
        
        // Limpiar cache local primero para forzar recarga
        await prefs.remove(_kActiveSubscriptionKey);
        
        final supabaseSubscription = await _fetchSubscriptionFromSupabase();
        debugPrint('📊 Suscripción de Supabase: isActive=${supabaseSubscription.isActive}');
        
        // Sincronizar cache local con Supabase
        if (supabaseSubscription.isActive) {
          await _saveSubscriptionLocally(supabaseSubscription);
        }
        
        return supabaseSubscription;
      }
      
      debugPrint('⚠️ No hay usuario autenticado, devolviendo inactivo');
      // Sin usuario, limpiar cache y devolver inactivo
      await prefs.remove(_kActiveSubscriptionKey);
      return SubscriptionInfo.inactive();
    } catch (e) {
      debugPrint('❌ Error getting current subscription: $e');
      return SubscriptionInfo.inactive();
    }
  }

  // Handle stream of purchase updates
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      try {
        debugPrint('📦 Purchase update: status=${purchaseDetails.status}, productId=${purchaseDetails.productID}');
        
        if (purchaseDetails.status == PurchaseStatus.pending) {
          debugPrint('⏳ Compra pendiente - esperando confirmación del usuario...');
          _purchasePending = true;
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          // Compra exitosa con diálogo de confirmación de Apple
          debugPrint('✅ Compra confirmada por el usuario');
          await _deliverProduct(purchaseDetails);
          _completePurchase(true);
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          // En sandbox de iOS, cuando ya compraste una suscripción, Apple envía
          // "restored" en lugar de "purchased". Debemos manejar esto correctamente.
          
          // Caso 1: Hay una compra en progreso esperando resultado
          // Esto significa que el usuario intentó comprar y Apple restauró en lugar de cobrar
          if (_purchasePending && _purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
            debugPrint('🔄 Restore durante compra activa - tratando como compra exitosa');
            await _deliverProduct(purchaseDetails);
            _completePurchase(true);
          }
          // Caso 2: Usuario presionó explícitamente "Restaurar compras"
          else if (_isExplicitRestoreRequest) {
            debugPrint('🔄 Restaurando compra explícitamente...');
            await _deliverProduct(purchaseDetails);
            _completePurchase(true);
          }
          // Caso 3: Restore automático al iniciar la app - ignorar silenciosamente
          else {
            debugPrint('ℹ️ Restore automático ignorado (no hay compra en progreso)');
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          // Usuario canceló la compra
          debugPrint('❌ Compra cancelada por el usuario');
          _completePurchase(false);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          // Error en la compra
          debugPrint('❌ Error en la compra: ${purchaseDetails.error?.message}');
          _completePurchase(false);
        }

        // Completar la compra en StoreKit
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      } catch (e) {
        debugPrint('❌ Error processing purchase update: $e');
        _completePurchase(false);
        _isExplicitRestoreRequest = false;
      }
    }
    
    // Resetear flag de restore explícito después de procesar todos los eventos
    _isExplicitRestoreRequest = false;
  }

  // Deactivate subscription
  Future<void> _deactivateSubscription(SubscriptionInfo subscription) async {
    try {
      final inactiveSubscription = subscription.copyWith(isActive: false);
      // Update local storage
      await _saveSubscriptionLocally(inactiveSubscription);
      // Update Supabase
      if (supabase.auth.currentUser != null) {
        await supabase
            .from('subscriptions')
            .update({'is_active': false})
            .eq('user_id', supabase.auth.currentUser!.id);
      }
    } catch (e) {
      debugPrint('Error deactivating subscription: $e');
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('❌ Purchase stream error: $error');
  }

  // Clean up resources
  void dispose() {
    _subscription.cancel();
  }
  
  // Método para verificar si hay una suscripción activa
  Future<bool> hasActiveSubscription() async {
    final subscription = await getCurrentSubscription();
    return subscription.isActive;
  }
  
  // Método para obtener información de la suscripción actual
  Future<SubscriptionInfo?> getSubscriptionInfo() async {
    return getCurrentSubscription();
  }
  
  // Método para obtener detalles de un producto específico por ID
  ProductDetails? getProductDetails(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      debugPrint('Product with ID $productId not found in available products');
      return null;
    }
  }
}

// Provider for subscription service
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  return SubscriptionService(supabase, prefs);
});

// Provider para verificar si hay una suscripción activa
final hasActiveSubscriptionProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.hasActiveSubscription();
});

// Provider para obtener información de la suscripción actual
final subscriptionInfoProvider = FutureProvider<SubscriptionInfo?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionInfo();
});

// Provider para obtener el tipo de suscripción actual
final subscriptionTypeProvider = Provider<SubscriptionType?>((ref) {
  return ref.watch(subscriptionInfoProvider).value?.type;
});

// Provider para obtener la fecha de expiración de la suscripción
final subscriptionExpiryProvider = Provider<DateTime?>((ref) {
  return ref.watch(subscriptionInfoProvider).value?.expiryDate;
});

// Provider para obtener los días restantes de suscripción
final subscriptionRemainingDaysProvider = Provider<int?>((ref) {
  final expiryDate = ref.watch(subscriptionExpiryProvider);
  if (expiryDate == null) return null;
  
  final now = DateTime.now();
  final difference = expiryDate.difference(now);
  return difference.inDays;
});

// Provider para obtener la suscripción actual
// Usa autoDispose para que se recalcule cada vez y no cachee datos obsoletos
final currentSubscriptionProvider = FutureProvider.autoDispose<SubscriptionInfo>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getCurrentSubscription();
});
