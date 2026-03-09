-- Función COMPLETA para eliminar todos los datos de un usuario
-- Respeta el orden de foreign keys para evitar errores de constraint
CREATE OR REPLACE FUNCTION delete_user_data(target_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- 1. Primero eliminar tablas dependientes (hijas) antes que las padres
  
  -- Eliminar detalles de facturas (depende de invoices)
  DELETE FROM invoice_detail WHERE user_id = target_user_id;
  
  -- Eliminar detalles de cotizaciones (depende de estimates)
  DELETE FROM estimate_detail WHERE user_id = target_user_id;
  
  -- Eliminar escaneos OCR (depende de expenses)
  DELETE FROM ocr_scans WHERE user_id = target_user_id;
  
  -- 2. Eliminar tablas principales
  
  -- Eliminar facturas del usuario
  DELETE FROM invoices WHERE user_id = target_user_id;
  
  -- Eliminar cotizaciones del usuario
  DELETE FROM estimates WHERE user_id = target_user_id;
  
  -- Eliminar gastos del usuario
  DELETE FROM expenses WHERE user_id = target_user_id;
  
  -- Eliminar categorías de gastos del usuario
  DELETE FROM expenses_categories WHERE user_id = target_user_id;
  
  -- Eliminar clientes del usuario
  DELETE FROM clients WHERE user_id = target_user_id;
  
  -- 3. Eliminar tablas de configuración y tracking
  
  -- Eliminar información de negocio del usuario
  DELETE FROM business_info WHERE user_id = target_user_id;
  
  -- Eliminar perfil del usuario
  DELETE FROM user_profiles WHERE id = target_user_id;
  
  -- Eliminar suscripciones del usuario
  DELETE FROM subscriptions WHERE user_id = target_user_id;
  
  -- Eliminar tokens FCM del usuario
  DELETE FROM fcm_tokens WHERE user_id = target_user_id;
  
  -- Eliminar tracking de usuario anónimo
  DELETE FROM anonymous_user_tracking WHERE user_id = target_user_id;
  
  -- Eliminar configuración de notificaciones
  DELETE FROM user_notification_settings WHERE user_id = target_user_id;
  
  -- Eliminar historial de notificaciones
  DELETE FROM notifications_history WHERE user_id = target_user_id;
  
  -- Eliminar solicitudes de soporte
  DELETE FROM support_requests WHERE user_id = target_user_id;
  
  -- Eliminar logs de consentimiento
  DELETE FROM user_consent_logs WHERE user_id = target_user_id;
  
  RAISE NOTICE 'All data deleted for user: %', target_user_id;
END;
$$;

-- Función para eliminar la cuenta de autenticación del usuario actual
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_user_id UUID;
BEGIN
  -- Obtener el ID del usuario actual
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'No authenticated user found';
  END IF;
  
  -- Eliminar el usuario de auth.users
  DELETE FROM auth.users WHERE id = current_user_id;
  
  RAISE NOTICE 'User account deleted: %', current_user_id;
END;
$$;

-- Otorgar permisos de ejecución a usuarios autenticados
GRANT EXECUTE ON FUNCTION delete_user_data(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_user_account() TO authenticated;

-- Nota: Esta función elimina datos de las siguientes 17 tablas:
-- 1. invoice_detail (detalles de facturas)
-- 2. estimate_detail (detalles de cotizaciones)
-- 3. ocr_scans (escaneos OCR)
-- 4. invoices (facturas)
-- 5. estimates (cotizaciones)
-- 6. expenses (gastos)
-- 7. expenses_categories (categorías de gastos)
-- 8. clients (clientes)
-- 9. business_info (información del negocio)
-- 10. user_profiles (perfil del usuario)
-- 11. subscriptions (suscripciones)
-- 12. fcm_tokens (tokens de notificaciones)
-- 13. anonymous_user_tracking (tracking de usuarios anónimos)
-- 14. user_notification_settings (configuración de notificaciones)
-- 15. notifications_history (historial de notificaciones)
-- 16. support_requests (solicitudes de soporte)
-- 17. user_consent_logs (logs de consentimiento)
