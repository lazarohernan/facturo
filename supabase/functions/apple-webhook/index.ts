import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

interface AppleNotification {
  notificationType: string;
  subtype?: string;
  data: {
    signedTransactionInfo?: string;
    signedRenewalInfo?: string;
  };
}

Deno.serve(async (req: Request) => {
  try {
    // Verificar que sea POST
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const notification: AppleNotification = await req.json();

    console.log('📱 Apple Webhook received:', notification.notificationType);

    const notificationType = notification.notificationType;
    const subtype = notification.subtype;

    // Decodificar el JWT de Apple
    // NOTA: Para máxima seguridad en producción, deberías verificar la firma JWT
    // usando las claves públicas de Apple disponibles en:
    // https://api.storekit.itunes.apple.com/v1/verifyReceipt
    // 
    // Para implementación completa con verificación de firma, considera usar:
    // - @apple/app-store-server-library (oficial de Apple)
    // - o implementar verificación manual con crypto.subtle.verify()
    let transactionId: string | null = null;
    let originalTransactionId: string | null = null;
    let expiresDate: number | null = null;
    let productId: string | null = null;
    
    if (notification.data?.signedTransactionInfo) {
      try {
        // Decodificar JWT (parte del payload)
        const parts = notification.data.signedTransactionInfo.split('.');
        if (parts.length === 3) {
          const payload = JSON.parse(atob(parts[1]));
          transactionId = payload.transactionId;
          originalTransactionId = payload.originalTransactionId;
          expiresDate = payload.expiresDate;
          productId = payload.productId;
          
          console.log('🔑 Transaction ID:', transactionId);
          console.log('🔑 Original Transaction ID:', originalTransactionId);
          console.log('🔑 Product ID:', productId);
          console.log('🔑 Expires Date:', expiresDate ? new Date(expiresDate).toISOString() : 'N/A');
          
          // Validación básica del payload
          if (!transactionId || !originalTransactionId) {
            console.error('❌ Invalid JWT payload: missing required fields');
            return new Response(
              JSON.stringify({ error: 'Invalid JWT payload' }),
              { status: 400, headers: { 'Content-Type': 'application/json' } }
            );
          }
        }
      } catch (e) {
        console.error('❌ Error decoding JWT:', e);
        return new Response(
          JSON.stringify({ error: 'Invalid JWT format' }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        );
      }
    }

    // Si no tenemos transaction_id, no podemos actualizar
    if (!transactionId && !originalTransactionId) {
      console.log('⚠️ No transaction ID found, skipping database update');
      return new Response(
        JSON.stringify({ success: true, message: 'No transaction ID' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    let updateData: any = {
      last_verified_at: new Date().toISOString(),
    };
    
    // Si tenemos expiresDate del JWT, actualizar expiry_date
    if (expiresDate) {
      updateData.expiry_date = new Date(expiresDate).toISOString();
    }
    
    // Si tenemos productId, guardarlo
    if (productId) {
      updateData.product_id = productId;
    }

    // Manejar diferentes tipos de notificaciones
    switch (notificationType) {
      case 'EXPIRED':
        // Suscripción expirada
        updateData.is_active = false;
        if (subtype === 'VOLUNTARY') {
          // Usuario canceló voluntariamente
          updateData.cancellation_date = new Date().toISOString();
          updateData.is_auto_renew = false;
        } else if (subtype === 'BILLING_RETRY') {
          // Problema de pago - marcar grace period
          updateData.grace_period_expires_at = new Date(Date.now() + 16 * 24 * 60 * 60 * 1000).toISOString(); // 16 días
        }
        console.log('⌛️ Subscription expired:', subtype);
        break;

      case 'DID_CHANGE_RENEWAL_STATUS':
        // Usuario cambió el estado de auto-renovación
        if (subtype === 'AUTO_RENEW_DISABLED') {
          updateData.is_auto_renew = false;
          updateData.cancellation_date = new Date().toISOString();
          console.log('🔄 Auto-renew disabled');
        } else if (subtype === 'AUTO_RENEW_ENABLED') {
          updateData.is_auto_renew = true;
          updateData.cancellation_date = null;
          console.log('✅ Auto-renew enabled');
        }
        break;

      case 'REFUND':
        // Reembolso procesado
        updateData.is_active = false;
        updateData.refund_date = new Date().toISOString();
        console.log('💰 Refund processed');
        break;

      case 'REVOKE':
        // Revocación (Family Sharing)
        updateData.is_active = false;
        console.log('🚫 Subscription revoked');
        break;

      case 'DID_FAIL_TO_RENEW':
        // Fallo en renovación - iniciar grace period
        updateData.grace_period_expires_at = new Date(Date.now() + 16 * 24 * 60 * 60 * 1000).toISOString();
        console.log('⚠️ Failed to renew - grace period started');
        break;

      case 'DID_RENEW':
        // Renovación exitosa
        updateData.is_active = true;
        updateData.grace_period_expires_at = null;
        updateData.cancellation_date = null;
        console.log('✅ Subscription renewed');
        break;

      default:
        console.log('ℹ️ Unhandled notification type:', notificationType);
    }

    // Actualizar la base de datos
    console.log('📊 Update data:', updateData);
    
    try {
      // Buscar la suscripción por transaction_id
      const { data: subscriptions, error: fetchError } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('transaction_id', originalTransactionId || transactionId)
        .limit(1);

      if (fetchError) {
        console.error('❌ Error fetching subscription:', fetchError);
        throw fetchError;
      }

      if (!subscriptions || subscriptions.length === 0) {
        console.log('⚠️ No subscription found for transaction_id:', originalTransactionId || transactionId);
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'No subscription found',
            transaction_id: originalTransactionId || transactionId
          }),
          {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
          }
        );
      }

      const subscription = subscriptions[0];
      console.log('📋 Found subscription for user:', subscription.user_id);

      // Actualizar la suscripción
      const { error: updateError } = await supabase
        .from('subscriptions')
        .update(updateData)
        .eq('id', subscription.id);

      if (updateError) {
        console.error('❌ Error updating subscription:', updateError);
        throw updateError;
      }

      console.log('✅ Subscription updated successfully');

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Webhook processed and database updated',
          type: notificationType,
          subtype: subtype,
          subscription_id: subscription.id
        }),
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    } catch (dbError) {
      console.error('❌ Database error:', dbError);
      // Aún así retornar 200 para que Apple no reintente
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'Database error but webhook received',
          error: dbError.message 
        }),
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

  } catch (error) {
    console.error('❌ Error processing Apple webhook:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
});
