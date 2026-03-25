-- ============================================================
-- LIMPIAR DATOS DEMO - Dietética Centro
-- Ejecutar para quitar todos los datos de ejemplo
-- y dejar las tablas vacías para datos reales
-- ============================================================
-- IMPORTANTE: Esto NO borra categorías, secciones ni navbar
-- (esos son estructurales). Solo borra contenido de ejemplo.
-- ============================================================

-- 1. Borrar promos demo (dependen de productos demo)
DELETE FROM promos WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 2. Borrar reservas demo (si hubiera)
DELETE FROM reservations WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 3. Borrar stock demo
DELETE FROM stock WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 4. Borrar movimientos de stock demo
DELETE FROM stock_movements WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 5. Borrar analytics demo
DELETE FROM product_views WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 6. Borrar section_products demo
DELETE FROM section_products WHERE product_id IN (
  SELECT id FROM products WHERE sku LIKE 'DEMO-%'
);

-- 7. Borrar productos demo
DELETE FROM products WHERE sku LIKE 'DEMO-%';

-- 8. Borrar sucursales demo
DELETE FROM locations WHERE id IN (
  'd0000000-0000-0000-0000-000000000001',
  'd0000000-0000-0000-0000-000000000002'
);

-- 9. Borrar galería demo (las que no tienen imagen)
DELETE FROM gallery WHERE image_path = '' OR image_path IS NULL;

-- 10. Borrar videos demo (los de URL placeholder)
DELETE FROM videos WHERE video_url LIKE '%dQw4w9WgXcQ%';

-- 11. Limpiar config demo (dejar vacíos para que el admin ponga los reales)
UPDATE site_config SET value = '' WHERE key = 'whatsapp_default' AND value = '5493414567890';
UPDATE site_config SET value = '' WHERE key = 'email_contacto' AND value = 'info@dieteticacentro.com';
UPDATE site_config SET value = '' WHERE key = 'instagram_url' AND value = 'https://instagram.com/dieteticacentro';
UPDATE site_config SET value = '' WHERE key = 'facebook_url' AND value = 'https://facebook.com/dieteticacentro';
UPDATE site_config SET value = '' WHERE key = 'cbu_info' AND value = '0000003100012345678901';
UPDATE site_config SET value = '' WHERE key = 'alias_cbu' AND value = 'dietetica.centro';

-- ============================================================
-- LISTO: Las tablas quedan vacías, listas para datos reales.
-- Las categorías, secciones y navbar se mantienen.
-- El admin puede empezar a cargar productos desde el panel.
-- ============================================================
