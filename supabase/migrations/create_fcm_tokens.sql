-- Tabla para almacenar tokens FCM de usuarios
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_type TEXT NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
  device_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  
  -- Índices para búsqueda rápida
  UNIQUE(user_id, fcm_token)
);

-- Índices para búsquedas por usuario
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_active ON fcm_tokens(is_active) WHERE is_active = true;

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.last_used_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar timestamps
CREATE TRIGGER fcm_tokens_updated_at
    BEFORE UPDATE ON fcm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_fcm_tokens_updated_at();

-- RLS (Row Level Security)
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo vean sus propios tokens
CREATE POLICY "Users can view their own FCM tokens"
    ON fcm_tokens FOR SELECT
    USING (auth.uid() = user_id);

-- Política para que los usuarios solo inserten sus propios tokens
CREATE POLICY "Users can insert their own FCM tokens"
    ON fcm_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios solo actualicen sus propios tokens
CREATE POLICY "Users can update their own FCM tokens"
    ON fcm_tokens FOR UPDATE
    USING (auth.uid() = user_id);

-- Política para que los usuarios solo eliminen sus propios tokens
CREATE POLICY "Users can delete their own FCM tokens"
    ON fcm_tokens FOR DELETE
    USING (auth.uid() = user_id);

-- Política para que las funciones pueden acceder a todos los tokens
CREATE POLICY "Service functions can access all FCM tokens"
    ON fcm_tokens FOR ALL
    USING (
        auth.uid() IS NULL OR 
        auth.jwt() ->> 'role' = 'service_role'
    );
