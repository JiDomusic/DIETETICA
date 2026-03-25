-- ============================================================
-- DATOS DEMO - Cúrcuma - Tienda Natural
-- CON IMÁGENES de Unsplash (fotos gratuitas)
-- Todos los SKU comienzan con 'DEMO-' para fácil identificación
-- ============================================================

-- ===================== SUCURSALES DEMO =====================
INSERT INTO locations (id, name, address, phone, whatsapp, horario, position, active, image_path) VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Sucursal Centro', 'Av. San Martín 1234, Centro', '0341-4567890', '5493414567890', 'Lun a Sáb 9:00 - 20:00', 0, true, 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=600&h=400&fit=crop'),
  ('d0000000-0000-0000-0000-000000000002', 'Sucursal Norte', 'Bv. Oroño 5678, Zona Norte', '0341-4561234', '5493414561234', 'Lun a Vie 9:00 - 19:00', 1, true, 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=400&fit=crop')
ON CONFLICT DO NOTHING;

-- ===================== PRODUCTOS DEMO =====================
-- Frutos Secos
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'DEMO-FS-001', 'Almendras Tostadas x 250g', 'Almendras crocantes tostadas sin sal. Ideales para snack o repostería. Fuente natural de vitamina E y fibra.', (SELECT id FROM categories WHERE slug='frutos-secos'), 3200.00, 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400&h=400&fit=crop', false, true, true, true),
  ('d1000000-0000-0000-0000-000000000002', 'DEMO-FS-002', 'Nueces Mariposa x 250g', 'Nueces peladas premium. Ricas en Omega 3 y antioxidantes. Perfectas para ensaladas y postres.', (SELECT id FROM categories WHERE slug='frutos-secos'), 4100.00, 'https://images.unsplash.com/photo-1563635529912-2be6e4832982?w=400&h=400&fit=crop', false, false, true, true),
  ('d1000000-0000-0000-0000-000000000003', 'DEMO-FS-003', 'Castañas de Cajú x 200g', 'Cajú entero natural sin sal. Fuente de magnesio y hierro. Snack premium.', (SELECT id FROM categories WHERE slug='frutos-secos'), 3800.00, 'https://images.unsplash.com/photo-1599599810694-b5b37304c041?w=400&h=400&fit=crop', true, false, false, true),
  ('d1000000-0000-0000-0000-000000000004', 'DEMO-FS-004', 'Mix Energético x 300g', 'Mezcla de almendras, nueces, pasas y arándanos. Ideal para llevar al trabajo o al gym.', (SELECT id FROM categories WHERE slug='frutos-secos'), 3500.00, 'https://images.unsplash.com/photo-1571750707292-e3e3c0123c5a?w=400&h=400&fit=crop', false, true, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Cereales y Semillas
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000005', 'DEMO-CS-001', 'Granola Artesanal con Miel x 400g', 'Granola casera con avena, miel, coco rallado y semillas. Sin conservantes ni colorantes.', (SELECT id FROM categories WHERE slug='cereales-semillas'), 2800.00, 'https://images.unsplash.com/photo-1517093728432-a0440f8d45af?w=400&h=400&fit=crop', false, true, true, true),
  ('d1000000-0000-0000-0000-000000000006', 'DEMO-CS-002', 'Semillas de Chía x 500g', 'Chía premium. Rica en fibra, Omega 3 y proteínas vegetales. Superfood certificado.', (SELECT id FROM categories WHERE slug='cereales-semillas'), 1900.00, 'https://images.unsplash.com/photo-1514733670139-4d87a1941d55?w=400&h=400&fit=crop', true, false, true, true),
  ('d1000000-0000-0000-0000-000000000007', 'DEMO-CS-003', 'Avena Arrollada Gruesa x 1kg', 'Avena integral de primera calidad. Base ideal para desayunos, porridge y granola casera.', (SELECT id FROM categories WHERE slug='cereales-semillas'), 1200.00, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop', false, false, false, true),
  ('d1000000-0000-0000-0000-000000000008', 'DEMO-CS-004', 'Semillas de Girasol Peladas x 300g', 'Semillas de girasol peladas, listas para ensaladas, panificados y snacks saludables.', (SELECT id FROM categories WHERE slug='cereales-semillas'), 1100.00, 'https://images.unsplash.com/photo-1574570068569-82e33e854b07?w=400&h=400&fit=crop', false, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Harinas y Legumbres
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000009', 'DEMO-HL-001', 'Harina de Almendras x 250g', 'Harina de almendras extra fina. Perfecta para repostería sin gluten. Keto friendly.', (SELECT id FROM categories WHERE slug='harinas-legumbres'), 4500.00, 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop', false, true, false, true),
  ('d1000000-0000-0000-0000-000000000010', 'DEMO-HL-002', 'Lentejas Turcas x 500g', 'Lentejas rojas de cocción rápida. Alto contenido proteico. Perfectas para sopas y guisos.', (SELECT id FROM categories WHERE slug='harinas-legumbres'), 1600.00, 'https://images.unsplash.com/photo-1585996838584-bf8a10b10363?w=400&h=400&fit=crop', false, false, true, true),
  ('d1000000-0000-0000-0000-000000000011', 'DEMO-HL-003', 'Garbanzos x 500g', 'Garbanzos secos premium. Ideales para hummus, falafel y guisos árabes.', (SELECT id FROM categories WHERE slug='harinas-legumbres'), 1400.00, 'https://images.unsplash.com/photo-1515543904462-7a9e3ef3593a?w=400&h=400&fit=crop', true, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Suplementos
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000012', 'DEMO-SU-001', 'Spirulina en Polvo x 100g', 'Spirulina orgánica. Superalimento rico en proteínas, hierro y antioxidantes. Color verde intenso.', (SELECT id FROM categories WHERE slug='suplementos'), 5200.00, 'https://images.unsplash.com/photo-1622485831930-34d5140b0a82?w=400&h=400&fit=crop', false, true, true, true),
  ('d1000000-0000-0000-0000-000000000013', 'DEMO-SU-002', 'Levadura Nutricional x 150g', 'Fuente de vitaminas del complejo B. Sabor a queso. 100% vegana y sin gluten.', (SELECT id FROM categories WHERE slug='suplementos'), 3900.00, 'https://images.unsplash.com/photo-1612187209234-a15d4e4682f9?w=400&h=400&fit=crop', false, false, true, true),
  ('d1000000-0000-0000-0000-000000000014', 'DEMO-SU-003', 'Proteína de Arvejas x 500g', 'Proteína vegetal en polvo. 80% proteína pura. Sabor neutro. Post-workout natural.', (SELECT id FROM categories WHERE slug='suplementos'), 7800.00, 'https://images.unsplash.com/photo-1593095948071-474c5cc2c4d8?w=400&h=400&fit=crop', true, true, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Snacks Saludables
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000015', 'DEMO-SN-001', 'Barrita de Cereal con Frutos Rojos x 30g', 'Barrita artesanal con avena, frutos rojos y miel. Sin conservantes. Energía natural.', (SELECT id FROM categories WHERE slug='snacks'), 800.00, 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=400&fit=crop', false, false, true, true),
  ('d1000000-0000-0000-0000-000000000016', 'DEMO-SN-002', 'Chips de Banana x 150g', 'Banana deshidratada crocante. Snack natural y energético. Sin azúcar añadida.', (SELECT id FROM categories WHERE slug='snacks'), 1500.00, 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?w=400&h=400&fit=crop', false, true, false, true),
  ('d1000000-0000-0000-0000-000000000017', 'DEMO-SN-003', 'Bolitas de Cacao y Coco x 100g', 'Bolitas energéticas sin azúcar añadida. Cacao puro y coco rallado. Veganas.', (SELECT id FROM categories WHERE slug='snacks'), 2200.00, 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=400&fit=crop', true, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Bebidas Naturales
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000018', 'DEMO-BE-001', 'Leche de Almendras x 1L', 'Leche vegetal de almendras sin azúcar. Apta para intolerantes a la lactosa. Cremosa y suave.', (SELECT id FROM categories WHERE slug='bebidas'), 2900.00, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=400&fit=crop', false, true, true, true),
  ('d1000000-0000-0000-0000-000000000019', 'DEMO-BE-002', 'Kombucha de Jengibre x 500ml', 'Bebida fermentada artesanal. Probióticos naturales. Refrescante y digestiva.', (SELECT id FROM categories WHERE slug='bebidas'), 3200.00, 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=400&h=400&fit=crop', true, true, false, true),
  ('d1000000-0000-0000-0000-000000000020', 'DEMO-BE-003', 'Jugo de Aloe Vera x 500ml', 'Jugo puro de aloe vera orgánico. Digestivo, refrescante y desintoxicante.', (SELECT id FROM categories WHERE slug='bebidas'), 2600.00, 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400&h=400&fit=crop', false, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Cosmética Natural
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000021', 'DEMO-CO-001', 'Aceite de Coco Virgen x 200ml', 'Aceite de coco extra virgen prensado en frío. Uso cosmético y alimenticio. Multi-uso.', (SELECT id FROM categories WHERE slug='cosmetica'), 3400.00, 'https://images.unsplash.com/photo-1526947425960-945c6e72858f?w=400&h=400&fit=crop', false, false, true, true),
  ('d1000000-0000-0000-0000-000000000022', 'DEMO-CO-002', 'Jabón Artesanal de Avena y Miel', 'Jabón natural hecho a mano. Hidratante y suave. Sin químicos ni parabenos.', (SELECT id FROM categories WHERE slug='cosmetica'), 1800.00, 'https://images.unsplash.com/photo-1600857544200-b2f666a9a2ec?w=400&h=400&fit=crop', false, true, false, true),
  ('d1000000-0000-0000-0000-000000000023', 'DEMO-CO-003', 'Manteca de Karité Pura x 100g', 'Karité sin refinar de origen africano. Hidratación profunda para piel y cabello.', (SELECT id FROM categories WHERE slug='cosmetica'), 4200.00, 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=400&h=400&fit=crop', true, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- Sin TACC
INSERT INTO products (id, sku, name, description, category_id, price, image_path, is_promo, is_new, is_featured, is_active) VALUES
  ('d1000000-0000-0000-0000-000000000024', 'DEMO-ST-001', 'Premezcla Sin TACC x 1kg', 'Premezcla multiuso apta celíacos. Para panes, tortas, empanadas y pizzas. Certificada.', (SELECT id FROM categories WHERE slug='sin-tacc'), 2800.00, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop', false, true, true, true),
  ('d1000000-0000-0000-0000-000000000025', 'DEMO-ST-002', 'Galletitas de Arroz x 150g', 'Galletas de arroz integral. Livianas, crujientes, sin gluten. Snack libre de culpa.', (SELECT id FROM categories WHERE slug='sin-tacc'), 1200.00, 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=400&fit=crop', false, false, false, true),
  ('d1000000-0000-0000-0000-000000000026', 'DEMO-ST-003', 'Fideos de Arroz x 500g', 'Fideos de arroz tipo spaghetti. Cocción rápida. Sin TACC certificado. Sabor auténtico.', (SELECT id FROM categories WHERE slug='sin-tacc'), 2100.00, 'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=400&h=400&fit=crop', true, false, false, true)
ON CONFLICT (sku) DO NOTHING;

-- ===================== STOCK DEMO =====================
INSERT INTO stock (product_id, location_id, qty, min_qty) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 25, 5),
  ('d1000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 18, 5),
  ('d1000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000001', 3, 5),
  ('d1000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000001', 12, 3),
  ('d1000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000001', 30, 10),
  ('d1000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000001', 40, 10),
  ('d1000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000001', 50, 15),
  ('d1000000-0000-0000-0000-000000000008', 'd0000000-0000-0000-0000-000000000001', 35, 10),
  ('d1000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000001', 8, 3),
  ('d1000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000001', 22, 8),
  ('d1000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000001', 0, 5),
  ('d1000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000001', 15, 5),
  ('d1000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000001', 20, 5),
  ('d1000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000001', 10, 3),
  ('d1000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000001', 60, 20),
  ('d1000000-0000-0000-0000-000000000016', 'd0000000-0000-0000-0000-000000000001', 2, 5),
  ('d1000000-0000-0000-0000-000000000017', 'd0000000-0000-0000-0000-000000000001', 25, 8),
  ('d1000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000001', 14, 5),
  ('d1000000-0000-0000-0000-000000000019', 'd0000000-0000-0000-0000-000000000001', 8, 3),
  ('d1000000-0000-0000-0000-000000000020', 'd0000000-0000-0000-0000-000000000001', 12, 5),
  ('d1000000-0000-0000-0000-000000000021', 'd0000000-0000-0000-0000-000000000001', 20, 5),
  ('d1000000-0000-0000-0000-000000000022', 'd0000000-0000-0000-0000-000000000001', 15, 5),
  ('d1000000-0000-0000-0000-000000000023', 'd0000000-0000-0000-0000-000000000001', 6, 3),
  ('d1000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000001', 18, 5),
  ('d1000000-0000-0000-0000-000000000025', 'd0000000-0000-0000-0000-000000000001', 40, 10),
  ('d1000000-0000-0000-0000-000000000026', 'd0000000-0000-0000-0000-000000000001', 0, 5)
ON CONFLICT (product_id, location_id) DO NOTHING;

INSERT INTO stock (product_id, location_id, qty, min_qty) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 10, 3),
  ('d1000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000002', 20, 5),
  ('d1000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000002', 15, 5),
  ('d1000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000002', 8, 3),
  ('d1000000-0000-0000-0000-000000000018', 'd0000000-0000-0000-0000-000000000002', 6, 3),
  ('d1000000-0000-0000-0000-000000000024', 'd0000000-0000-0000-0000-000000000002', 12, 5)
ON CONFLICT (product_id, location_id) DO NOTHING;

-- ===================== PROMOS DEMO =====================
INSERT INTO promos (product_id, title, promo_text, discount_pct, promo_price, active, position) VALUES
  ('d1000000-0000-0000-0000-000000000003', '¡Cajú en Oferta!', 'Llevá Castañas de Cajú con 15% OFF', 15, 3230.00, true, 0),
  ('d1000000-0000-0000-0000-000000000006', 'Chía Promo Semana', 'Semillas de Chía a precio especial', 20, 1520.00, true, 1),
  ('d1000000-0000-0000-0000-000000000011', 'Garbanzos 2x1', 'Llevá 2 paquetes al precio de 1', NULL, 1400.00, true, 2),
  ('d1000000-0000-0000-0000-000000000017', 'Bolitas de Cacao -10%', 'Snack saludable con descuento', 10, 1980.00, true, 3),
  ('d1000000-0000-0000-0000-000000000019', 'Kombucha Promo', 'Probá la Kombucha con 25% OFF', 25, 2400.00, true, 4),
  ('d1000000-0000-0000-0000-000000000023', 'Karité al Mejor Precio', 'Manteca de Karité con 20% OFF', 20, 3360.00, true, 5),
  ('d1000000-0000-0000-0000-000000000026', 'Fideos Sin TACC -15%', 'Fideos de arroz a precio promo', 15, 1785.00, true, 6),
  ('d1000000-0000-0000-0000-000000000014', 'Proteína Vegana Promo', 'Proteína de arvejas con 10% OFF', 10, 7020.00, true, 7)
ON CONFLICT DO NOTHING;

-- ===================== GALERÍA DEMO =====================
INSERT INTO gallery (title, description, image_path, position, active) VALUES
  ('Nuestro Local', 'Vista del local con góndolas llenas de productos naturales', 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=600&h=400&fit=crop', 0, true),
  ('Frutos Secos a Granel', 'Variedad de frutos secos y semillas por kilo', 'https://images.unsplash.com/photo-1599599810694-b5b37304c041?w=600&h=400&fit=crop', 1, true),
  ('Rincón Saludable', 'Todo lo natural en un solo lugar', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600&h=400&fit=crop', 2, true),
  ('Cosmética Natural', 'Productos de belleza naturales y artesanales', 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=600&h=400&fit=crop', 3, true)
ON CONFLICT DO NOTHING;

-- ===================== VIDEOS DEMO =====================
INSERT INTO videos (title, description, video_url, thumbnail_path, position, active) VALUES
  ('Granola Casera en 5 Minutos', 'Aprendé a hacer granola artesanal con ingredientes naturales', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://images.unsplash.com/photo-1517093728432-a0440f8d45af?w=400&h=300&fit=crop', 0, true),
  ('Beneficios de la Chía', 'Todo lo que necesitás saber sobre las semillas de chía', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://images.unsplash.com/photo-1514733670139-4d87a1941d55?w=400&h=300&fit=crop', 1, true),
  ('Receta: Hummus de Garbanzos', 'Hummus cremoso casero, fácil y rápido', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'https://images.unsplash.com/photo-1515543904462-7a9e3ef3593a?w=400&h=300&fit=crop', 2, true)
ON CONFLICT DO NOTHING;

-- ===================== BANNERS DEL HERO =====================
-- Necesitamos el ID de la sección hero
INSERT INTO banners (section_id, title, subtitle, cta_label, image_path, position, active)
SELECT s.id, 'Naturaleza en tu Mesa', 'Alimentos 100% naturales, frescos y de la mejor calidad. Envíos a todo Rosario.', 'Ver Productos', 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=1200&h=600&fit=crop', 0, true
FROM sections s WHERE s.slug = 'hero'
ON CONFLICT DO NOTHING;

INSERT INTO banners (section_id, title, subtitle, cta_label, image_path, position, active)
SELECT s.id, '¡Ofertas de la Semana!', 'Descuentos de hasta 25% en frutos secos, semillas y suplementos.', 'Ver Promos', 'https://images.unsplash.com/photo-1607532941433-304659e8198a?w=1200&h=600&fit=crop', 1, true
FROM sections s WHERE s.slug = 'hero'
ON CONFLICT DO NOTHING;

INSERT INTO banners (section_id, title, subtitle, cta_label, image_path, position, active)
SELECT s.id, 'Sección Sin TACC', 'Más de 50 productos certificados para celíacos. Confiá en nosotros.', 'Explorar', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&h=600&fit=crop', 2, true
FROM sections s WHERE s.slug = 'hero'
ON CONFLICT DO NOTHING;

-- ===================== CATEGORÍAS: agregar imágenes =====================
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400&h=300&fit=crop' WHERE slug = 'frutos-secos' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1517093728432-a0440f8d45af?w=400&h=300&fit=crop' WHERE slug = 'cereales-semillas' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop' WHERE slug = 'harinas-legumbres' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1622485831930-34d5140b0a82?w=400&h=300&fit=crop' WHERE slug = 'suplementos' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=300&fit=crop' WHERE slug = 'snacks' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=300&fit=crop' WHERE slug = 'bebidas' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=300&fit=crop' WHERE slug = 'cosmetica' AND (image_path IS NULL OR image_path = '');
UPDATE categories SET image_path = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop' WHERE slug = 'sin-tacc' AND (image_path IS NULL OR image_path = '');

-- ===================== SITE CONFIG DEMO =====================
UPDATE site_config SET value = '5493414567890' WHERE key = 'whatsapp_default' AND (value IS NULL OR value = '');
UPDATE site_config SET value = 'info@curcumatiendanatural.com' WHERE key = 'email_contacto' AND (value IS NULL OR value = '');
UPDATE site_config SET value = 'https://instagram.com/curcuma.tiendanatural' WHERE key = 'instagram_url' AND (value IS NULL OR value = '');
UPDATE site_config SET value = 'https://facebook.com/curcumatiendanatural' WHERE key = 'facebook_url' AND (value IS NULL OR value = '');
UPDATE site_config SET value = '0000003100012345678901' WHERE key = 'cbu_info' AND (value IS NULL OR value = '');
UPDATE site_config SET value = 'curcuma.tienda' WHERE key = 'alias_cbu' AND (value IS NULL OR value = '');

-- Colores de marca Cúrcuma
INSERT INTO site_config (key, value) VALUES ('color_primary', '#F0A830') ON CONFLICT (key) DO UPDATE SET value = '#F0A830';
INSERT INTO site_config (key, value) VALUES ('color_secondary', '#2D2D2D') ON CONFLICT (key) DO UPDATE SET value = '#2D2D2D';
INSERT INTO site_config (key, value) VALUES ('color_accent', '#F5C563') ON CONFLICT (key) DO UPDATE SET value = '#F5C563';
INSERT INTO site_config (key, value) VALUES ('site_name', 'Cúrcuma') ON CONFLICT (key) DO UPDATE SET value = 'Cúrcuma';
INSERT INTO site_config (key, value) VALUES ('footer_text', '© 2026 Cúrcuma - Tienda Natural') ON CONFLICT (key) DO UPDATE SET value = '© 2026 Cúrcuma - Tienda Natural';
