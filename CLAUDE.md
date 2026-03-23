# Dietética Centro - Flutter Web

## Arquitectura
- **Flutter Web** + **Supabase** (Auth, DB, Storage) + **Firebase Hosting**
- Estado: StatefulWidget + setState (sin Provider/Riverpod)
- Bucket de imágenes: `images-dietetica` (lectura pública, escritura solo admin)

## Seguridad
- Claves inyectadas via `--dart-define` en `build_prod.sh`, NUNCA en código fuente
- RLS habilitado en TODAS las tablas
- Solo admins (máx 3) pueden escribir/editar/eliminar
- Storage: solo admin autenticado sube/edita/elimina imágenes
- Función `is_admin()` como SECURITY DEFINER verifica rol
- Sin service_role_key en el frontend

## Build & Deploy
```bash
# SIEMPRE usar:
bash build_prod.sh
# NUNCA: flutter build web --release (sin dart-define)
```

## Supabase
- URL: inyectada via dart-define
- Auth: Supabase Auth (email/password)
- Admin principal: programacionjjj@gmail.com
- UUID admin: fc1bccf6-8618-44ca-a7b7-b54418fe6111

## Firebase
- Proyecto: dietetica-centro
- Hosting: https://dietetica-centro.web.app/

## Estructura
```
lib/
├── config/app_config.dart          # Config centralizada
├── main.dart                       # Entry point + theme
├── services/supabase_service.dart  # Todo CRUD Supabase
├── screens/
│   ├── splash_screen.dart
│   ├── public/home_screen.dart     # Home público
│   └── admin/
│       ├── admin_login_screen.dart
│       ├── admin_dashboard_screen.dart
│       └── tabs/                   # 10 tabs del admin
├── widgets/
│   ├── admin_helpers.dart          # ImagePicker, confirmDialog, snackbar
│   ├── hero_banner.dart
│   ├── product_carousel.dart
│   ├── promo_carousel.dart
│   ├── netflix_section.dart
│   ├── category_grid.dart
│   ├── locations_section.dart
│   ├── gallery_carousel.dart
│   ├── video_grid.dart
│   ├── reservation_section.dart
│   └── whatsapp_fab.dart
sql/
├── 001_tables.sql                  # Todas las tablas
├── 002_rls_policies.sql            # RLS + is_admin()
├── 003_functions.sql               # RPCs (stock, reservas, analytics)
├── 004_storage_policies.sql        # Bucket policies
└── 005_seed_admin.sql              # Admin + datos iniciales
```

## Convenciones
- Variables/métodos en español para lógica de negocio
- Inglés para código técnico
- Todos los avisos de éxito/error via SnackBar
- Imágenes: solo JPG/PNG, máx 5MB
