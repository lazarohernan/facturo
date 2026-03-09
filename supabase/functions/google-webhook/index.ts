import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

interface GoogleNotification {
  message: {
    data: string;
    messageId: string;
    publishTime: string;
  };
  subscription: string;
}

interface GoogleNotificationData {
  version: string;
  packageName: string;
  eventTimeMillis: string;
  subscriptionNotification?: {
    version: string;
    notificationType: number;
    purchaseToken: string;
    subscriptionId: string;
  };
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const notification: GoogleNotification = await req.json();

    const decodedData = atob(notification.message.data);
    const data: GoogleNotificationData = JSON.parse(decodedData);

    console.log('🤖 Google Webhook received:', data);

    const subscriptionNotification = data.subscriptionNotification;
    if (!subscriptionNotification) {
      console.log('⚠️ No subscription notification in payload');
      return new Response(JSON.stringify({ success: true, message: 'No subscription data' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const notificationType = subscriptionNotification.notificationType;
    const purchaseToken = subscriptionNotification.purchaseToken;
    const subscriptionId = subscriptionNotification.subscriptionId;

    console.log('🔑 Purchase Token:', purchaseToken);
    console.log('📝 Subscription ID:', subscriptionId);
    console.log('📢 Notification Type:', notificationType);

    let updateData: any = {
      last_verified_at: new Date().toISOString(),
    };

    switch (notificationType) {
      case 1: // SUBSCRIPTION_RECOVERED
        updateData.is_active = true;
        updateData.grace_period_expires_at = null;
        console.log('✅ Subscription recovered');
        break;
      case 2: // SUBSCRIPTION_RENEWED
        updateData.is_active = true;
        updateData.grace_period_expires_at = null;
        updateData.cancellation_date = null;
        console.log('✅ Subscription renewed');
        break;
      case 3: // SUBSCRIPTION_CANCELED
        updateData.is_auto_renew = false;
        updateData.cancellation_date = new Date().toISOString();
        console.log('🔄 Subscription canceled (still active until expiry)');
        break;
      case 4: // SUBSCRIPTION_PURCHASED
        updateData.is_active = true;
        updateData.is_auto_renew = true;
        console.log('🎉 New subscription purchased');
        break;
      case 5: // SUBSCRIPTION_ON_HOLD
        updateData.is_active = false;
        console.log('⏸️ Subscription on hold');
        break;
      case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
        updateData.grace_period_expires_at = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
        console.log('⚠️ Subscription in grace period (7 days)');
        break;
      case 7: // SUBSCRIPTION_RESTARTED
        updateData.is_active = true;
        updateData.is_auto_renew = true;
        updateData.cancellation_date = null;
        console.log('🔄 Subscription restarted');
        break;
      case 10: // SUBSCRIPTION_PAUSED
        updateData.is_active = false;
        console.log('⏸️ Subscription paused');
        break;
      case 12: // SUBSCRIPTION_REVOKED
        updateData.is_active = false;
        updateData.refund_date = new Date().toISOString();
        console.log('💰 Subscription revoked (refund)');
        break;
      case 13: // SUBSCRIPTION_EXPIRED
        updateData.is_active = false;
        console.log('⌛️ Subscription expired');
        break;
      default:
        console.log('ℹ️ Unhandled notification type:', notificationType);
    }

    console.log('📊 Update data:', updateData);

    try {
      const { data: subscriptions, error: fetchError } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('transaction_id', purchaseToken)
        .limit(1);

      if (fetchError) {
        console.error('❌ Error fetching subscription:', fetchError);
        throw fetchError;
      }

      if (!subscriptions || subscriptions.length === 0) {
        console.log('⚠️ No subscription found for purchaseToken, trying by product_id...');
        
        const { data: subsByProduct, error: productError } = await supabase
          .from('subscriptions')
          .select('*')
          .eq('product_id', subscriptionId)
          .eq('platform', 'android')
          .eq('is_active', true)
          .order('created_at', { ascending: false })
          .limit(1);

        if (productError || !subsByProduct || subsByProduct.length === 0) {
          console.log('⚠️ No subscription found for:', { purchaseToken, subscriptionId });
          return new Response(
            JSON.stringify({ 
              success: true, 
              message: 'No subscription found',
              purchase_token: purchaseToken,
              subscription_id: subscriptionId
            }),
            { status: 200, headers: { 'Content-Type': 'application/json' } }
          );
        }

        const subscription = subsByProduct[0];
        console.log('📋 Found subscription by product_id for user:', subscription.user_id);

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
            subscription_id: subscription.id
          }),
          { status: 200, headers: { 'Content-Type': 'application/json' } }
        );
      }

      const subscription = subscriptions[0];
      console.log('📋 Found subscription for user:', subscription.user_id);

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
          subscription_id: subscription.id
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      );

    } catch (dbError: any) {
      console.error('❌ Database error:', dbError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'Database error but webhook received',
          error: dbError?.message || 'Unknown error'
        }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      );
    }

  } catch (error: any) {
    console.error('❌ Error processing Google webhook:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error?.message || 'Unknown error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});
