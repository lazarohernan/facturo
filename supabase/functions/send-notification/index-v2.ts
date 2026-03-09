import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { jwt } from 'https://deno.land/x/djwt@v3/mod.ts'

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
          .from('user_notification_settings')
          .select('user_id')
          .eq('weekly_digest_enabled', true)

        if (usersError) throw usersError
        targetUsers = users?.map(u => u.user_id) || []
      } else if (type === 'specific_users' && userIds) {
        targetUsers = userIds
      } else if (type === 'all_users') {
        // Get all active users
        const { data: users, error: usersError } = await supabase
          .from('user_notification_settings')
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
      const results = await sendFCMNotifications(tokens as FCMToken[], notification)

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

async function sendFCMNotifications(tokens: FCMToken[], notification: NotificationPayload) {
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

    // Crear JWT usando la librería djwt
    const privateKey = serviceAccount.private_key;
    const jwtToken = await jwt.create(header, payload, privateKey);
    
    // Obtener access token
    const tokenResponse = await fetch('https://www.googleapis.com/oauth2/v4/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwtToken
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
