# Configuración de Webhooks de Suscripciones

Este documento explica cómo configurar los webhooks de Apple App Store y Google Play para recibir notificaciones en tiempo real sobre cambios en las suscripciones.

## 📱 Apple App Store Server Notifications

### URLs de Webhooks

**Producción:**
```
https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/apple-webhook
```

**Sandbox (Testing):**
```
https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/apple-webhook
```

### Configuración en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu app **Facturo**
3. Ve a **General** > **App Information**
4. Busca la sección **App Store Server Notifications**
5. Haz clic en el botón **+** para agregar una URL de servidor
6. Configura:
   - **Production Server URL**: `https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/apple-webhook`
   - **Sandbox Server URL**: `https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/apple-webhook`
   - **Version**: Selecciona **Version 2** (recomendado)
7. Guarda los cambios

### Eventos que se reciben

La función maneja los siguientes eventos de Apple:

- **EXPIRED** - Suscripción expirada
  - `VOLUNTARY` - Usuario canceló
  - `BILLING_RETRY` - Problema de pago
  - `PRICE_INCREASE` - Usuario rechazó aumento de precio
  
- **DID_CHANGE_RENEWAL_STATUS** - Cambio en auto-renovación
  - `AUTO_RENEW_DISABLED` - Usuario desactivó auto-renovación
  - `AUTO_RENEW_ENABLED` - Usuario reactivó auto-renovación

- **REFUND** - Reembolso procesado
- **REVOKE** - Suscripción revocada (Family Sharing)
- **DID_FAIL_TO_RENEW** - Fallo en renovación (inicia grace period)
- **DID_RENEW** - Renovación exitosa

## 🤖 Google Play Real-time Developer Notifications

### URL de Webhook

```
https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/google-webhook
```

### Configuración en Google Play Console

1. Ve a [Google Play Console](https://play.google.com/console)
2. Selecciona tu app **Facturo**
3. Ve a **Monetization setup** > **Real-time developer notifications**
4. Haz clic en **Enable real-time developer notifications**
5. Configura:
   - **Topic name**: Crea un nuevo topic en Google Cloud Pub/Sub o usa uno existente
   - **Service account**: Asegúrate de que tenga permisos de Pub/Sub Publisher
6. Configura el Push endpoint:
   - **Endpoint URL**: `https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/google-webhook`
7. Guarda los cambios

### Configuración de Google Cloud Pub/Sub

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto
3. Ve a **Pub/Sub** > **Topics**
4. Selecciona el topic que creaste
5. Ve a **Subscriptions**
6. Crea una nueva suscripción:
   - **Delivery type**: Push
   - **Endpoint URL**: `https://sztkpkplvzyltsdmdnsw.supabase.co/functions/v1/google-webhook`
   - **Acknowledgement deadline**: 10 segundos
7. Guarda la configuración

### Eventos que se reciben

La función maneja los siguientes tipos de notificación:

- **1** - SUBSCRIPTION_RECOVERED - Recuperada de account hold
- **2** - SUBSCRIPTION_RENEWED - Renovada exitosamente
- **3** - SUBSCRIPTION_CANCELED - Usuario canceló (aún activa hasta expiración)
- **4** - SUBSCRIPTION_PURCHASED - Nueva suscripción
- **5** - SUBSCRIPTION_ON_HOLD - En hold por problema de pago
- **6** - SUBSCRIPTION_IN_GRACE_PERIOD - En grace period (7 días)
- **7** - SUBSCRIPTION_RESTARTED - Reiniciada
- **10** - SUBSCRIPTION_PAUSED - Pausada
- **12** - SUBSCRIPTION_REVOKED - Revocada (reembolso)
- **13** - SUBSCRIPTION_EXPIRED - Expirada

## 🔍 Verificación y Testing

### Probar Apple Webhooks

1. En App Store Connect, ve a tu app
2. Ve a **TestFlight** > **Sandbox Testers**
3. Crea un tester de sandbox
4. Realiza una compra de prueba en tu app
5. Verifica los logs en Supabase:
   ```bash
   # Ver logs de la función
   supabase functions logs apple-webhook --project-ref sztkpkplvzyltsdmdnsw
   ```

### Probar Google Webhooks

1. En Google Play Console, usa una cuenta de prueba
2. Realiza una compra de prueba
3. Verifica los logs en Supabase:
   ```bash
   # Ver logs de la función
   supabase functions logs google-webhook --project-ref sztkpkplvzyltsdmdnsw
   ```

### Ver logs en tiempo real

Puedes ver los logs de las funciones usando el MCP de Supabase o directamente en el dashboard:

```
https://supabase.com/dashboard/project/sztkpkplvzyltsdmdnsw/logs/edge-functions
```

## 📊 Monitoreo

### Campos actualizados en la base de datos

Cuando se recibe un webhook, se actualizan los siguientes campos en la tabla `subscriptions`:

- `is_active` - Estado activo/inactivo
- `cancellation_date` - Fecha de cancelación
- `grace_period_expires_at` - Fecha de expiración del grace period
- `is_auto_renew` - Si se renovará automáticamente
- `refund_date` - Fecha de reembolso
- `last_verified_at` - Última verificación
- `webhooks_received` - Historial de webhooks recibidos (JSONB)

### Consultar webhooks recibidos

```sql
SELECT 
  user_id,
  type,
  is_active,
  cancellation_date,
  grace_period_expires_at,
  webhooks_received,
  last_verified_at
FROM subscriptions
WHERE user_id = 'USER_ID_HERE'
ORDER BY updated_at DESC;
```

## ⚠️ Consideraciones de Seguridad

### Para Producción

1. **Verificar firma de Apple**: Implementar verificación de JWT con la clave pública de Apple
2. **Verificar origen de Google**: Validar que las peticiones vengan de Google Cloud Pub/Sub
3. **Rate limiting**: Implementar límites de tasa para prevenir abuso
4. **Logging**: Mantener logs detallados para debugging
5. **Alertas**: Configurar alertas para errores críticos

### Ejemplo de verificación de firma (Apple)

```typescript
// TODO: Implementar verificación de signedTransactionInfo
// Usar la clave pública de Apple para verificar el JWT
// https://developer.apple.com/documentation/appstoreserverapi/jwstransactiondecodedpayload
```

## 🔗 Referencias

- [Apple Server Notifications v2](https://developer.apple.com/documentation/appstoreservernotifications)
- [Google Play Real-time Developer Notifications](https://developer.android.com/google/play/billing/rtdn-reference)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

## 📝 Notas

- Los webhooks están configurados sin verificación de JWT (`verify_jwt: false`) para permitir peticiones de Apple/Google
- En producción, considera implementar verificación adicional de seguridad
- Los webhooks se procesan de forma asíncrona
- La base de datos se actualiza automáticamente cuando se recibe un webhook válido
