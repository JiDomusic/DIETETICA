-- ============================================================
-- DIETÉTICA CENTRO - SQL COMPLETO (todo junto)
-- Pegar en Supabase SQL Editor y dar RUN una sola vez
-- ============================================================

-- ===================== 1. TABLAS =====================

create table if not exists site_config (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  value text,
  updated_at timestamptz default now()
);

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

create table if not exists sections (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  subtitle text,
  description text,
  layout text default 'carousel',
  position int default 0,
  published boolean default true,
  bg_color text,
  text_color text,
  show_title boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

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

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  image_path text,
  position int default 0,
  active boolean default true
);

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

create table if not exists stock (
  product_id uuid references products(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  qty int not null default 0,
  min_qty int default 0,
  updated_at timestamptz default now(),
  primary key (product_id, location_id)
);

create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  location_id uuid references locations(id) on delete cascade,
  delta int not null,
  reason text,
  external_ref text,
  created_by uuid,
  created_at timestamptz default now()
);

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

create table if not exists gallery (
  id uuid primary key default gen_random_uuid(),
  title text,
  description text,
  image_path text not null,
  position int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

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

create table if not exists reservations (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete set null,
  location_id uuid references locations(id) on delete set null,
  qty int not null default 1,
  customer_name text not null,
  customer_phone text,
  customer_email text,
  payment_method text default 'cbu',
  payment_ref text,
  comprobante_path text,
  status text default 'pending',
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists navbar_items (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  url text,
  section_slug text,
  icon_name text,
  position int default 0,
  active boolean default true
);

create table if not exists admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin',
  created_at timestamptz default now(),
  created_by uuid
);

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

create table if not exists section_products (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references sections(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  position int default 0,
  unique(section_id, product_id)
);

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

-- ===================== 2. FUNCIÓN HELPER is_admin() =====================

create or replace function is_admin()
returns boolean as $$
begin
  return exists (
    select 1 from admin_roles
    where user_id = auth.uid()
    and role in ('admin', 'editor')
  );
end;
$$ language plpgsql security definer stable;

-- ===================== 3. RLS EN TODAS LAS TABLAS =====================

alter table site_config enable row level security;
create policy "public read site_config" on site_config for select using (true);
create policy "admin manage site_config" on site_config for all using (is_admin()) with check (is_admin());

alter table sections enable row level security;
create policy "public read published sections" on sections for select using (published = true);
create policy "admin read all sections" on sections for select using (is_admin());
create policy "admin insert sections" on sections for insert with check (is_admin());
create policy "admin update sections" on sections for update using (is_admin()) with check (is_admin());
create policy "admin delete sections" on sections for delete using (is_admin());

alter table banners enable row level security;
create policy "public read active banners" on banners for select using (active = true);
create policy "admin manage banners" on banners for all using (is_admin()) with check (is_admin());

alter table categories enable row level security;
create policy "public read active categories" on categories for select using (active = true);
create policy "admin manage categories" on categories for all using (is_admin()) with check (is_admin());

alter table products enable row level security;
create policy "public read active products" on products for select using (is_active = true);
create policy "admin read all products" on products for select using (is_admin());
create policy "admin insert products" on products for insert with check (is_admin());
create policy "admin update products" on products for update using (is_admin()) with check (is_admin());
create policy "admin delete products" on products for delete using (is_admin());

alter table locations enable row level security;
create policy "public read active locations" on locations for select using (active = true);
create policy "admin manage locations" on locations for all using (is_admin()) with check (is_admin());

alter table stock enable row level security;
create policy "public read stock" on stock for select using (true);
create policy "admin manage stock" on stock for all using (is_admin()) with check (is_admin());

alter table stock_movements enable row level security;
create policy "admin read stock_movements" on stock_movements for select using (is_admin());
create policy "admin insert stock_movements" on stock_movements for insert with check (is_admin());

alter table promos enable row level security;
create policy "public read active promos" on promos for select using (active = true);
create policy "admin manage promos" on promos for all using (is_admin()) with check (is_admin());

alter table gallery enable row level security;
create policy "public read active gallery" on gallery for select using (active = true);
create policy "admin manage gallery" on gallery for all using (is_admin()) with check (is_admin());

alter table videos enable row level security;
create policy "public read active videos" on videos for select using (active = true);
create policy "admin manage videos" on videos for all using (is_admin()) with check (is_admin());

alter table reservations enable row level security;
create policy "public insert reservations" on reservations for insert with check (true);
create policy "admin manage reservations" on reservations for all using (is_admin()) with check (is_admin());

alter table navbar_items enable row level security;
create policy "public read active navbar" on navbar_items for select using (active = true);
create policy "admin manage navbar" on navbar_items for all using (is_admin()) with check (is_admin());

alter table admin_roles enable row level security;
create policy "admin read roles" on admin_roles for select using (is_admin());
create policy "admin manage roles" on admin_roles for all using (is_admin()) with check (is_admin());

alter table onboarding_config enable row level security;
create policy "public read active onboarding" on onboarding_config for select using (active = true);
create policy "admin manage onboarding" on onboarding_config for all using (is_admin()) with check (is_admin());

alter table home_banners enable row level security;
create policy "public read active home_banners" on home_banners for select using (active = true);
create policy "admin manage home_banners" on home_banners for all using (is_admin()) with check (is_admin());

alter table section_products enable row level security;
create policy "public read section_products" on section_products for select using (true);
create policy "admin manage section_products" on section_products for all using (is_admin()) with check (is_admin());

alter table product_views enable row level security;
create policy "anyone insert product_views" on product_views for insert with check (true);
create policy "admin read product_views" on product_views for select using (is_admin());

alter table search_logs enable row level security;
create policy "anyone insert search_logs" on search_logs for insert with check (true);
create policy "admin read search_logs" on search_logs for select using (is_admin());

-- ===================== 4. FUNCIONES RPC =====================

create or replace function decrement_stock(
  p_product_id uuid, p_location_id uuid, p_qty int, p_reason text default 'sale'
) returns int as $$
declare new_qty int;
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  update stock set qty = qty - p_qty, updated_at = now()
  where product_id = p_product_id and location_id = p_location_id
  returning qty into new_qty;
  if new_qty is null then raise exception 'Producto/sucursal no encontrado en stock'; end if;
  if new_qty < 0 then
    update stock set qty = qty + p_qty where product_id = p_product_id and location_id = p_location_id;
    raise exception 'Stock insuficiente';
  end if;
  insert into stock_movements (product_id, location_id, delta, reason, created_by)
  values (p_product_id, p_location_id, -p_qty, p_reason, auth.uid());
  return new_qty;
end;
$$ language plpgsql security definer;

create or replace function increment_stock(
  p_product_id uuid, p_location_id uuid, p_qty int, p_reason text default 'manual_adjust'
) returns int as $$
declare new_qty int;
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  update stock set qty = qty + p_qty, updated_at = now()
  where product_id = p_product_id and location_id = p_location_id
  returning qty into new_qty;
  if new_qty is null then
    insert into stock (product_id, location_id, qty) values (p_product_id, p_location_id, p_qty)
    returning qty into new_qty;
  end if;
  insert into stock_movements (product_id, location_id, delta, reason, created_by)
  values (p_product_id, p_location_id, p_qty, p_reason, auth.uid());
  return new_qty;
end;
$$ language plpgsql security definer;

create or replace function set_stock(
  p_product_id uuid, p_location_id uuid, p_qty int
) returns int as $$
declare old_qty int; diff int;
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  select qty into old_qty from stock where product_id = p_product_id and location_id = p_location_id;
  if old_qty is null then
    insert into stock (product_id, location_id, qty) values (p_product_id, p_location_id, p_qty);
    diff := p_qty;
  else
    diff := p_qty - old_qty;
    update stock set qty = p_qty, updated_at = now() where product_id = p_product_id and location_id = p_location_id;
  end if;
  if diff != 0 then
    insert into stock_movements (product_id, location_id, delta, reason, created_by)
    values (p_product_id, p_location_id, diff, 'manual_adjust', auth.uid());
  end if;
  return p_qty;
end;
$$ language plpgsql security definer;

create or replace function create_reservation(
  p_product_id uuid, p_location_id uuid, p_qty int,
  p_customer_name text, p_customer_phone text,
  p_customer_email text default null, p_payment_ref text default null, p_notes text default null
) returns uuid as $$
declare v_reservation_id uuid; v_stock int;
begin
  select qty into v_stock from stock where product_id = p_product_id and location_id = p_location_id;
  if v_stock is null or v_stock < p_qty then raise exception 'Stock insuficiente para reservar'; end if;
  insert into reservations (product_id, location_id, qty, customer_name, customer_phone, customer_email, payment_ref, notes)
  values (p_product_id, p_location_id, p_qty, p_customer_name, p_customer_phone, p_customer_email, p_payment_ref, p_notes)
  returning id into v_reservation_id;
  update stock set qty = qty - p_qty, updated_at = now() where product_id = p_product_id and location_id = p_location_id;
  insert into stock_movements (product_id, location_id, delta, reason, external_ref)
  values (p_product_id, p_location_id, -p_qty, 'reservation', v_reservation_id::text);
  return v_reservation_id;
end;
$$ language plpgsql security definer;

create or replace function cancel_reservation(p_reservation_id uuid)
returns void as $$
declare v_rec record;
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  select * into v_rec from reservations where id = p_reservation_id;
  if v_rec is null then raise exception 'Reserva no encontrada'; end if;
  if v_rec.status = 'canceled' then raise exception 'Reserva ya cancelada'; end if;
  update stock set qty = qty + v_rec.qty, updated_at = now()
  where product_id = v_rec.product_id and location_id = v_rec.location_id;
  update reservations set status = 'canceled', updated_at = now() where id = p_reservation_id;
  insert into stock_movements (product_id, location_id, delta, reason, external_ref, created_by)
  values (v_rec.product_id, v_rec.location_id, v_rec.qty, 'reservation_cancel', p_reservation_id::text, auth.uid());
end;
$$ language plpgsql security definer;

create or replace function add_admin(p_user_id uuid, p_role text default 'admin')
returns void as $$
declare admin_count int;
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  select count(*) into admin_count from admin_roles;
  if admin_count >= 3 then raise exception 'Máximo 3 administradores permitidos'; end if;
  insert into admin_roles (user_id, role, created_by) values (p_user_id, p_role, auth.uid())
  on conflict (user_id) do update set role = p_role;
end;
$$ language plpgsql security definer;

create or replace function remove_admin(p_user_id uuid)
returns void as $$
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  if p_user_id = auth.uid() then raise exception 'No puedes eliminarte a ti mismo como admin'; end if;
  delete from admin_roles where user_id = p_user_id;
end;
$$ language plpgsql security definer;

create or replace function get_top_products(p_limit int default 10)
returns table(product_id uuid, product_name text, view_count bigint) as $$
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  return query
    select pv.product_id, p.name, count(*) as view_count
    from product_views pv join products p on p.id = pv.product_id
    group by pv.product_id, p.name order by view_count desc limit p_limit;
end;
$$ language plpgsql security definer stable;

create or replace function get_stock_movements_summary(
  p_location_id uuid default null, p_days int default 30
) returns table(product_id uuid, product_name text, total_sold bigint, total_returned bigint) as $$
begin
  if not is_admin() then raise exception 'No autorizado'; end if;
  return query
    select sm.product_id, p.name as product_name,
      coalesce(sum(case when sm.delta < 0 and sm.reason = 'sale' then abs(sm.delta) else 0 end), 0) as total_sold,
      coalesce(sum(case when sm.delta > 0 and sm.reason = 'return' then sm.delta else 0 end), 0) as total_returned
    from stock_movements sm join products p on p.id = sm.product_id
    where sm.created_at >= now() - (p_days || ' days')::interval
    and (p_location_id is null or sm.location_id = p_location_id)
    group by sm.product_id, p.name order by total_sold desc;
end;
$$ language plpgsql security definer stable;

create or replace function pos_sync_stock(
  p_sku text, p_location_id uuid, p_new_qty int, p_api_key text
) returns json as $$
declare v_product_id uuid; v_old_qty int; v_diff int; v_valid_key text;
begin
  select value into v_valid_key from site_config where key = 'pos_api_key';
  if v_valid_key is null or v_valid_key != p_api_key then raise exception 'API key inválida'; end if;
  select id into v_product_id from products where sku = p_sku;
  if v_product_id is null then raise exception 'SKU no encontrado: %', p_sku; end if;
  select qty into v_old_qty from stock where product_id = v_product_id and location_id = p_location_id;
  if v_old_qty is null then
    insert into stock (product_id, location_id, qty) values (v_product_id, p_location_id, p_new_qty);
    v_diff := p_new_qty;
  else
    v_diff := p_new_qty - v_old_qty;
    update stock set qty = p_new_qty, updated_at = now() where product_id = v_product_id and location_id = p_location_id;
  end if;
  insert into stock_movements (product_id, location_id, delta, reason, external_ref)
  values (v_product_id, p_location_id, v_diff, 'pos_sync', p_sku);
  return json_build_object('success', true, 'sku', p_sku, 'new_qty', p_new_qty, 'diff', v_diff);
end;
$$ language plpgsql security definer;

-- ===================== 5. STORAGE POLICIES =====================

create policy "public read images" on storage.objects for select using (bucket_id = 'images-dietetica');
create policy "admin upload images" on storage.objects for insert with check (bucket_id = 'images-dietetica' and auth.role() = 'authenticated' and is_admin());
create policy "admin update images" on storage.objects for update using (bucket_id = 'images-dietetica' and auth.role() = 'authenticated' and is_admin());
create policy "admin delete images" on storage.objects for delete using (bucket_id = 'images-dietetica' and auth.role() = 'authenticated' and is_admin());

-- ===================== 6. SEED: ADMIN + DATOS INICIALES =====================

INSERT INTO admin_roles (user_id, role) VALUES ('fc1bccf6-8618-44ca-a7b7-b54418fe6111', 'admin');

insert into sections (slug, title, subtitle, layout, position, published) values
  ('hero', 'Bienvenidos a Dietética Centro', 'Alimentos saludables para tu bienestar', 'banner', 0, true),
  ('promos', 'Promociones', 'Las mejores ofertas de la semana', 'carousel', 1, true),
  ('nuevos', 'Productos Nuevos', 'Recién llegados a nuestras góndolas', 'carousel', 2, true),
  ('categorias', 'Categorías', 'Explorá nuestros productos', 'grid', 3, true),
  ('destacados', 'Más Vendidos', 'Lo que más eligen nuestros clientes', 'netflix', 4, true),
  ('sucursales', 'Nuestras Sucursales', 'Encontranos en 3 ubicaciones', 'locations', 5, true),
  ('galeria', 'Galería', 'Nuestro local y productos', 'carousel', 6, true),
  ('videos', 'Videos', 'Recetas y consejos saludables', 'grid', 7, true),
  ('reservas', 'Reservá tu Producto', 'Reservá y pagá por CBU', 'custom', 8, true)
on conflict (slug) do nothing;

insert into categories (name, slug, position) values
  ('Frutos Secos', 'frutos-secos', 0),
  ('Cereales y Semillas', 'cereales-semillas', 1),
  ('Harinas y Legumbres', 'harinas-legumbres', 2),
  ('Suplementos', 'suplementos', 3),
  ('Snacks Saludables', 'snacks', 4),
  ('Bebidas Naturales', 'bebidas', 5),
  ('Cosmética Natural', 'cosmetica', 6),
  ('Sin TACC', 'sin-tacc', 7)
on conflict (slug) do nothing;

insert into navbar_items (label, section_slug, position) values
  ('Inicio', 'hero', 0),
  ('Promos', 'promos', 1),
  ('Productos', 'categorias', 2),
  ('Sucursales', 'sucursales', 3),
  ('Galería', 'galeria', 4),
  ('Reservar', 'reservas', 5);

-- ============================================================
-- FIN - Todo listo!
-- ============================================================
