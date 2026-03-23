-- ============================================================
-- FUNCIONES RPC - Dietética Centro
-- Todas con SECURITY DEFINER para máxima seguridad
-- ============================================================

-- ===================== STOCK: DECREMENTAR =====================
create or replace function decrement_stock(
  p_product_id uuid,
  p_location_id uuid,
  p_qty int,
  p_reason text default 'sale'
)
returns int as $$
declare
  new_qty int;
begin
  -- Solo admins pueden decrementar
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  update stock
  set qty = qty - p_qty, updated_at = now()
  where product_id = p_product_id and location_id = p_location_id
  returning qty into new_qty;

  if new_qty is null then
    raise exception 'Producto/sucursal no encontrado en stock';
  end if;

  if new_qty < 0 then
    -- Revertir
    update stock set qty = qty + p_qty where product_id = p_product_id and location_id = p_location_id;
    raise exception 'Stock insuficiente';
  end if;

  -- Registrar movimiento
  insert into stock_movements (product_id, location_id, delta, reason, created_by)
  values (p_product_id, p_location_id, -p_qty, p_reason, auth.uid());

  return new_qty;
end;
$$ language plpgsql security definer;

-- ===================== STOCK: INCREMENTAR =====================
create or replace function increment_stock(
  p_product_id uuid,
  p_location_id uuid,
  p_qty int,
  p_reason text default 'manual_adjust'
)
returns int as $$
declare
  new_qty int;
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  update stock
  set qty = qty + p_qty, updated_at = now()
  where product_id = p_product_id and location_id = p_location_id
  returning qty into new_qty;

  if new_qty is null then
    -- Crear registro si no existe
    insert into stock (product_id, location_id, qty)
    values (p_product_id, p_location_id, p_qty)
    returning qty into new_qty;
  end if;

  insert into stock_movements (product_id, location_id, delta, reason, created_by)
  values (p_product_id, p_location_id, p_qty, p_reason, auth.uid());

  return new_qty;
end;
$$ language plpgsql security definer;

-- ===================== STOCK: SET DIRECTO =====================
create or replace function set_stock(
  p_product_id uuid,
  p_location_id uuid,
  p_qty int
)
returns int as $$
declare
  old_qty int;
  diff int;
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  select qty into old_qty from stock
  where product_id = p_product_id and location_id = p_location_id;

  if old_qty is null then
    insert into stock (product_id, location_id, qty)
    values (p_product_id, p_location_id, p_qty);
    diff := p_qty;
  else
    diff := p_qty - old_qty;
    update stock set qty = p_qty, updated_at = now()
    where product_id = p_product_id and location_id = p_location_id;
  end if;

  if diff != 0 then
    insert into stock_movements (product_id, location_id, delta, reason, created_by)
    values (p_product_id, p_location_id, diff, 'manual_adjust', auth.uid());
  end if;

  return p_qty;
end;
$$ language plpgsql security definer;

-- ===================== RESERVA: CREAR (pública) =====================
create or replace function create_reservation(
  p_product_id uuid,
  p_location_id uuid,
  p_qty int,
  p_customer_name text,
  p_customer_phone text,
  p_customer_email text default null,
  p_payment_ref text default null,
  p_notes text default null
)
returns uuid as $$
declare
  v_reservation_id uuid;
  v_stock int;
begin
  -- Verificar stock
  select qty into v_stock from stock
  where product_id = p_product_id and location_id = p_location_id;

  if v_stock is null or v_stock < p_qty then
    raise exception 'Stock insuficiente para reservar';
  end if;

  -- Crear reserva
  insert into reservations (product_id, location_id, qty, customer_name, customer_phone, customer_email, payment_ref, notes)
  values (p_product_id, p_location_id, p_qty, p_customer_name, p_customer_phone, p_customer_email, p_payment_ref, p_notes)
  returning id into v_reservation_id;

  -- Descontar stock
  update stock set qty = qty - p_qty, updated_at = now()
  where product_id = p_product_id and location_id = p_location_id;

  -- Log
  insert into stock_movements (product_id, location_id, delta, reason, external_ref)
  values (p_product_id, p_location_id, -p_qty, 'reservation', v_reservation_id::text);

  return v_reservation_id;
end;
$$ language plpgsql security definer;

