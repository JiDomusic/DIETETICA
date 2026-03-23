-- ============================================================
-- RLS POLICIES - Dietética Centro
-- Lectura pública de contenido activo
-- Escritura SOLO para admins autenticados
-- ============================================================

-- ===================== HELPER: verificar si es admin =====================
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

-- ===================== SITE CONFIG =====================
alter table site_config enable row level security;

create policy "public read site_config"
  on site_config for select
  using (true);

create policy "admin manage site_config"
  on site_config for all
  using (is_admin())
  with check (is_admin());

-- ===================== SECTIONS =====================
alter table sections enable row level security;

create policy "public read published sections"
  on sections for select
  using (published = true);

create policy "admin read all sections"
  on sections for select
  using (is_admin());

create policy "admin manage sections"
  on sections for insert
  using (is_admin())
  with check (is_admin());

create policy "admin update sections"
  on sections for update
  using (is_admin())
  with check (is_admin());

create policy "admin delete sections"
  on sections for delete
  using (is_admin());

-- ===================== BANNERS =====================
alter table banners enable row level security;

create policy "public read active banners"
  on banners for select
  using (active = true);

create policy "admin manage banners"
  on banners for all
  using (is_admin())
  with check (is_admin());

-- ===================== CATEGORIES =====================
alter table categories enable row level security;

create policy "public read active categories"
  on categories for select
  using (active = true);

create policy "admin manage categories"
  on categories for all
  using (is_admin())
  with check (is_admin());

-- ===================== PRODUCTS =====================
alter table products enable row level security;

create policy "public read active products"
  on products for select
  using (is_active = true);

create policy "admin read all products"
  on products for select
  using (is_admin());

create policy "admin manage products"
  on products for insert
  using (is_admin())
  with check (is_admin());

create policy "admin update products"
  on products for update
  using (is_admin())
  with check (is_admin());

create policy "admin delete products"
  on products for delete
  using (is_admin());

-- ===================== LOCATIONS =====================
alter table locations enable row level security;

create policy "public read active locations"
  on locations for select
  using (active = true);

create policy "admin manage locations"
  on locations for all
  using (is_admin())
  with check (is_admin());

-- ===================== STOCK =====================
alter table stock enable row level security;

create policy "public read stock"
  on stock for select
  using (true);

create policy "admin manage stock"
  on stock for all
  using (is_admin())
  with check (is_admin());

-- ===================== STOCK MOVEMENTS =====================
alter table stock_movements enable row level security;

create policy "admin read stock_movements"
  on stock_movements for select
  using (is_admin());

create policy "admin manage stock_movements"
  on stock_movements for insert
  using (is_admin())
  with check (is_admin());

-- ===================== PROMOS =====================
alter table promos enable row level security;

create policy "public read active promos"
  on promos for select
  using (active = true);

create policy "admin manage promos"
  on promos for all
  using (is_admin())
  with check (is_admin());

-- ===================== GALLERY =====================
alter table gallery enable row level security;

create policy "public read active gallery"
  on gallery for select
  using (active = true);

create policy "admin manage gallery"
  on gallery for all
  using (is_admin())
  with check (is_admin());

-- ===================== VIDEOS =====================
alter table videos enable row level security;

create policy "public read active videos"
  on videos for select
  using (active = true);

create policy "admin manage videos"
  on videos for all
  using (is_admin())
  with check (is_admin());

-- ===================== RESERVATIONS =====================
alter table reservations enable row level security;

create policy "public insert reservations"
  on reservations for insert
  with check (true);

create policy "admin manage reservations"
  on reservations for all
  using (is_admin())
  with check (is_admin());

-- ===================== NAVBAR ITEMS =====================
alter table navbar_items enable row level security;

create policy "public read active navbar"
  on navbar_items for select
  using (active = true);

create policy "admin manage navbar"
  on navbar_items for all
  using (is_admin())
  with check (is_admin());

-- ===================== ADMIN ROLES =====================
alter table admin_roles enable row level security;

create policy "admin read roles"
  on admin_roles for select
  using (is_admin());

create policy "admin manage roles"
  on admin_roles for all
  using (is_admin())
  with check (is_admin());

-- ===================== ONBOARDING CONFIG =====================
alter table onboarding_config enable row level security;

create policy "public read active onboarding"
  on onboarding_config for select
  using (active = true);

create policy "admin manage onboarding"
  on onboarding_config for all
  using (is_admin())
  with check (is_admin());

-- ===================== HOME BANNERS =====================
alter table home_banners enable row level security;

create policy "public read active home_banners"
  on home_banners for select
  using (active = true);

create policy "admin manage home_banners"
  on home_banners for all
  using (is_admin())
  with check (is_admin());

-- ===================== SECTION PRODUCTS =====================
alter table section_products enable row level security;

create policy "public read section_products"
  on section_products for select
  using (true);

create policy "admin manage section_products"
  on section_products for all
  using (is_admin())
  with check (is_admin());

-- ===================== ANALYTICS =====================
alter table product_views enable row level security;

create policy "anyone insert product_views"
  on product_views for insert
  with check (true);

create policy "admin read product_views"
  on product_views for select
  using (is_admin());

alter table search_logs enable row level security;

create policy "anyone insert search_logs"
  on search_logs for insert
  with check (true);

create policy "admin read search_logs"
  on search_logs for select
  using (is_admin());
