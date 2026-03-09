-- Agregar campos para tracking avanzado de suscripciones
ALTER TABLE user_subscriptions
ADD COLUMN IF NOT EXISTS subscription_type TEXT DEFAULT 'monthly' CHECK (subscription_type IN ('monthly', 'annual')),
ADD COLUMN IF NOT EXISTS purchase_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS cancellation_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS grace_period_expires_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS is_auto_renew BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS refund_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_verified_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS webhooks_received JSONB DEFAULT '{}';

-- Crear índices para los nuevos campos
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_type ON user_subscriptions(subscription_type);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_expires_at ON user_subscriptions(expires_at);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_cancellation ON user_subscriptions(cancellation_date) WHERE cancellation_date IS NOT NULL;

-- Agregar comentario a la tabla
COMMENT ON TABLE user_subscriptions IS 'Tabla para tracking de suscripciones con soporte para cancelaciones, grace periods y reembolsos';
