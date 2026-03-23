-- ============================================================
-- STORAGE POLICIES - Bucket: images-dietetica
-- Lectura pública, escritura/edición/eliminación SOLO admin
-- ============================================================

-- El bucket 'images-dietetica' ya fue creado como público (lectura sin auth)
-- Ahora restringimos escritura/actualización/eliminación a admins autenticados

-- Lectura pública (cualquiera puede ver las imágenes)
create policy "public read images"
  on storage.objects for select
  using (bucket_id = 'images-dietetica');

-- Solo admins autenticados pueden subir imágenes
create policy "admin upload images"
  on storage.objects for insert
  with check (
    bucket_id = 'images-dietetica'
    and auth.role() = 'authenticated'
    and is_admin()
  );

-- Solo admins pueden actualizar imágenes
create policy "admin update images"
  on storage.objects for update
  using (
    bucket_id = 'images-dietetica'
    and auth.role() = 'authenticated'
    and is_admin()
  );

-- Solo admins pueden eliminar imágenes
create policy "admin delete images"
  on storage.objects for delete
  using (
    bucket_id = 'images-dietetica'
    and auth.role() = 'authenticated'
    and is_admin()
  );
