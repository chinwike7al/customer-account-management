-- Métier tapis et moquettes : toutes les dimensions sont en centimètres.
-- Une ligne M2 calcule surface = longueur_cm × largeur_cm × quantité / 10000.

alter table public.products
  add column if not exists default_length_cm numeric(14,2) check (default_length_cm is null or default_length_cm > 0),
  add column if not exists default_width_cm numeric(14,2) check (default_width_cm is null or default_width_cm > 0),
  add column if not exists default_color text;

alter table public.operation_details
  add column if not exists color_code text;

create or replace function public.validate_line() returns trigger language plpgsql as $$
declare surface numeric(14,4); expected_total numeric(14,2);
begin
  if new.unit = 'M2' then
    if new.length_cm is null or new.width_cm is null then
      raise exception 'La longueur et la largeur sont obligatoires pour une moquette vendue au m²';
    end if;
    surface := round(new.length_cm * new.width_cm * new.quantity / 10000, 4);
    expected_total := round(surface * new.unit_price, 2);
    if new.calculated_surface <> surface or new.line_total <> expected_total then
      raise exception 'Calcul tapis/moquette invalide : (longueur × largeur × quantité / 10000) × prix au m²';
    end if;
  elsif new.line_total <> round(new.quantity * new.unit_price, 2) then
    raise exception 'Total de ligne invalide';
  end if;
  return new;
end $$;

comment on column public.products.default_length_cm is 'Longueur indicative d’un tapis ou rouleau, en cm.';
comment on column public.products.default_width_cm is 'Largeur indicative d’un tapis ou rouleau, en cm.';
comment on column public.operation_details.calculated_surface is 'Surface en m² : longueur_cm × largeur_cm × quantité / 10000.';

create or replace function public.create_carpet_operation(
  p_client_id uuid, p_product_id uuid, p_operation_date date,
  p_length_cm numeric, p_width_cm numeric, p_quantity numeric,
  p_unit_price numeric, p_color text default null, p_color_code text default null, p_notes text default null
) returns uuid language plpgsql security invoker set search_path=public as $$
declare v_operation_id uuid; v_product record; v_surface numeric(14,4); v_total numeric(14,2);
begin
  if not exists (select 1 from public.clients where id=p_client_id and status='ACTIF') then raise exception 'Client actif introuvable'; end if;
  select id,reference,name,unit into v_product from public.products where id=p_product_id and status='ACTIF';
  if not found then raise exception 'Produit actif introuvable'; end if;
  if v_product.unit <> 'M2' then raise exception 'Cette opération tapis/moquette exige un produit en M2'; end if;
  if p_length_cm<=0 or p_width_cm<=0 or p_quantity<=0 or p_unit_price<0 then raise exception 'Dimensions, quantité et prix doivent être valides'; end if;
  v_surface:=round(p_length_cm*p_width_cm*p_quantity/10000,4); v_total:=round(v_surface*p_unit_price,2);
  insert into public.operations(client_id,operation_date,total_amount,status,description,created_by) values(p_client_id,p_operation_date,v_total,'BROUILLON','Vente tapis/moquette',auth.uid()) returning id into v_operation_id;
  insert into public.operation_details(operation_id,product_id,product_reference_snapshot,product_name_snapshot,quantity,length_cm,width_cm,unit,unit_price,calculated_surface,line_total,color,color_code,notes)
  values(v_operation_id,v_product.id,v_product.reference,v_product.name,p_quantity,p_length_cm,p_width_cm,'M2',p_unit_price,v_surface,v_total,p_color,p_color_code,p_notes);
  return v_operation_id;
end $$;
grant execute on function public.create_carpet_operation(uuid,uuid,date,numeric,numeric,numeric,numeric,text,text,text) to authenticated;
