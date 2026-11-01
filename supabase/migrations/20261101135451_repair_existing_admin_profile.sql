-- Backfill profils pour les utilisateurs créés avant le trigger de profils.
insert into public.profiles (id, display_name, role, is_active)
select u.id, coalesce(u.raw_user_meta_data ->> 'full_name', u.email), 'EMPLOYEE'::public.app_role, true
from auth.users u
on conflict (id) do nothing;

-- Exécuter ensuite, une seule fois, la commande d'administration fournie
-- dans la documentation pour promouvoir le propriétaire voulu en ADMIN.
