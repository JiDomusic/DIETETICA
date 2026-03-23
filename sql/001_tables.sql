-- ============================================================
-- DIETÉTICA CENTRO - Esquema completo de base de datos
-- Supabase PostgreSQL
-- ============================================================

-- ===================== CONFIGURACIÓN GLOBAL =====================
create table if not exists site_config (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  value text,
  updated_at timestamptz default now()
);

-- Insertar configuraciones por defecto
insert into site_config (key, value) values
  ('site_name', 'Dietética Centro'),
  ('logo_path', ''),
  ('favicon_path', ''),
  ('whatsapp_default', ''),
  ('primary_color', '#2E7D32'),
  ('secondary_color', '#FF8F00'),
  ('accent_color', '#1B5E20'),
  ('footer_text', '© 2026 Dietética Centro'),
  ('meta_description', 'Tienda de alimentos saludables'),
  ('cbu_info', ''),
  ('alias_cbu', ''),
  ('instagram_url', ''),
  ('facebook_url', ''),
  ('email_contacto', ''),
  ('horario_atencion', 'Lunes a Sábado 9:00 - 20:00')
on conflict (key) do nothing;

-- ===================== SECCIONES DEL HOME =====================
create table if not exists sections (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  subtitle text,
  description text,
  layout text default 'carousel',  -- carousel, grid, netflix, banner, locations, promo, stock, custom
  position int default 0,
  published boolean default true,
  bg_color text,
  text_color text,
  show_title boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ===================== BANNERS =====================
create table if not exists banners (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references sections(id) on delete cascade,
  title text,
  subtitle text,
  cta_label text,
  cta_url text,
  image_path text,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

-- ===================== CATEGORÍAS =====================
create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  image_path text,
  position int default 0,
  active boolean default true
);

-- ===================== PRODUCTOS =====================
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  sku text unique not null,
  name text not null,
  description text,
  category_id uuid references categories(id) on delete set null,
  price numeric(12,2) not null default 0,
  currency text default 'ARS',
  image_path text,
  is_promo boolean default false,
  is_new boolean default false,
  is_featured boolean default false,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ===================== SUCURSALES / UBICACIONES =====================
create table if not exists locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  whatsapp text,
  map_url text,
  image_path text,
  horario text,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

-- ===================== STOCK (por producto + sucursal) =====================
create table if not exists stock (
  product_id uuid references products(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  qty int not null default 0,
  min_qty int default 0,
  updated_at timestamptz default now(),
  primary key (product_id, location_id)
);

-- ===================== MOVIMIENTOS DE STOCK =====================
create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  delta int not null,
  reason text, -- sale, return, manual_adjust, pos_sync, reservation
  external_ref text,
  created_by uuid,
  created_at timestamptz default now()
);

-- ===================== PROMOCIONES =====================
create table if not exists promos (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  title text,
  promo_text text,
  discount_pct numeric(5,2),
  promo_price numeric(12,2),
  start_at timestamptz,
  end_at timestamptz,
  active boolean default true,
  position int default 0,
  created_at timestamptz default now()
);

-- ===================== GALERÍA =====================
create table if not exists gallery (
  id uuid primary key default gen_random_uuid(),
  title text,
  description text,
  image_path text not null,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

-- ===================== VIDEOS =====================
create table if not exists videos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  video_url text not null,
  thumbnail_path text,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

-- ===================== RESERVAS DE PRODUCTOS =====================
create table if not exists reservations (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete set null,
  location_id uuid references locations(id) on delete set null,
  qty int not null default 1,
  customer_name text not null,
  customer_phone text,
  customer_email text,
  payment_method text default 'cbu', -- cbu, efectivo
  payment_ref text,
  comprobante_path text,
  status text default 'pending', -- pending, confirmed, paid, picked_up, canceled
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ===================== BARRA HORIZONTAL DEL HOME =====================
create table if not exists navbar_items (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  url text,
  section_slug text,
  icon_name text,
  position int default 0,
  active boolean default true
);

-- ===================== ADMINS (metadata en auth.users) =====================
-- No se crea tabla aparte; se usa raw_user_meta_data->>'role' = 'admin'
-- El admin principal es programacionjjj@gmail.com
-- Puede agregar hasta 2 co-admins

create table if not exists admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin', -- admin, editor
  created_at timestamptz default now(),
  created_by uuid
);

-- ===================== ONBOARDING =====================
create table if not exists onboarding_config (
  id uuid primary key default gen_random_uuid(),
  step_number int not null,
  title text not null,
  description text,
  image_path text,
  icon_name text,
  position int default 0,
  active boolean default true
);

-- ===================== BANNERS OPCIONALES DEL HOME =====================
create table if not exists home_banners (
  id uuid primary key default gen_random_uuid(),
  title text,
  subtitle text,
  image_path text,
  link_url text,
  position int default 0,
  active boolean default true,
  show_from timestamptz,
  show_until timestamptz,
  created_at timestamptz default now()
);

-- ===================== PRODUCTOS EN SECCIÓN (muchos a muchos) =====================
create table if not exists section_products (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references sections(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  position int default 0,
  unique(section_id, product_id)
);

-- ===================== ANALYTICS BÁSICO =====================
create table if not exists product_views (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  viewed_at timestamptz default now()
);

create table if not exists search_logs (
  id uuid primary key default gen_random_uuid(),
  query text not null,
  results_count int default 0,
  created_at timestamptz default now()
);
