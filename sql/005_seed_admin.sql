-- ============================================================
-- SEED: Admin principal + secciones iniciales
-- Ejecutar DESPUÉS de crear el usuario en Supabase Auth
-- ============================================================

-- Admin principal ya creado en Supabase Auth
INSERT INTO admin_roles (user_id, role) VALUES ('fc1bccf6-8618-44ca-a7b7-b54418fe6111', 'admin');

-- ===================== SECCIONES INICIALES DEL HOME =====================
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

-- ===================== CATEGORÍAS EJEMPLO =====================
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

-- ===================== NAVBAR ITEMS INICIALES =====================
insert into navbar_items (label, section_slug, position) values
  ('Inicio', 'hero', 0),
  ('Promos', 'promos', 1),
  ('Productos', 'categorias', 2),
  ('Sucursales', 'sucursales', 3),
  ('Galería', 'galeria', 4),
  ('Reservar', 'reservas', 5);
