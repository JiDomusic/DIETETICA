#!/bin/bash
# ============================================================
# BUILD DE PRODUCCIÓN - Dietética Centro
# Las claves se inyectan via --dart-define, NO en el código
# ============================================================

set -e

echo "🌿 Construyendo Dietética Centro..."

# Las credenciales se leen de variables de entorno.
# Configurá antes de ejecutar:
#   export SUPABASE_URL="https://tu-proyecto.supabase.co"
#   export SUPABASE_ANON_KEY="tu-anon-key-aqui"
# O crealas en un archivo .env (NO commitear):
#   source .env
if [ -f .env ]; then
  source .env
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "ERROR: Definí SUPABASE_URL y SUPABASE_ANON_KEY como variables de entorno"
  echo "  export SUPABASE_URL=\"https://tu-proyecto.supabase.co\""
  echo "  export SUPABASE_ANON_KEY=\"tu-anon-key\""
  exit 1
fi

flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "✅ Build completado. Desplegando a Firebase..."
firebase deploy --only hosting

echo "🚀 ¡Desplegado exitosamente!"
echo "   https://dietetica-centro.web.app/"
