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