-- ===================== RESERVA: CANCELAR =====================
create or replace function cancel_reservation(p_reservation_id uuid)
returns void as $$
declare
  v_rec record;
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  select * into v_rec from reservations where id = p_reservation_id;

  if v_rec is null then
    raise exception 'Reserva no encontrada';
  end if;

  if v_rec.status = 'canceled' then
    raise exception 'Reserva ya cancelada';
  end if;

  -- Devolver stock
  update stock set qty = qty + v_rec.qty, updated_at = now()
  where product_id = v_rec.product_id and location_id = v_rec.location_id;

  -- Actualizar estado
  update reservations set status = 'canceled', updated_at = now()
  where id = p_reservation_id;

  insert into stock_movements (product_id, location_id, delta, reason, external_ref, created_by)
  values (v_rec.product_id, v_rec.location_id, v_rec.qty, 'reservation_cancel', p_reservation_id::text, auth.uid());
end;
$$ language plpgsql security definer;

-- ===================== ADMIN: AGREGAR CO-ADMIN =====================
create or replace function add_admin(p_user_id uuid, p_role text default 'admin')
returns void as $$
declare
  admin_count int;
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  select count(*) into admin_count from admin_roles;
  if admin_count >= 3 then
    raise exception 'Máximo 3 administradores permitidos';
  end if;

  insert into admin_roles (user_id, role, created_by)
  values (p_user_id, p_role, auth.uid())
  on conflict (user_id) do update set role = p_role;
end;
$$ language plpgsql security definer;

-- ===================== ADMIN: QUITAR CO-ADMIN =====================
create or replace function remove_admin(p_user_id uuid)
returns void as $$
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  -- No puede quitarse a sí mismo
  if p_user_id = auth.uid() then
    raise exception 'No puedes eliminarte a ti mismo como admin';
  end if;

  delete from admin_roles where user_id = p_user_id;
end;
$$ language plpgsql security definer;

-- ===================== ANALYTICS: TOP PRODUCTOS =====================
create or replace function get_top_products(p_limit int default 10)
returns table(product_id uuid, product_name text, view_count bigint) as $$
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  return query
    select pv.product_id, p.name, count(*) as view_count
    from product_views pv
    join products p on p.id = pv.product_id
    group by pv.product_id, p.name
    order by view_count desc
    limit p_limit;
end;
$$ language plpgsql security definer stable;

-- ===================== ANALYTICS: VENTAS POR SUCURSAL =====================
create or replace function get_stock_movements_summary(
  p_location_id uuid default null,
  p_days int default 30
)
returns table(product_id uuid, product_name text, total_sold bigint, total_returned bigint) as $$
begin
  if not is_admin() then
    raise exception 'No autorizado';
  end if;

  return query
    select
      sm.product_id,
      p.name as product_name,
      coalesce(sum(case when sm.delta < 0 and sm.reason = 'sale' then abs(sm.delta) else 0 end), 0) as total_sold,
      coalesce(sum(case when sm.delta > 0 and sm.reason = 'return' then sm.delta else 0 end), 0) as total_returned
    from stock_movements sm
    join products p on p.id = sm.product_id
    where sm.created_at >= now() - (p_days || ' days')::interval
    and (p_location_id is null or sm.location_id = p_location_id)
    group by sm.product_id, p.name
    order by total_sold desc;
end;
$$ language plpgsql security definer stable;

-- ===================== WEBHOOK POS: SYNC STOCK =====================
create or replace function pos_sync_stock(
  p_sku text,
  p_location_id uuid,
  p_new_qty int,
  p_api_key text
)
returns json as $$
declare
  v_product_id uuid;
  v_old_qty int;
  v_diff int;
  v_valid_key text;
begin
  -- Verificar API key desde site_config
  select value into v_valid_key from site_config where key = 'pos_api_key';
  if v_valid_key is null or v_valid_key != p_api_key then
    raise exception 'API key inválida';
  end if;

  select id into v_product_id from products where sku = p_sku;
  if v_product_id is null then
    raise exception 'SKU no encontrado: %', p_sku;
  end if;

  select qty into v_old_qty from stock
  where product_id = v_product_id and location_id = p_location_id;

  if v_old_qty is null then
    insert into stock (product_id, location_id, qty) values (v_product_id, p_location_id, p_new_qty);
    v_diff := p_new_qty;
  else
    v_diff := p_new_qty - v_old_qty;
    update stock set qty = p_new_qty, updated_at = now()
    where product_id = v_product_id and location_id = p_location_id;
  end if;

  insert into stock_movements (product_id, location_id, delta, reason, external_ref)
  values (v_product_id, p_location_id, v_diff, 'pos_sync', p_sku);

  return json_build_object('success', true, 'sku', p_sku, 'new_qty', p_new_qty, 'diff', v_diff);
end;
$$ language plpgsql security definer;
