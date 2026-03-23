#!/bin/bash
# ============================================================
# BUILD DE PRODUCCIÓN - Dietética Centro
# Las claves se inyectan via --dart-define, NO en el código
# ============================================================

set -e

echo "🌿 Construyendo Dietética Centro..."

# Verificar que las variables estén definidas
SUPABASE_URL="https://cupvpsysisybfyexnrtt.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1cHZwc3lzaXN5YmZ5ZXhucnR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODg1MjQsImV4cCI6MjA4OTg2NDUyNH0.VN8Hf4tNTiIMhtTI2tuobG-AsP7Iw_9lMvRaAzXAFt4"

flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "✅ Build completado. Desplegando a Firebase..."
firebase deploy --only hosting

echo "🚀 ¡Desplegado exitosamente!"
echo "   https://dietetica-centro.web.app/"
