# Système de gestion des comptes clients

Application React / TypeScript / Vite en français, conçue pour Supabase et le dirham marocain (MAD/DH).

## Lancer l’interface

```powershell
npm install
npm run dev
```

## Connecter Supabase

1. Créez un projet Supabase, activez Email/Password, puis copiez `.env.example` vers `.env.local`.
2. Renseignez uniquement l’URL et la clé **publishable**. Ne placez jamais de clé `service_role` dans le frontend.
3. Liez explicitement le projet: `supabase link --project-ref VOTRE_REF`.
4. Exécutez `supabase db push --linked` après revue de `supabase/migrations/202611010001_complete_customer_account_system.sql`.

La migration crée les UUID, références permanentes, contraintes financières, prix datés, opérations, paiements, documents, grand livre et RLS. Les documents émis devront conserver des instantanés dans `documents.snapshot_data`; aucun logo ni information de société ne doit être introduit dans les modèles PDF.

## État actuel

Le shell UI est en place et compile. La migration est prête à être appliquée sur un **nouveau** projet Supabase. L’interface doit encore être reliée aux tables Supabase et complétée avec les workflows de confirmation, impressions/PDF, gestion des rôles et tests d’intégration avant une utilisation en production.

## Dépannage RLS

Si la création d’un client affiche `new row violates row-level security policy`, l’utilisateur connecté n’est pas encore un profil actif `ADMIN` ou `MANAGER`. Exécutez d’abord la migration de réparation des profils, puis dans SQL Editor :

```sql
insert into public.profiles (id, display_name, role, is_active)
select id, email, 'ADMIN'::public.app_role, true
from auth.users
where email = 'VOTRE_EMAIL'
on conflict (id) do update set role = 'ADMIN', is_active = true;
```
