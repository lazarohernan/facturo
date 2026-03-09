import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface FCMToken {
  id: string
  user_id: string
  fcm_token: string
  device_type: string
  device_name?: string
  created_at: string
  updated_at: string
  last_used_at: string
  is_active: boolean
}

interface NotificationPayload {
  title: string
  body: string
  data?: Record<string, string>
  image?: string
}

interface WeeklySummaryData {
  total_invoices: number
  total_amount: number
  total_expenses: number
  total_clients: number
  week_start: string
  week_end: string
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { method } = req
    
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    if (method === 'POST') {
      const { type, userIds, notification } = await req.json()

      if (!type || !notification) {
        return new Response(
          JSON.stringify({ error: 'Missing required fields: type, notification' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      let targetUsers: string[] = []

      if (type === 'weekly_summary') {
        // Get all users with weekly digest enabled
        const { data: users, error: usersError } = await supabase
          .from('user_settings')
          .select('user_id')
          .eq('weekly_digest_enabled', true)

        if (usersError) throw usersError
        targetUsers = users?.map(u => u.user_id) || []
      } else if (type === 'specific_users' && userIds) {
        targetUsers = userIds
      } else if (type === 'all_users') {
        // Get all active users
        const { data: users, error: usersError } = await supabase
          .from('user_settings')
          .select('user_id')
          .eq('push_enabled', true)

        if (usersError) throw usersError
        targetUsers = users?.map(u => u.user_id) || []
      }

      if (targetUsers.length === 0) {
        return new Response(
          JSON.stringify({ message: 'No target users found' }),
          { 
            status: 200, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      // Get FCM tokens for target users
      const { data: tokens, error: tokensError } = await supabase
        .from('fcm_tokens')
        .select('*')
        .in('user_id', targetUsers)
        .eq('is_active', true)

      if (tokensError) throw tokensError

      // Send notifications via Firebase
      const results = await sendFCMNotifications(tokens as FCMToken[], notification, supabase)

      return new Response(
        JSON.stringify({ 
          success: true, 
          sent: results.successful,
          failed: results.failed,
          total: tokens?.length || 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { 
        status: 405, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in send-notification function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function sendFCMNotifications(tokens: FCMToken[], notification: NotificationPayload, supabase: any) {
  const results = { successful: 0, failed: 0 }
  
  // Obtener access token para Firebase API v1
  const accessToken = await getFirebaseAccessToken();
  if (!accessToken) {
    console.error('No se pudo obtener access token de Firebase');
    tokens.forEach(() => results.failed++);
    return results;
  }

  for (const tokenData of tokens) {
    try {
      const fcmPayload = {
        message: {
          token: tokenData.fcm_token,
          notification: {
            title: notification.title,
            body: notification.body,
            imageUrl: notification.image
          },
          data: notification.data || {},
          android: {
            priority: 'HIGH',
            notification: {
              sound: 'default',
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
                'mutable-content': 1
              }
            }
          }
        }
      }

      // Usar Firebase Cloud Messaging API v1
      const projectId = Deno.env.get('FIREBASE_PROJECT_ID') || 'facturo-app-84a32';
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(fcmPayload)
        }
      )

      if (response.ok) {
        results.successful++
        console.log(`✅ Notificación enviada a token ${tokenData.id}`)
        
        // Guardar en historial de notificaciones
        await saveNotificationToHistory(supabase, {
          user_id: tokenData.user_id,
          title: notification.title,
          body: notification.body,
          data: notification.data || {},
          image_url: notification.image,
          notification_type: notification.data?.type || 'general'
        });
      } else {
        results.failed++
        const errorText = await response.text();
        console.error(`❌ FCM v1 failed for token ${tokenData.id}:`, errorText)
      }
    } catch (error) {
      results.failed++
      console.error(`❌ Error sending to token ${tokenData.id}:`, error)
    }
  }

  return results
}

// Guardar notificación en historial
async function saveNotificationToHistory(supabase: any, notificationData: any) {
  try {
    const { error } = await supabase
      .from('notifications_history')
      .insert({
        user_id: notificationData.user_id,
        title: notificationData.title,
        body: notificationData.body,
        data: notificationData.data,
        image_url: notificationData.image_url,
        notification_type: notificationData.notification_type,
        is_read: false
      });
    
    if (error) {
      console.error('Error guardando notificación en historial:', error);
    } else {
      console.log(`📝 Notificación guardada en historial para usuario ${notificationData.user_id}`);
    }
  } catch (error) {
    console.error('Error en saveNotificationToHistory:', error);
  }
}

// Obtener access token de Firebase usando OAuth 2.0
async function getFirebaseAccessToken(): Promise<string | null> {
  try {
    const serviceAccountKey = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_KEY');
    if (!serviceAccountKey) {
      console.error('FIREBASE_SERVICE_ACCOUNT_KEY no configurada');
      return null;
    }

    const serviceAccount = JSON.parse(serviceAccountKey);
    
    // Crear JWT para OAuth 2.0
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    };

    const now = Math.floor(Date.now() / 1000);
    const payload = {
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://www.googleapis.com/oauth2/v4/token',
      exp: now + 3600,
      iat: now
    };

    // Importar la clave privada
    const privateKey = serviceAccount.private_key;
    
    // Crear JWT usando Web Crypto API
    const jwt = await createManualJWT(header, payload, privateKey);
    
    // Obtener access token
    const tokenResponse = await fetch('https://www.googleapis.com/oauth2/v4/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt
      })
    });

    if (tokenResponse.ok) {
      const tokenData = await tokenResponse.json();
      return tokenData.access_token;
    } else {
      console.error('Error obteniendo access token:', await tokenResponse.text());
      return null;
    }
  } catch (error) {
    console.error('Error en getFirebaseAccessToken:', error);
    return null;
  }
}

// Función para crear JWT manualmente usando Web Crypto API
async function createManualJWT(header: any, payload: any, privateKey: string): Promise<string> {
  try {
    // Codificar header y payload
    const encoder = new TextEncoder();
    const headerB64 = base64UrlEncode(JSON.stringify(header));
    const payloadB64 = base64UrlEncode(JSON.stringify(payload));
    const message = `${headerB64}.${payloadB64}`;
    
    // Importar la clave privada PEM
    const pemHeader = '-----BEGIN PRIVATE KEY-----';
    const pemFooter = '-----END PRIVATE KEY-----';
    const pemContents = privateKey
      .replace(pemHeader, '')
      .replace(pemFooter, '')
      .replace(/\\n/g, '')
      .replace(/\s/g, '');
    
    // Decodificar base64 a ArrayBuffer
    const binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0));
    
    // Importar la clave
    const cryptoKey = await crypto.subtle.importKey(
      'pkcs8',
      binaryDer,
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256'
      },
      false,
      ['sign']
    );
    
    // Firmar el mensaje
    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      cryptoKey,
      encoder.encode(message)
    );
    
    // Codificar la firma
    const signatureB64 = base64UrlEncode(signature);
    
    return `${message}.${signatureB64}`;
  } catch (error) {
    console.error('Error creando JWT:', error);
    throw error;
  }
}

// Helper para codificar en base64url
function base64UrlEncode(data: string | ArrayBuffer): string {
  let base64: string;
  
  if (typeof data === 'string') {
    base64 = btoa(data);
  } else {
    const bytes = new Uint8Array(data);
    let binary = '';
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    base64 = btoa(binary);
  }
  
  return base64
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

// Helper function to generate weekly summary data
async function generateWeeklySummary(supabase: any, userId: string): Promise<WeeklySummaryData> {
  const now = new Date()
  const weekStart = new Date(now.setDate(now.getDate() - 7))
  const weekEnd = new Date()

  // Get invoices from last week
  const { data: invoices } = await supabase
    .from('invoices')
    .select('amount')
    .eq('user_id', userId)
    .gte('created_at', weekStart.toISOString())
    .lte('created_at', weekEnd.toISOString())

  // Get expenses from last week
  const { data: expenses } = await supabase
    .from('expenses')
    .select('amount')
    .eq('user_id', userId)
    .gte('created_at', weekStart.toISOString())
    .lte('created_at', weekEnd.toISOString())

  // Get clients count
  const { data: clients } = await supabase
    .from('clients')
    .select('id')
    .eq('user_id', userId)

  const totalInvoices = invoices?.length || 0
  const totalAmount = invoices?.reduce((sum, inv) => sum + (inv.amount || 0), 0) || 0
  const totalExpenses = expenses?.reduce((sum, exp) => sum + (exp.amount || 0), 0) || 0
  const totalClients = clients?.length || 0

  return {
    total_invoices: totalInvoices,
    total_amount: totalAmount,
    total_expenses: totalExpenses,
    total_clients: totalClients,
    week_start: weekStart.toISOString().split('T')[0],
    week_end: weekEnd.toISOString().split('T')[0]
  }
}
